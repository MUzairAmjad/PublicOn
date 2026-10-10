package com.uzair.publicon.servlets;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.uzair.publicon.util.DBConnection;
import com.uzair.publicon.model.SearchUser;

@WebServlet("/SearchServlet")
public class SearchServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
            return;
        }

        int currentUserID = (Integer) session.getAttribute("userID");
        String searchQuery = request.getParameter("query");
        List<SearchUser> userList = new ArrayList<>();

        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            // Query checks follows table to see if currentUserID follows the searched user
            String sql = "SELECT userID, first_name, last_name, handle, profile_pic, " +
                         "(SELECT COUNT(*) FROM follows WHERE follower_id = ? AND following_id = Users.userID) AS is_following " +
                         "FROM Users WHERE (handle LIKE ? OR first_name LIKE ? OR last_name LIKE ?)";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql)) {
                
                String keyword = "%" + searchQuery.trim() + "%";
                stmt.setInt(1, currentUserID); // Maps to follower_id in subquery
                stmt.setString(2, keyword);    // handle LIKE ?
                stmt.setString(3, keyword);    // first_name LIKE ?
                stmt.setString(4, keyword);    // last_name LIKE ?

                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        int profileUserID = rs.getInt("userID");
                        
                        // Skip yourself from the search results
                        if (profileUserID == currentUserID) continue; 

                        SearchUser u = new SearchUser();
                        u.setUserID(profileUserID);
                        u.setFirstName(rs.getString("first_name"));
                        u.setLastName(rs.getString("last_name"));
                        u.setHandle(rs.getString("handle"));
                        
                        // Dynamically sets true if already following, false otherwise
                        u.setFollowing(rs.getInt("is_following") > 0);
                        
                        try {
                            u.setProfilePic(rs.getString("profile_pic"));
                        } catch (SQLException ex) {
                            u.setProfilePic("");
                        }

                        userList.add(u);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace(); 
            }
        }

        request.setAttribute("searchResults", userList);
        request.setAttribute("searchQuery", searchQuery);
        
        request.getRequestDispatcher("/JSP/search.jsp").forward(request, response);
    }
}
package com.uzair.publicon.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.uzair.publicon.util.DBConnection;

@WebServlet("/GetCommentsServlet")
public class GetCommentsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String postIDParam = request.getParameter("postID");
        if (postIDParam == null) {
            out.write("[]");
            return;
        }

        int postID = Integer.parseInt(postIDParam);
        StringBuilder json = new StringBuilder("[");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT c.comment_text, u.handle, u.profile_pic " +
                         "FROM comments c JOIN Users u ON c.userID = u.userID " +
                         "WHERE c.postID = ? ORDER BY c.commentID ASC";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, postID);
                try (ResultSet rs = stmt.executeQuery()) {
                    boolean first = true;
                    while (rs.next()) {
                        if (!first) json.append(",");
                        first = false;
                        
                        String handle = rs.getString("handle");
                        if (handle == null) handle = "user";

                        String profilePic = rs.getString("profile_pic");
                        if (profilePic == null) profilePic = "";

                        String text = rs.getString("comment_text").replace("\"", "\\\"").replace("\n", " ");
                        
                        json.append("{\"handle\":\"").append(handle)
                            .append("\", \"profilePic\":\"").append(profilePic)
                            .append("\", \"text\":\"").append(text).append("\"}");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        json.append("]");
        out.write(json.toString());
    }
}
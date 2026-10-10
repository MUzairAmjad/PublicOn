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
import jakarta.servlet.http.HttpSession;
import com.uzair.publicon.util.DBConnection;

@WebServlet("/LikeServlet")
public class LikeServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Prepare to send JSON back
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (session == null || session.getAttribute("userID") == null) {
            // Tell the frontend the user isn't logged in
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\": \"Not logged in\"}");
            return;
        }

        int userID = (Integer) session.getAttribute("userID");
        int postID = Integer.parseInt(request.getParameter("postID"));
        boolean isNowLiked = false;

        try (Connection conn = DBConnection.getConnection()) {
            String checkSql = "SELECT * FROM likes WHERE userID = ? AND postID = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, userID);
                checkStmt.setInt(2, postID);
                ResultSet rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    // They already liked it, so UNLIKE it
                    String deleteSql = "DELETE FROM likes WHERE userID = ? AND postID = ?";
                    try (PreparedStatement delStmt = conn.prepareStatement(deleteSql)) {
                        delStmt.setInt(1, userID);
                        delStmt.setInt(2, postID);
                        delStmt.executeUpdate();
                    }
                    isNowLiked = false;
                } else {
                    // They haven't liked it, so LIKE it
                    String insertSql = "INSERT INTO likes (userID, postID) VALUES (?, ?)";
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                        insertStmt.setInt(1, userID);
                        insertStmt.setInt(2, postID);
                        insertStmt.executeUpdate();
                    }
                    isNowLiked = true;
                }
            }
            
            // --- NEW CODE: Count the total likes for this post ---
            int totalLikes = 0;
            String countSql = "SELECT COUNT(*) FROM likes WHERE postID = ?";
            try (PreparedStatement countStmt = conn.prepareStatement(countSql)) {
                countStmt.setInt(1, postID);
                ResultSet countRs = countStmt.executeQuery();
                if (countRs.next()) {
                    totalLikes = countRs.getInt(1);
                }
            }
            
            // Send success response with the new status AND the total like count
            out.write("{\"success\": true, \"liked\": " + isNowLiked + ", \"likeCount\": " + totalLikes + "}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\": \"Database error\"}");
        }
    }
}
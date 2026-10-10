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

@WebServlet("/CommentServlet")
public class CommentServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (session == null || session.getAttribute("userID") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\": \"Not logged in\"}");
            return;
        }

        int userID = (Integer) session.getAttribute("userID");
        String postIDParam = request.getParameter("postID");
        String commentText = request.getParameter("commentText");

        if (postIDParam == null || commentText == null || commentText.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"error\": \"Invalid parameters\"}");
            return;
        }

        int postID = Integer.parseInt(postIDParam);

        try (Connection conn = DBConnection.getConnection()) {
            // 1. Insert comment into DB
            String insertSql = "INSERT INTO comments (postID, userID, comment_text) VALUES (?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                stmt.setInt(1, postID);
                stmt.setInt(2, userID);
                stmt.setString(3, commentText.trim());
                stmt.executeUpdate();
            }

            // 2. Count total comments for badge update
            int totalComments = 0;
            String countSql = "SELECT COUNT(*) FROM comments WHERE postID = ?";
            try (PreparedStatement cStmt = conn.prepareStatement(countSql)) {
                cStmt.setInt(1, postID);
                try (ResultSet cRs = cStmt.executeQuery()) {
                    if (cRs.next()) {
                        totalComments = cRs.getInt(1);
                    }
                }
            }

            out.write("{\"success\": true, \"commentCount\": " + totalComments + "}");

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\": \"Database error\"}");
        }
    }
}
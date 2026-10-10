package com.uzair.publicon.servlets;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.uzair.publicon.util.DBConnection;

@WebServlet("/FollowServlet")
public class FollowServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // 1. Safe Session Validation
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"status\":\"error\", \"message\": \"Not logged in\"}");
            return;
        } 
        
        int followerId = (int) session.getAttribute("userID");

        // 2. Read raw JSON string from the incoming HTTP request body
        StringBuilder jsonBuffer = new StringBuilder();
        String line;
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
        }

        String jsonString = jsonBuffer.toString();

        // 3. Parse targetUserId and action fields from the JSON string
        int followingId = -1;
        String action = "";

        try {
            String targetUserMatch = "\"targetUserId\":";
            int targetIndex = jsonString.indexOf(targetUserMatch);
            if (targetIndex != -1) {
                int start = targetIndex + targetUserMatch.length();
                int end = jsonString.indexOf(",", start);
                if (end == -1) {
                    end = jsonString.indexOf("}", start);
                }
                followingId = Integer.parseInt(jsonString.substring(start, end).trim());
            }

            String actionMatch = "\"action\":";
            int actionIndex = jsonString.indexOf(actionMatch);
            if (actionIndex != -1) {
                int start = jsonString.indexOf("\"", actionIndex + actionMatch.length()) + 1;
                int end = jsonString.indexOf("\"", start);
                action = jsonString.substring(start, end).trim();
            }
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"status\":\"error\", \"message\": \"Invalid JSON formatting.\"}");
            return;
        }

        if (followingId == -1 || action.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"status\":\"error\", \"message\": \"Missing required parameters.\"}");
            return;
        }

        // Prevent self-following
        if (followerId == followingId) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.write("{\"status\":\"error\", \"message\": \"Cannot follow yourself.\"}");
            return;
        }

        // 4. Update the MySQL Database (`follows` table)
        String sql;
        if ("followed".equals(action)) {
            // INSERT IGNORE prevents duplicate row errors
            sql = "INSERT IGNORE INTO follows (follower_id, following_id) VALUES (?, ?)";
        } else {
            sql = "DELETE FROM follows WHERE follower_id = ? AND following_id = ?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, followerId);    // Logged-in user
            ps.setInt(2, followingId);   // Target profile user
            
            ps.executeUpdate();
            
            out.write("{\"status\":\"success\"}");
            
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"status\":\"error\", \"message\": \"Database transaction failed.\"}");
        }
    }   
}
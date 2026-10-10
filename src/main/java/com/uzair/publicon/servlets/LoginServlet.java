package com.uzair.publicon.servlets;

import com.uzair.publicon.util.DBConnection;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        
        String email = request.getParameter("emailIn");
        String password = request.getParameter("passIn");
        
        String getData = 
                "SELECT userID, email, password, accountStatus, first_name, last_name FROM users WHERE email = ?";
        
        try {
            Connection connection = DBConnection.getConnection();
            
            PreparedStatement statement = connection.prepareStatement(
                    getData
            );
            
            statement.setString(1, email);
            
            ResultSet resultSet = statement.executeQuery();
            
            if (resultSet.next()) {
                int userID = resultSet.getInt("userID");
                String storedPassword = resultSet.getString("password");
                String accountStatus = resultSet.getString("accountStatus");
                String firstName = resultSet.getString("first_name");
                String lastName = resultSet.getString("last_name");
                
                if (password.equals(storedPassword)) {
                    
                    if (accountStatus.equals("active")) {
    
                        HttpSession session = request.getSession();
                        session.setAttribute("userID", userID);
    
                        // 1. Log to NetBeans first (Before redirecting!)
                        System.out.println("[LIVE LOG] WORKING! User logged in: " + firstName + " " + lastName);
    
                        // 2. Fix the header structure (Valid header key without spaces/colons)
                        response.setHeader("X-User-Login-Status", "Logged-In");
                        response.setHeader("X-User-Name", firstName + "-" + lastName);
    
                        // 3. Perform the redirect last
                        response.sendRedirect(request.getContextPath() + "/JSP/dashboard.jsp");

                    } else {
                            response.sendRedirect(request.getContextPath() + "/JSP/otp_verification.jsp");
                    } 
                    
                } else {
                    
                    response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html?error=wrongpassword");
                }
            } else {
                
                response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html?error=nouser");
            }
            
            statement.setString(1, email);
            
            
            } catch(SQLException | ClassNotFoundException e) {
                e.printStackTrace();
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error occurred.");
            }
        
    }
    
}

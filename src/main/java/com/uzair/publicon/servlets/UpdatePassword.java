package com.uzair.publicon.servlets;

import com.uzair.publicon.util.DBConnection;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.ServletException;
import java.io.IOException;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/UpdatePassword")
public class UpdatePassword extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        Integer userID = (Integer) session.getAttribute("userID");
        
        if (userID != null) {
        
            String getPassword = 
                    "SELECT password FROM users WHERE userID = ?";
            
            String updatePassword = 
                    "UPDATE users SET password = ? WHERE userID = ?";
        
            String currentPass = request.getParameter("CP");
            String newPass = request.getParameter("NP");
            String storedPass = "";
        
            try {
                Connection connection = DBConnection.getConnection();
            
                PreparedStatement statement = connection.prepareStatement(getPassword);
                statement.setInt(1, userID);
                
                ResultSet result = statement.executeQuery();
                
                if (result.next()) {
                    
                    storedPass = result.getString("password");
                }
                
                if (currentPass.equals(storedPass)) {
                    
                    PreparedStatement statement2 = connection.prepareStatement(updatePassword);
                    statement2.setString(1, newPass.trim());
                    statement2.setInt(2, userID);
                    
                    statement2.executeUpdate();
                    statement2.close();
                    
                    response.sendRedirect(request.getContextPath() + "/JSP/settings.jsp");
                } else {
                    
                    response.sendRedirect(request.getContextPath() + "/JSP/settings.jsp");
                }
                
                result.close();
                connection.close();
                statement.close();
                
            } catch (SQLException | ClassNotFoundException e) {
                e.printStackTrace();
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
        }
        
    }
    
}

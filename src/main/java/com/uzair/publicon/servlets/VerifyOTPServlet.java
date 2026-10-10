package com.uzair.publicon.servlets;

import com.uzair.publicon.util.DBConnection;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

@WebServlet("/VerifyOTPServlet")
public class VerifyOTPServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // Grab the inputs sent by the form submit
        String userEnteredOTP = request.getParameter("otp1") +
                                request.getParameter("otp2") +
                                request.getParameter("otp3") +
                                request.getParameter("otp4") +
                                request.getParameter("otp5") +
                                request.getParameter("otp6");

        HttpSession session = request.getSession();
        String actualOTP = (String) session.getAttribute("verificationOTP");    
        
        if (actualOTP != null && actualOTP.equals(userEnteredOTP)) {
    
            String email = (String) session.getAttribute("signupEmail");
            String password = (String) session.getAttribute("password");
            String firstName = (String) session.getAttribute("firstName");
            String lastName = (String) session.getAttribute("lastName");
            String handle = (String) session.getAttribute("handle");
            
            String insertData =
                "INSERT INTO Users(email, password, accountStatus, first_name, last_name, profile_pic, handle, post_count) " +
                "VALUES(?, ?, 'active', ?, ?, 'Images/defaultProfile.png', ?, 0)";
            
            try (Connection connection = DBConnection.getConnection();
                 PreparedStatement statement = connection.prepareStatement(insertData)) {
                
                statement.setString(1, email);
                statement.setString(2, password);
                statement.setString(3, firstName);
                statement.setString(4, lastName);
                statement.setString(5, handle);
                
                statement.executeUpdate();
                
                // Clear temporary signup session data
                session.removeAttribute("verificationOTP");
                session.removeAttribute("signupEmail");
                session.removeAttribute("password");
                session.removeAttribute("firstName");
                session.removeAttribute("lastName");
                session.removeAttribute("handle");
                
                System.out.println("[LIVE LOG] WORKING! User Signed Up: " + firstName + " " + lastName + " (@" + handle + ")");
            
                response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
                
            } catch (SQLException | ClassNotFoundException e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/UserAuthPages/signup.html?error=serverError");
            }
            
        } else {
            response.sendRedirect(request.getContextPath() + "/JSP/otp_verification.jsp?error=invalid");        
        }
    }
}
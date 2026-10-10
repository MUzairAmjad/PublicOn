package com.uzair.publicon.servlets;

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

import com.uzair.publicon.util.OTPGenerator;
import com.uzair.publicon.util.EmailUtility;
import com.uzair.publicon.util.DBConnection;

@WebServlet("/SignupServlet")
public class SignupServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String firstName = request.getParameter("FnIn");
        String lastName = request.getParameter("LnIn");
        String email = request.getParameter("SEmailIn");
        String password = request.getParameter("SPassIn");
        String handle = request.getParameter("SHandleIn");

        // Basic trim check
        if (handle != null) {
            handle = handle.trim();
        }

        try (Connection connection = DBConnection.getConnection()) {
            
            // 1. Check if Email or Handle already exists
            String checkQuery = "SELECT COUNT(*) FROM Users WHERE email = ? OR handle = ?";
            try (PreparedStatement checkStmt = connection.prepareStatement(checkQuery)) {
                checkStmt.setString(1, email);
                checkStmt.setString(2, handle);
                
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        // Handle or Email is already taken! Redirect back with an error flag.
                        response.sendRedirect(request.getContextPath() + "/UserAuthPages/signup.html?error=taken");
                        
                        return;
                    }
                }
            }

            // 2. Generate OTP and store everything in Session (including handle!)
            String generatedOTP = OTPGenerator.generateOTP();
            HttpSession session = request.getSession();
                
            session.setAttribute("verificationOTP", generatedOTP);
            session.setAttribute("signupEmail", email);
            session.setAttribute("password", password);
            session.setAttribute("firstName", firstName);
            session.setAttribute("lastName", lastName);
            session.setAttribute("handle", handle); // <-- Added handle to session
                
            // 3. Send email and move to OTP verification page
            EmailUtility.sendOTPEmail(email, generatedOTP);

            response.sendRedirect(request.getContextPath() + "/JSP/otp_verification.jsp");

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Database error occurred."
            );
        }
    }
}
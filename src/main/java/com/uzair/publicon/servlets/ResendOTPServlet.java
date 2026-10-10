package com.uzair.publicon.servlets;

import java.io.IOException;
import java.util.Random;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
// Import your email utility class here (e.g., com.uzair.publicon.util.EmailUtil)

@WebServlet("/ResendOTPServlet")
public class ResendOTPServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Ensure the user is in the middle of signing up/verifying
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect(request.getContextPath() + "/UserAuthPages/signup.html");
            return;
        }

        String email = (String) session.getAttribute("email");

        // 1. Generate a new 6-digit OTP
        String newOtp = String.format("%06d", new Random().nextInt(999999));
        
        // 2. Update the OTP in the session (or your database temporary store)
        session.setAttribute("otp", newOtp);

        try {
            // 3. Call your email utility to send the code
            // EmailUtil.sendVerificationEmail(email, newOtp); 
            // ^ Replace with your actual email utility method call
            
            // Redirect back with a success message flag
            response.sendRedirect(request.getContextPath() + "/JSP/OTPVerification.jsp?resend=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/JSP/OTPVerification.jsp?resend=error");
        }
    }
}


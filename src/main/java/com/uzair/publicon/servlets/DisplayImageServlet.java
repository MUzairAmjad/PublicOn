package com.uzair.publicon.servlets;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/images/*") // Matches anything requested after /images/
public class DisplayImageServlet extends HttpServlet {

    // Make sure it ends with a trailing slash
    private static final String PROFILE_UPLOAD_DIR = "C:/Users/Uzair Desktop/Desktop/PublicOnProfiles/avatars/";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the requested file name from the URL path
        String requestedFile = request.getPathInfo(); // e.g., "/user_1_pic.jpg"
        
        if (requestedFile == null || requestedFile.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // FIX: Strip the leading slash so Java correctly joins it to UPLOAD_DIR on Windows
        if (requestedFile.startsWith("/")) {
            requestedFile = requestedFile.substring(1);
        }

        File image = new File(PROFILE_UPLOAD_DIR, requestedFile);

        if (!image.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND); // 404 if missing
            return;
        }

        // Set content type automatically (image/jpeg, image/png, etc.)
        String contentType = getServletContext().getMimeType(image.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLengthLong(image.length());

        // Stream the physical file bytes directly to the browser output stream
        Files.copy(image.toPath(), response.getOutputStream());
    }
}
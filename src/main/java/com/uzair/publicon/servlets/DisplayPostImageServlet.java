package com.uzair.publicon.servlets;

import java.io.File;
import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/post-images/*")
public class DisplayPostImageServlet extends HttpServlet {
    private static final String POST_UPLOAD_DIR = "C:/Users/Uzair Desktop/Desktop/PublicOnProfiles/posts/";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String requestedFile = request.getPathInfo();
        
        if (requestedFile == null || requestedFile.equals("/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        if (requestedFile.startsWith("/")) {
            requestedFile = requestedFile.substring(1);
        }
        
        // Decode URL encoding (e.g., turn %20 back into spaces)
        requestedFile = URLDecoder.decode(requestedFile, StandardCharsets.UTF_8.name());
        
        File image = new File(POST_UPLOAD_DIR, requestedFile);
        
        // DEBUG LOGS: Check your NetBeans console if you get a 404!
        System.out.println("[DEBUG Post Image] Looking for file: " + image.getAbsolutePath());
        System.out.println("[DEBUG Post Image] File exists? " + image.exists());

        if (!image.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(image.getName());
        if (contentType == null) {
            contentType = "application/octet-stream";
        }
        response.setContentType(contentType);
        response.setContentLengthLong(image.length());

        Files.copy(image.toPath(), response.getOutputStream());
    }
}
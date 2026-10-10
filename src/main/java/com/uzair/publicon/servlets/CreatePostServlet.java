package com.uzair.publicon.servlets;

import com.uzair.publicon.dao.PostDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

import jakarta.servlet.annotation.WebServlet;

import jakarta.servlet.http.HttpServlet;

@WebServlet("/CreatePostServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 102,
    maxFileSize = 1024 * 1024 * 10,  // 10MB max for high-res images
    maxRequestSize = 1024 * 1024 * 15
)
public class CreatePostServlet extends HttpServlet {
    private static final String POST_UPLOAD_DIR = "C:/Users/Uzair Desktop/Desktop/PublicOnProfiles/posts/";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
            return;
        }

        int userID = (Integer) session.getAttribute("userID");
        String caption = request.getParameter("caption");
        Part filePart = request.getPart("postImage");

        if (filePart != null && filePart.getSize() > 0) {
            File uploadDir = new File(POST_UPLOAD_DIR);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String originalFileName = Path.of(filePart.getSubmittedFileName()).getFileName().toString().replaceAll("\\s+", "_");
            String uniqueFileName = "post_" + userID + "_" + System.currentTimeMillis() + "_" + originalFileName;
            
            File fileToSave = new File(POST_UPLOAD_DIR + uniqueFileName);
            
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            String dbPath = "posts/" + uniqueFileName;
            
            PostDao dao = new PostDao();
            dao.createPost(userID, dbPath, caption);
        }

        response.sendRedirect(request.getContextPath() + "/JSP/dashboard.jsp");
    }
}
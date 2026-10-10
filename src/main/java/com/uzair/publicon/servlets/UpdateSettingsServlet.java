package com.uzair.publicon.servlets;

import com.uzair.publicon.util.DBConnection;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/UpdateSettingsServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 102,   // 2MB threshold
    maxFileSize = 1024 * 1024 * 5,    // 5MB max file size
    maxRequestSize = 1024 * 1024 * 10 // 10MB total request size
)
public class UpdateSettingsServlet extends HttpServlet {

    // Define your physical folder path on your computer
    private static final String UPLOAD_DIR = "C:/Users/Uzair Desktop/Desktop/PublicOnProfiles/avatars/";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Verify user session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
            return;
        }

        int userID = (Integer) session.getAttribute("userID");
        
        // 2. Grab text inputs from the form
        String firstName = request.getParameter("fn");
        String lastName = request.getParameter("ln");

        // 3. Handle file upload (if a new file was chosen)
        Part filePart = request.getPart("avatarFile");
        String dbPath = null;

        if (filePart != null && filePart.getSize() > 0) {
            File uploadDirFile = new File(UPLOAD_DIR);
            if (!uploadDirFile.exists()) {
                uploadDirFile.mkdirs();
            }

            String originalFileName = Path.of(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = "user_" + userID + "_" + System.currentTimeMillis() + "_" + originalFileName;
            File fileToSave = new File(UPLOAD_DIR + uniqueFileName);

            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            dbPath = "avatars/" + uniqueFileName;
        }

        // 4. Update the database
        try {
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement;

            if (dbPath != null) {
                // Update names AND profile picture if a new picture was provided
                String query = "UPDATE Users SET first_name = ?, last_name = ?, profile_pic = ? WHERE userID = ?";
                statement = connection.prepareStatement(query);
                statement.setString(1, firstName);
                statement.setString(2, lastName);
                statement.setString(3, dbPath);
                statement.setInt(4, userID);
            } else {
                // Update names ONLY if no new profile picture was uploaded
                String query = "UPDATE Users SET first_name = ?, last_name = ? WHERE userID = ?";
                statement = connection.prepareStatement(query);
                statement.setString(1, firstName);
                statement.setString(2, lastName);
                statement.setInt(3, userID);
            }

            statement.executeUpdate();
            statement.close();
            connection.close();

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database update failed.");
            return;
        }

        // 5. Redirect back to settings page with success feedback
        response.sendRedirect(request.getContextPath() + "/JSP/settings.jsp?success=updated");
    }
}
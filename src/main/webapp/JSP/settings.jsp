<%-- 
    Document   : settings
    Created on : Sep 4, 2026, 11:27:53 PM
    Author     : Uzair Desktop
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="com.uzair.publicon.util.DBConnection"%>

<%
    // Get the logged-in user's ID from the session
    Integer userID = (Integer) session.getAttribute("userID");

    String firstName = "";
    String lastName = "";
    String email = "";
    String profilePic = "";

    if (userID != null) {
        String query = "SELECT first_name, last_name, email, profile_pic " +
                       "FROM Users WHERE userID = ?";

        try {
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(query);
            statement.setInt(1, userID);
            ResultSet result = statement.executeQuery();

            if (result.next()) {
                firstName = result.getString("first_name");
                lastName = result.getString("last_name");
                email = result.getString("email");
                
                try {
                    profilePic = result.getString("profile_pic");
                } catch (SQLException ex) {
                    // Ignore if column missing
                }
            }

            result.close();
            statement.close();
            connection.close();

        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
    }
    
    // Determine the correct image source path safely
    String imageSrc = request.getContextPath() + "/Images/defaultProfile.png";
    
    if (profilePic != null && !profilePic.trim().isEmpty()) {
        // Clean up any stray prefixes so we only isolate the actual file name
        String fileName = profilePic;
        if (fileName.contains("/")) {
            fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
        }
        // Forcefully route through the DisplayImageServlet mapping (/images/*)
        imageSrc = request.getContextPath() + "/images/" + fileName;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>PublicOn | Account Settings</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/settings.css">
    </head>
    <body>
        
    <nav id="nav" class="navbar">
        <div class="logo-area">
            <img src="../Images/PB.png" width="80" alt="Logo">
            <h1>PublicOn</h1>
        </div>
    </nav>
        
    <!-- Point action to your unified UpdateSettingsServlet -->
    <form class="main" action="<%= request.getContextPath() %>/UpdateSettingsServlet" method="POST" enctype="multipart/form-data" id="profileForm">
        <a href="<%= request.getContextPath() %>/JSP/Profile.jsp" class="back-button" id="BackBTN">Back</a>
        <h1>Account Settings</h1><br><br>
        
        <div class="profile-container" id="PC">
            <!-- The label acts as the clickable trigger for the hidden input inside it -->
            <label class="avatar-upload">
                <!-- Dynamically load the user's current avatar -->
                <img id="profile-display" src="<%= imageSrc %>" alt="Profile Picture">
                <!-- Added name="avatarFile" so the Servlet can grab it -->
                <input type="file" id="image-input" name="avatarFile" accept="image/*" onchange="previewImage(event)">
            </label>
                
            <div class="FnLn-Inputs">
                <input type="text" class="Fn-input" name="fn" value="<%= firstName %>">
                <input type="text" class="Ln-input" name="ln" value="<%= lastName %>">
            </div>
        </div>
            
        <div class="option-container">
            <button type="button" id="CPB" class="changePassBTN" onclick="showPassForm()">Change Password</button>
            <button type="submit" id="SCB" class="saveChangesBTN">Save Changes</button>
        </div>
        
    </form>   
                
    <form action="<%= request.getContextPath() %>/UpdatePassword" class="passwordForm" method="POST" id="passForm">
        <h1> Change Password </h1>
        
        <input type="password" id="CurrentPass" name="CP" placeholder="Current Password" required /> 
        <input type="password" id="NewPass" name="NP" placeholder="New Password" required /> 
        
        <div class="buttons">
            <button type="button" class="backBTN" id="BBTN" onclick="showProfileForm()">Back</button>
            <button type="submit" class="changePassBTN" id="CPBTN">Save</button>
        </div>
    </form>
    
    </body>
    
    <script src="<%= request.getContextPath() %>/JS/settings.js"></script>
  
</html>
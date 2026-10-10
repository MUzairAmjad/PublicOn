<%-- 
    Document   : Profile
    Created on : Sep 12, 2026
    Author     : Uzair Desktop
--%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.uzair.publicon.model.Post"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="com.uzair.publicon.util.DBConnection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // 1. Get the logged-in user's ID from the session
    Integer loggedInUserID = (Integer) session.getAttribute("userID");
    
    // Safety check: redirect to login if not logged in
    if (loggedInUserID == null) {
        response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
        return;
    }

    // 2. Figure out WHOSE profile we are viewing
    int profileUserID = loggedInUserID; // Default to your own profile
    String requestedId = request.getParameter("id");
    
    if (requestedId != null && !requestedId.trim().isEmpty()) {
        try {
            profileUserID = Integer.parseInt(requestedId);
        } catch (NumberFormatException e) {
            // If the URL id is invalid, just ignore it and show own profile
        }
    }

    // 3. Create the boolean flag!
    boolean isOwnProfile = (loggedInUserID == profileUserID);

    String firstName = "";
    String lastName = "";
    String email = "";
    String profilePic = "";
    String handle = "";
    int postCount = 0;
    int followers = 0;
    int following = 0;
    boolean isFollowing = false;

    List<Post> userPosts = new ArrayList<>();

    // Query profile details and check if logged-in user follows this profile user
    String query = "SELECT first_name, last_name, email, profile_pic, handle, " +
            "(SELECT COUNT(*) FROM posts WHERE userID = ?) AS post_count, " +
            "(SELECT COUNT(*) FROM follows WHERE following_id = ?) AS followers, " +
            "(SELECT COUNT(*) FROM follows WHERE follower_id = ?) AS following, " +
            "(SELECT COUNT(*) FROM follows WHERE follower_id = ? AND following_id = ?) AS is_following " +
            "FROM Users WHERE userID = ?";

    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(query)) {
        
        statement.setInt(1, profileUserID);
        statement.setInt(2, profileUserID);
        statement.setInt(3, profileUserID);
        statement.setInt(4, loggedInUserID); // follower_id (logged-in user)
        statement.setInt(5, profileUserID);  // following_id (profile being viewed)
        statement.setInt(6, profileUserID);  // Users.userID
        
        try (ResultSet result = statement.executeQuery()) {
            if (result.next()) {
                firstName = result.getString("first_name");
                lastName = result.getString("last_name");
                email = result.getString("email");
                handle = result.getString("handle");
                postCount = result.getInt("post_count");
                followers = result.getInt("followers");
                following = result.getInt("following");
                isFollowing = result.getInt("is_following") > 0;
                
                try {
                    profilePic = result.getString("profile_pic");
                } catch (SQLException ex) {
                    // Ignore if column missing
                }
            }
        }

        // Fetch user posts and their respective like/comment counts for the grid
        String postsQuery = "SELECT p.postID, p.image_path, " +
                            "(SELECT COUNT(*) FROM likes WHERE postID = p.postID) AS like_count, " +
                            "(SELECT COUNT(*) FROM comments WHERE postID = p.postID) AS comment_count " +
                            "FROM posts p WHERE p.userID = ? ORDER BY p.created_at DESC";

        try (PreparedStatement postStmt = connection.prepareStatement(postsQuery)) {
            postStmt.setInt(1, profileUserID);
            try (ResultSet postRs = postStmt.executeQuery()) {
                while (postRs.next()) {
                    Post p = new Post();
                    p.setPostID(postRs.getInt("postID"));
                    p.setImagePath(postRs.getString("image_path"));
                    p.setLikeCount(postRs.getInt("like_count"));
                    p.setCommentCount(postRs.getInt("comment_count"));
                    userPosts.add(p);
                }
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Determine the correct image source path safely
    String imageSrc = request.getContextPath() + "/Images/defaultProfile.png";
    if (profilePic != null && !profilePic.trim().isEmpty()) {
        String fileName = profilePic;
        if (fileName.contains("/")) {
            fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
        }
        imageSrc = request.getContextPath() + "/images/" + fileName.replace(" ", "%20");
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= firstName %> <%= lastName %> (@<%= handle %>) | PublicOn</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/Profile.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>

<body>

    <!-- =========================================
         BACK BUTTON
         ========================================= -->
    <a href="<%= request.getContextPath() %>/JSP/dashboard.jsp" class="backButton">
        <svg viewBox="0 0 24 24">
            <path d="M19 12H5"/>
            <path d="m12 19-7-7 7-7"/>
        </svg>
        <span>Back</span>
    </a>

    <!-- =========================================
         PROFILE PAGE
         ========================================= -->
    <main class="profilePage">

        <!-- =====================================
             PROFILE HEADER
             ===================================== -->
        <section class="profileHeader">
            
            <% if(isOwnProfile) { %>
                <!-- Settings Button -->
                <a href="<%= request.getContextPath() %>/JSP/settings.jsp">
                    <button class="profileSettingsButton" type="button" title="Settings">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M20 13.2V10.8L17.9 10.3C17.7 9.7 17.4 9.2 17 8.7L18.1 6.8L16.4 5.1L14.5 6.2C14 5.8 13.4 5.5 12.8 5.3L12.3 3.2H9.9L9.4 5.3C8.8 5.5 8.2 5.8 7.7 6.2L5.8 5.1L4.1 6.8L5.2 8.7C4.8 9.2 4.5 9.7 4.3 10.3L2.2 10.8V13.2L4.3 13.7C4.5 14.3 4.8 14.8 5.2 15.3L4.1 17.2L5.8 18.9L7.7 17.8C8.2 18.2 8.8 18.5 9.4 18.7L9.9 20.8H12.3L12.8 18.7C13.4 18.5 14 18.2 14.5 17.8L16.4 18.9L18.1 17.2L17 15.3C17.4 14.8 17.7 14.3 17.9 13.7Z"/>
                            <circle cx="11.1" cy="12" r="2.8"/>
                        </svg>
                    </button>
                </a>
                
                <!-- Logout Button -->
                <form action="<%= request.getContextPath() %>/LogOutServlet" method="GET" class="logout-form">
                    <button class="profileLogoutButton" type="submit" title="Log out">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="M10 4H5a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h5"/>
                            <path d="M14 8l4 4-4 4"/>
                            <path d="M9 12h9"/>
                        </svg>
                    </button>
                </form>
            <% } %> 

            <!-- Profile Picture -->
            <div class="profilePictureContainer">
                <img src="<%= imageSrc %>" width="100" alt="Profile Picture" class="profilePicture">
            </div>

            <!-- Profile Information -->
            <div class="profileInformation">

                <!-- Name + Handle -->
                <div class="profileIdentity">
                    <h1><%= firstName + " " + lastName %></h1>
                    <span class="profileHandle">@<%= handle %></span>
                </div>

                <!-- Statistics -->
                <div class="profileStats">
                    <div class="stat">
                        <strong><%= followers %></strong>
                        <span>Followers</span>
                    </div>
                    <div class="stat">
                        <strong><%= following %></strong>
                        <span>Following</span>
                    </div>
                    <div class="stat">
                        <strong><%= postCount %></strong>
                        <span>Posts</span>
                    </div>
                </div>
         
                <!-- Action Buttons -->
                <div class="profileActions">
                    <% if (!isOwnProfile) { %>
                        <!-- Follow/Unfollow Button for OTHER profiles -->    
                        <button 
                            class="followButton" 
                            type="button"
                            data-user-id="<%= profileUserID %>" 
                            data-status="<%= isFollowing ? "followed" : "unfollowed" %>"
                            onclick="toggleFollow(this)"
                            style="<%= isFollowing ? "background-color: #efefef; color: #262626;" : "background-color: #0095f6; color: #ffffff;" %>"
                        >
                            <%= isFollowing ? "Unfollow" : "Follow" %>
                        </button>

                        <button class="messageButton" type="button">
                            <svg viewBox="0 0 24 24">
                                <path d="M20 11.5a7.5 7.5 0 0 1-7.5 7.5H8l-4 2v-5.2A7.5 7.5 0 1 1 20 11.5Z"/>
                            </svg>
                            Message
                        </button>
                    <% } else { %>
                        <!-- Edit Profile button on your OWN profile -->
                        <a href="<%= request.getContextPath() %>/JSP/settings.jsp" style="text-decoration: none;">
                            <button class="followButton" type="button" style="background: #efefef; color: black;">
                                Edit Profile
                            </button>
                        </a>
                    <% } %>
                </div>

            </div>

        </section>

        <!-- =====================================
             PROFILE BIO
             ===================================== -->
        <section class="profileBio">
            <p>Building things, learning new stuff, and sharing the journey.</p>
        </section>

        <!-- =====================================
             POSTS SECTION
             ===================================== -->
        <section class="postsSection">
            <div class="postsHeader">
                <div class="postsTitle">
                    <svg viewBox="0 0 24 24">
                        <rect x="3" y="3" width="18" height="18" rx="2"/>
                        <circle cx="8.5" cy="8.5" r="1.5"/>
                        <path d="m21 15-5-5L5 21"/>
                    </svg>
                    <h2>Posts</h2>
                </div>
            </div>

            <!-- =================================
                 POST GRID
                 ================================= -->
            <div class="postGrid">
                <% 
                    if (userPosts != null && !userPosts.isEmpty()) {
                        for (Post p : userPosts) {
                            String rawPath = p.getImagePath();
                            if (rawPath != null && rawPath.contains("/")) {
                                rawPath = rawPath.substring(rawPath.lastIndexOf("/") + 1);
                            }
                            String postImgSrc = request.getContextPath() + "/post-images/" + (rawPath != null ? rawPath.replace(" ", "%20") : "");
                %>
                <!-- Dynamic Post -->
                <div class="post">
                    <img src="<%= postImgSrc %>" alt="Post">
                    <div class="postOverlay">
                        <span>♥ <%= p.getLikeCount() %></span>
                        <span>💬 <%= p.getCommentCount() %></span>
                    </div>
                </div>
                <% 
                        }
                    } else { 
                %>
                    <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                        <h3>No posts yet</h3>
                        <p>When you share photos, they will appear here.</p>
                    </div>
                <% 
                    } 
                %>
            </div>
        </section>

    </main>

    <!-- AJAX Follow Script -->
    <script>
    function toggleFollow(button) {
        const targetId = button.getAttribute('data-user-id');
        const currentStatus = button.getAttribute('data-status');
        
        if (!targetId) {
            console.error("Error: Could not find a valid user ID in the button attributes.");
            return;
        }

        const nextStatus = (currentStatus === 'followed') ? 'unfollowed' : 'followed';

        const payload = {
            targetUserId: parseInt(targetId),
            action: nextStatus
        };

        fetch('<%= request.getContextPath() %>/FollowServlet', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        })
        .then(response => {
            if (!response.ok) {
                throw new Error('Server returned an error status.');
            }
            return response.json();
        })
        .then(data => {
            if (data.status === 'success') {
                if (nextStatus === 'followed') {
                    button.setAttribute('data-status', 'followed');
                    button.innerText = 'Unfollow';
                    button.style.backgroundColor = '#efefef';
                    button.style.color = '#262626';
                } else {
                    button.setAttribute('data-status', 'unfollowed');
                    button.innerText = 'Follow';
                    button.style.backgroundColor = '#0095f6';
                    button.style.color = '#ffffff';
                }
            } else {
                alert('Could not update follow status. Please try again.');
            }
        })
        .catch(error => {
            console.error('AJAX Error:', error);
            alert('A network error occurred. Please check your connection.');
        });
    }
    </script>

</body>
</html>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.List"%>
<%@page import="com.uzair.publicon.model.Post"%>
<%@page import="com.uzair.publicon.dao.PostDao"%>
<%@page import="com.uzair.publicon.util.DBConnection"%>

<%
    Integer userID = (Integer) session.getAttribute("userID");
    if (userID == null) {
        response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
        return;
    }

    String firstName = "";
    String lastName = "";
    String profilePic = "";

    String query = "SELECT first_name, last_name, profile_pic FROM Users WHERE userID = ?";
    try (Connection connection = DBConnection.getConnection();
         PreparedStatement statement = connection.prepareStatement(query)) {
        statement.setInt(1, userID);
        try (ResultSet result = statement.executeQuery()) {
            if (result.next()) {
                firstName = result.getString("first_name");
                lastName = result.getString("last_name");
                try { profilePic = result.getString("profile_pic"); } catch (SQLException ex) {}
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    String imageSrc = request.getContextPath() + "/images/defaultProfile.png";
    if (profilePic != null && !profilePic.trim().isEmpty()) {
        String fileName = profilePic.contains("/") ? profilePic.substring(profilePic.lastIndexOf("/") + 1) : profilePic;
        imageSrc = request.getContextPath() + "/images/" + fileName.replace(" ", "%20");
    }

    PostDao postDao = new PostDao();
    List<Post> feedPosts = postDao.getAllPosts(userID);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PublicOn | Dashboard</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/dashboard.css">
    <style>
        /* Compact Feed & Post Card Styling Fixes */
        .feed-container {
            width: 100%;
            max-width: 470px;
            margin: 20px auto;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .post-card {
            background: white;
            border: 1px solid #dbdbdb;
            margin-bottom: 20px;
            border-radius: 8px;
            width: 100%;
            max-width: 470px;
            overflow: hidden;
        }
        .post-image-box {
            width: 100%;
            aspect-ratio: 1 / 1;
            background: #000;
        }
        .post-image-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .comment-sidebar {
            display: none;
            width: 100%;
            border-top: 1px solid #dbdbdb;
            flex-direction: column;
            background: #fafafa;
        }
    </style>
</head>
<body>

    <nav class="navbar">
        <div class="logo-area">  
            <img src="<%= request.getContextPath() %>/Images/PB.png" alt="PublicOn Logo">
            <h1>PublicOn</h1>
        </div>
    </nav>
  
    <div class="sideNavBarWrapper" id="SNav">
        <div class="sideNav">
            <button class="sideNavButton active" type="button" title="Home"><svg viewBox="0 0 24 24"><path d="M3 10.8 12 3l9 7.8v9.2a1 1 0 0 1-1 1h-5.5v-6h-5v6H4a1 1 0 0 1-1-1v-9.2Z"/></svg></button>
            <a href="<%= request.getContextPath() %>/JSP/search.jsp">
            <button class="sideNavButton" type="button" title="Search">
                <svg viewBox="0 0 24 24">
                <circle cx="10.8" cy="10.8" r="6.8"/>
                <path d="m16 16 5 5"/></svg>
            </button>
            </a>
            
            <a href="<%= request.getContextPath() %>/JSP/CreatePost.jsp"><button class="sideNavButton" type="button" title="Create"><svg viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg></button></a>
            <button class="sideNavButton" type="button" title="Messages"><svg viewBox="0 0 24 24"><path d="M20 11.5a7.5 7.5 0 0 1-7.5 7.5H8l-4 2v-5.2A7.5 7.5 0 1 1 20 11.5Z"/></svg></button>
            <div class="sideNavDivider"></div>
            <a href="<%= request.getContextPath() %>/JSP/Profile.jsp"><button class="sideNavButton profileNavButton" type="button" title="Profile"><img src="<%= imageSrc %>" alt="Profile"></button></a>
        </div>
    </div>
                
    <main class="dashboard">
        <div class="feed-container">
            <% 
                if (feedPosts != null && !feedPosts.isEmpty()) {
                    for (Post p : feedPosts) {
                        String userAvatarSrc = request.getContextPath() + "/images/defaultProfile.png";
                        if (p.getUserAvatar() != null && !p.getUserAvatar().trim().isEmpty()) {
                            String avatarName = p.getUserAvatar();
                            if (avatarName.contains("/")) avatarName = avatarName.substring(avatarName.lastIndexOf("/") + 1);
                            userAvatarSrc = request.getContextPath() + "/images/" + avatarName.replace(" ", "%20");
                        }

                        String rawPath = p.getImagePath();
                        if (rawPath != null && rawPath.contains("/")) rawPath = rawPath.substring(rawPath.lastIndexOf("/") + 1);
                        String postImgSrc = request.getContextPath() + "/post-images/" + (rawPath != null ? rawPath.replace(" ", "%20") : "");
            %>
               
            <!-- Post Card -->
            <div class="post-card">
                <!-- Header -->
                <div class="post-header" style="display: flex; align-items: center; padding: 10px 12px; border-bottom: 1px solid #efefef;">
                    <img src="<%= userAvatarSrc %>" alt="Avatar" style="width: 32px; height: 32px; border-radius: 50%; object-fit: cover; margin-right: 10px;">
                    <a href="<%= request.getContextPath() %>/JSP/Profile.jsp?id=<%= p.getUserID() %>" style="text-decoration: none; display: flex; align-items: baseline; gap: 6px;">
                        <span style="font-weight: 600; font-size: 14px; color: #262626;"><%= p.getFirstName() %> <%= p.getLastName() %></span>
                        <span style="font-size: 12px; color: #8e8e8e;">@<%= p.getHandle() %></span>
                    </a>
                </div>

                <!-- Image -->
                <div class="post-image-box">
                    <img src="<%= postImgSrc %>" alt="Post Image">
                </div>

                <!-- Action Bar -->
                <div style="padding: 10px 12px; display: flex; gap: 15px; align-items: center;">
                    <div style="display: flex; gap: 5px; align-items: center;">
                        <button type="button" class="like-btn" data-postid="<%= p.getPostID() %>" onclick="toggleLike(this)" style="background:none; border:none; cursor:pointer; font-size: 22px;" title="Like">
                            <%= p.isLikedByCurrentUser() ? "❤️" : "🤍" %> 
                        </button>
                        <span id="like-count-<%= p.getPostID() %>" style="font-size: 14px; font-weight: 600; color: #262626;"><%= p.getLikeCount() %></span>
                    </div>

                    <button type="button" onclick="toggleCommentSidebar('<%= p.getPostID() %>')" style="background:none; border:none; cursor:pointer; font-size: 20px; display: flex; align-items: center; gap: 5px;" title="Comments">
                        💬 <span id="comment-count-<%= p.getPostID() %>" style="font-size: 14px; font-weight: 600; color: #262626;"><%= p.getCommentCount() %></span>
                    </button>
                </div>

                <!-- Caption -->
                <div style="padding: 0 12px 10px 12px; font-size: 14px; color: #262626;">
                    <span style="font-weight: 600; margin-right: 6px;"><%= p.getFirstName() %></span>
                    <span><%= p.getCaption() %></span>
                </div>

                <!-- Comments Drawer/Section -->
                <div id="comment-sidebar-<%= p.getPostID() %>" class="comment-sidebar">
                    <div style="color: black; padding: 10px 12px; border-bottom: 1px solid #efefef; font-weight: 600; font-size: 13px; display: flex; justify-content: space-between;">
                        <span>Comments</span>
                        <button type="button" onclick="toggleCommentSidebar('<%= p.getPostID() %>')" style="background:none; border:none; cursor:pointer; font-size: 14px; font-weight: bold;">&times;</button>
                    </div>

                    <div class="comments-list" id="comments-list-<%= p.getPostID() %>" style="color:black; max-height: 200px; overflow-y: auto; padding: 10px 12px; display: flex; flex-direction: column; gap: 8px;">
                        <div style="font-size: 12px; color: black; text-align: center;">Loading comments...</div>
                    </div>

                    <!-- AJAX Comment Form -->
                    <form onsubmit="submitComment(event, '<%= p.getPostID() %>')" style="padding: 8px 12px; border-top: 1px solid #efefef; display: flex; gap: 6px; background: white;">
                        <input type="text" name="commentText" id="comment-input-<%= p.getPostID() %>" placeholder="Add a comment..." required style="flex-grow: 1; padding: 6px 10px; border: 1px solid #dbdbdb; border-radius: 4px; font-size: 13px; outline: none;">
                        <button type="submit" style="background: none; border: none; color: #0095f6; font-weight: 600; cursor: pointer; font-size: 13px;">Post</button>
                    </form>
                </div>

            </div>
            <% 
                    }
                } else { 
            %>
                <p style="text-align: center; color: #8e8e8e; padding: 20px;">No posts yet. Be the first to share something!</p>
            <% } %>
        </div>
    </main>

    <script>
        function toggleLike(button) {
            const postId = button.getAttribute('data-postid');
            fetch('<%= request.getContextPath() %>/LikeServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'postID=' + postId
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    button.innerHTML = data.liked ? '❤️' : '🤍';
                    document.getElementById('like-count-' + postId).innerText = data.likeCount;
                }
            });
        }

        function toggleCommentSidebar(postId) {
            const sidebar = document.getElementById('comment-sidebar-' + postId);
            if (sidebar.style.display === 'flex') {
                sidebar.style.display = 'none';
            } else {
                sidebar.style.display = 'flex';
                loadComments(postId);
            }
        }

        function loadComments(postId) {
            const listContainer = document.getElementById('comments-list-' + postId);
            if (!listContainer) return;
            
            listContainer.innerHTML = '<div style="font-size: 12px; color: #666; text-align: center;">Loading comments...</div>';

            fetch('<%= request.getContextPath() %>/GetCommentsServlet?postID=' + postId)
                .then(res => {
                    if (!res.ok) throw new Error('Network response was not ok');
                    return res.json();
                })
                .then(comments => {
                    listContainer.innerHTML = '';
                    
                    if (!comments || comments.length === 0) {
                        listContainer.innerHTML = '<div style="font-size: 12px; color: #8e8e8e; text-align: center;">No comments yet.</div>';
                        return;
                    }

                    comments.forEach(c => {
                        const div = document.createElement('div');
                        div.style.display = 'flex';
                        div.style.alignItems = 'flex-start'; // Keeps avatar at the top if the comment is very long
                        div.style.gap = '12px'; // Slightly increased gap for breathing room
                        div.style.marginBottom = '14px'; // More space between different comments

                        // Extract filename to match your /images/ mapping
                        let avatarSrc = '<%= request.getContextPath() %>/images/defaultProfile.png';
                        if (c.profilePic && c.profilePic.trim() !== '') {
                            let fileName = c.profilePic.trim();
                            if (fileName.includes('/')) {
                                fileName = fileName.substring(fileName.lastIndexOf('/') + 1);
                            }
                            avatarSrc = '<%= request.getContextPath() %>/images/' + fileName.replace(/ /g, '%20');
                        }

                        const handle = c.handle ? c.handle : 'user';
                        const text = c.text ? c.text : '';

                        // BYPASS JSP EL: Using string concatenation (+)
                        div.innerHTML = 
                            // Avatar (Increased to 32x32 to match the height of two lines of text)
                            '<img src="' + avatarSrc + '" alt="Avatar" style="margin-top: 3px; width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0;" onerror="this.src=\'<%= request.getContextPath() %>/images/defaultProfile.png\'">' +
                            
                            // Text Container (Flex Column to stack Handle on top of Comment)
                            '<div style="font-size: 13px; word-break: break-word; display: flex; flex-direction: column;">' +
                                '<span style="font-weight: 600; color: #262626; margin-bottom: 3px;">@' + handle + '</span>' +
                                '<span style="color: #444; line-height: 1.2;">' + text + '</span>' +
                            '</div>';
                        
                        listContainer.appendChild(div);
                    });
                })
                .catch(err => {
                    console.error('Failed to load comments:', err);
                    listContainer.innerHTML = '<div style="font-size: 12px; color: #ff3b30; text-align: center;">Failed to load comments</div>';
                });
        }
        
        function submitComment(event, postId) {
            event.preventDefault();
            const input = document.getElementById('comment-input-' + postId);
            const text = input.value.trim();
            if (!text) return;

            fetch('<%= request.getContextPath() %>/CommentServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'postID=' + postId + '&commentText=' + encodeURIComponent(text)
            })
            .then(res => {
                if (!res.ok) throw new Error('Server returned error status');
                return res.json();
            })
            .then(data => {
                if (data.success) {
                    input.value = ''; 
                    document.getElementById('comment-count-' + postId).innerText = data.commentCount; 
                    loadComments(postId); 
                }
            })
            .catch(err => {
                console.error('Error posting comment:', err);
            });
        }
    </script>
</body>
</html>
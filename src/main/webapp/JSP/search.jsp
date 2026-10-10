<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.uzair.publicon.model.SearchUser"%>

<%
    // Session check
    Integer userID = (Integer) session.getAttribute("userID");
    if (userID == null) {
        response.sendRedirect(request.getContextPath() + "/UserAuthPages/login.html");
        return;
    }

    String searchQuery = (String) request.getAttribute("searchQuery");
    List<SearchUser> searchResults = (List<SearchUser>) request.getAttribute("searchResults");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search | PublicOn</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/search.css">
</head>

<body>

    <!-- Back Button -->
    <a href="<%= request.getContextPath() %>/JSP/dashboard.jsp" class="backButton">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M19 12H5"/>
            <path d="m12 19-7-7 7-7"/>
        </svg>
        <span>Back</span>
    </a>

    <!-- Search Section -->
    <main class="searchPage">
        <div class="searchCard">

            <div class="searchHeader">
                <h1>Search</h1>
                <p>Find people on PublicOn</p>
            </div>

            <!-- Form pointing to SearchServlet via GET method -->
            <form action="<%= request.getContextPath() %>/SearchServlet" method="GET" class="searchForm">
                <div class="searchInputWrapper">
                    <svg class="searchIcon" viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="11" cy="11" r="7"/>
                        <path d="m20 20-4-4"/>
                    </svg>
                    <input type="text" 
                           name="query" 
                           placeholder="Search users..." 
                           autocomplete="off" 
                           value="<%= searchQuery != null ? searchQuery : "" %>"
                           required>
                </div>

                <button type="submit" class="searchButton">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="11" cy="11" r="7"/>
                        <path d="m20 20-4-4"/>
                    </svg>
                    <span>Search</span>
                </button>
            </form>

            <!-- Results Section -->
            <div class="searchResultsContainer" style="margin-top: 20px; display: flex; flex-direction: column; gap: 10px;">
                <% 
                    if (searchResults != null) {
                        if (!searchResults.isEmpty()) {
                            for (SearchUser u : searchResults) {
                                // Safely resolve profile picture path using getters
                                String avatarSrc = request.getContextPath() + "/images/defaultProfile.png";
                                String pPic = u.getProfilePic();
                                if (pPic != null && !pPic.trim().isEmpty()) {
                                    String picName = pPic.contains("/") ? pPic.substring(pPic.lastIndexOf("/") + 1) : pPic;
                                    avatarSrc = request.getContextPath() + "/images/" + picName.replace(" ", "%20");
                                }
                                
                                // Determine styling based on follow status
                                String btnBg = u.isFollowing() ? "#efefef" : "#0095f6";
                                String btnColor = u.isFollowing() ? "#262626" : "white";
                                String btnText = u.isFollowing() ? "Unfollow" : "Follow";
                %>
                    <!-- Instagram-style user result row -->
                    <div class="userResultRow" style="display: flex; align-items: center; background: #fafafa; border: 1px solid #dbdbdb; border-radius: 6px; overflow: hidden; transition: background 0.2s;">
                        
                        <!-- FIXED: Route profile link through ProfileServlet so ID is parsed correctly -->
                        <a href="<%= request.getContextPath() %>/JSP/Profile.jsp?id=<%= u.getUserID() %>" style="display: flex; align-items: center; gap: 10px; text-decoration: none; color: inherit; flex-grow: 1; padding: 10px 12px; cursor: pointer;">
                            <img src="<%= avatarSrc %>" alt="Avatar" style="width: 40px; height: 40px; border-radius: 50%; object-fit: cover;">
                            <div>
                                <div style="font-weight: 600; font-size: 14px; color: #262626;">@<%= u.getHandle() %></div>
                                <div style="font-size: 12px; color: #8e8e8e;"><%= u.getFirstName() %> <%= u.getLastName() %></div>
                            </div>
                        </a>
                        
                        <!-- Follow Button Wrapper -->
                        <div style="padding-right: 12px;">
                            <button type="button" 
                                    data-user-id="<%= u.getUserID() %>"
                                    data-status="<%= u.isFollowing() ? "followed" : "unfollowed" %>"
                                    onclick="toggleFollow(this)" 
                                    style="background: <%= btnBg %>; color: <%= btnColor %>; border: none; padding: 6px 14px; border-radius: 4px; font-weight: 600; font-size: 13px; cursor: pointer; min-width: 80px;">
                                <%= btnText %>
                            </button>
                        </div>
                    </div>
                <% 
                            }
                        } else { 
                %>
                    <div style="text-align: center; color: #8e8e8e; padding: 20px; font-size: 14px;">
                        No IDs found.
                    </div>
                <% 
                        }
                    } 
                %>
            </div>

        </div>
    </main>

    <!-- AJAX Follow Logic Matching JSON Servlet -->
    <script>
        function toggleFollow(button) {
            const targetId = button.getAttribute('data-user-id');
            const currentStatus = button.getAttribute('data-status');
            
            if (!targetId) {
                console.error("Error: Could not find a valid user ID.");
                return;
            }

            // Instantly disable button to prevent spam clicks
            button.disabled = true; 

            // Determine next action expected by FollowServlet ('followed' or 'unfollowed')
            const nextAction = (currentStatus === 'followed') ? 'unfollowed' : 'followed';

            const payload = {
                targetUserId: parseInt(targetId),
                action: nextAction
            };
            
            fetch('<%= request.getContextPath() %>/FollowServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(payload)
            })
            .then(res => {
                if (!res.ok) throw new Error('Server returned an error status.');
                return res.json();
            })
            .then(data => {
                if (data.status === 'success') {
                    // Update UI based on the new state
                    if (nextAction === 'followed') {
                        button.setAttribute('data-status', 'followed');
                        button.innerText = 'Unfollow';
                        button.style.background = '#efefef';
                        button.style.color = '#262626';
                    } else {
                        button.setAttribute('data-status', 'unfollowed');
                        button.innerText = 'Follow';
                        button.style.background = '#0095f6';
                        button.style.color = 'white';
                    }
                } else {
                    console.error("Error from server:", data.message);
                }
            })
            .catch(error => console.error("Error toggling follow:", error))
            .finally(() => {
                button.disabled = false; // Re-enable button
            });
        }
    </script>

</body>
</html>
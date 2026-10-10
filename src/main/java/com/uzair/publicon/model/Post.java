package com.uzair.publicon.model;

public class Post {
    private int postID;
    private int userID;
    private String firstName;
    private String lastName;
    private String userAvatar;
    private String imagePath;
    private String caption;
    private String createdAt;
    private String handle;
    
    private int likeCount;
    private boolean isLikedByCurrentUser;
    private int commentCount;

    // Getters and Setters
    public int getPostID() { return postID; }
    public void setPostID(int postID) { this.postID = postID; }

    public int getUserID() { return userID; }
    public void setUserID(int userID) { this.userID = userID; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getUserAvatar() { return userAvatar; }
    public void setUserAvatar(String userAvatar) { this.userAvatar = userAvatar; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getCaption() { return caption; }
    public void setCaption(String caption) { this.caption = caption; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }
    
    public String getHandle() { return handle; }
    public void setHandle(String handle) { this.handle = handle; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public boolean isLikedByCurrentUser() { return isLikedByCurrentUser; }
    public void setLikedByCurrentUser(boolean isLikedByCurrentUser) { this.isLikedByCurrentUser = isLikedByCurrentUser; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }
}
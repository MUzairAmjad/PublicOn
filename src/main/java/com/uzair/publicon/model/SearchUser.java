package com.uzair.publicon.model;

public class SearchUser {
    private int userID;
    private String firstName;
    private String lastName;
    private String handle;
    private String profilePic;
    private boolean isFollowing; // New property!

    public int getUserID() { return userID; }
    public void setUserID(int userID) { this.userID = userID; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getHandle() { return handle; }
    public void setHandle(String handle) { this.handle = handle; }

    public String getProfilePic() { return profilePic; }
    public void setProfilePic(String profilePic) { this.profilePic = profilePic; }

    public boolean isFollowing() { return isFollowing; }
    public void setFollowing(boolean isFollowing) { this.isFollowing = isFollowing; }
}
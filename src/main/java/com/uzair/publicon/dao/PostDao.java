package com.uzair.publicon.dao;

import com.uzair.publicon.model.Post;
import com.uzair.publicon.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostDao {

    public boolean createPost(int userID, String imagePath, String caption) {
        String query = "INSERT INTO posts (userID, image_path, caption) VALUES (?, ?, ?)";
        String updatePostCount = "UPDATE users SET post_count = post_count + 1 WHERE userID = ?";
        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(query);
            PreparedStatement stmt2 = conn.prepareStatement(updatePostCount)){
            
            stmt.setInt(1, userID);
            stmt.setString(2, imagePath);
            stmt.setString(3, caption);
            
            stmt2.setInt(1, userID);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Post> getAllPosts(int currentUserID) {
        List<Post> posts = new ArrayList<>();
        
        // Added u.handle to the SELECT clause
        String query = "SELECT p.postID, p.userID, p.image_path, p.caption, p.created_at, " +
                       "u.first_name, u.last_name, u.profile_pic, u.handle, " +
                       "(SELECT COUNT(*) FROM likes WHERE postID = p.postID) AS total_likes, " +
                       "(SELECT COUNT(*) FROM likes WHERE postID = p.postID && userID = ?) AS user_liked, " +
                       "(SELECT COUNT(*) FROM comments WHERE postID = p.postID) AS total_comments " +
                       "FROM posts p " +
                       "JOIN Users u ON p.userID = u.userID " +
                       "ORDER BY p.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, currentUserID);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Post p = new Post();
                    p.setPostID(rs.getInt("postID"));
                    p.setUserID(rs.getInt("userID"));
                    p.setImagePath(rs.getString("image_path"));
                    p.setCaption(rs.getString("caption"));
                    p.setFirstName(rs.getString("first_name"));
                    p.setLastName(rs.getString("last_name"));
                    p.setUserAvatar(rs.getString("profile_pic"));
                    p.setLikeCount(rs.getInt("total_likes"));
                    p.setLikedByCurrentUser(rs.getInt("user_liked") > 0);
                    p.setCommentCount(rs.getInt("total_comments"));
                    p.setHandle(rs.getString("handle")); // Maps correctly now!
                    
                    posts.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return posts;
    }
}
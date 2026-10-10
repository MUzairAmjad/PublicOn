<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Post</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/CSS/createPost.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    
    <a href="javascript:history.back()" class="backButton">
        <svg viewBox="0 0 24 24" aria-hidden="true">
            <path d="M19 12H5"/>
            <path d="m12 19-7-7 7-7"/>
        </svg>
        <span>Back</span>
    </a>

    <main class="createPostPage">
        <section class="createPostCard">
            <!-- Header -->
            <div class="createPostHeader">
                <div>
                    <h1>Create Post</h1>
                    <p>Share something with your network</p>
                </div>
                <div class="headerGlow"></div>
            </div>

            <!-- FORM START -->
            <form action="<%= request.getContextPath() %>/CreatePostServlet" method="POST" enctype="multipart/form-data" id="createPostForm">
                
                <!-- Image Selector -->
                <div class="imageSection">
                    <label class="sectionLabel">Image</label>
                    
                    <div class="imageSelector" id="imageDropZone">
                        
                        <!-- Image Preview (Hidden by default) -->
                        <img id="imagePreview" src="" alt="Image Preview" style="display: none; width: 100%; max-height: 300px; object-fit: cover; border-radius: 8px; margin-bottom: 15px;">

                        <div id="uploadPrompt">
                            <div class="uploadIcon">
                                <svg viewBox="0 0 24 24">
                                    <path d="M12 16V4"/>
                                    <path d="m7 9 5-5 5 5"/>
                                    <path d="M5 20h14"/>
                                </svg>
                            </div>
                            <h2>Select an image</h2>
                            <p>Choose an image from your device</p>
                        </div>

                        <button class="selectImageButton" type="button" id="triggerFileInput">
                            Select Image
                        </button>

                        <!-- Hidden File Input -->
                        <input type="file" id="postImage" name="postImage" accept="image/*" required hidden>
                    </div>
                </div>

                <!-- Caption -->
                <div class="captionSection">
                    <label for="caption" class="sectionLabel">Caption</label>
                    <div class="captionWrapper">
                        <textarea id="caption" name="caption" maxlength="500" placeholder="Write a caption..." required></textarea>
                        <span class="characterCount" id="charCount">0 / 500</span>
                    </div>
                </div>

                <!-- Post Button (Changed to type="submit") -->
                <button class="postButton" type="submit" id="PBTN">
                    <svg viewBox="0 0 24 24">
                        <path d="M22 2 11 13"/>
                        <path d="m22 2-7 20-4-9-9-4Z"/>
                    </svg>
                    <span>Post</span>
                </button>
                
            </form>
            <!-- FORM END -->

        </section>
    </main>

    <!-- JavaScript to handle UI interactions -->
    <script>
        
        // 1. Handle clicking the custom "Select Image" button
        const triggerBtn = document.getElementById('triggerFileInput');
        const fileInput = document.getElementById('postImage');
        const imagePreview = document.getElementById('imagePreview');
        const uploadPrompt = document.getElementById('uploadPrompt');
        
        const PBTN = document.getElementById("PBTN");

        triggerBtn.addEventListener('click', () => {
            fileInput.click(); // Simulates a click on the hidden file input
        });

        // 2. Show image preview when a file is selected
        fileInput.addEventListener('change', function() {
            const file = this.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    imagePreview.src = e.target.result;
                    imagePreview.style.display = 'block'; // Show preview
                    uploadPrompt.style.display = 'none';  // Hide the icon and text
                    triggerBtn.innerText = "Change Image"; // Update button text
                }
                reader.readAsDataURL(file);
            }
        });

        // 3. Update character counter for caption
        const captionInput = document.getElementById('caption');
        const charCountDisplay = document.getElementById('charCount');

        captionInput.addEventListener('input', function() {
            const currentLength = this.value.length;
            charCountDisplay.innerText = `${currentLength} / 500`;
        });
        
        PBTN.addEventListener('click', () => {
            this.disabled = true
        })
        
    </script>

</body>
</html>
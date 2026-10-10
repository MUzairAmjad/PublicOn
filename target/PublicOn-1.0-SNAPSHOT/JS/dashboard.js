const profileButton = document.getElementById("profileButton");
const profileDropdown = document.getElementById("profileDropdown");

profileButton.addEventListener("click", function (event) {
    event.stopPropagation();

    profileDropdown.classList.toggle("show");
});

document.addEventListener("click", function () {
    profileDropdown.classList.remove("show");
});

// 1:1 Preview JavaScript
    function previewPostImage(event) {
            const file = event.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewImg = document.getElementById('post-preview');
                    const placeholder = document.getElementById('placeholder-text');
                    
                    previewImg.src = e.target.result;
                    previewImg.style.display = 'block';
                    placeholder.style.display = 'none';
                }
                reader.readAsDataURL(file);
            }
        }
        
       
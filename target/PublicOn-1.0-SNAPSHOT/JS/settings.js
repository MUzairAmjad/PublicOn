
// Instant client-side image preview
function previewImage(event) {
    const file = event.target.files[0];
    
    if (file) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            // Find the image element on the page and update its source
            const profileDisplay = document.getElementById('profile-display');
            profileDisplay.src = e.target.result;
        }
        
        // Read the local file as a Data URL
        reader.readAsDataURL(file);
    }
}

const profileForm = document.getElementById("profileForm");
const passForm = document.getElementById("passForm");

const backBTN = document.getElementById("BBTN");
const CPB = document.getElementById("CPB");

function showProfileForm() {
    profileForm.style.display = "flex";
    passForm.style.display = "none";
}

function showPassForm() {
    profileForm.style.display = "none";
    passForm.style.display = "flex";
}
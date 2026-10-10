
const form = document.querySelector("#LoginForm");

const email = document.querySelector("#LogiEmailINP");
const password = document.querySelector("#LoginPassINP");

form.addEventListener("submit", function(event) {

    const emailValue = email.value.trim();
    const passwordValue = password.value.trim();

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailPattern.test(emailValue)) {
        event.preventDefault();
        alert("Please enter a valid email address.");
        email.focus();
        return;
    }

    if (passwordValue.length < 8) {
        event.preventDefault();
        alert("Password must be at least 8 characters long.");
        password.focus();
        return;
    }

});


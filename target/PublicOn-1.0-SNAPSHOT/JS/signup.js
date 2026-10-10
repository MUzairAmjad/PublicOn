
    const form = document.getElementById("SignupForm");

    const email = document.getElementById("SignupEmailINP");

    const passInput = document.getElementById("SignupPassINP");

    const confirmPassInput =
        document.getElementById("CSignupPassINP");

    const errorText =
        document.getElementById("passwordError");

    const strengthText =
        document.getElementById("strengthText");

    const strengthBars =
        document.querySelectorAll(".strength-bar span");


    function validateEmail(email) {

        const emailRegex =
            /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

        return emailRegex.test(email);

    }


    function showError(message) {

        errorText.textContent = message;

    }


    function clearError() {

        errorText.textContent = "";

    }


    /* Password strength */

    passInput.addEventListener("input", () => {

        const password = passInput.value;

        strengthBars.forEach(bar => {
            bar.classList.remove(
                "weak",
                "medium",
                "strong"
            );
        });


        if (password.length === 0) {

            strengthText.textContent =
                "Enter a password";

            return;

        }


        let strength = 0;


        if (password.length >= 8)
            strength++;

        if (/[A-Z]/.test(password))
            strength++;

        if (/[0-9]/.test(password))
            strength++;

        if (/[^A-Za-z0-9]/.test(password))
            strength++;


        if (strength === 1) {

            strengthText.textContent = "Weak";

            strengthBars[0].classList.add("weak");

        }

        else if (strength === 2) {

            strengthText.textContent = "Fair";

            strengthBars[0].classList.add("medium");
            strengthBars[1].classList.add("medium");

        }

        else if (strength === 3) {

            strengthText.textContent = "Good";

            for (let i = 0; i < 3; i++)
                strengthBars[i].classList.add("strong");

        }

        else {

            strengthText.textContent = "Strong";

            strengthBars.forEach(bar =>
                bar.classList.add("strong")
            );

        }

    });


    /* Password visibility */

    function setupPasswordToggle(buttonId, inputId) {

        const button =
            document.getElementById(buttonId);

        const input =
            document.getElementById(inputId);


        button.addEventListener("click", () => {

            const isPassword =
                input.type === "password";


            input.type =
                isPassword ? "text" : "password";


            button.textContent =
                isPassword ? "Hide" : "Show";


            button.setAttribute(
                "aria-label",
                isPassword
                    ? "Hide password"
                    : "Show password"
            );

        });

    }


    setupPasswordToggle(
        "togglePassword",
        "SignupPassINP"
    );


    setupPasswordToggle(
        "toggleConfirmPassword",
        "CSignupPassINP"
    );


    /* Form validation */

    form.addEventListener("submit", (e) => {

        clearError();


        const emailValue =
            email.value.trim();

        const password =
            passInput.value;

        const confirmPassword =
            confirmPassInput.value;


        if (!validateEmail(emailValue)) {

            e.preventDefault();

            showError(
                "Please enter a valid email address."
            );

            email.focus();

            return;
        }


        if (
            password.length < 8 ||
            password.length > 20
        ) {

            e.preventDefault();

            showError(
                "Password must be between 8 and 20 characters."
            );

            passInput.focus();

            return;
        }


        if (password !== confirmPassword) {

            e.preventDefault();

            showError(
                "Passwords do not match."
            );

            confirmPassInput.focus();

            return;
        }

    });


    passInput.addEventListener(
        "input",
        clearError
    );

    confirmPassInput.addEventListener(
        "input",
        clearError
    );

    email.addEventListener(
        "input",
        clearError
    );
    
    

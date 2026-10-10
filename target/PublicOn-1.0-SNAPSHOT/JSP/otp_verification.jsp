<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PublicOn | Verification</title>
    <link rel="stylesheet" href="../CSS/OTPVerification.css">
</head>

<body>

    <nav id="nav" class="navbar">
        <div class="logo-area">
            <img src="../Images/PB.png" width="80" alt="PublicOn Logo">
            <h1>PublicOn</h1>
        </div>
    </nav>

    <form action="<%= request.getContextPath() %>/VerifyOTPServlet" method="post">
        <div class="form" id="FRM">
            <div class="form-area" id="formArea">
                <div class="otp-form" id="OTPForm">
                    <h1>Verification</h1>
                    <p class="subtitle">Enter the 6-digit code we sent to your email.</p>

                    <%
                        if ("invalid".equals(request.getParameter("error"))) {
                    %>
                        <div style="color: red; font-weight: bold; margin-bottom: 10px;">
                            The OTP you entered is incorrect. Please try again.
                        </div><br>
                    <%
                        }
                    %>

                    
                    <div class="otp-input-holder" id="otp-container">
                        <input type="text" maxlength="1" name="otp1" required autofocus autocomplete="off"/>
                        <input type="text" maxlength="1" name="otp2" required autocomplete="off"/>
                        <input type="text" maxlength="1" name="otp3" required autocomplete="off"/>
                        <input type="text" maxlength="1" name="otp4" required autocomplete="off"/>
                        <input type="text" maxlength="1" name="otp5" required autocomplete="off"/>
                        <input type="text" maxlength="1" name="otp6" required autocomplete="off"/>
                    </div>
                    
                    <button type="submit" class="submit-btn" id="VerifyBTN">Verify Code</button>

                    <h2>Didn't receive it? <a href="<%= request.getContextPath() %>/ResendOTPServlet">Resend</a></h2>
                    <%
                    if ("success".equals(request.getParameter("resend"))) {
                    %>
                    <div style="color: green; font-weight: bold; margin-bottom: 10px;">
                        A new verification code has been sent to your email.
                    </div><br>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </form>

    <script>
        const inputs = document.querySelectorAll('#otp-container input');

        inputs.forEach((input, index) => {
            input.addEventListener('input', (e) => {
                if (e.target.value.length === 1 && index < inputs.length - 1) {
                    inputs[index + 1].focus();
                }
            });

            input.addEventListener('keydown', (e) => {
                if (e.key === 'Backspace' && !e.target.value && index > 0) {
                    inputs[index - 1].focus();
                }
            });
        });
    </script>
</body>
</html>
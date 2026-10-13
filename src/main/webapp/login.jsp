<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Login</title>

<style>
* {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}

body {
    min-height: 100vh;
    font-family: "Segoe UI", Arial, sans-serif;
    background:
        linear-gradient(120deg, rgba(35, 19, 63, 0.72),
        rgba(194, 61, 135, 0.38)),
        url("https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=2000&q=85")
        center/cover no-repeat fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 30px 18px;
    color: #29204c;
}

.container {
    width: 100%;
    max-width: 1050px;
    display: grid;
    grid-template-columns: 1fr 440px;
    gap: 45px;
    align-items: center;
}

.brand {
    color: white;
    padding: 20px;
}

.brand h1 {
    font-size: clamp(38px, 5vw, 65px);
    margin-bottom: 12px;
    letter-spacing: -1px;
}

.brand h1 span {
    color: #ffb9df;
}

.brand .tagline {
    font-size: 21px;
    margin-bottom: 22px;
}

.brand .description {
    font-size: 16px;
    line-height: 1.8;
    max-width: 430px;
    color: #fff4fb;
}

.features {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 28px;
}

.feature {
    padding: 11px 15px;
    border: 1px solid rgba(255,255,255,.35);
    background: rgba(255,255,255,.15);
    border-radius: 12px;
    color: white;
    font-size: 14px;
    backdrop-filter: blur(8px);
}

.card {
    width: 100%;
    padding: 36px;
    border-radius: 24px;
    background: rgba(255,255,255,.96);
    box-shadow: 0 24px 70px rgba(22, 9, 49, .3);
}

.logo {
    text-align: center;
    font-size: 38px;
    font-weight: 800;
    color: #5140a0;
    letter-spacing: -1px;
}

.logo span {
    color: #e83e96;
}

.subtitle {
    text-align: center;
    color: #777087;
    margin: 10px 0 27px;
    line-height: 1.5;
}

.message, .success {
    padding: 11px;
    margin-bottom: 16px;
    border-radius: 9px;
    text-align: center;
    font-size: 14px;
}

.message {
    color: #a51d36;
    background: #fff0f2;
}

.success {
    color: #176b46;
    background: #e9f9ef;
}

label {
    display: block;
    font-weight: 650;
    margin: 17px 0 8px;
    font-size: 14px;
}

.input-wrap {
    position: relative;
}

input[type="email"],
input[type="password"],
input[type="text"] {
    width: 100%;
    padding: 14px 15px;
    border: 1px solid #ded7ed;
    border-radius: 11px;
    background: #fff;
    color: #29204c;
    font-size: 15px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}

.input-wrap input {
    padding-right: 55px;
}

input:focus {
    border-color: #a05bd7;
    box-shadow: 0 0 0 3px rgba(160,91,215,.13);
}

.show-password {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    border: none;
    background: transparent;
    color: #67548c;
    padding: 8px;
    cursor: pointer;
    font-size: 13px;
    font-weight: 700;
}

.options {
    display: flex;
    justify-content: flex-end;
    margin-top: 14px;
    font-size: 13px;
}

a {
    color: #c52c87;
    text-decoration: none;
    font-weight: 650;
}

a:hover {
    text-decoration: underline;
}

.login-btn {
    width: 100%;
    margin-top: 24px;
    padding: 14px;
    border: none;
    border-radius: 11px;
    background: linear-gradient(110deg, #ed69b2, #7646c5);
    color: white;
    font-size: 16px;
    font-weight: 750;
    cursor: pointer;
    box-shadow: 0 7px 18px rgba(143, 64, 176, .2);
    transition: transform .2s, box-shadow .2s;
}

.login-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 23px rgba(143, 64, 176, .3);
}

.bottom {
    text-align: center;
    margin-top: 24px;
    font-size: 14px;
    color: #716981;
    line-height: 1.8;
}

.footer-note {
    margin-top: 24px;
    padding: 12px;
    text-align: center;
    background: #fff0f8;
    border-radius: 10px;
    color: #875276;
    font-size: 13px;
}

@media (max-width: 800px) {
    .container {
        max-width: 470px;
        grid-template-columns: 1fr;
        gap: 22px;
    }

    .brand {
        text-align: center;
        padding: 5px;
    }

    .brand .description {
        margin: auto;
    }

    .features {
        justify-content: center;
        margin-top: 18px;
    }

    .brand h1 {
        font-size: 38px;
    }

    .brand .tagline {
        font-size: 17px;
    }

    .card {
        padding: 27px 23px;
    }
}
</style>
</head>

<body>
<div class="container">

    <section class="brand">
        <h1>Student<span>Sphere</span></h1>
        <p class="tagline">Plan. Track. Connect. Grow.</p>

        <p class="description">
            Your student life, organised in one place.
            Manage study tasks, track expenses, explore campus
            events and work towards your personal goals.
        </p>

        <div class="features">
            <div class="feature">📚 Study Planner</div>
            <div class="feature">💰 Expense Tracker</div>
            <div class="feature">🎉 Campus Events</div>
            <div class="feature">🎯 Personal Goals</div>
        </div>
    </section>

    <main class="card">
        <div class="logo">Student<span>Sphere</span></div>
        <p class="subtitle">Welcome back! Log in to continue.</p>

        <% if ("invalid".equals(request.getParameter("error"))) { %>
            <p class="message" role="alert">
                Invalid email or password. Please try again.
            </p>
        <% } %>

        <% if ("1".equals(request.getParameter("registered"))) { %>
            <p class="success" role="status">
                Registration successful! You can now log in.
            </p>
        <% } %>

        <form action="<%= request.getContextPath() %>/login"
              method="post">

            <label for="email">Email Address</label>
            <input
                type="email"
                id="email"
                name="email"
                maxlength="150"
                autocomplete="username"
                placeholder="Enter your registered email"
                required>

            <label for="password">Password</label>
            <div class="input-wrap">
                <input
                    type="password"
                    id="password"
                    name="password"
                    autocomplete="current-password"
                    placeholder="Enter your password"
                    required>

                <button
                    type="button"
                    class="show-password"
                    id="togglePassword"
                    aria-label="Show password"
                    aria-pressed="false">
                    Show
                </button>
            </div>

            <div class="options">
                <a href="<%= request.getContextPath() %>/forgotPassword.jsp">
                    Forgot Password?
                </a>
            </div>

            <button type="submit" class="login-btn">
                Login &rarr;
            </button>
        </form>

        <p class="bottom">
            New to StudentSphere?
            <a href="<%= request.getContextPath() %>/register.jsp">
                Create an account
            </a>
        </p>

        <div class="footer-note">
            ✨ Better Students. Brighter Tomorrows.
        </div>
    </main>
</div>

<script>
const passwordInput = document.getElementById("password");
const toggleButton = document.getElementById("togglePassword");

toggleButton.addEventListener("click", function () {
    const showPassword = passwordInput.type === "password";

    passwordInput.type = showPassword ? "text" : "password";
    toggleButton.textContent = showPassword ? "Hide" : "Show";
    toggleButton.setAttribute("aria-pressed", String(showPassword));
    toggleButton.setAttribute(
        "aria-label",
        showPassword ? "Hide password" : "Show password"
    );
});
</script>
</body>
</html>


<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Create Account</title>

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
        linear-gradient(120deg, rgba(35, 19, 63, .76),
        rgba(194, 61, 135, .40)),
        url("https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=2000&q=85")
        center/cover no-repeat fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 28px 16px;
    color: #29204c;
}

.container {
    width: 100%;
    max-width: 1000px;
    display: grid;
    grid-template-columns: 1fr 430px;
    align-items: center;
    gap: 40px;
}

.brand {
    color: white;
    padding: 20px;
}

.brand h1 {
    font-size: clamp(38px, 5vw, 60px);
    letter-spacing: -1px;
    margin-bottom: 14px;
}

.brand h1 span {
    color: #ffb9df;
}

.tagline {
    font-size: 21px;
    margin-bottom: 20px;
}

.description {
    max-width: 420px;
    line-height: 1.8;
    color: #fff4fb;
    font-size: 16px;
}

.features {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 26px;
}

.feature {
    padding: 11px 14px;
    border: 1px solid rgba(255,255,255,.35);
    background: rgba(255,255,255,.15);
    border-radius: 12px;
    color: white;
    font-size: 14px;
    backdrop-filter: blur(8px);
}

.card {
    width: 100%;
    padding: 34px;
    border-radius: 24px;
    background: rgba(255,255,255,.97);
    box-shadow: 0 24px 70px rgba(22,9,49,.3);
}

.logo {
    text-align: center;
    font-size: 34px;
    font-weight: 800;
    letter-spacing: -1px;
    color: #5140a0;
}

.logo span {
    color: #e83e96;
}

.subtitle {
    text-align: center;
    color: #777087;
    margin: 10px 0 24px;
    line-height: 1.5;
}

.message {
    padding: 11px;
    margin-bottom: 15px;
    border-radius: 9px;
    text-align: center;
    font-size: 14px;
    color: #a51d36;
    background: #fff0f2;
}

label {
    display: block;
    font-weight: 650;
    margin: 16px 0 8px;
    font-size: 14px;
}

.input-wrap {
    position: relative;
}

input {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #ded7ed;
    border-radius: 11px;
    background: white;
    color: #29204c;
    font-size: 15px;
    outline: none;
    transition: border-color .2s, box-shadow .2s;
}

.input-wrap input {
    padding-right: 60px;
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

.hint {
    display: block;
    color: #827990;
    font-size: 12px;
    margin-top: 7px;
}

.create-btn {
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
    box-shadow: 0 7px 18px rgba(143,64,176,.2);
    transition: transform .2s, box-shadow .2s;
}

.create-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 23px rgba(143,64,176,.3);
}

.bottom {
    text-align: center;
    margin-top: 22px;
    font-size: 14px;
    color: #716981;
    line-height: 1.8;
}

a {
    color: #c52c87;
    text-decoration: none;
    font-weight: 650;
}

a:hover {
    text-decoration: underline;
}

.footer-note {
    margin-top: 20px;
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
        gap: 20px;
    }

    .brand {
        text-align: center;
        padding: 5px;
    }

    .description {
        margin: auto;
    }

    .features {
        justify-content: center;
        margin-top: 18px;
    }

    .brand h1 {
        font-size: 38px;
    }

    .tagline {
        font-size: 17px;
    }

    .card {
        padding: 27px 22px;
    }
}
</style>
</head>

<body>
<div class="container">

    <section class="brand">
        <h1>Student<span>Sphere</span></h1>
        <p class="tagline">Your journey starts here.</p>

        <p class="description">
            Create your account and bring your student life together.
            Organise study tasks, track expenses, explore campus events
            and work towards your goals in one place.
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
        <p class="subtitle">Create your student account</p>

        <% if ("empty".equals(request.getParameter("error"))) { %>
            <p class="message" role="alert">
                Please fill in all fields.
            </p>
        <% } else if ("duplicate".equals(
                request.getParameter("error"))) { %>
            <p class="message" role="alert">
                This email is already registered. Please log in.
            </p>
        <% } %>

        <form action="<%= request.getContextPath() %>/register"
              method="post" id="registerForm">

            <label for="name">Full Name</label>
            <input type="text"
                   id="name"
                   name="name"
                   maxlength="100"
                   autocomplete="name"
                   placeholder="Enter your full name"
                   required>

            <label for="email">Email Address</label>
            <input type="email"
                   id="email"
                   name="email"
                   maxlength="150"
                   autocomplete="email"
                   placeholder="Enter your email address"
                   required>

            <label for="password">Password</label>
            <div class="input-wrap">
                <input type="password"
                       id="password"
                       name="password"
                       minlength="8"
                       autocomplete="new-password"
                       placeholder="Create a password"
                       required>

                <button type="button"
                        class="show-password"
                        id="togglePassword"
                        aria-label="Show password"
                        aria-pressed="false">
                    Show
                </button>
            </div>

            <small class="hint">
                Use at least 8 characters.
            </small>

            <label for="confirmPassword">Confirm Password</label>
            <div class="input-wrap">
                <input type="password"
                       id="confirmPassword"
                       name="confirmPassword"
                       minlength="8"
                       autocomplete="new-password"
                       placeholder="Re-enter your password"
                       required>

                <button type="button"
                        class="show-password"
                        id="toggleConfirm"
                        aria-label="Show confirm password"
                        aria-pressed="false">
                    Show
                </button>
            </div>

            <button type="submit" class="create-btn">
                Create Account &rarr;
            </button>
        </form>

        <p class="bottom">
            Already registered?
            <a href="<%= request.getContextPath() %>/login.jsp">
                Login here
            </a>
        </p>

        <div class="footer-note">
            ✨ Better Students. Brighter Tomorrows.
        </div>
    </main>
</div>

<script>
const password = document.getElementById("password");
const confirmPassword = document.getElementById("confirmPassword");
const registerForm = document.getElementById("registerForm");

function setupPasswordToggle(input, button) {
    button.addEventListener("click", function () {
        const show = input.type === "password";
        input.type = show ? "text" : "password";
        button.textContent = show ? "Hide" : "Show";
        button.setAttribute("aria-pressed", String(show));
        button.setAttribute(
            "aria-label",
            show ? "Hide password" : "Show password"
        );
    });
}

setupPasswordToggle(
    password,
    document.getElementById("togglePassword")
);

setupPasswordToggle(
    confirmPassword,
    document.getElementById("toggleConfirm")
);

registerForm.addEventListener("submit", function (event) {
    if (password.value !== confirmPassword.value) {
        event.preventDefault();
        confirmPassword.setCustomValidity("Passwords do not match.");
        confirmPassword.reportValidity();
    } else {
        confirmPassword.setCustomValidity("");
    }
});

confirmPassword.addEventListener("input", function () {
    confirmPassword.setCustomValidity("");
});
</script>
</body>
</html>
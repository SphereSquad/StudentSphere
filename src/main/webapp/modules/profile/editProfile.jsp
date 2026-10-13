
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");

    if (userName == null) userName = "Student";
    if (userEmail == null) userEmail = "Not available";

    String safeName = userName.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    String safeEmail = userEmail.replace("&", "&amp;").replace("<", "&lt;")
        .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Profile | StudentSphere</title>
<style>
* { box-sizing: border-box; }
body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: #292052;
    background: linear-gradient(135deg, #f3edff, #fff0f8, #eeeaff);
    min-height: 100vh;
}
header {
    padding: 20px 6%;
    background: rgba(255,255,255,.85);
    border-bottom: 1px solid #e8defb;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
}
.brand { color: #7254e8; font-size: 23px; font-weight: 800; }
header a { text-decoration: none; color: #6045c4; font-weight: 600; }
.container { max-width: 720px; margin: 38px auto; padding: 0 18px 35px; }
.card {
    background: rgba(255,255,255,.95);
    border: 1px solid #e9e0fc;
    border-radius: 24px;
    padding: 32px;
    box-shadow: 0 14px 38px #5b42a716;
}
.banner {
    background: linear-gradient(115deg, #7054e7, #aa85f5, #f0b2dc);
    height: 115px;
    border-radius: 17px;
    margin-bottom: -50px;
}
.avatar {
    width: 105px;
    height: 105px;
    margin-left: 22px;
    position: relative;
    display: grid;
    place-items: center;
    border: 5px solid white;
    border-radius: 50%;
    background: #f0e7ff;
    color: #7054e7;
    font-size: 40px;
    font-weight: 800;
}
h1 { font-size: 26px; margin: 18px 0 5px; }
.subtitle { color: #81799e; margin-bottom: 25px; }
.notice {
    padding: 13px;
    background: #f6f1ff;
    border-radius: 12px;
    color: #6752ad;
    font-size: 14px;
    line-height: 1.6;
}
label { display: block; margin: 19px 0 8px; font-weight: 650; }
input {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #ded5f5;
    border-radius: 11px;
    background: #fcfbff;
    font-size: 15px;
    color: #292052;
}
input:focus { outline: 2px solid #c4b5fd; }
input[readonly] { background: #f0edf7; color: #827b9a; }
button, .cancel {
    border: none;
    border-radius: 11px;
    padding: 13px 19px;
    margin-top: 23px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
}
button {
    color: white;
    background: linear-gradient(110deg, #7554e8, #a36ee9);
}
.cancel { color: #634cb9; background: #f2edff; margin-left: 8px; }
@media(max-width: 500px) {
    .card { padding: 20px; }
    header { padding: 17px; }
}
</style>
</head>
<body>
<header>
    <a class="brand" href="<%= request.getContextPath() %>/dashboard.jsp">🎓 StudentSphere</a>
    <a href="<%= request.getContextPath() %>/modules/profile/profile.jsp">← My Profile</a>
</header>

<main class="container">
    <section class="card">
        <div class="banner"></div>
        <div class="avatar"><%= safeName.trim().isEmpty() ? "S" : safeName.substring(0,1).toUpperCase() %></div>

        <h1>Edit Your Profile ✨</h1>
        <p class="subtitle">Keep your StudentSphere information up to date.</p>

        <div class="notice">
            💜 You can update your name below. Your email address is read-only because it is linked to your account.
        </div>

        <form action="<%= request.getContextPath() %>/profile" method="post">
            <label for="name">Full Name</label>
            <input type="text" id="name" name="name"
                   value="<%= safeName %>" maxlength="100"
                   autocomplete="name" required>

            <label for="email">Email Address</label>
            <input type="email" id="email" value="<%= safeEmail %>" readonly>

            <button type="submit">💾 Save Changes</button>
            <a class="cancel" href="<%= request.getContextPath() %>/modules/profile/profile.jsp">Cancel</a>
        </form>
    </section>
</main>
</body>
</html>

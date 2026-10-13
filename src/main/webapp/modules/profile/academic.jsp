
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet" %>
<%@ page import="com.studentsphere.common.DMConnection" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = ((Number) session.getAttribute("userId")).intValue();

    String branch = "";
    String semester = "";
    String cgpa = "";
    String attendance = "";

    try (Connection con = DMConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT branch, semester, cgpa, attendance FROM student_academics WHERE user_id = ?")) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                branch = rs.getString("branch");
                semester = rs.getString("semester");
                cgpa = rs.getString("cgpa");
                attendance = rs.getString("attendance");

                if (branch == null) branch = "";
                if (semester == null) semester = "";
                if (cgpa == null) cgpa = "";
                if (attendance == null) attendance = "";
            }
        }
    } catch (Exception e) {
        throw new jakarta.servlet.ServletException(
            "Unable to load academic details.", e);
    }

    String updated = request.getParameter("updated");
    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Academic Details | StudentSphere</title>

<style>
* { box-sizing:border-box; }

body {
    margin:0;
    font-family:"Segoe UI",Arial,sans-serif;
    color:#29234f;
    background:linear-gradient(135deg,#f5edff,#fff2f9,#eceaff);
    min-height:100vh;
}

header {
    padding:20px 6%;
    background:white;
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:12px;
    box-shadow:0 3px 18px #49358c10;
}

header h2 { margin:0; color:#7254e8; }

header a {
    color:#7254e8;
    text-decoration:none;
    font-weight:600;
}

.container {
    max-width:750px;
    margin:40px auto;
    padding:0 18px;
}

.card {
    background:white;
    border:1px solid #ebe5fb;
    border-radius:22px;
    padding:30px;
    box-shadow:0 12px 35px #49358c12;
}

h1 { margin:0 0 8px; font-size:28px; }

.subtitle {
    color:#777493;
    margin:0 0 25px;
    line-height:1.6;
}

label {
    display:block;
    font-weight:600;
    margin:18px 0 8px;
}

input, select {
    width:100%;
    padding:13px;
    border:1px solid #ded6f4;
    border-radius:11px;
    font-size:15px;
    color:#29234f;
    background:#fdfcff;
}

input:focus, select:focus {
    outline:2px solid #c5b7ff;
    border-color:#7254e8;
}

.hint {
    font-size:12px;
    color:#777493;
    margin-top:7px;
}

button {
    width:100%;
    padding:14px;
    margin-top:25px;
    border:0;
    border-radius:11px;
    color:white;
    background:linear-gradient(110deg,#7254e8,#a06be9);
    font-size:16px;
    font-weight:700;
    cursor:pointer;
}

button:hover { opacity:.92; }

.message {
    padding:13px;
    margin:18px 0;
    border-radius:10px;
}

.success { background:#e5f9ed; color:#167443; }
.error { background:#fff0f0; color:#b42332; }

@media(max-width:500px) {
    .card { padding:21px; }
    header { padding:17px; }
    h1 { font-size:24px; }
}
</style>
</head>

<body>

<header>
    <h2>🎓 StudentSphere</h2>
    <a href="<%= request.getContextPath() %>/modules/profile/profile.jsp">
        ← Back to Profile
    </a>
</header>

<div class="container">
    <div class="card">

        <h1>🎓 Academic Details</h1>
        <p class="subtitle">
            Keep your academic information updated in your StudentSphere profile.
        </p>

        <% if ("1".equals(updated)) { %>
            <div class="message success">
                Academic details saved successfully! 💜
            </div>
        <% } %>

        <% if (error != null) { %>
            <div class="message error">
                <% if ("empty".equals(error)) { %>
                    Please enter your branch and semester.
                <% } else { %>
                    Invalid details. Semester must be 1–12,
                    CGPA must be 0–10, and attendance must be 0–100.
                <% } %>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/academic-profile"
              method="post">

            <label for="branch">Branch / Course</label>
            <input type="text" id="branch" name="branch"
                   value="<%= branch.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;") %>"
                   maxlength="100"
                   placeholder="e.g. B.Tech AI & Data Science"
                   required>

            <label for="semester">Current Semester</label>
            <select id="semester" name="semester" required>
                <option value="">Select semester</option>
                <% for (int i = 1; i <= 12; i++) { %>
                    <option value="<%= i %>"
                        <%= String.valueOf(i).equals(semester) ? "selected" : "" %>>
                        Semester <%= i %>
                    </option>
                <% } %>
            </select>

            <label for="cgpa">Current CGPA (out of 10)</label>
            <input type="number" id="cgpa" name="cgpa"
                   min="0" max="10" step="0.01"
                   value="<%= cgpa %>"
                   placeholder="Enter actual CGPA">

            <p class="hint">Leave blank if your CGPA is not available yet.</p>

            <label for="attendance">Attendance Percentage</label>
            <input type="number" id="attendance" name="attendance"
                   min="0" max="100" step="0.01"
                   value="<%= attendance %>"
                   placeholder="Enter actual attendance">

            <p class="hint">Enter your actual attendance percentage.</p>

            <button type="submit">💾 Save Academic Details</button>

        </form>
    </div>
</div>

</body>
</html>

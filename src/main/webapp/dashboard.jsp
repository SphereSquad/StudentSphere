//
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.studentsphere.common.DMConnection" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        userName = "Student";
    }

    String ctx = request.getContextPath();
    int userId = ((Number) session.getAttribute("userId")).intValue();

    String branch = "Not added yet";
    String semester = "Not added yet";
    String cgpa = "Not added yet";
    String attendance = "Not added yet";

    double cgpaValue = -1;
    double attendanceValue = -1;

    try (Connection con = DMConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT branch, semester, cgpa, attendance FROM student_academics WHERE user_id = ?")) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                if (rs.getString("branch") != null) {
                    branch = rs.getString("branch");
                }

                int sem = rs.getInt("semester");
                if (!rs.wasNull()) {
                    semester = String.valueOf(sem);
                }

                BigDecimal c = rs.getBigDecimal("cgpa");
                if (c != null) {
                    cgpaValue = c.doubleValue();
                    cgpa = c.toPlainString() + " / 10";
                }

                BigDecimal a = rs.getBigDecimal("attendance");
                if (a != null) {
                    attendanceValue = a.doubleValue();
                    attendance = a.toPlainString() + "%";
                }
            }
        }
    } catch (Exception e) {
        application.log("Unable to load dashboard academic details", e);
    }

    String safeName = userName.replace("&", "&amp;")
        .replace("<", "&lt;").replace(">", "&gt;")
        .replace("\"", "&quot;").replace("'", "&#39;");

    String safeBranch = branch.replace("&", "&amp;")
        .replace("<", "&lt;").replace(">", "&gt;")
        .replace("\"", "&quot;").replace("'", "&#39;");

    String cgpaWidth = cgpaValue >= 0
        ? String.valueOf(Math.min(100, cgpaValue * 10)) : "0";

    String attendanceWidth = attendanceValue >= 0
        ? String.valueOf(Math.min(100, attendanceValue)) : "0";
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Dashboard</title>

<link rel="stylesheet"
      href="<%= ctx %>/css/theme.css">

<style>
* {
    box-sizing: border-box;
}

:root {
    --bg: #f5f4fc;
    --card: #ffffff;
    --text: #272344;
    --muted: #77758f;
    --border: #e9e6f5;
    --accent: #7058ee;
    --soft: #efebff;
}

body.dark {
    --bg: #111323;
    --card: #1d2035;
    --text: #f3f0ff;
    --muted: #b8b5d0;
    --border: #373750;
    --accent: #a494ff;
    --soft: #302b4b;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background:
        radial-gradient(ellipse at 85% 0%, #eee7ff, transparent 30%),
        var(--bg);
    color: var(--text);
    transition: background .25s, color .25s;
}

body.dark {
    background:
        radial-gradient(ellipse at 85% 0%, #292345, transparent 30%),
        var(--bg);
}

.layout {
    display: flex;
    min-height: 100vh;
}

.sidebar {
    width: 248px;
    flex-shrink: 0;
    background: linear-gradient(180deg, #29264b, #37305f);
    color: white;
    padding: 28px 18px;
    display: flex;
    flex-direction: column;
}

.brand {
    font-size: 23px;
    font-weight: 800;
    letter-spacing: -.5px;
    margin: 0 0 38px 8px;
    color: white;
}

.brand span {
    color: #cbbfff;
}

.nav-title {
    color: #aaa6cb;
    font-size: 10px;
    font-weight: 800;
    letter-spacing: 1.7px;
    margin: 0 8px 12px;
}

.nav-link {
    display: flex;
    align-items: center;
    gap: 10px;
    text-decoration: none;
    color: #e8e5fa;
    padding: 13px 12px;
    margin: 4px 0;
    border-radius: 11px;
    font-size: 13px;
    transition: .2s;
}

.nav-link:hover,
.nav-link.active {
    background: rgba(255,255,255,.15);
    color: white;
    transform: translateX(2px);
}

.sidebar-bottom {
    margin-top: auto;
    padding-top: 30px;
}

.main {
    flex: 1;
    min-width: 0;
    padding: 30px clamp(18px, 3vw, 42px);
}

.topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 25px;
}

.topbar h2 {
    margin: 0;
    font-size: 25px;
    letter-spacing: -.5px;
}

.topbar p {
    margin: 6px 0 0;
    color: var(--muted);
    font-size: 13px;
}

.top-actions {
    display: flex;
    align-items: center;
    gap: 10px;
    flex-wrap: wrap;
}

.profile {
    background: var(--card);
    border: 1px solid var(--border);
    padding: 10px 14px;
    border-radius: 13px;
    font-size: 13px;
    box-shadow: 0 5px 18px #29264b08;
}

.profile a {
    color: var(--accent);
    text-decoration: none;
    font-weight: 700;
}

.theme-toggle {
    border: 1px solid var(--border);
    background: var(--card);
    color: var(--text);
    padding: 10px 13px;
    border-radius: 12px;
    cursor: pointer;
    font-weight: 700;
    font-size: 12px;
}

.theme-toggle:hover {
    border-color: var(--accent);
}

.welcome {
    position: relative;
    overflow: hidden;
    background: linear-gradient(115deg, #5d4cc2, #8b78ec 72%, #ad9df5);
    border-radius: 22px;
    padding: 32px;
    color: white;
    margin-bottom: 26px;
    box-shadow: 0 15px 35px #6552c526;
}

.welcome:after {
    content: "✦";
    position: absolute;
    font-size: 150px;
    right: 34px;
    top: -38px;
    color: #ffffff19;
}

.eyebrow {
    font-size: 11px;
    font-weight: 800;
    letter-spacing: 1.7px;
    text-transform: uppercase;
    color: #e8e2ff;
    margin-bottom: 12px;
}

.welcome h1 {
    position: relative;
    z-index: 1;
    font-size: clamp(24px, 3vw, 34px);
    margin: 0 0 10px;
    letter-spacing: -.7px;
}

.welcome p {
    position: relative;
    z-index: 1;
    margin: 0;
    max-width: 620px;
    line-height: 1.7;
    color: #f0edff;
    font-size: 14px;
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin: 28px 0 15px;
}

.section-heading h3 {
    margin: 0;
    font-size: 18px;
}

.section-heading span {
    font-size: 12px;
    color: var(--muted);
}

.academic-panel {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 19px;
    padding: 23px;
    margin-bottom: 27px;
    box-shadow: 0 9px 28px #29264b09;
}

.academic-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 18px;
}

.academic-header h3 {
    margin: 0;
    font-size: 18px;
}

.edit-button {
    display: inline-block;
    padding: 10px 13px;
    background: var(--soft);
    color: var(--accent);
    text-decoration: none;
    border-radius: 10px;
    font-size: 12px;
    font-weight: 800;
}

.academic-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 12px;
}

.academic-item {
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 16px;
    min-width: 0;
}

.academic-item .icon {
    font-size: 22px;
    margin-bottom: 12px;
}

.academic-item .label {
    font-size: 11px;
    color: var(--muted);
    margin-bottom: 7px;
}

.academic-item .value {
    font-size: 16px;
    font-weight: 800;
    overflow-wrap: anywhere;
}

.progress-area {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 14px;
    margin-top: 17px;
}

.progress-card {
    background: var(--bg);
    border: 1px solid var(--border);
    padding: 16px;
    border-radius: 13px;
}

.progress-top {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 11px;
    font-size: 12px;
}

.progress-top strong {
    color: var(--accent);
}

.progress-track {
    height: 8px;
    background: var(--border);
    border-radius: 20px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    border-radius: 20px;
    background: linear-gradient(90deg, #7254e8, #b28aef);
}

.progress-fill.pink {
    background: linear-gradient(90deg, #db69b2, #f1a5d3);
}

.academic-note {
    font-size: 11px;
    color: var(--muted);
    margin: 14px 0 0;
    line-height: 1.6;
}

.modules {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 16px;
}

.module {
    display: block;
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 17px;
    padding: 21px;
    text-decoration: none;
    color: var(--text);
    transition: transform .2s, box-shadow .2s, border-color .2s;
    min-height: 190px;
}

.module:hover {
    transform: translateY(-4px);
    box-shadow: 0 14px 30px #29264b12;
    border-color: #c9bfff;
}

.module-icon {
    width: 48px;
    height: 48px;
    display: grid;
    place-items: center;
    border-radius: 14px;
    font-size: 23px;
    margin-bottom: 16px;
}

.purple { background: #eeeaff; }
.pink { background: #ffeaf3; }
.blue { background: #e7f2ff; }
.green { background: #e5f8ed; }
.orange { background: #fff0df; }
.yellow { background: #fff7d9; }

.module h4 {
    margin: 0 0 8px;
    font-size: 15px;
}

.module p {
    margin: 0;
    color: var(--muted);
    font-size: 12px;
    line-height: 1.65;
}

.open-label {
    display: inline-block;
    color: var(--accent);
    font-size: 12px;
    font-weight: 800;
    margin-top: 15px;
}

.notice {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 15px;
    padding: 18px;
    color: var(--muted);
    line-height: 1.7;
    font-size: 13px;
}

.footer {
    text-align: center;
    color: var(--muted);
    font-size: 11px;
    padding: 27px 0 5px;
}

@media(max-width:1100px) {
    .modules {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
    .academic-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media(max-width:800px) {
    .sidebar { width: 205px; }
    .main { padding: 22px 18px; }
}

@media(max-width:620px) {
    .layout { display: block; }
    .sidebar { width: 100%; padding: 18px; }
    .brand { margin-bottom: 18px; }
    .sidebar-bottom { margin-top: 10px; padding-top: 0; }
    .main { padding: 18px 14px; }
    .topbar { align-items: flex-start; flex-direction: column; }
    .modules, .progress-area { grid-template-columns: 1fr; }
    .welcome { padding: 24px; }
    .academic-panel { padding: 16px; }
    .academic-header { align-items: flex-start; flex-direction: column; }
    .section-heading { align-items: flex-start; flex-direction: column; }
}
</style>
</head>

<body>
<div class="layout">

    <aside class="sidebar">
        <div class="brand">Student<span>Sphere</span></div>
        <div class="nav-title">YOUR WORKSPACE</div>

        <a class="nav-link active" href="<%= ctx %>/dashboard.jsp">⌂ <span>Dashboard</span></a>
        <a class="nav-link" href="<%= ctx %>/studyplanner">▣ <span>Study Planner</span></a>
        <a class="nav-link" href="<%= ctx %>/expensetracker">₹ <span>Expense Tracker</span></a>
        <a class="nav-link" href="<%= ctx %>/events">✦ <span>Campus Events</span></a>
        <a class="nav-link" href="<%= ctx %>/clubs">♧ <span>Clubs &amp; Community</span></a>
        <a class="nav-link" href="<%= ctx %>/goals">🎯 <span>Personal Goals</span></a>

        <div class="sidebar-bottom">
            <a class="nav-link" href="<%= ctx %>/logout">↪ <span>Logout</span></a>
        </div>
    </aside>

    <main class="main">

        <div class="topbar">
            <div>
                <h2>Dashboard</h2>
                <p>Your personal student workspace</p>
            </div>

            <div class="top-actions">
                <button type="button" class="theme-toggle"
                        id="themeToggle"
                        onclick="toggleStudentSphereTheme()">
                    🌙 Dark Mode
                </button>

                <div class="profile">
                    👋 <%= safeName %> &nbsp;|&nbsp;
                    <a href="<%= ctx %>/modules/profile/profile.jsp">My Profile ↗</a>
                </div>
            </div>
        </div>

        <section class="welcome">
            <div class="eyebrow">Your campus · Your goals · Your growth</div>
            <h1>Welcome back, <%= safeName %>! ✨</h1>
            <p>
                Bring your student life together in one place. Organize your studies,
                keep an eye on your academic progress, manage your budget and discover
                campus opportunities.
            </p>
        </section>

        <section class="academic-panel">
            <div class="academic-header">
                <h3>🎓 Academic Overview</h3>
                <a class="edit-button"
                   href="<%= ctx %>/modules/profile/academic.jsp">
                    ✏️ Edit Academic Details
                </a>
            </div>

            <div class="academic-grid">
                <div class="academic-item">
                    <div class="icon">📚</div>
                    <div class="label">Branch / Course</div>
                    <div class="value"><%= safeBranch %></div>
                </div>

                <div class="academic-item">
                    <div class="icon">🎓</div>
                    <div class="label">Current Semester</div>
                    <div class="value"><%= semester %></div>
                </div>

                <div class="academic-item">
                    <div class="icon">🏆</div>
                    <div class="label">Current CGPA</div>
                    <div class="value"><%= cgpa %></div>
                </div>

                <div class="academic-item">
                    <div class="icon">📅</div>
                    <div class="label">Attendance</div>
                    <div class="value"><%= attendance %></div>
                </div>
            </div>

            <div class="progress-area">
                <div class="progress-card">
                    <div class="progress-top">
                        <span>CGPA Progress</span>
                        <strong>
                            <% if (cgpaValue >= 0) { %>
                                <%= String.format(java.util.Locale.US, "%.1f", cgpaValue * 10) %>%
                            <% } else { %>
                                Not added
                            <% } %>
                        </strong>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill" style="width:<%= cgpaWidth %>%"></div>
                    </div>
                </div>

                <div class="progress-card">
                    <div class="progress-top">
                        <span>Attendance</span>
                        <strong>
                            <% if (attendanceValue >= 0) { %>
                                <%= attendance %>
                            <% } else { %>
                                Not added
                            <% } %>
                        </strong>
                    </div>
                    <div class="progress-track">
                        <div class="progress-fill pink" style="width:<%= attendanceWidth %>%"></div>
                    </div>
                </div>
            </div>

            <p class="academic-note">
                These values come from your saved academic details.
                Update them anytime using Edit Academic Details.
            </p>
        </section>

        <div class="section-heading">
            <h3>Your Workspace</h3>
            <span>Choose a module to get started</span>
        </div>

        <section class="modules">

            <a class="module" href="<%= ctx %>/studyplanner">
                <div class="module-icon purple">📚</div>
                <h4>Study Planner</h4>
                <p>Organize assignments, plan study sessions and keep track of deadlines.</p>
                <span class="open-label">Open module →</span>
            </a>

            <a class="module" href="<%= ctx %>/expensetracker">
                <div class="module-icon pink">💰</div>
                <h4>Expense Tracker</h4>
                <p>Record daily spending, set monthly budgets and understand your expenses.</p>
                <span class="open-label">Open module →</span>
            </a>

            <a class="module" href="<%= ctx %>/events">
                <div class="module-icon blue">🎓</div>
                <h4>Campus Events</h4>
                <p>Explore hackathons, seminars, workshops and student opportunities.</p>
                <span class="open-label">Open module →</span>
            </a>

            <a class="module" href="<%= ctx %>/clubs">
                <div class="module-icon green">🤝</div>
                <h4>Clubs &amp; Community</h4>
                <p>Discover clubs, student communities and their announcements.</p>
                <span class="open-label">Open module →</span>
            </a>

            <a class="module" href="<%= ctx %>/goals">
                <div class="module-icon orange">🎯</div>
                <h4>Personal Goals</h4>
                <p>Set goals and track your progress throughout the semester.</p>
                <span class="open-label">Open module →</span>
            </a>

            <a class="module" href="<%= ctx %>/modules/profile/profile.jsp">
                <div class="module-icon yellow">👤</div>
                <h4>My Profile</h4>
                <p>Manage your account, academic details and student profile.</p>
                <span class="open-label">Open module →</span>
            </a>

        </section>

        <div class="section-heading">
            <h3>Quick Note</h3>
        </div>

        <div class="notice">
            Your dashboard is your personal space. Your academic overview displays
            the information you have saved. Explore the modules to manage your studies,
            spending, goals and campus activities.
        </div>

        <div class="footer">
            StudentSphere · Your campus, organized your way 💜
        </div>

    </main>
</div>

<script src="<%= ctx %>/js/theme.js"></script>
<script>
(function () {
    const key = "studentsphere-theme";
    const button = document.getElementById("themeToggle");

    function applyTheme() {
        let theme = "light";
        try {
            theme = localStorage.getItem(key) || "light";
        } catch (e) {}

        document.body.classList.toggle("dark", theme === "dark");

        if (button) {
            button.textContent = theme === "dark"
                ? "☀️ Light Mode" : "🌙 Dark Mode";
        }
    }

    window.toggleStudentSphereTheme = function () {
        const dark = !document.body.classList.contains("dark");
        try {
            localStorage.setItem(key, dark ? "dark" : "light");
        } catch (e) {}
        applyTheme();
    };

    applyTheme();
})();
</script>
</body>
</html>


<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
             "SELECT branch, semester, cgpa, attendance " +
             "FROM student_academics WHERE user_id = ?")) {

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

<style>
* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: #f6f7fc;
    color: #252542;
}

.layout {
    display: flex;
    min-height: 100vh;
}

.sidebar {
    width: 245px;
    flex-shrink: 0;
    background: #29264b;
    color: white;
    padding: 28px 18px;
    display: flex;
    flex-direction: column;
}

.brand {
    font-size: 23px;
    font-weight: 750;
    margin: 0 0 38px 8px;
}

.brand span {
    color: #c7b9ff;
}

.nav-title {
    color: #aaa6cb;
    font-size: 11px;
    letter-spacing: 1.5px;
    margin: 0 8px 12px;
}

.nav-link {
    display: block;
    text-decoration: none;
    color: #e4e1f4;
    padding: 13px 12px;
    margin: 4px 0;
    border-radius: 9px;
    font-size: 14px;
}

.nav-link.active,
.nav-link:hover {
    background: #514b7d;
    color: white;
}

.sidebar-bottom {
    margin-top: auto;
    padding-top: 35px;
}

.main {
    flex: 1;
    min-width: 0;
    padding: 30px 36px;
}

.topbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 28px;
}

.topbar h2 {
    margin: 0;
    font-size: 24px;
}

.topbar p {
    margin: 7px 0 0;
    color: #77758d;
    font-size: 14px;
}

.profile {
    background: white;
    padding: 10px 16px;
    border-radius: 12px;
    font-size: 14px;
    box-shadow: 0 3px 15px #26234b08;
}

.profile a {
    color: #6558c9;
    text-decoration: none;
    font-weight: 600;
}

.welcome {
    background: linear-gradient(115deg, #6658c9, #9685e8);
    border-radius: 18px;
    padding: 30px;
    color: white;
    margin-bottom: 27px;
}

.welcome h1 {
    font-size: 27px;
    margin: 0 0 10px;
}

.welcome p {
    margin: 0;
    line-height: 1.7;
    color: #f0edff;
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin: 28px 0 16px;
}

.section-heading h3 {
    margin: 0;
    font-size: 19px;
}

.section-heading span {
    font-size: 13px;
    color: #85829b;
}

.academic-panel {
    background: linear-gradient(135deg, #ffffff, #faf7ff);
    border: 1px solid #e9e3fb;
    border-radius: 18px;
    padding: 24px;
    margin-bottom: 28px;
    box-shadow: 0 7px 22px #29264b08;
}

.academic-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
}

.academic-header h3 {
    margin: 0;
    font-size: 19px;
}

.edit-button {
    display: inline-block;
    padding: 10px 14px;
    background: #eeeaff;
    color: #6550c7;
    text-decoration: none;
    border-radius: 10px;
    font-size: 13px;
    font-weight: 700;
}

.edit-button:hover {
    background: #e1d9ff;
}

.academic-grid {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 13px;
}

.academic-item {
    background: white;
    border: 1px solid #eeebf8;
    border-radius: 13px;
    padding: 17px 15px;
    min-width: 0;
}

.academic-item .icon {
    font-size: 22px;
    margin-bottom: 12px;
}

.academic-item .label {
    font-size: 12px;
    color: #85829b;
    margin-bottom: 7px;
}

.academic-item .value {
    font-size: 18px;
    font-weight: 750;
    color: #332963;
    overflow-wrap: anywhere;
}

.progress-area {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
    margin-top: 20px;
}

.progress-card {
    background: white;
    border: 1px solid #eeebf8;
    padding: 17px;
    border-radius: 13px;
}

.progress-top {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    margin-bottom: 12px;
    font-size: 13px;
}

.progress-top strong {
    color: #5141a5;
}

.progress-track {
    height: 9px;
    background: #efedf6;
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
    font-size: 12px;
    color: #85829b;
    margin: 16px 0 0;
    line-height: 1.6;
}

.modules {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
}

.module {
    background: white;
    border: 1px solid #eeedf6;
    border-radius: 15px;
    padding: 23px;
    text-decoration: none;
    color: inherit;
    transition: transform .2s, box-shadow .2s;
}

.module:hover {
    transform: translateY(-3px);
    box-shadow: 0 10px 25px #29264b12;
}

.module-icon {
    width: 47px;
    height: 47px;
    display: grid;
    place-items: center;
    border-radius: 13px;
    font-size: 23px;
    margin-bottom: 15px;
}

.purple { background: #eeeaff; }
.pink { background: #ffeaf3; }
.blue { background: #e7f2ff; }
.green { background: #e5f8ed; }
.orange { background: #fff0df; }
.yellow { background: #fff7d9; }

.module h4 {
    margin: 0 0 9px;
    font-size: 17px;
}

.module p {
    margin: 0;
    color: #7d7a92;
    font-size: 13px;
    line-height: 1.6;
}

.open-label {
    display: inline-block;
    color: #6558c9;
    font-size: 13px;
    font-weight: 650;
    margin-top: 17px;
}

.notice {
    background: white;
    border: 1px solid #eeedf6;
    border-radius: 14px;
    padding: 20px;
    color: #77758d;
    line-height: 1.6;
    font-size: 14px;
}

.footer {
    text-align: center;
    color: #9693a8;
    font-size: 12px;
    padding: 28px 0 5px;
}

@media(max-width: 1050px) {
    .academic-grid {
        grid-template-columns: repeat(2, minmax(0, 1fr));
    }
}

@media(max-width: 850px) {
    .sidebar { width: 190px; }
    .main { padding: 22px; }
}

@media(max-width: 600px) {
    .layout { display: block; }
    .sidebar { width: 100%; padding: 18px; }
    .brand { margin-bottom: 18px; }
    .sidebar-bottom { margin-top: 10px; padding-top: 0; }
    .main { padding: 18px; }
    .modules, .progress-area { grid-template-columns: 1fr; }
    .topbar { align-items: flex-start; flex-direction: column; }
    .welcome h1 { font-size: 23px; }
    .academic-panel { padding: 17px; }
}
</style>
</head>

<body>
<div class="layout">

    <aside class="sidebar">
        <div class="brand">Student<span>Sphere</span></div>

        <div class="nav-title">WORKSPACE</div>

        <a class="nav-link active" href="<%= ctx %>/dashboard.jsp">⌂ &nbsp; Dashboard</a>
        <a class="nav-link" href="<%= ctx %>/studyplanner">▣ &nbsp; Study Planner</a>
        <a class="nav-link" href="<%= ctx %>/expensetracker">₹ &nbsp; Expense Tracker</a>
        <a class="nav-link" href="<%= ctx %>/events">✦ &nbsp; Campus Events</a>
        <a class="nav-link" href="<%= ctx %>/clubs">♧ &nbsp; Clubs &amp; Community</a>
        <a class="nav-link" href="<%= ctx %>/goals">🎯 &nbsp; Personal Goals</a>

        <div class="sidebar-bottom">
            <a class="nav-link" href="<%= ctx %>/logout">↪ &nbsp; Logout</a>
        </div>
    </aside>

    <main class="main">

        <div class="topbar">
            <div>
                <h2>Dashboard</h2>
                <p>Your personal student workspace</p>
            </div>
            <div class="profile">
                👋 <%= safeName %> &nbsp;|&nbsp;
                <a href="<%= ctx %>/modules/profile/profile.jsp">My Profile</a>
            </div>
        </div>

        <section class="welcome">
            <h1>Welcome back, <%= safeName %>! ✨</h1>
            <p>
                Organize your studies, manage your budget and discover
                opportunities—all in one place.
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
                Update them using the Edit Academic Details button.
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
                <span class="open-label">Explore module →</span>
            </a>

            <a class="module" href="<%= ctx %>/expensetracker">
                <div class="module-icon pink">💰</div>
                <h4>Expense Tracker</h4>
                <p>Record daily spending, set monthly budgets and understand your expenses.</p>
                <span class="open-label">Explore module →</span>
            </a>

            <a class="module" href="<%= ctx %>/events">
                <div class="module-icon blue">🎓</div>
                <h4>Campus Events</h4>
                <p>Explore hackathons, seminars, workshops and other student opportunities.</p>
                <span class="open-label">Explore module →</span>
            </a>

            <a class="module" href="<%= ctx %>/clubs">
                <div class="module-icon green">🤝</div>
                <h4>Clubs &amp; Community</h4>
                <p>Discover clubs, student communities and their announcements.</p>
                <span class="open-label">Explore module →</span>
            </a>

            <a class="module" href="<%= ctx %>/goals">
                <div class="module-icon orange">🎯</div>
                <h4>Personal Goals</h4>
                <p>Set your goals and track your progress throughout the semester.</p>
                <span class="open-label">Explore module →</span>
            </a>

            <a class="module" href="<%= ctx %>/modules/profile/profile.jsp">
                <div class="module-icon yellow">👤</div>
                <h4>My Profile</h4>
                <p>View your account, academic details and manage your student profile.</p>
                <span class="open-label">Explore module →</span>
            </a>

        </section>

        <div class="section-heading">
            <h3>Quick Note</h3>
        </div>

        <div class="notice">
            Your dashboard is your personal space. Your academic overview
            displays the information you have saved. Explore the modules to
            manage your studies, spending, goals and campus activities.
        </div>

        <div class="footer">
            StudentSphere · Your campus, organized your way.
        </div>

    </main>
</div>
</body>
</html>

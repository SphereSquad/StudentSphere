<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection,java.sql.PreparedStatement,java.sql.ResultSet,java.util.List,java.util.ArrayList" %>
<%@ page import="com.studentsphere.common.DMConnection" %>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");

    if (userName == null || userName.trim().isEmpty()) userName = "Student";
    if (userEmail == null) userEmail = "Not available";

    String updated = request.getParameter("updated");
    String error = request.getParameter("error");
    String initial = userName.trim().substring(0, 1).toUpperCase();

    String safeName = userName.replace("&", "&amp;")
        .replace("<", "&lt;").replace(">", "&gt;")
        .replace("\"", "&quot;").replace("'", "&#39;");

    String safeEmail = userEmail.replace("&", "&amp;")
        .replace("<", "&lt;").replace(">", "&gt;")
        .replace("\"", "&quot;").replace("'", "&#39;");

    String profilePhoto = (String) session.getAttribute("profilePhoto");

    int academicUserId =
        ((Number) session.getAttribute("userId")).intValue();

    String academicBranch = "Not added yet";
    String academicSemester = "Not added yet";
    String academicCgpa = "Not added yet";
    String academicAttendance = "Not added yet";

    try (Connection con = DMConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT branch, semester, cgpa, attendance " +
             "FROM student_academics WHERE user_id = ?")) {

        ps.setInt(1, academicUserId);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                if (rs.getString("branch") != null)
                    academicBranch = rs.getString("branch");

                int sem = rs.getInt("semester");
                if (!rs.wasNull())
                    academicSemester = String.valueOf(sem);

                java.math.BigDecimal c = rs.getBigDecimal("cgpa");
                if (c != null)
                    academicCgpa = c.toPlainString() + " / 10";

                java.math.BigDecimal a = rs.getBigDecimal("attendance");
                if (a != null)
                    academicAttendance = a.toPlainString() + "%";
            }
        }
    } catch (Exception e) {
        application.log("Unable to load academic details", e);
    }

    // Load only the skills saved for this logged-in student.
    List<String> savedSkills = new ArrayList<>();

    try (Connection con = DMConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT skill_name FROM student_skills WHERE user_id = ? ORDER BY id")) {

        ps.setInt(1, academicUserId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String skill = rs.getString("skill_name");

                if (skill != null && !skill.trim().isEmpty()) {
                    savedSkills.add(skill);
                }
            }
        }
    } catch (Exception e) {
        application.log("Unable to load saved student skills", e);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Profile | StudentSphere</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/theme.css">

<style>
:root {
    --purple: #7254e8;
    --dark: #382b79;
    --text: #29234f;
    --muted: #777493;
    --border: #ebe5fb;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: var(--text);
    min-height: 100vh;
    background:
        radial-gradient(ellipse at 8% 12%, #f5d9f4 0, transparent 32%),
        radial-gradient(ellipse at 92% 22%, #dcd4ff 0, transparent 34%),
        linear-gradient(135deg, #fbf8ff, #fff4fa 52%, #f1efff);
}

a {
    text-decoration: none;
    color: inherit;
}

.topbar {
    padding: 18px 5%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    background: rgba(255,255,255,.92);
    border-bottom: 1px solid var(--border);
}

.brand {
    font-size: 23px;
    font-weight: 800;
    color: var(--purple);
}

.top-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.top-actions a {
    padding: 10px 15px;
    background: #f5f1ff;
    border-radius: 12px;
    color: var(--dark);
    font-weight: 600;
}

.layout {
    max-width: 1120px;
    margin: 30px auto;
    padding: 0 20px 35px;
}

.hero {
    position: relative;
    overflow: hidden;
    border-radius: 25px;
    padding: 32px;
    color: white;
    background: linear-gradient(115deg, #6650db, #a18bff 53%, #eea9d8);
    box-shadow: 0 14px 34px #7358d52b;
}

.profile-head {
    position: relative;
    z-index: 1;
    display: flex;
    align-items: center;
    gap: 22px;
    flex-wrap: wrap;
}

.avatar-wrap {
    position: relative;
    flex-shrink: 0;
}

.avatar {
    width: 115px;
    height: 115px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 42px;
    font-weight: 800;
    background: white;
    color: var(--purple);
    border: 5px solid #ffffffd9;
    box-shadow: 0 5px 18px #32206435;
    overflow: hidden;
}

.avatar img,
.photo-preview img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.camera-link {
    position: absolute;
    right: -3px;
    bottom: 0;
    width: 38px;
    height: 38px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    background: white;
    color: var(--purple);
    border: 2px solid #e8ddff;
    font-size: 18px;
}

.profile-title {
    display: flex;
    align-items: center;
    gap: 11px;
    flex-wrap: wrap;
}

.hero h1 {
    margin: 0;
    font-size: clamp(25px, 4vw, 34px);
}

.hero p {
    margin: 7px 0;
    color: #f7f2ff;
    overflow-wrap: anywhere;
}

.edit-icon {
    width: 36px;
    height: 36px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    border-radius: 50%;
    background: white;
    color: var(--purple);
    border: 1px solid #e8ddff;
    font-size: 17px;
    box-shadow: 0 3px 10px #382b7925;
    transition: .2s;
}

.edit-icon:hover {
    transform: scale(1.08);
    background: #ffe6f6;
    color: #a72a91;
}

.pills {
    display: flex;
    flex-wrap: wrap;
    gap: 9px;
    margin-top: 14px;
}

.pill {
    border-radius: 20px;
    padding: 7px 13px;
    background: #ffffff28;
    border: 1px solid #ffffff45;
    font-size: 13px;
    font-weight: 600;
}

.quote {
    margin-left: auto;
    background: #ffffff25;
    border: 1px solid #ffffff45;
    border-radius: 16px;
    padding: 16px;
    max-width: 205px;
    line-height: 1.6;
}

.stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 15px;
    margin: 21px 0;
}

.stat,
.card {
    background: rgba(255,255,255,.96);
    border: 1px solid #eee8fb;
    border-radius: 19px;
    box-shadow: 0 7px 22px #4c38860c;
}

.stat {
    padding: 20px;
    text-align: center;
}

.stat strong {
    display: block;
    font-size: 25px;
    color: var(--dark);
}

.stat span {
    display: block;
    margin-top: 5px;
    color: var(--muted);
    font-size: 13px;
}

.columns {
    display: grid;
    grid-template-columns: minmax(0, 1.3fr) minmax(260px, .8fr);
    gap: 20px;
    align-items: start;
}

.card {
    padding: 24px;
    margin-bottom: 19px;
}

.card-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 18px;
}

.card-heading h2 {
    margin: 0;
    font-size: 19px;
}

.detail {
    padding: 14px;
    margin: 10px 0;
    border-radius: 12px;
    background: #faf8ff;
    border: 1px solid #f0ebfc;
    overflow-wrap: anywhere;
}

.detail small {
    display: block;
    color: var(--muted);
    margin-bottom: 6px;
}

.detail strong {
    font-size: 15px;
}

.btn {
    display: inline-block;
    border: 0;
    border-radius: 11px;
    padding: 12px 16px;
    cursor: pointer;
    font: inherit;
    font-weight: 700;
    background: linear-gradient(110deg, #7955ed, #a06be9);
    color: white;
}

.btn-light {
    background: #f5efff;
    color: var(--dark);
}

.btn-pink {
    background: #ffe6f4;
    color: #a72a91;
}

.message {
    padding: 12px 14px;
    border-radius: 11px;
    margin-bottom: 15px;
}

.success {
    background: #e5f9ed;
    color: #167443;
}

.error {
    background: #fff0f0;
    color: #b42332;
}

.about {
    line-height: 1.8;
    color: #66617f;
    margin: 0;
}

.skills {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.skill {
    padding: 8px 12px;
    border-radius: 20px;
    background: #f1ebff;
    color: #6747cb;
    font-size: 13px;
    border: 1px solid #e5dcff;
    overflow-wrap: anywhere;
}

.photo-preview {
    width: 120px;
    height: 120px;
    margin: 0 auto 16px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    font-size: 42px;
    font-weight: 800;
    color: var(--purple);
    background: linear-gradient(140deg, #f7dff3, #e6ddff);
    border: 5px solid white;
    box-shadow: 0 0 0 1px var(--border);
    overflow: hidden;
}

.photo-actions {
    display: flex;
    justify-content: center;
    gap: 9px;
    flex-wrap: wrap;
}

.photo-note {
    font-size: 12px;
    color: var(--muted);
    text-align: center;
    line-height: 1.6;
}

input[type="file"] {
    display: none;
}

footer {
    text-align: center;
    padding: 20px;
    color: var(--muted);
    font-size: 13px;
}

/* Dark mode */
body.dark {
    background: #151323 !important;
    color: #f1edff !important;
}

body.dark .topbar {
    background: #211d35 !important;
    border-color: #39314f !important;
}

body.dark .top-actions a,
body.dark .card,
body.dark .stat {
    background: #211d35 !important;
    color: #f1edff !important;
    border-color: #39314f !important;
}

body.dark .stat strong,
body.dark .stat span,
body.dark .detail small,
body.dark .about,
body.dark .photo-note {
    color: #d0c8e8 !important;
}

body.dark .detail {
    background: #29243e !important;
    border-color: #494064 !important;
}

body.dark .skill {
    background: #302849 !important;
    color: #e8deff !important;
    border-color: #494064 !important;
}

body.dark .btn-light {
    background: #302849 !important;
    color: #e8deff !important;
}

body.dark .photo-preview {
    border-color: #39314f !important;
}

@media(max-width:760px) {
    .layout {
        margin-top: 18px;
        padding: 0 12px 25px;
    }

    .hero {
        padding: 23px;
    }

    .quote {
        margin-left: 0;
        max-width: none;
    }

    .stats {
        grid-template-columns: 1fr;
        gap: 10px;
    }

    .columns {
        grid-template-columns: 1fr;
    }

    .card {
        padding: 19px;
    }

    .topbar {
        padding: 15px;
    }
}
</style>
</head>

<body>

<header class="topbar">
    <a class="brand"
       href="<%= request.getContextPath() %>/dashboard.jsp">
        🎓 StudentSphere
    </a>

    <nav class="top-actions">
        <a href="<%= request.getContextPath() %>/dashboard.jsp">⌂ Dashboard</a>
        <a href="<%= request.getContextPath() %>/logout">Log out ↗</a>
    </nav>
</header>

<main class="layout">

    <section class="hero">
        <div class="profile-head">

            <div class="avatar-wrap">
                <div class="avatar" id="heroAvatar">
                    <% if (profilePhoto != null && !profilePhoto.isEmpty()) { %>
                        <img src="<%= request.getContextPath() %>/<%= profilePhoto %>"
                             alt="Profile photo">
                    <% } else { %>
                        <%= initial %>
                    <% } %>
                </div>

                <a class="camera-link" href="#photoCard" title="Profile photo">📷</a>
            </div>

            <div>
                <div class="profile-title">
                    <h1><%= safeName %></h1>
                    <a class="edit-icon"
                       href="<%= request.getContextPath() %>/modules/profile/editProfile.jsp"
                       title="Edit Profile">✏️</a>
                </div>

                <p>🎓 Student Account · StudentSphere Member</p>
                <p><%= safeEmail %></p>

                <div class="pills">
                    <span class="pill">✦ Student</span>
                    <span class="pill">● My Profile</span>
                </div>
            </div>

            <div class="quote">
                “Small steps every day lead to big results.” 💜
            </div>
        </div>
    </section>

    <section class="stats">
        <div class="stat">
            <strong>✦</strong>
            <span>Your Student Journey</span>
        </div>

        <div class="stat">
            <strong>✓</strong>
            <span>Account Access</span>
        </div>

        <div class="stat">
            <strong>∞</strong>
            <span>Room to Grow</span>
        </div>
    </section>

    <% if ("1".equals(updated)) { %>
        <div class="message success">
            Profile updated successfully! 💜
        </div>
    <% } %>

    <% if (error != null) { %>
        <div class="message error">
            <% if ("empty".equals(error)) { %>
                Name cannot be empty.
            <% } else if ("length".equals(error)) { %>
                Name must not exceed 100 characters.
            <% } else { %>
                Unable to update profile. Please try again.
            <% } %>
        </div>
    <% } %>

    <div class="columns">

        <div>

            <section class="card">
                <div class="card-heading">
                    <h2>👤 Personal Information</h2>
                    <a class="edit-icon"
                       href="<%= request.getContextPath() %>/modules/profile/editProfile.jsp"
                       title="Edit personal information">✏️</a>
                </div>

                <div class="detail">
                    <small>Full Name</small>
                    <strong><%= safeName %></strong>
                </div>

                <div class="detail">
                    <small>Email Address</small>
                    <strong><%= safeEmail %></strong>
                </div>

                <div class="detail">
                    <small>Account Type</small>
                    <strong>Student Account</strong>
                </div>
            </section>

            <section class="card">
                <div class="card-heading">
                    <h2>🎓 Academic Details</h2>
                    <a class="edit-icon"
                       href="<%= request.getContextPath() %>/modules/profile/academic.jsp"
                       title="Edit Academic Details">✏️</a>
                </div>

                <div class="detail">
                    <small>Branch / Course</small>
                    <strong><%= academicBranch %></strong>
                </div>

                <div class="detail">
                    <small>Current Semester</small>
                    <strong><%= academicSemester %></strong>
                </div>

                <div class="detail">
                    <small>CGPA</small>
                    <strong><%= academicCgpa %></strong>
                </div>

                <div class="detail">
                    <small>Attendance</small>
                    <strong><%= academicAttendance %></strong>
                </div>
            </section>

            <!-- Skills are loaded from the database -->
            <section class="card">
                <div class="card-heading">
                    <h2>💡 Skills</h2>

                    <a class="edit-icon"
                       href="<%= request.getContextPath() %>/modules/profile/editProfile.jsp"
                       title="Edit Skills"
                       aria-label="Edit Skills">✏️</a>
                </div>

                <div class="skills">
                    <% if (savedSkills.isEmpty()) { %>

                        <p class="about">
                            No skills added yet. Click the edit icon to add your skills.
                        </p>

                    <% } else { %>

                        <% for (String skill : savedSkills) {
                            String safeSkill = skill.replace("&", "&amp;")
                                .replace("<", "&lt;")
                                .replace(">", "&gt;")
                                .replace("\"", "&quot;")
                                .replace("'", "&#39;");
                        %>

                            <span class="skill"><%= safeSkill %></span>

                        <% } %>

                    <% } %>
                </div>
            </section>

        </div>

        <aside>

            <section class="card" id="photoCard">
                <div class="card-heading">
                    <h2>📸 Profile Photo</h2>
                </div>

                <div class="photo-preview" id="photoPreview">
                    <% if (profilePhoto != null && !profilePhoto.isEmpty()) { %>
                        <img src="<%= request.getContextPath() %>/<%= profilePhoto %>"
                             alt="Profile photo">
                    <% } else { %>
                        <%= initial %>
                    <% } %>
                </div>

                <form action="<%= request.getContextPath() %>/profile-photo"
                      method="post"
                      enctype="multipart/form-data"
                      id="photoForm">

                    <input type="file"
                           id="photoFile"
                           name="photo"
                           accept="image/jpeg,image/png">

                    <div class="photo-actions">
                        <label for="photoFile" class="btn">📷 Choose Photo</label>

                        <button class="btn btn-pink"
                                type="submit"
                                name="action"
                                value="remove"
                                onclick="return confirm('Remove your profile photo?')">
                            🗑 Remove
                        </button>
                    </div>

                    <p class="photo-note">JPG or PNG · Maximum 2 MB</p>

                    <button class="btn"
                            id="savePhoto"
                            type="submit"
                            name="action"
                            value="upload"
                            style="display:none;width:100%">
                        Save Photo
                    </button>

                    <p class="photo-note" id="photoStatus">
                        Choose a photo to preview it.
                    </p>
                </form>
            </section>

            <section class="card">
                <div class="card-heading">
                    <h2>💜 About StudentSphere</h2>
                </div>

                <p class="about">
                    One place for study planning, expenses, campus events,
                    clubs and personal goals. Keep learning, keep growing!
                </p>
            </section>

            <section class="card">
                <div class="card-heading">
                    <h2>🔗 Quick Links</h2>
                </div>

                <p>
                    <a class="btn btn-light"
                       href="<%= request.getContextPath() %>/studyplanner">
                        📚 Study Planner
                    </a>
                </p>

                <p>
                    <a class="btn btn-light"
                       href="<%= request.getContextPath() %>/expensetracker">
                        💳 Expense Tracker
                    </a>
                </p>

                <p>
                    <a class="btn btn-light"
                       href="<%= request.getContextPath() %>/events">
                        📅 Events
                    </a>
                </p>

                <p>
                    <a class="btn btn-light"
                       href="<%= request.getContextPath() %>/clubs">
                        👥 Clubs
                    </a>
                </p>

                <p>
                    <a class="btn btn-light"
                       href="<%= request.getContextPath() %>/goals">
                        🎯 Goals
                    </a>
                </p>
            </section>

        </aside>

    </div>
</main>

<footer>Made with 💜 for your StudentSphere journey</footer>

<script>
document.getElementById("photoFile").addEventListener("change", function () {
    const file = this.files && this.files[0];
    const status = document.getElementById("photoStatus");
    const saveButton = document.getElementById("savePhoto");

    if (!file) return;

    if (!["image/jpeg", "image/png"].includes(file.type)) {
        alert("Please select a JPG or PNG image.");
        this.value = "";
        saveButton.style.display = "none";
        return;
    }

    if (file.size > 2 * 1024 * 1024) {
        alert("Photo must be smaller than 2 MB.");
        this.value = "";
        saveButton.style.display = "none";
        return;
    }

    const reader = new FileReader();

    reader.onload = function (event) {
        const imageMarkup =
            '<img src="' + event.target.result + '" alt="Photo preview">';

        document.getElementById("photoPreview").innerHTML = imageMarkup;
        document.getElementById("heroAvatar").innerHTML = imageMarkup;

        status.textContent = "Preview ready. Click Save Photo to upload.";
        saveButton.style.display = "block";
    };

    reader.readAsDataURL(file);
});
</script>

<script src="<%= request.getContextPath() %>/js/theme.js"></script>

</body>
</html>
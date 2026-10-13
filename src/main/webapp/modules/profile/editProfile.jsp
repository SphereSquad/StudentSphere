
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.sql.*,java.util.*,com.studentsphere.common.DMConnection" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    int userId = Integer.parseInt(
        session.getAttribute("userId").toString()
    );

    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");

    if (userName == null) userName = "Student";
    if (userEmail == null) userEmail = "Not available";

    String safeName = escapeHtml(userName);
    String safeEmail = escapeHtml(userEmail);

    String[][] skillGroups = {
        {"Programming Languages", "Java", "Python", "C", "C++", "JavaScript"},
        {"Web Development", "HTML", "CSS", "React", "JSP", "Servlets", "Responsive Design"},
        {"Database & Tools", "MySQL", "DBMS", "Git", "GitHub", "Eclipse IDE", "Apache Tomcat", "Linux"},
        {"AI & Data Science", "Artificial Intelligence", "Machine Learning",
         "Data Analysis", "Data Visualization", "NLP", "Pandas", "NumPy"},
        {"Core Computer Science", "Data Structures & Algorithms", "OOP",
         "Operating Systems", "Computer Networks", "Problem Solving"},
        {"Soft Skills", "Communication", "Teamwork", "Leadership",
         "Time Management", "Critical Thinking", "Adaptability", "Presentation Skills"}
    };

    Set<String> savedSkills = new LinkedHashSet<>();

    try (Connection con = DMConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(
             "SELECT skill_name FROM student_skills WHERE user_id = ?")) {

        ps.setInt(1, userId);

        try (ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                savedSkills.add(rs.getString("skill_name"));
            }
        }
    } catch (Exception e) {
        application.log("Unable to load saved skills", e);
    }

    Set<String> predefinedSkills = new HashSet<>();
    for (String[] group : skillGroups) {
        for (int i = 1; i < group.length; i++) {
            predefinedSkills.add(group[i]);
        }
    }

    Set<String> customSkills = new LinkedHashSet<>();
    for (String skill : savedSkills) {
        if (!predefinedSkills.contains(skill)) {
            customSkills.add(skill);
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Edit Profile | StudentSphere</title>

<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/theme.css">

<style>
* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: #292052;
    background: linear-gradient(135deg, #f3edff, #fff0f8, #eeeaff);
    min-height: 100vh;
    transition: background .2s, color .2s;
}

header {
    padding: 20px 6%;
    background: rgba(255,255,255,.9);
    border-bottom: 1px solid #e8defb;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
}

.brand {
    color: #7254e8;
    font-size: 23px;
    font-weight: 800;
    text-decoration: none;
}

header a:not(.brand) {
    text-decoration: none;
    color: #6045c4;
    font-weight: 600;
}

.container {
    max-width: 850px;
    margin: 38px auto;
    padding: 0 18px 35px;
}

.card {
    background: rgba(255,255,255,.96);
    border: 1px solid #e9e0fc;
    border-radius: 24px;
    padding: 32px;
    box-shadow: 0 14px 38px #5b42a716;
    margin-bottom: 22px;
}

.banner {
    background: linear-gradient(115deg, #7054e7, #aa85f5, #f0b2dc);
    height: 100px;
    border-radius: 17px;
    margin-bottom: -45px;
}

.avatar {
    width: 95px;
    height: 95px;
    margin-left: 22px;
    position: relative;
    display: grid;
    place-items: center;
    border: 5px solid white;
    border-radius: 50%;
    background: #f0e7ff;
    color: #7054e7;
    font-size: 36px;
    font-weight: 800;
}

h1 { font-size: 27px; margin: 18px 0 5px; }
.subtitle { color: #81799e; margin-bottom: 25px; }

.notice {
    padding: 13px;
    background: #f6f1ff;
    border-radius: 12px;
    color: #6752ad;
    font-size: 14px;
    line-height: 1.6;
    margin-bottom: 22px;
}

.field-label {
    display: block;
    margin: 19px 0 8px;
    font-weight: 650;
}

input[type="text"], input[type="email"] {
    width: 100%;
    padding: 13px 14px;
    border: 1px solid #ded5f5;
    border-radius: 11px;
    background: #fcfbff;
    font-size: 15px;
    color: #292052;
}

input:focus { outline: 2px solid #c4b5fd; }

input[readonly] {
    background: #f0edf7;
    color: #827b9a;
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin: 20px 0 8px;
}

.section-heading h2 { margin: 0; font-size: 20px; }

.help-text {
    color: #81799e;
    font-size: 13px;
    line-height: 1.5;
    margin: 8px 0 20px;
}

.skill-group {
    padding: 18px;
    margin: 15px 0;
    border: 1px solid #ece5fc;
    border-radius: 16px;
    background: #fdfbff;
}

.skill-group h3 {
    margin: 0 0 14px;
    color: #6747cb;
    font-size: 15px;
}

.skill-options {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
}

.skill-option {
    display: inline-flex;
    align-items: center;
    gap: 7px;
    border: 1px solid #e5dcff;
    background: #f2edff;
    color: #6747cb;
    border-radius: 22px;
    padding: 9px 12px;
    font-size: 13px;
    cursor: pointer;
}

.skill-option input {
    accent-color: #7655e8;
    cursor: pointer;
    margin: 0;
}

.skill-option:has(input:checked) {
    background: #dfd4ff;
    border-color: #9d83ef;
    font-weight: 700;
}

.custom-skill {
    display: flex;
    gap: 10px;
    margin-top: 14px;
}

.custom-skill input { flex: 1; min-width: 0; }

.actions {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 25px;
}

button, .cancel {
    border: none;
    border-radius: 11px;
    padding: 13px 19px;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
}

.save {
    color: white;
    background: linear-gradient(110deg, #7554e8, #a36ee9);
}

.reset, .cancel {
    color: #634cb9;
    background: #f2edff;
}

#selectedCount {
    font-size: 13px;
    color: #7054e7;
    font-weight: 700;
}

body.dark {
    color: #eee9ff;
    background: #171526;
}

body.dark header {
    background: #211e35;
    border-color: #39314f;
}

body.dark header a:not(.brand) { color: #c7b7ff; }

body.dark .card {
    background: #211e35;
    border-color: #39314f;
}

body.dark .subtitle,
body.dark .help-text { color: #bcb4d5; }

body.dark .notice {
    background: #302846;
    color: #ded3ff;
}

body.dark .skill-group {
    background: #29243d;
    border-color: #403657;
}

body.dark .skill-option {
    background: #352b50;
    color: #e1d6ff;
    border-color: #4a3b69;
}

body.dark .skill-option:has(input:checked) {
    background: #574080;
    border-color: #a18ae7;
}

body.dark input[type="text"],
body.dark input[type="email"] {
    background: #29243d;
    color: #f2edff;
    border-color: #4a3b69;
}

body.dark input[readonly] { background: #302b43; }

body.dark .reset,
body.dark .cancel { background: #352b50; color: #e1d6ff; }

@media(max-width:550px) {
    .card { padding: 20px; }
    header { padding: 17px; }
    .brand { font-size: 19px; }
    .custom-skill { flex-direction: column; }
    .section-heading h2 { font-size: 18px; }
}
</style>
</head>

<body>

<header>
    <a class="brand"
       href="<%= request.getContextPath() %>/dashboard.jsp">
        🎓 StudentSphere
    </a>

    <a href="<%= request.getContextPath() %>/modules/profile/profile.jsp">
        ← My Profile
    </a>
</header>

<main class="container">

    <section class="card">
        <div class="banner"></div>

        <div class="avatar">
            <%= safeName.trim().isEmpty()
                ? "S"
                : escapeHtml(userName.trim().substring(0, 1).toUpperCase()) %>
        </div>

        <h1>Edit Your Profile ✨</h1>
        <p class="subtitle">Keep your StudentSphere information up to date.</p>

        <div class="notice">
            💜 Update your name and manage your skills.
            Your email address is read-only.
        </div>

        <!-- FORM 1: Update name -->
        <form action="<%= request.getContextPath() %>/profile"
              method="post">

            <label class="field-label" for="name">Full Name</label>
            <input type="text"
                   id="name"
                   name="name"
                   value="<%= safeName %>"
                   maxlength="100"
                   autocomplete="name"
                   required>

            <label class="field-label" for="email">Email Address</label>
            <input type="email"
                   id="email"
                   value="<%= safeEmail %>"
                   readonly>

            <div class="actions">
                <button type="submit" class="save">💾 Save Name</button>
                <a class="cancel"
                   href="<%= request.getContextPath() %>/modules/profile/profile.jsp">
                    Cancel
                </a>
            </div>
        </form>
    </section>

    <!-- FORM 2: Save skills to database -->
    <section class="card">

        <div class="section-heading">
            <h2>💡 Skills & Expertise</h2>
            <button type="button"
                    class="reset"
                    id="focusSkills">✏️ Edit Skills</button>
        </div>

        <p class="help-text">
            Select all the skills you want to display on your profile.
            Your saved skills will remain selected when you return.
            <br>
            <span id="selectedCount">0 skills selected</span>
        </p>

        <form action="<%= request.getContextPath() %>/save-skills"
              method="post"
              id="skillsForm">

            <div id="skillsContainer">

                <% for (int g = 0; g < skillGroups.length; g++) { %>

                    <div class="skill-group">
                        <h3><%= escapeHtml(skillGroups[g][0]) %></h3>

                        <div class="skill-options">

                            <% for (int s = 1; s < skillGroups[g].length; s++) {
                                String skill = skillGroups[g][s];
                            %>

                                <label class="skill-option">
                                    <input type="checkbox"
                                           name="skills"
                                           value="<%= escapeHtml(skill) %>"
                                           <%= savedSkills.contains(skill) ? "checked" : "" %>>
                                    <%= escapeHtml(skill) %>
                                </label>

                            <% } %>

                        </div>
                    </div>

                <% } %>

                <% if (!customSkills.isEmpty()) { %>
                    <div class="skill-group">
                        <h3>✨ Custom Skills</h3>
                        <div class="skill-options">

                            <% for (String skill : customSkills) { %>
                                <label class="skill-option">
                                    <input type="checkbox"
                                           name="skills"
                                           value="<%= escapeHtml(skill) %>"
                                           checked>
                                    <%= escapeHtml(skill) %>
                                </label>
                            <% } %>

                        </div>
                    </div>
                <% } %>

            </div>

            <div class="section-heading">
                <h2>➕ Add Your Own Skill</h2>
            </div>

            <p class="help-text">
                Add a custom skill and select it before saving.
                Custom skills will also be saved in the database.
            </p>

            <div class="custom-skill">
                <input type="text"
                       id="customSkill"
                       placeholder="Example: Figma, Docker, Public Speaking"
                       maxlength="100">

                <button type="button"
                        class="reset"
                        id="addSkill">+ Add Skill</button>
            </div>

            <div class="actions">
                <button type="submit" class="save">💾 Save Skills</button>
                <button type="reset" class="reset">↺ Reset Skills</button>
                <a class="cancel"
                   href="<%= request.getContextPath() %>/modules/profile/profile.jsp">
                    Cancel
                </a>
            </div>
        </form>
    </section>

</main>

<script>
const skillsContainer = document.getElementById("skillsContainer");
const selectedCount = document.getElementById("selectedCount");
const customSkill = document.getElementById("customSkill");
const skillsForm = document.getElementById("skillsForm");

function updateSelectedCount() {
    const checked = skillsContainer.querySelectorAll(
        'input[name="skills"]:checked'
    ).length;

    selectedCount.textContent =
        checked + (checked === 1 ? " skill selected" : " skills selected");
}

skillsContainer.addEventListener("change", function(event) {
    if (event.target.matches('input[name="skills"]')) {
        updateSelectedCount();
    }
});

document.getElementById("focusSkills").addEventListener("click", function() {
    skillsContainer.scrollIntoView({
        behavior: "smooth",
        block: "start"
    });
});

document.getElementById("addSkill").addEventListener("click", function() {
    const skillName = customSkill.value.trim();

    if (!skillName) {
        alert("Please enter a skill name.");
        customSkill.focus();
        return;
    }

    if (skillName.length > 100) {
        alert("Skill name must be 100 characters or less.");
        return;
    }

    const existingSkills = Array.from(
        skillsContainer.querySelectorAll('input[name="skills"]')
    );

    const duplicate = existingSkills.some(function(input) {
        return input.value.toLowerCase() === skillName.toLowerCase();
    });

    if (duplicate) {
        alert("This skill is already available.");
        return;
    }

    let group = skillsContainer.querySelector(
        '[data-custom-skills="true"]'
    );

    if (!group) {
        group = document.createElement("div");
        group.className = "skill-group";
        group.dataset.customSkills = "true";

        const heading = document.createElement("h3");
        heading.textContent = "✨ Custom Skills";

        const options = document.createElement("div");
        options.className = "skill-options";

        group.appendChild(heading);
        group.appendChild(options);
        skillsContainer.appendChild(group);
    }

    const options = group.querySelector(".skill-options");
    const label = document.createElement("label");
    label.className = "skill-option";

    const checkbox = document.createElement("input");
    checkbox.type = "checkbox";
    checkbox.name = "skills";
    checkbox.value = skillName;
    checkbox.checked = true;

    label.appendChild(checkbox);
    label.appendChild(document.createTextNode(" " + skillName));
    options.appendChild(label);

    customSkill.value = "";
    updateSelectedCount();
});

skillsForm.addEventListener("reset", function() {
    setTimeout(updateSelectedCount, 0);
});

updateSelectedCount();
</script>

<script src="<%= request.getContextPath() %>/js/theme.js"></script>

</body>
</html>

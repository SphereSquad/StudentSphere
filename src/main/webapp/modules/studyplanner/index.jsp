
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map,java.time.LocalDate"%>

<%!
    private String esc(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
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

    List<Map<String, Object>> tasks =
        (List<Map<String, Object>>) request.getAttribute("tasks");

    if (tasks == null) {
        tasks = new java.util.ArrayList<Map<String, Object>>();
    }

    String userName = (String) session.getAttribute("userName");
    if (userName == null || userName.trim().isEmpty()) {
        userName = "Student";
    }

    int total = tasks.size();
    int completedCount = 0;
    int pendingCount = 0;
    int todayCount = 0;
    int overdueCount = 0;

    LocalDate today = LocalDate.now();

    for (Map<String, Object> task : tasks) {
        String status = String.valueOf(task.get("status"));
        String due = task.get("due_date") == null
            ? "" : task.get("due_date").toString();

        boolean done = "Completed".equalsIgnoreCase(status);

        if (done) {
            completedCount++;
        } else {
            pendingCount++;

            try {
                LocalDate dueDate = LocalDate.parse(due.substring(0, 10));

                if (dueDate.isEqual(today)) {
                    todayCount++;
                } else if (dueDate.isBefore(today)) {
                    overdueCount++;
                }
            } catch (Exception ignored) {
                // Ignore an invalid or missing date.
            }
        }
    }

    int completionPercent = total == 0
        ? 0 : (completedCount * 100 / total);
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Study Planner</title>

<style>
:root {
    --bg: #f5f3ff;
    --surface: #ffffff;
    --text: #282347;
    --muted: #77738f;
    --border: #e9e5f5;
    --purple: #7055e8;
    --purple-dark: #5338c9;
    --pink: #ee75b7;
    --green: #159968;
    --red: #e44e68;
    --shadow: 0 12px 35px rgba(63, 43, 125, .07);
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    background: var(--bg);
    color: var(--text);
    transition: background .25s, color .25s;
}

body.dark {
    --bg: #171529;
    --surface: #232039;
    --text: #f3f0ff;
    --muted: #b0aaca;
    --border: #393451;
    --shadow: 0 12px 35px rgba(0, 0, 0, .15);
}

header {
    padding: 17px 5%;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    flex-wrap: wrap;
}

.brand {
    display: flex;
    align-items: center;
    gap: 12px;
}

.brand-icon {
    width: 43px;
    height: 43px;
    border-radius: 14px;
    display: grid;
    place-items: center;
    color: white;
    font-size: 22px;
    background: linear-gradient(135deg, var(--purple), var(--pink));
}

.brand h2 { margin: 0; font-size: 20px; }
.brand small { color: var(--muted); }

.header-actions {
    display: flex;
    align-items: center;
    gap: 12px;
}

a { text-decoration: none; color: inherit; }

.back-link {
    color: var(--purple);
    font-size: 14px;
    font-weight: 600;
}

button, input, textarea, select { font: inherit; }

button {
    border: none;
    cursor: pointer;
    transition: transform .18s, opacity .18s;
}

button:hover { opacity: .9; }
button:active { transform: scale(.98); }

.theme-btn, .secondary-btn {
    padding: 10px 14px;
    border: 1px solid var(--border);
    border-radius: 11px;
    background: var(--surface);
    color: var(--text);
    font-size: 13px;
    font-weight: 600;
}

.container {
    max-width: 1250px;
    margin: 28px auto;
    padding: 0 22px 40px;
}

.page-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 22px;
}

.page-heading h1 {
    margin: 0 0 7px;
    font-size: clamp(25px, 3vw, 34px);
    letter-spacing: -.7px;
}

.page-heading p {
    margin: 0;
    color: var(--muted);
    font-size: 14px;
}

.hero {
    position: relative;
    overflow: hidden;
    border-radius: 22px;
    padding: 30px;
    color: white;
    background: linear-gradient(115deg, #573bd0 0%, #8462ed 57%, #ed82bd 120%);
    box-shadow: 0 15px 35px rgba(112, 85, 232, .19);
    margin-bottom: 24px;
}

.hero:after {
    content: "✦";
    position: absolute;
    right: 38px;
    top: 10px;
    font-size: 115px;
    opacity: .13;
}

.hero h2 { margin: 0 0 9px; font-size: 25px; }
.hero p { margin: 0; line-height: 1.7; max-width: 620px; opacity: .92; }
.hero .date-label { margin-top: 15px; font-size: 13px; opacity: .85; }

.stats {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 16px;
    margin-bottom: 23px;
}

.stat {
    padding: 20px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 17px;
    box-shadow: var(--shadow);
    min-width: 0;
}

.stat-top {
    display: flex;
    justify-content: space-between;
    gap: 8px;
    align-items: center;
    color: var(--muted);
    font-size: 13px;
}

.stat-icon {
    display: grid;
    place-items: center;
    width: 36px;
    height: 36px;
    border-radius: 12px;
    background: #f0ebff;
    color: #6d51dc;
    font-size: 18px;
}

body.dark .stat-icon { background: #383052; }

.stat-number {
    font-size: 30px;
    font-weight: 750;
    margin-top: 12px;
}

.stat-note { color: var(--muted); font-size: 12px; margin-top: 5px; }

.progress-track {
    height: 7px;
    border-radius: 20px;
    background: var(--border);
    margin-top: 13px;
    overflow: hidden;
}

.progress-fill {
    height: 100%;
    border-radius: 20px;
    background: linear-gradient(90deg, var(--purple), var(--pink));
}

.layout {
    display: grid;
    grid-template-columns: minmax(280px, .82fr) minmax(0, 1.55fr);
    gap: 22px;
    align-items: start;
}

.card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 19px;
    padding: 23px;
    box-shadow: var(--shadow);
    margin-bottom: 22px;
    min-width: 0;
}

.card-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 18px;
}

.card-heading h3 { margin: 0; font-size: 18px; }
.card-heading p { color: var(--muted); font-size: 12px; margin: 5px 0 0; }

label {
    display: block;
    font-size: 13px;
    font-weight: 650;
    margin: 15px 0 7px;
}

input, textarea, select {
    width: 100%;
    min-width: 0;
    padding: 12px;
    border: 1px solid var(--border);
    border-radius: 11px;
    background: var(--surface);
    color: var(--text);
    outline: none;
}

input:focus, textarea:focus, select:focus {
    border-color: var(--purple);
    box-shadow: 0 0 0 3px rgba(112, 85, 232, .10);
}

textarea { resize: vertical; min-height: 90px; }

.primary-btn {
    background: linear-gradient(110deg, var(--purple), var(--pink));
    color: white;
    padding: 12px 16px;
    border-radius: 11px;
    font-weight: 700;
    font-size: 14px;
}

.full-width { width: 100%; margin-top: 18px; }

.error {
    color: #b42318;
    background: #fff0f0;
    border-radius: 10px;
    padding: 11px;
    font-size: 13px;
}

.task-toolbar {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 10px;
    margin-bottom: 12px;
}

.filters {
    display: flex;
    gap: 7px;
    flex-wrap: wrap;
    margin-bottom: 12px;
}

.filter-btn {
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--muted);
    border-radius: 30px;
    padding: 8px 12px;
    font-size: 12px;
    font-weight: 650;
}

.filter-btn.active {
    background: var(--purple);
    border-color: var(--purple);
    color: white;
}

.task {
    padding: 17px 0;
    border-bottom: 1px solid var(--border);
}

.task:last-child { border-bottom: none; }

.task-row {
    display: flex;
    justify-content: space-between;
    gap: 12px;
    align-items: flex-start;
}

.task-main { min-width: 0; }

.task h4 {
    margin: 0 0 7px;
    font-size: 15px;
    overflow-wrap: anywhere;
}

.task p {
    margin: 6px 0;
    font-size: 13px;
    line-height: 1.5;
    color: var(--muted);
    overflow-wrap: anywhere;
    white-space: pre-wrap;
}

.task.completed h4 {
    text-decoration: line-through;
    opacity: .7;
}

.status {
    display: inline-block;
    border-radius: 30px;
    padding: 5px 9px;
    font-size: 11px;
    font-weight: 700;
    background: #fff1d8;
    color: #936000;
    white-space: nowrap;
}

.status.completed { background: #dcfce7; color: #166534; }
.status.overdue { background: #ffe4e8; color: #bd2944; }
.status.today { background: #f2eaff; color: #7040c9; }

.actions {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-top: 10px;
}

.actions form { margin: 0; }

.small-btn {
    padding: 8px 10px;
    border-radius: 9px;
    font-size: 12px;
    font-weight: 650;
}

.complete-btn { background: #d9f8e9; color: #137b4f; }
.delete-btn { background: #ffe5e9; color: #c0344a; }

.empty {
    padding: 28px 12px;
    text-align: center;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}

.empty-icon { font-size: 34px; margin-bottom: 10px; }

.timer-card { text-align: center; }

.timer-modes {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 8px;
    margin: 17px 0 22px;
}

.timer-mode {
    background: var(--surface);
    color: var(--muted);
    border: 1px solid var(--border);
    padding: 9px 12px;
    border-radius: 30px;
    font-size: 12px;
}

.timer-mode.active {
    background: var(--purple);
    color: white;
    border-color: var(--purple);
}

.timer-display {
    font-size: clamp(42px, 7vw, 59px);
    font-weight: 800;
    letter-spacing: 2px;
    margin: 12px 0 18px;
    font-variant-numeric: tabular-nums;
}

.timer-controls { display: flex; justify-content: center; gap: 10px; }

.session-note { color: var(--muted); font-size: 12px; margin-top: 15px; }

.tip {
    border-radius: 14px;
    padding: 16px;
    background: linear-gradient(110deg, rgba(112,85,232,.10), rgba(238,117,183,.10));
    font-size: 13px;
    line-height: 1.7;
}

.tip strong { display: block; margin-bottom: 4px; }

.footer {
    text-align: center;
    padding: 12px;
    color: var(--muted);
    font-size: 12px;
}

.no-results { display: none; }

@media(max-width: 950px) {
    .stats { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .layout { grid-template-columns: 1fr; }
}

@media(max-width: 520px) {
    header { padding: 15px; }
    .container { padding: 0 13px 25px; margin-top: 17px; }
    .hero { padding: 22px; }
    .card { padding: 17px; }
    .stats { gap: 10px; }
    .stat { padding: 14px; }
    .stat-number { font-size: 25px; }
    .task-toolbar { grid-template-columns: 1fr; }
    .task-row { flex-wrap: wrap; }
}

/* ===== Premium StudentSphere Background ===== */

body {
    background:
        radial-gradient(ellipse at 8% 8%,
            rgba(191, 155, 255, 0.35), transparent 32%),
        radial-gradient(ellipse at 92% 18%,
            rgba(255, 164, 211, 0.28), transparent 30%),
        radial-gradient(ellipse at 78% 85%,
            rgba(149, 131, 255, 0.23), transparent 35%),
        linear-gradient(135deg, #f8f5ff 0%, #f2efff 48%, #fff3f9 100%);
    background-attachment: fixed;
    min-height: 100vh;
}

/* Soft dotted texture */
.container {
    position: relative;
    isolation: isolate;
}

.container::before {
    content: "";
    position: fixed;
    inset: 0;
    z-index: -1;
    pointer-events: none;
    opacity: 0.20;
    background-image: radial-gradient(#8973d8 0.8px, transparent 0.8px);
    background-size: 23px 23px;
}

/* Make cards look elevated */
.card,
.stat {
    backdrop-filter: blur(12px);
    box-shadow:
        0 12px 32px rgba(77, 53, 145, 0.07),
        0 2px 7px rgba(77, 53, 145, 0.035);
    transition: transform 0.25s ease, box-shadow 0.25s ease;
}

.card:hover,
.stat:hover {
    transform: translateY(-3px);
    box-shadow: 0 17px 38px rgba(77, 53, 145, 0.12);
}

/* More attractive hero section */
.hero {
    background:
        radial-gradient(circle at 88% 12%,
            rgba(255, 255, 255, 0.25), transparent 25%),
        linear-gradient(120deg, #5336c7 0%, #8061ed 52%, #e77bb9 110%);
    box-shadow: 0 18px 42px rgba(105, 73, 208, 0.22);
}

/* Dark mode background */
body.dark {
    background:
        radial-gradient(ellipse at 8% 8%,
            rgba(111, 76, 195, 0.20), transparent 32%),
        radial-gradient(ellipse at 92% 20%,
            rgba(180, 74, 139, 0.13), transparent 30%),
        linear-gradient(135deg, #171529, #211b38 55%, #241a30);
    background-attachment: fixed;
}

body.dark .container::before {
    opacity: 0.08;
    background-image: radial-gradient(#c4b6ff 0.8px, transparent 0.8px);
}

@media (prefers-reduced-motion: reduce) {
    .card, .stat {
        transition: none;
    }
}

</style>
</head>

<body>
<header>
    <div class="brand">
        <div class="brand-icon">📚</div>
        <div>
            <h2>StudentSphere</h2>
            <small>Study Planner & Focus Space</small>
        </div>
    </div>

    <div class="header-actions">
        <button class="theme-btn" id="themeToggle" type="button">🌙 Dark Mode</button>
        <a class="back-link" href="<%= request.getContextPath() %>/dashboard.jsp">
            ← Dashboard
        </a>
    </div>
</header>

<main class="container">

    <div class="page-heading">
        <div>
            <h1>Tasks & Study Planner</h1>
            <p>Plan your day, track deadlines and make every study session count.</p>
        </div>
    </div>

    <section class="hero">
        <h2>Hello, <%= esc(userName) %>! 👋</h2>
        <p>Your goals are closer than you think. Organize your assignments,
           focus on one task at a time and celebrate your progress.</p>
        <div class="date-label">📅 <span id="todayDate"></span></div>
    </section>

    <section class="stats">
        <article class="stat">
            <div class="stat-top">
                <span>Completed</span><span class="stat-icon">✓</span>
            </div>
            <div class="stat-number"><%= completionPercent %>%</div>
            <div class="stat-note"><%= completedCount %> of <%= total %> tasks completed</div>
            <div class="progress-track">
                <div class="progress-fill" style="width:<%= completionPercent %>%"></div>
            </div>
        </article>

        <article class="stat">
            <div class="stat-top">
                <span>Pending tasks</span><span class="stat-icon">◷</span>
            </div>
            <div class="stat-number"><%= pendingCount %></div>
            <div class="stat-note">Tasks still to complete</div>
        </article>

        <article class="stat">
            <div class="stat-top">
                <span>Due today</span><span class="stat-icon">📅</span>
            </div>
            <div class="stat-number"><%= todayCount %></div>
            <div class="stat-note">Pending tasks for today</div>
        </article>

        <article class="stat">
            <div class="stat-top">
                <span>Overdue</span><span class="stat-icon">!</span>
            </div>
            <div class="stat-number" style="color:var(--red)"><%= overdueCount %></div>
            <div class="stat-note">Past-due pending tasks</div>
        </article>
    </section>

    <div class="layout">

        <div>
            <section class="card">
                <div class="card-heading">
                    <div>
                        <h3>＋ Add a New Task</h3>
                        <p>Break your study goals into small steps.</p>
                    </div>
                </div>

                <% if ("empty".equals(request.getParameter("error"))) { %>
                    <p class="error">Please enter a task title and due date.</p>
                <% } %>

                <form action="<%= request.getContextPath() %>/studyplanner"
                      method="post">
                    <label for="title">Task title *</label>
                    <input type="text" id="title" name="title" maxlength="150"
                           placeholder="e.g. Complete DBMS assignment" required>

                    <label for="description">Description</label>
                    <textarea id="description" name="description"
                              placeholder="Add notes, chapters or details..."></textarea>

                    <label for="dueDate">Deadline *</label>
                    <input type="date" id="dueDate" name="dueDate" required>

                    <button class="primary-btn full-width" type="submit">
                        ＋ Save Study Task
                    </button>
                </form>
            </section>

            <section class="card timer-card">
                <div class="card-heading">
                    <div>
                        <h3>⏱ Focus Timer</h3>
                        <p>Work in focused intervals.</p>
                    </div>
                </div>

                <div class="timer-modes">
                    <button class="timer-mode active" data-minutes="25" type="button">Focus 25</button>
                    <button class="timer-mode" data-minutes="5" type="button">Break 5</button>
                    <button class="timer-mode" data-minutes="15" type="button">Long 15</button>
                </div>

                <div class="timer-display" id="timerDisplay">25:00</div>

                <div class="timer-controls">
                    <button class="primary-btn" id="startPause" type="button">▶ Start</button>
                    <button class="secondary-btn" id="resetTimer" type="button">↻ Reset</button>
                </div>

                <div class="session-note">
                    Focus sessions completed: <strong id="sessionCount">0</strong>
                </div>
            </section>

            <section class="card">
                <div class="tip">
                    <strong>💡 Study tip of the day</strong>
                    Focus on one task at a time. Try a 25-minute study session,
                    take a short break, and repeat.
                </div>
            </section>
        </div>

        <section class="card">
            <div class="card-heading">
                <div>
                    <h3>My Study Tasks</h3>
                    <p>Search, filter and manage your assignments.</p>
                </div>
                <span class="status"><%= total %> total</span>
            </div>

            <div class="task-toolbar">
                <input type="search" id="taskSearch" placeholder="🔎 Search tasks...">
                <button class="secondary-btn" id="clearSearch" type="button">Clear</button>
            </div>

            <div class="filters">
                <button type="button" class="filter-btn active" data-filter="all">All</button>
                <button type="button" class="filter-btn" data-filter="pending">Pending</button>
                <button type="button" class="filter-btn" data-filter="completed">Completed</button>
                <button type="button" class="filter-btn" data-filter="today">Due today</button>
                <button type="button" class="filter-btn" data-filter="overdue">Overdue</button>
            </div>

            <div id="taskList">
                <% if (!tasks.isEmpty()) {
                    for (Map<String, Object> task : tasks) {
                        String status = String.valueOf(task.get("status"));
                        boolean done = "Completed".equalsIgnoreCase(status);

                        String due = task.get("due_date") == null
                            ? "" : task.get("due_date").toString();

                        String dueClass = "";
                        String dueLabel = "Upcoming";

                        try {
                            LocalDate dueDate = LocalDate.parse(due.substring(0, 10));
                            if (!done && dueDate.isBefore(today)) {
                                dueClass = "overdue";
                                dueLabel = "Overdue";
                            } else if (!done && dueDate.isEqual(today)) {
                                dueClass = "today";
                                dueLabel = "Due today";
                            }
                        } catch (Exception ignored) { }

                        String title = task.get("title") == null
                            ? "" : task.get("title").toString();

                        String description = task.get("description") == null
                            || task.get("description").toString().trim().isEmpty()
                            ? "No description added."
                            : task.get("description").toString();
                %>

                <article class="task <%= done ? "completed" : "" %>"
                    data-status="<%= done ? "completed" : "pending" %>"
                    data-dueclass="<%= dueClass %>"
                    data-search="<%= esc(title + " " + description).toLowerCase() %>">

                    <div class="task-row">
                        <div class="task-main">
                            <h4><%= esc(title) %></h4>
                            <p><%= esc(description) %></p>
                            <p>📅 Deadline: <%= esc(due.isEmpty() ? "Not set" : due) %></p>
                        </div>

                        <span class="status <%= done ? "completed" : dueClass %>">
                            <%= done ? "Completed" : dueLabel %>
                        </span>
                    </div>

                    <div class="actions">
                        <% if (!done) { %>
                        <form action="<%= request.getContextPath() %>/studyplanner"
                              method="post">
                            <input type="hidden" name="action" value="complete">
                            <input type="hidden" name="taskId"
                                   value="<%= task.get("task_id") %>">
                            <button class="small-btn complete-btn" type="submit">
                                ✓ Mark Complete
                            </button>
                        </form>
                        <% } %>

                        <form action="<%= request.getContextPath() %>/studyplanner"
                              method="post"
                              onsubmit="return confirm('Are you sure you want to delete this task?');">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="taskId"
                                   value="<%= task.get("task_id") %>">
                            <button class="small-btn delete-btn" type="submit">
                                🗑 Delete
                            </button>
                        </form>
                    </div>
                </article>

                <% } } %>
            </div>

            <div class="empty" id="noResults"
                 style="<%= tasks.isEmpty() ? "" : "display:none" %>">
                <div class="empty-icon">📚</div>
                <strong>No tasks found</strong>
                <p>Add a new task or change your search/filter.</p>
            </div>
        </section>
    </div>

    <div class="footer">StudentSphere · Your campus, organized your way.</div>
</main>

<script>
(function () {
    const body = document.body;
    const themeToggle = document.getElementById("themeToggle");

    try {
        if (localStorage.getItem("ss-study-theme") === "dark") {
            body.classList.add("dark");
        }
    } catch (e) {}

    function updateThemeLabel() {
        themeToggle.textContent = body.classList.contains("dark")
            ? "☀️ Light Mode" : "🌙 Dark Mode";
    }

    updateThemeLabel();

    themeToggle.addEventListener("click", function () {
        body.classList.toggle("dark");
        try {
            localStorage.setItem(
                "ss-study-theme",
                body.classList.contains("dark") ? "dark" : "light"
            );
        } catch (e) {}
        updateThemeLabel();
    });

    document.getElementById("todayDate").textContent =
        new Date().toLocaleDateString(undefined, {
            weekday: "long", year: "numeric", month: "long", day: "numeric"
        });

    const searchInput = document.getElementById("taskSearch");
    const clearSearch = document.getElementById("clearSearch");
    const filterButtons = document.querySelectorAll(".filter-btn");
    const taskCards = Array.from(document.querySelectorAll("#taskList .task"));
    const noResults = document.getElementById("noResults");

    let activeFilter = "all";

    function filterTasks() {
        const query = searchInput.value.trim().toLowerCase();
        let visible = 0;

        taskCards.forEach(function (card) {
            const status = card.dataset.status;
            const due = card.dataset.dueclass;
            const matchesSearch = card.dataset.search.includes(query);

            let matchesFilter = true;

            if (activeFilter === "pending") matchesFilter = status === "pending";
            if (activeFilter === "completed") matchesFilter = status === "completed";
            if (activeFilter === "today") matchesFilter = due === "today";
            if (activeFilter === "overdue") matchesFilter = due === "overdue";

            const show = matchesSearch && matchesFilter;
            card.style.display = show ? "" : "none";

            if (show) visible++;
        });

        noResults.style.display = visible === 0 ? "" : "none";
    }

    searchInput.addEventListener("input", filterTasks);

    clearSearch.addEventListener("click", function () {
        searchInput.value = "";
        filterTasks();
        searchInput.focus();
    });

    filterButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            activeFilter = button.dataset.filter;

            filterButtons.forEach(function (item) {
                item.classList.toggle("active", item === button);
            });

            filterTasks();
        });
    });

    const dueDate = document.getElementById("dueDate");
    const localToday = new Date();
    const year = localToday.getFullYear();
    const month = String(localToday.getMonth() + 1).padStart(2, "0");
    const day = String(localToday.getDate()).padStart(2, "0");
    dueDate.min = year + "-" + month + "-" + day;

    let initialMinutes = 25;
    let remainingSeconds = initialMinutes * 60;
    let timerInterval = null;
    let running = false;
    let sessions = 0;

    const timerDisplay = document.getElementById("timerDisplay");
    const startPause = document.getElementById("startPause");
    const resetTimer = document.getElementById("resetTimer");
    const sessionCount = document.getElementById("sessionCount");
    const modeButtons = document.querySelectorAll(".timer-mode");

    function renderTimer() {
        const mins = Math.floor(remainingSeconds / 60);
        const secs = remainingSeconds % 60;

        timerDisplay.textContent =
            String(mins).padStart(2, "0") + ":" +
            String(secs).padStart(2, "0");
    }

    function stopTimer() {
        if (timerInterval !== null) {
            clearInterval(timerInterval);
            timerInterval = null;
        }
        running = false;
        startPause.textContent = "▶ Start";
    }

    function resetCountdown() {
        stopTimer();
        remainingSeconds = initialMinutes * 60;
        renderTimer();
    }

    function startCountdown() {
        if (running) {
            stopTimer();
            return;
        }

        if (remainingSeconds <= 0) {
            remainingSeconds = initialMinutes * 60;
            renderTimer();
        }

        running = true;
        startPause.textContent = "Ⅱ Pause";

        timerInterval = setInterval(function () {
            remainingSeconds--;
            renderTimer();

            if (remainingSeconds <= 0) {
                stopTimer();

                const activeMode = document.querySelector(".timer-mode.active");
                if (activeMode && activeMode.dataset.minutes === "25") {
                    sessions++;
                    sessionCount.textContent = sessions;
                }

                alert("Timer finished! Take a moment before your next session.");
            }
        }, 1000);
    }

    modeButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            modeButtons.forEach(function (item) {
                item.classList.toggle("active", item === button);
            });

            initialMinutes = Number(button.dataset.minutes);
            resetCountdown();
        });
    });

    startPause.addEventListener("click", startCountdown);
    resetTimer.addEventListener("click", resetCountdown);

    renderTimer();
})();
</script>
</body>
</html>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map" %>

<%!
    public String safe(Object value) {
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

    String ctx = request.getContextPath();

    List<Map<String,Object>> goals =
        (List<Map<String,Object>>) request.getAttribute("goals");

    List<Map<String,Object>> week =
        (List<Map<String,Object>>) request.getAttribute("weeklyActivity");

    List<Map<String,Object>> history =
        (List<Map<String,Object>>) request.getAttribute("recentLogs");

    int total = goals == null ? 0 : goals.size();
    int completed = 0;
    int active = 0;

    if (goals != null) {
        for (Map<String,Object> g : goals) {
            if ("Completed".equalsIgnoreCase(
                    String.valueOf(g.get("status")))) {
                completed++;
            } else {
                active++;
            }
        }
    }

    int overall = total == 0 ? 0 : completed * 100 / total;

    Integer todayMins = (Integer) request.getAttribute("todayMinutes");
    Integer yesterdayMins = (Integer) request.getAttribute("yesterdayMinutes");
    Integer streak = (Integer) request.getAttribute("streak");
    Integer todayActivities = (Integer) request.getAttribute("todayActivities");
    Integer todayCompleted = (Integer) request.getAttribute("todayCompleted");

    if (todayMins == null) todayMins = 0;
    if (yesterdayMins == null) yesterdayMins = 0;
    if (streak == null) streak = 0;
    if (todayActivities == null) todayActivities = 0;
    if (todayCompleted == null) todayCompleted = 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Personal Goals</title>

<style>
:root {
    --bg: #f4f3fc;
    --card: #ffffff;
    --text: #252344;
    --muted: #777792;
    --border: #e9e7f4;
    --accent: #7058ee;
    --accent2: #a17bff;
    --soft: #efebff;
    --shadow: 0 12px 35px rgba(58,43,116,.08);
}

body.dark {
    --bg: #111326;
    --card: #1d2038;
    --text: #f3f0ff;
    --muted: #b1b2ce;
    --border: #343653;
    --accent: #9681ff;
    --accent2: #b39cff;
    --soft: #302a50;
    --shadow: 0 12px 35px rgba(0,0,0,.2);
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: var(--text);
    background:
        radial-gradient(ellipse at 8% 8%, rgba(161,120,255,.14), transparent 35%),
        radial-gradient(ellipse at 90% 25%, rgba(238,132,181,.11), transparent 30%),
        var(--bg);
    transition: background .25s, color .25s;
}

header {
    padding: 17px 6%;
    background: var(--card);
    border-bottom: 1px solid var(--border);
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 14px;
    position: sticky;
    top: 0;
    z-index: 5;
}

.brand {
    font-size: 21px;
    font-weight: 800;
}

.brand span {
    color: var(--accent);
}

a {
    color: inherit;
    text-decoration: none;
}

button, input, select {
    font: inherit;
}

button {
    cursor: pointer;
    border: 0;
    border-radius: 11px;
    padding: 11px 15px;
    font-weight: 650;
}

.primary {
    color: white;
    background: linear-gradient(120deg, var(--accent), var(--accent2));
    box-shadow: 0 7px 18px rgba(112,88,238,.2);
}

.secondary {
    color: var(--text);
    background: var(--soft);
}

.container {
    max-width: 1180px;
    margin: 30px auto;
    padding: 0 22px;
}

.heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
    margin-bottom: 20px;
}

.heading h1 {
    margin: 0 0 7px;
    font-size: 30px;
}

.heading p {
    margin: 0;
    color: var(--muted);
    line-height: 1.6;
}

.hero {
    padding: 29px;
    color: white;
    border-radius: 22px;
    background: linear-gradient(120deg, #5140ca, #8062ee 60%, #b47cdb);
    box-shadow: var(--shadow);
    display: grid;
    grid-template-columns: 1fr auto;
    align-items: center;
    gap: 20px;
}

.hero small {
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 750;
    opacity: .85;
}

.hero h2 {
    margin: 12px 0 8px;
    font-size: 26px;
}

.hero p {
    margin: 0;
    line-height: 1.7;
    color: #f0edff;
}

.ring {
    width: 118px;
    height: 118px;
    border-radius: 50%;
    display: grid;
    place-items: center;
    background: conic-gradient(white var(--progress), rgba(255,255,255,.23) 0);
    position: relative;
}

.ring:before {
    content: "";
    position: absolute;
    inset: 9px;
    border-radius: 50%;
    background: #6652df;
}

.ring strong {
    position: relative;
    font-size: 25px;
}

.stats {
    display: grid;
    grid-template-columns: repeat(3, minmax(0,1fr));
    gap: 16px;
    margin: 20px 0;
}

.stat, .panel, .goal-card {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
}

.stat {
    padding: 19px 21px;
}

.stat small {
    display: block;
    color: var(--muted);
    margin-bottom: 8px;
}

.stat strong {
    font-size: 25px;
}

.stat-icon {
    float: right;
    font-size: 24px;
    background: var(--soft);
    border-radius: 12px;
    padding: 7px;
}

.panel {
    padding: 22px;
    margin: 21px 0;
}

.panel h2 {
    margin: 0 0 12px;
    font-size: 20px;
}

.muted {
    color: var(--muted);
    line-height: 1.6;
}

.chart-grid {
    display: grid;
    grid-template-columns: repeat(7, minmax(0,1fr));
    gap: 10px;
    align-items: end;
    min-height: 190px;
}

.chart-column {
    text-align: center;
    min-width: 0;
}

.chart-track {
    height: 130px;
    display: flex;
    align-items: flex-end;
}

.chart-bar {
    width: 100%;
    max-width: 44px;
    margin: auto;
    background: linear-gradient(180deg, var(--accent2), var(--accent));
    border-radius: 9px 9px 3px 3px;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

.field label {
    display: block;
    margin-bottom: 7px;
    font-size: 13px;
    font-weight: 700;
}

input, select {
    width: 100%;
    padding: 12px;
    border: 1px solid var(--border);
    border-radius: 11px;
    background: var(--card);
    color: var(--text);
    outline: none;
}

input:focus, select:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(112,88,238,.12);
}

.field.full {
    grid-column: 1 / -1;
}

.field.check label {
    display: flex;
    align-items: center;
    gap: 8px;
}

.field.check input {
    width: auto;
}

.form-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 17px;
}

.tools {
    display: flex;
    gap: 12px;
    margin: 18px 0;
}

.tools input {
    flex: 1;
    min-width: 150px;
}

.filters {
    display: flex;
    flex-wrap: wrap;
    gap: 9px;
}

.pill {
    border: 1px solid var(--border);
    color: var(--text);
    background: var(--card);
    border-radius: 25px;
    padding: 9px 15px;
}

.pill.active {
    background: var(--accent);
    color: white;
    border-color: var(--accent);
}

.goal-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0,1fr));
    gap: 17px;
    margin-top: 18px;
}

.goal-card {
    padding: 21px;
    min-width: 0;
}

.goal-card h3 {
    margin: 0 0 10px;
    font-size: 18px;
    overflow-wrap: anywhere;
}

.goal-icon {
    display: inline-grid;
    place-items: center;
    width: 43px;
    height: 43px;
    background: var(--soft);
    border-radius: 13px;
    font-size: 22px;
    margin-bottom: 12px;
}

.status {
    display: inline-block;
    padding: 5px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 750;
    background: #fff0d6;
    color: #925d00;
}

.status.done {
    background: #dcfce7;
    color: #166534;
}

.progress-label {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    color: var(--muted);
    font-size: 13px;
    margin: 18px 0 8px;
}

.track {
    height: 8px;
    background: var(--border);
    border-radius: 20px;
    overflow: hidden;
}

.fill {
    height: 100%;
    background: linear-gradient(90deg, var(--accent), var(--accent2));
}

.goal-meta {
    color: var(--muted);
    font-size: 13px;
    margin-top: 14px;
}

.goal-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
    border-top: 1px solid var(--border);
    padding-top: 15px;
    margin-top: 17px;
}

.goal-actions form {
    margin: 0;
}

.goal-actions button {
    font-size: 12px;
    padding: 9px 11px;
}

.danger {
    color: #bd344a;
    background: #ffe9ed;
}

.hidden {
    display: none !important;
}

.empty {
    text-align: center;
    color: var(--muted);
    padding: 35px 10px;
    line-height: 1.7;
}

.message {
    padding: 13px 16px;
    border-radius: 11px;
    margin: 18px 0;
}

.message.error {
    background: #ffe9ed;
    color: #a42143;
}

.message.success {
    background: #dcfce7;
    color: #166534;
}

.history-item {
    padding: 13px 0;
    border-bottom: 1px solid var(--border);
    overflow-wrap: anywhere;
}

.history-meta {
    color: var(--muted);
    font-size: 13px;
    margin-top: 6px;
}

footer {
    text-align: center;
    color: var(--muted);
    padding: 24px;
    font-size: 13px;
}

@media (max-width: 720px) {
    .goal-grid, .stats, .form-grid {
        grid-template-columns: 1fr;
    }

    .field.full {
        grid-column: auto;
    }

    .hero {
        grid-template-columns: 1fr;
    }

    .ring {
        width: 100px;
        height: 100px;
    }

    .container {
        padding: 0 14px;
        margin-top: 20px;
    }

    header {
        padding: 14px 5%;
    }

    .tools {
        flex-direction: column;
    }

    .chart-grid {
        gap: 4px;
    }

    .chart-column {
        font-size: 11px;
    }
}
</style>
</head>

<body>

<header>
    <div class="brand">🎯 Student<span>Sphere</span></div>

    <div style="display:flex;gap:10px;flex-wrap:wrap">
        <button class="secondary" id="themeBtn" type="button"
                onclick="toggleTheme()">🌙 Dark mode</button>

        <a class="secondary"
           style="padding:11px 14px;border-radius:11px"
           href="<%=ctx%>/dashboard.jsp">← Dashboard</a>
    </div>
</header>

<main class="container">

    <div class="heading">
        <div>
            <h1>Personal Goals</h1>
            <p>Small steps today. Big achievements tomorrow. ✨</p>
        </div>

        <button class="primary" type="button" onclick="toggleForm()">
            ＋ New Goal
        </button>
    </div>

    <section class="hero">
        <div>
            <small>Your progress at a glance</small>
            <h2>Keep moving forward!</h2>
            <p>You have completed <%=completed%> out of <%=total%> goals.
                Every step counts — keep building your future.</p>
        </div>

        <div class="ring" style="--progress:<%=overall%>%">
            <strong><%=overall%>%</strong>
        </div>
    </section>

    <section class="stats">
        <div class="stat">
            <span class="stat-icon">🚀</span>
            <small>Total goals</small>
            <strong><%=total%></strong>
        </div>

        <div class="stat">
            <span class="stat-icon">⚡</span>
            <small>Active goals</small>
            <strong><%=active%></strong>
        </div>

        <div class="stat">
            <span class="stat-icon">🏆</span>
            <small>Completed goals</small>
            <strong><%=completed%></strong>
        </div>
    </section>

    <section class="stats">
        <div class="stat">
            <span class="stat-icon">📚</span>
            <small>Today's study / work</small>
            <strong><%=todayMins/60%>h <%=todayMins%60%>m</strong>
        </div>

        <div class="stat">
            <span class="stat-icon">🔥</span>
            <small>Current streak</small>
            <strong><%=streak%> days</strong>
        </div>

        <div class="stat">
            <span class="stat-icon">✅</span>
            <small>Completed today</small>
            <strong><%=todayCompleted%></strong>
            <small><%=todayActivities%> activities logged</small>
        </div>
    </section>

    <section class="panel">
        <h2>📈 Your last 7 days</h2>
        <p class="muted">Daily study/work time. Compare today with yesterday.</p>

        <div class="chart-grid">
            <% if (week != null) {
                for (Map<String,Object> day : week) {
                    int minutes = (Integer) day.get("minutes");
                    int barHeight = Math.min(130,
                        minutes == 0 ? 4 : Math.max(8, minutes / 5));
            %>
                <div class="chart-column">
                    <div style="font-size:12px;color:var(--muted);margin-bottom:7px">
                        <%=minutes%>m
                    </div>

                    <div class="chart-track">
                        <div class="chart-bar"
                             title="<%=minutes%> minutes"
                             style="height:<%=barHeight%>px"></div>
                    </div>

                    <div style="font-size:12px;margin-top:8px;color:var(--muted)">
                        <%=safe(day.get("label"))%>
                    </div>
                </div>
            <%  }
               } %>
        </div>

        <p class="muted">
            Yesterday: <strong><%=yesterdayMins%> minutes</strong>
            · Today: <strong><%=todayMins%> minutes</strong>
        </p>
    </section>

    <section class="panel">
        <h2>📝 Daily check-in</h2>
        <p class="muted">
            Log your study session or progress on any personal goal.
            Every saved activity contributes to your streak.
        </p>

        <% if ("activity".equals(request.getParameter("error"))) { %>
            <div class="message error">
                Please enter a valid activity, date and duration (0–1440 minutes).
            </div>
        <% } %>

        <form action="<%=ctx%>/goals" method="post">
            <input type="hidden" name="action" value="log">

            <div class="form-grid">
                <div class="field full">
                    <label for="activityTitle">What did you work on? *</label>
                    <input id="activityTitle" name="activityTitle"
                           maxlength="150"
                           placeholder="e.g. Studied DBMS normalization" required>
                </div>

                <div class="field">
                    <label for="minutesSpent">Time spent (minutes) *</label>
                    <input id="minutesSpent" name="minutesSpent"
                           type="number" min="0" max="1440"
                           value="60" required>
                </div>

                <div class="field">
                    <label for="activityDate">Activity date *</label>
                    <input id="activityDate" name="activityDate"
                           type="date"
                           value="<%=java.time.LocalDate.now()%>"
                           max="<%=java.time.LocalDate.now()%>" required>
                </div>

                <div class="field full">
                    <label for="notes">Notes (optional)</label>
                    <input id="notes" name="notes" maxlength="500"
                           placeholder="What did you learn or finish?">
                </div>

                <div class="field full check">
                    <label>
                        <input type="checkbox" name="isCompleted" value="yes">
                        I completed this activity today
                    </label>
                </div>
            </div>

            <div class="form-actions">
                <button class="primary" type="submit">
                    Save Daily Check-in ✓
                </button>
            </div>
        </form>
    </section>

    <section class="panel">
        <h2>🗓 Recent activity history</h2>

        <% if (history != null && !history.isEmpty()) {
            for (Map<String,Object> log : history) {
        %>
            <div class="history-item">
                <strong><%=safe(log.get("activity_title"))%></strong>

                <div class="history-meta">
                    📅 <%=safe(log.get("activity_date"))%>
                    · ⏱ <%=safe(log.get("minutes_spent"))%> minutes
                    · <%=Boolean.TRUE.equals(log.get("is_completed"))
                        ? "✓ Completed" : "In progress"%>
                </div>

                <% if (log.get("notes") != null &&
                       !log.get("notes").toString().trim().isEmpty()) { %>
                    <p class="muted"><%=safe(log.get("notes"))%></p>
                <% } %>
            </div>
        <%  }
           } else { %>
            <p class="muted">
                No activity logged yet. Save your first daily check-in above!
            </p>
        <% } %>
    </section>

    <% if ("created".equals(request.getParameter("success"))) { %>
        <div class="message success">✓ Your goal was saved successfully!</div>
    <% } %>

    <% if ("empty".equals(request.getParameter("error"))) { %>
        <div class="message error">Please enter a goal title.</div>
    <% } %>

    <section class="panel hidden" id="goalForm">
        <h2>✨ Create a new goal</h2>

        <form action="<%=ctx%>/goals" method="post">
            <div class="form-grid">
                <div class="field full">
                    <label for="title">Goal title *</label>
                    <input id="title" name="title" maxlength="150"
                           placeholder="e.g. Complete DSA in Java" required>
                </div>

                <div class="field">
                    <label for="targetDate">Target date</label>
                    <input id="targetDate" name="targetDate" type="date">
                </div>
            </div>

            <div class="form-actions">
                <button class="primary" type="submit">Save Goal ✓</button>
                <button class="secondary" type="button" onclick="toggleForm()">
                    Cancel
                </button>
            </div>
        </form>
    </section>

    <section class="panel">
        <h2>My goals</h2>

        <div class="tools">
            <input type="search" id="search"
                   placeholder="🔍 Search your goals..."
                   oninput="filterGoals()">
        </div>

        <div class="filters">
            <button class="pill active" type="button"
                    onclick="setFilter('all',this)">All goals</button>
            <button class="pill" type="button"
                    onclick="setFilter('active',this)">In progress</button>
            <button class="pill" type="button"
                    onclick="setFilter('completed',this)">Completed</button>
        </div>

        <div class="goal-grid" id="goalGrid">
        <% if (goals != null && !goals.isEmpty()) {
            for (Map<String,Object> goal : goals) {
                String status = String.valueOf(goal.get("status"));
                boolean done = "Completed".equalsIgnoreCase(status);
                Object dateObject = goal.get("target_date");
                String date = dateObject == null ? "" : dateObject.toString();
        %>
            <article class="goal-card"
                     data-status="<%=done ? "completed" : "active"%>"
                     data-search="<%=safe(goal.get("title")).toLowerCase()%>">

                <div class="goal-icon"><%=done ? "🏆" : "🎯"%></div>

                <h3><%=safe(goal.get("title"))%></h3>

                <span class="status <%=done ? "done" : ""%>">
                    <%=safe(status)%>
                </span>

                <div class="progress-label">
                    <span>Goal progress</span>
                    <strong><%=done ? 100 : 0%>%</strong>
                </div>

                <div class="track">
                    <div class="fill" style="width:<%=done ? 100 : 0%>%"></div>
                </div>

                <div class="goal-meta">
                    📅 Target date:
                    <%=date.isEmpty() ? "Not set" : safe(date)%>
                </div>

                <div class="goal-actions">
                    <% if (!done) { %>
                        <form action="<%=ctx%>/goals" method="post">
                            <input type="hidden" name="action" value="complete">
                            <input type="hidden" name="goalId"
                                   value="<%=goal.get("goal_id")%>">
                            <button class="primary" type="submit">✓ Complete</button>
                        </form>
                    <% } else { %>
                        <form action="<%=ctx%>/goals" method="post">
                            <input type="hidden" name="action" value="progress">
                            <input type="hidden" name="goalId"
                                   value="<%=goal.get("goal_id")%>">
                            <button class="secondary" type="submit">↻ Reopen</button>
                        </form>
                    <% } %>

                    <form action="<%=ctx%>/goals" method="post"
                          onsubmit="return confirm('Delete this goal permanently?');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="goalId"
                               value="<%=goal.get("goal_id")%>">
                        <button class="danger" type="submit">🗑 Delete</button>
                    </form>
                </div>
            </article>
        <%  }
           } %>
        </div>

        <div class="empty <%=total > 0 ? "hidden" : ""%>" id="emptyMessage">
            <div style="font-size:42px">🌱</div>
            <h3>Your journey starts here!</h3>
            <p>Create your first goal and start tracking your progress.</p>
        </div>
    </section>
</main>

<footer>StudentSphere · Your goals, your journey, your growth.</footer>

<script>
let currentFilter = "all";

function toggleForm() {
    const form = document.getElementById("goalForm");
    form.classList.toggle("hidden");
    if (!form.classList.contains("hidden")) {
        form.scrollIntoView({behavior:"smooth", block:"start"});
    }
}

function setFilter(filter, button) {
    currentFilter = filter;
    document.querySelectorAll(".filters .pill").forEach(x =>
        x.classList.remove("active"));
    button.classList.add("active");
    filterGoals();
}

function filterGoals() {
    const q = document.getElementById("search").value.toLowerCase();
    let visible = 0;

    document.querySelectorAll(".goal-card").forEach(card => {
        const show = (currentFilter === "all" ||
                      card.dataset.status === currentFilter) &&
                      card.dataset.search.includes(q);
        card.classList.toggle("hidden", !show);
        if (show) visible++;
    });

    document.getElementById("emptyMessage")
        .classList.toggle("hidden", visible !== 0);
}

function applyTheme(dark) {
    document.body.classList.toggle("dark", dark);
    document.getElementById("themeBtn").textContent =
        dark ? "☀ Light mode" : "🌙 Dark mode";
}

function toggleTheme() {
    const dark = !document.body.classList.contains("dark");
    try {
        localStorage.setItem("ss-goals-dark", dark ? "yes" : "no");
    } catch (e) {}
    applyTheme(dark);
}

try {
    applyTheme(localStorage.getItem("ss-goals-dark") === "yes");
} catch (e) {
    applyTheme(false);
}

const targetInput = document.getElementById("targetDate");
if (targetInput) {
    const d = new Date();
    targetInput.min = d.getFullYear() + "-" +
        String(d.getMonth() + 1).padStart(2, "0") + "-" +
        String(d.getDate()).padStart(2, "0");
}
</script>

</body>
</html>

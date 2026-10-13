
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map" %>

<%!
    public String esc(Object value) {
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

    List<Map<String, Object>> events =
        (List<Map<String, Object>>) request.getAttribute("events");

    Object currentIdObj = session.getAttribute("userId");
    int currentUserId = currentIdObj instanceof Number
        ? ((Number) currentIdObj).intValue() : 0;

    String ctx = request.getContextPath();
    int totalEvents = events == null ? 0 : events.size();
    int hostedCount = 0;

    if (events != null) {
        for (Map<String, Object> ev : events) {
            Object creator = ev.get("created_by");
            if (creator instanceof Number
                    && ((Number) creator).intValue() == currentUserId) {
                hostedCount++;
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Campus Events</title>

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

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: var(--text);
    background:
        radial-gradient(ellipse at 10% 5%, rgba(161,120,255,.13), transparent 35%),
        radial-gradient(ellipse at 90% 25%, rgba(239,133,177,.11), transparent 30%),
        var(--bg);
    transition: background .25s, color .25s;
}

header {
    padding: 17px 6%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    background: var(--card);
    border-bottom: 1px solid var(--border);
    position: sticky;
    top: 0;
    z-index: 10;
}

.brand { font-size: 21px; font-weight: 800; }
.brand span { color: var(--accent); }

.header-actions {
    display: flex;
    gap: 10px;
    align-items: center;
    flex-wrap: wrap;
}

a { color: inherit; text-decoration: none; }

button, input, textarea, select { font: inherit; }

button {
    cursor: pointer;
    border: 0;
    border-radius: 11px;
    padding: 11px 16px;
    font-weight: 650;
    transition: transform .2s, opacity .2s;
}

button:hover { transform: translateY(-1px); }

.primary {
    color: white;
    background: linear-gradient(120deg, var(--accent), var(--accent2));
    box-shadow: 0 7px 18px rgba(112,88,238,.22);
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

.hero {
    padding: 35px;
    border-radius: 23px;
    color: white;
    background: linear-gradient(120deg, #5140ca, #8062ee 60%, #b47cdb);
    box-shadow: var(--shadow);
    overflow: hidden;
    position: relative;
}

.hero:after {
    content: "✦";
    position: absolute;
    right: 45px;
    top: 8px;
    font-size: 120px;
    opacity: .13;
    pointer-events: none;
}

.eyebrow {
    font-size: 12px;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    font-weight: 800;
    opacity: .85;
}

.hero h1 { font-size: clamp(27px, 4vw, 39px); margin: 12px 0; }
.hero p { line-height: 1.7; max-width: 650px; color: #f0edff; }
.hero button { background: white; color: #5743c9; margin-top: 8px; }

.stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
    margin: 22px 0;
}

.stat, .panel, .event-card {
    background: var(--card);
    border: 1px solid var(--border);
    border-radius: 18px;
    box-shadow: var(--shadow);
}

.stat { padding: 19px 22px; }
.stat small { color: var(--muted); display: block; margin-bottom: 8px; }
.stat strong { font-size: 25px; }

.panel { padding: 23px; margin: 22px 0; }
.panel h2 { margin: 0 0 17px; font-size: 20px; }

.search-row { display: flex; gap: 12px; margin: 22px 0 15px; }

input, textarea, select {
    width: 100%;
    border: 1px solid var(--border);
    background: var(--card);
    color: var(--text);
    border-radius: 11px;
    padding: 12px 13px;
    outline: none;
}

input:focus, textarea:focus, select:focus {
    border-color: var(--accent);
    box-shadow: 0 0 0 3px rgba(112,88,238,.12);
}

textarea { min-height: 95px; resize: vertical; }

.tabs, .filters {
    display: flex;
    flex-wrap: wrap;
    gap: 9px;
    margin: 16px 0;
}

.pill {
    background: var(--card);
    color: var(--text);
    border: 1px solid var(--border);
    border-radius: 25px;
    padding: 9px 16px;
}

.pill.active {
    background: var(--accent);
    color: white;
    border-color: var(--accent);
}

.event-grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 18px;
    margin-top: 18px;
}

.event-card {
    padding: 21px;
    min-width: 0;
    transition: transform .2s, border-color .2s;
}

.event-card:hover { transform: translateY(-3px); border-color: var(--accent); }

.event-top { display: flex; gap: 14px; align-items: flex-start; }

.date-box {
    min-width: 65px;
    text-align: center;
    padding: 12px 7px;
    border-radius: 14px;
    background: var(--soft);
    color: var(--accent);
    font-weight: 800;
}

.date-box small { display: block; margin-bottom: 4px; font-size: 12px; }
.event-title { margin: 0 0 8px; font-size: 19px; overflow-wrap: anywhere; }

.event-description {
    color: var(--muted);
    line-height: 1.65;
    margin: 15px 0;
    overflow-wrap: anywhere;
}

.category {
    display: inline-block;
    border-radius: 20px;
    padding: 5px 10px;
    background: var(--soft);
    color: var(--accent);
    font-size: 12px;
    font-weight: 750;
    margin-bottom: 7px;
}

.meta { color: var(--muted); font-size: 14px; line-height: 1.9; }

.seat-track {
    height: 7px;
    border-radius: 20px;
    background: var(--border);
    overflow: hidden;
    margin: 12px 0 7px;
}

.seat-fill {
    height: 100%;
    background: linear-gradient(90deg, #24b47e, #8ad6b1);
    border-radius: inherit;
}

.host-label { color: var(--muted); font-size: 12px; }

.empty { color: var(--muted); text-align: center; padding: 35px 10px; }

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 15px;
}

.field label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 7px;
}

.field.full { grid-column: 1 / -1; }
.form-actions { display: flex; gap: 10px; flex-wrap: wrap; margin-top: 18px; }

.message { padding: 13px 16px; border-radius: 11px; margin: 18px 0; }
.message.error { background: #ffe9ed; color: #a42143; }
.message.success { background: #dcfce7; color: #166534; }

.hidden { display: none !important; }

footer { text-align: center; color: var(--muted); padding: 24px; font-size: 13px; }

@media (max-width: 720px) {
    .event-grid, .stats, .form-grid { grid-template-columns: 1fr; }
    .field.full { grid-column: auto; }
    header { padding: 15px 5%; }
    .container { padding: 0 14px; margin-top: 18px; }
    .hero { padding: 25px 21px; }
    .search-row { flex-direction: column; }
}
</style>
</head>

<body>
<header>
    <div class="brand">🎓 Student<span>Sphere</span></div>
    <div class="header-actions">
        <button class="secondary" id="themeBtn" type="button"
                onclick="toggleTheme()">🌙 Dark mode</button>
        <a class="secondary" style="padding:11px 14px;border-radius:11px"
           href="<%= ctx %>/dashboard.jsp">← Dashboard</a>
    </div>
</header>

<main class="container">

    <section class="hero">
        <div class="eyebrow">Discover · Connect · Participate</div>
        <h1>Campus Events ✨</h1>
        <p>
            Find your next hackathon, workshop, seminar or campus celebration.
            Have an idea? Host an event and bring your campus community together.
        </p>
        <button type="button" onclick="showHostForm()">＋ Host an Event</button>
    </section>

    <section class="stats">
        <div class="stat">
            <small>🎉 Events listed</small>
            <strong><%= totalEvents %></strong>
        </div>
        <div class="stat">
            <small>🗓 Your hosted events</small>
            <strong><%= hostedCount %></strong>
        </div>
        <div class="stat">
            <small>🌟 Explore</small>
            <strong>Something new</strong>
        </div>
    </section>

    <% if ("created".equals(request.getParameter("success"))) { %>
        <div class="message success">✓ Your event has been created successfully!</div>
    <% } %>

    <% if ("empty".equals(request.getParameter("error"))) { %>
        <div class="message error">Please fill in the event title, date and venue.</div>
    <% } else if ("invalid".equals(request.getParameter("error"))) { %>
        <div class="message error">Please check the event details and seat capacity.</div>
    <% } else if ("date".equals(request.getParameter("error"))) { %>
        <div class="message error">Please select today or a future date.</div>
    <% } %>

    <section class="panel hidden" id="hostPanel">
        <h2>✦ Host Your Event</h2>
        <p style="color:var(--muted);line-height:1.6">
            Share the details below to publish your event for other students.
        </p>

        <form action="<%= ctx %>/events" method="post">
            <div class="form-grid">
                <div class="field full">
                    <label for="title">Event title *</label>
                    <input id="title" name="title" maxlength="150"
                           placeholder="e.g. Inter-College Hackathon" required>
                </div>

                <div class="field full">
                    <label for="description">Description</label>
                    <textarea id="description" name="description" maxlength="2000"
                              placeholder="What is the event about? Who can participate?"></textarea>
                </div>

                <div class="field">
                    <label for="category">Category</label>
                    <select id="category" name="category">
                        <option>Hackathon</option>
                        <option>Workshop</option>
                        <option>Seminar</option>
                        <option>Cultural</option>
                        <option>Sports</option>
                        <option>Other</option>
                    </select>
                </div>

                <div class="field">
                    <label for="venue">Venue *</label>
                    <input id="venue" name="venue" maxlength="150"
                           placeholder="e.g. Main Auditorium" required>
                </div>

                <div class="field">
                    <label for="eventDate">Event date *</label>
                    <input id="eventDate" name="eventDate" type="date" required>
                </div>

                <div class="field">
                    <label for="eventTime">Start time</label>
                    <input id="eventTime" name="eventTime" type="time">
                </div>

                <div class="field">
                    <label for="capacity">Seat capacity</label>
                    <input id="capacity" name="capacity" type="number"
                           min="1" max="100000" value="100" required>
                </div>
            </div>

            <div class="form-actions">
                <button class="primary" type="submit">Publish Event →</button>
                <button class="secondary" type="button"
                        onclick="showHostForm()">Cancel</button>
            </div>
        </form>
    </section>

    <section class="panel">
        <h2>Find your next experience</h2>

        <div class="search-row">
            <input type="search" id="searchBox"
                   placeholder="🔍 Search by event, venue or description..."
                   oninput="filterEvents()">
        </div>

        <div class="tabs">
            <button type="button" class="pill active" data-tab="all"
                    onclick="setTab('all', this)">All events</button>
            <button type="button" class="pill" data-tab="hosted"
                    onclick="setTab('hosted', this)">My hosted events</button>
        </div>

        <div class="filters">
            <button type="button" class="pill active" data-category="all"
                    onclick="setCategory('all', this)">All</button>
            <button type="button" class="pill" data-category="hackathon"
                    onclick="setCategory('hackathon', this)">Hackathon</button>
            <button type="button" class="pill" data-category="workshop"
                    onclick="setCategory('workshop', this)">Workshop</button>
            <button type="button" class="pill" data-category="seminar"
                    onclick="setCategory('seminar', this)">Seminar</button>
            <button type="button" class="pill" data-category="cultural"
                    onclick="setCategory('cultural', this)">Cultural</button>
            <button type="button" class="pill" data-category="sports"
                    onclick="setCategory('sports', this)">Sports</button>
            <button type="button" class="pill" data-category="other"
                    onclick="setCategory('other', this)">Other</button>
        </div>

        <div class="event-grid" id="eventGrid">
        <% if (events != null && !events.isEmpty()) {
               for (Map<String, Object> event : events) {
                   Object categoryObj = event.get("category");
                   String category = categoryObj == null
                       ? "Other" : categoryObj.toString();

                   Object creator = event.get("created_by");
                   boolean mine = creator instanceof Number
                       && ((Number) creator).intValue() == currentUserId;

                   Object dateObj = event.get("event_date");
                   String dateText = dateObj == null ? "" : dateObj.toString();
                   String day = "";
                   String month = "";

                   if (dateText.length() >= 10) {
                       day = dateText.substring(8, 10);
                       String m = dateText.substring(5, 7);
                       String[] months = {"Jan","Feb","Mar","Apr","May","Jun",
                           "Jul","Aug","Sep","Oct","Nov","Dec"};
                       try {
                           month = months[Integer.parseInt(m) - 1];
                       } catch (Exception ignored) {
                           month = "";
                       }
                   }

                   Object timeObj = event.get("event_time");
                   String timeText = timeObj == null
                       ? "Time to be announced" : timeObj.toString();
                   if (timeText.length() >= 5) {
                       timeText = timeText.substring(0, 5);
                   }

                   Object capacityObj = event.get("capacity");
                   int capacity = capacityObj instanceof Number
                       ? ((Number) capacityObj).intValue() : 100;
                   if (capacity < 1) capacity = 100;
        %>
            <article class="event-card"
                data-category="<%= esc(category.toLowerCase()) %>"
                data-mine="<%= mine %>"
                data-search="<%= esc(
                    String.valueOf(event.get("title")) + " "
                    + String.valueOf(event.get("venue")) + " "
                    + String.valueOf(event.get("description"))).toLowerCase() %>">

                <div class="event-top">
                    <div class="date-box">
                        <small><%= esc(month) %></small>
                        <%= esc(day) %>
                    </div>

                    <div style="min-width:0">
                        <span class="category"><%= esc(category) %></span>
                        <h3 class="event-title"><%= esc(event.get("title")) %></h3>
                        <% if (mine) { %>
                            <span class="host-label">✦ Hosted by you</span>
                        <% } %>
                    </div>
                </div>

                <p class="event-description"><%= esc(
                    event.get("description") == null
                    || event.get("description").toString().trim().isEmpty()
                    ? "More details will be announced soon."
                    : event.get("description")) %></p>

                <div class="meta">
                    🕒 <%= esc(timeText) %><br>
                    📍 <%= esc(event.get("venue")) %>
                </div>

                <div class="seat-track">
                    <div class="seat-fill" style="width:100%"></div>
                </div>
                <div class="host-label">
                    Capacity: <%= capacity %> seats
                </div>
            </article>
        <%     }
           } %>
        </div>

        <div class="empty <%= totalEvents > 0 ? "hidden" : "" %>"
             id="emptyMessage">
            <div style="font-size:38px">🎪</div>
            <h3>No matching events</h3>
            <p>Try another category, or host an event for your campus.</p>
        </div>
    </section>
</main>

<footer>StudentSphere · Your campus, your community.</footer>

<script>
let selectedCategory = "all";
let selectedTab = "all";

function showHostForm() {
    const panel = document.getElementById("hostPanel");
    panel.classList.toggle("hidden");

    if (!panel.classList.contains("hidden")) {
        panel.scrollIntoView({ behavior: "smooth", block: "start" });
    }
}

function setCategory(category, button) {
    selectedCategory = category;

    document.querySelectorAll("[data-category]").forEach(b =>
        b.classList.remove("active"));

    button.classList.add("active");
    filterEvents();
}

function setTab(tab, button) {
    selectedTab = tab;

    document.querySelectorAll("[data-tab]").forEach(b =>
        b.classList.remove("active"));

    button.classList.add("active");
    filterEvents();
}

function filterEvents() {
    const query = document.getElementById("searchBox").value.toLowerCase();
    let visible = 0;

    document.querySelectorAll(".event-card").forEach(card => {
        const matchesCategory = selectedCategory === "all"
            || card.dataset.category === selectedCategory;
        const matchesTab = selectedTab === "all"
            || card.dataset.mine === "true";
        const matchesSearch = card.dataset.search.includes(query);

        const show = matchesCategory && matchesTab && matchesSearch;
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
        localStorage.setItem("ss-events-dark", dark ? "yes" : "no");
    } catch (e) {}

    applyTheme(dark);
}

try {
    applyTheme(localStorage.getItem("ss-events-dark") === "yes");
} catch (e) {
    applyTheme(false);
}

const dateInput = document.getElementById("eventDate");
const today = new Date();

dateInput.min = today.getFullYear() + "-"
    + String(today.getMonth() + 1).padStart(2, "0") + "-"
    + String(today.getDate()).padStart(2, "0");
</script>

</body>
</html>

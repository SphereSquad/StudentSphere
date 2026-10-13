<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map,java.util.Set,java.util.HashMap,java.util.HashSet" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%!
    private String safeText(Object value) {
        if (value == null) return "";
        return value.toString()
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private String iconFor(String name) {
        if (name == null) return "🤝";
        String n = name.toLowerCase();

        if (n.contains("coding") || n.contains("tech")) return "💻";
        if (n.contains("ai") || n.contains("innovation")) return "🤖";
        if (n.contains("cultural") || n.contains("drama")) return "🎭";
        if (n.contains("music")) return "🎸";
        if (n.contains("sport") || n.contains("cricket")) return "🏏";
        if (n.contains("photo")) return "📸";
        if (n.contains("entrepreneur") || n.contains("career")) return "🚀";
        if (n.contains("literary") || n.contains("writing")) return "📚";
        if (n.contains("social") || n.contains("service")) return "🤝";
        return "🌟";
    }

    private String categoryFor(String name) {
        if (name == null) return "Community";
        String n = name.toLowerCase();

        if (n.contains("coding") || n.contains("tech")
                || n.contains("ai") || n.contains("robot")
                || n.contains("innovation")) return "Tech";

        if (n.contains("cultural") || n.contains("drama")
                || n.contains("music") || n.contains("literary")
                || n.contains("photo") || n.contains("art")) return "Arts";

        if (n.contains("sport") || n.contains("cricket")) return "Sports";
        if (n.contains("career") || n.contains("entrepreneur")) return "Career";
        if (n.contains("social") || n.contains("service")) return "Social";

        return "Community";
    }
%>

<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Map<String, Object>> clubs =
        (List<Map<String, Object>>) request.getAttribute("clubs");

    List<Map<String, Object>> announcements =
        (List<Map<String, Object>>) request.getAttribute("announcements");

    List<Map<String, Object>> events =
        (List<Map<String, Object>>) request.getAttribute("events");

    Map<Integer, String> membershipStatuses =
        (Map<Integer, String>) request.getAttribute("membershipStatuses");

    Set<Integer> registeredEventIds =
        (Set<Integer>) request.getAttribute("registeredEventIds");

    if (clubs == null) clubs = new java.util.ArrayList<>();
    if (announcements == null) announcements = new java.util.ArrayList<>();
    if (events == null) events = new java.util.ArrayList<>();
    if (membershipStatuses == null) membershipStatuses = new HashMap<>();
    if (registeredEventIds == null) registeredEventIds = new HashSet<>();

    int joinedCount = request.getAttribute("joinedCount") == null
        ? 0 : (Integer) request.getAttribute("joinedCount");

    int pendingCount = request.getAttribute("pendingCount") == null
        ? 0 : (Integer) request.getAttribute("pendingCount");

    String result = request.getParameter("result");
    String currentUserId = String.valueOf(session.getAttribute("userId"));

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Clubs &amp; Community</title>

<style>
:root {
    --bg: #f5f4ff;
    --surface: #ffffff;
    --text: #242044;
    --muted: #77748f;
    --border: #e9e6f7;
    --primary: #6854e8;
    --soft: #efebff;
    --shadow: 0 12px 30px rgba(64,48,130,.08);
}

* { box-sizing: border-box; }

body {
    margin: 0;
    font-family: "Segoe UI", Arial, sans-serif;
    color: var(--text);
    background:
        radial-gradient(ellipse at 8% 5%, #e7e0ff, transparent 32%),
        radial-gradient(ellipse at 95% 30%, #fce6f2, transparent 28%),
        var(--bg);
    min-height: 100vh;
}

body.dark {
    --bg: #111226;
    --surface: #1c1d36;
    --text: #f2efff;
    --muted: #b5b1d0;
    --border: #34344f;
    --primary: #9584ff;
    --soft: #30294d;
    --shadow: 0 12px 30px rgba(0,0,0,.2);
    background: radial-gradient(ellipse at 8% 5%, #2c244c, transparent 32%), var(--bg);
}

button, input, textarea { font: inherit; }
button { cursor: pointer; }

.topbar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 15px 5%;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
}

.brand {
    display: flex;
    align-items: center;
    gap: 10px;
    font-size: 19px;
    font-weight: 800;
}

.logo {
    width: 42px;
    height: 42px;
    border-radius: 14px;
    display: grid;
    place-items: center;
    color: white;
    font-size: 23px;
    background: linear-gradient(135deg, #4f3ac9, #a477ed);
}

.nav-actions { display: flex; gap: 8px; align-items: center; }

.nav-link, .theme-btn {
    padding: 10px 13px;
    border: 1px solid var(--border);
    border-radius: 11px;
    text-decoration: none;
    color: var(--text);
    background: var(--surface);
    font-size: 12px;
}

.container { max-width: 1250px; margin: auto; padding: 28px 22px 55px; }
.heading { margin-bottom: 22px; }
.eyebrow { color: var(--primary); font-size: 11px; font-weight: 800; letter-spacing: 1.5px; text-transform: uppercase; }
h1 { margin: 8px 0; font-size: clamp(27px, 4vw, 36px); }
.subtitle { color: var(--muted); line-height: 1.6; margin: 0; }

.hero {
    display: grid;
    grid-template-columns: 1fr auto;
    gap: 22px;
    align-items: center;
    padding: 32px;
    border-radius: 24px;
    color: white;
    background: linear-gradient(120deg, #4936c6, #765bea 60%, #a477ed);
    box-shadow: 0 17px 35px rgba(94,68,211,.2);
    margin-bottom: 22px;
}

.hero h2 { margin: 0 0 9px; font-size: clamp(22px, 3vw, 31px); }
.hero p { margin: 0; color: #eeeaff; line-height: 1.7; max-width: 680px; }

.stats { display: flex; gap: 9px; }
.stat { min-width: 82px; text-align: center; padding: 14px 10px; border-radius: 15px; background: #ffffff24; border: 1px solid #ffffff40; }
.stat strong { display: block; font-size: 24px; }
.stat span { font-size: 11px; }

.notice {
    padding: 13px 16px;
    margin-bottom: 18px;
    border-radius: 12px;
    background: var(--soft);
    color: var(--text);
    font-size: 13px;
    line-height: 1.6;
    border: 1px solid var(--border);
}

.section-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin: 30px 0 15px;
}

.section-heading h2 { margin: 0; font-size: 21px; }
.count { color: var(--muted); font-size: 12px; }

.tabs, .filters { display: flex; gap: 8px; flex-wrap: wrap; margin-bottom: 17px; }

.tab, .filter {
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--text);
    border-radius: 25px;
    padding: 10px 15px;
    font-size: 12px;
}

.tab.active, .filter.active, .primary-btn {
    color: white;
    background: var(--primary);
    border-color: var(--primary);
}

.search {
    width: 100%;
    padding: 13px 15px;
    border: 1px solid var(--border);
    border-radius: 13px;
    background: var(--surface);
    color: var(--text);
    outline: none;
    margin-bottom: 14px;
}

.grid {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 17px;
}

.card {
    min-width: 0;
    display: flex;
    flex-direction: column;
    padding: 21px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 19px;
    box-shadow: var(--shadow);
    transition: transform .2s;
}

.card:hover { transform: translateY(-3px); }

.card-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 10px;
    margin-bottom: 15px;
}

.club-icon {
    width: 54px;
    height: 54px;
    border-radius: 17px;
    display: grid;
    place-items: center;
    background: var(--soft);
    font-size: 27px;
}

.badge {
    padding: 6px 9px;
    border-radius: 20px;
    background: var(--soft);
    color: var(--primary);
    font-size: 10px;
    font-weight: 750;
}

.card h3 { font-size: 18px; margin: 0 0 9px; overflow-wrap: anywhere; }
.desc { color: var(--muted); font-size: 13px; line-height: 1.7; margin: 0 0 15px; flex: 1; overflow-wrap: anywhere; }
.meta { font-size: 11px; color: var(--muted); line-height: 1.9; margin-bottom: 14px; }
.actions { display: flex; gap: 8px; flex-wrap: wrap; margin-top: auto; }

.actions form { margin: 0; }

.primary-btn, .secondary-btn, .danger-btn {
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 10px 12px;
    font-size: 12px;
    font-weight: 700;
}

.primary-btn { background: var(--primary); }
.secondary-btn { background: var(--soft); color: var(--primary); }
.danger-btn { background: transparent; color: #d34e69; border-color: #e8a0b0; }
.primary-btn:hover { filter: brightness(.94); }

.empty {
    grid-column: 1 / -1;
    text-align: center;
    padding: 30px 18px;
    border: 1px dashed var(--border);
    border-radius: 16px;
    color: var(--muted);
    background: var(--surface);
    line-height: 1.7;
}

.announcements { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }

.announcement {
    display: flex;
    gap: 13px;
    padding: 18px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 16px;
    box-shadow: var(--shadow);
}

.ann-icon { font-size: 22px; background: var(--soft); border-radius: 12px; padding: 10px; height: 44px; }
.announcement h3 { margin: 0 0 7px; font-size: 15px; overflow-wrap: anywhere; }
.announcement p { margin: 0 0 9px; color: var(--muted); font-size: 13px; line-height: 1.65; overflow-wrap: anywhere; }
.small { color: var(--muted); font-size: 11px; line-height: 1.7; }
.footer { border-top: 1px solid var(--border); text-align: center; padding: 22px; color: var(--muted); font-size: 12px; }

@media (max-width: 1000px) {
    .grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
    .hero { grid-template-columns: 1fr; }
}

@media (max-width: 650px) {
    .container { padding: 20px 14px 40px; }
    .topbar { padding: 12px 4%; }
    .brand { font-size: 15px; }
    .nav-link, .theme-btn { padding: 9px; font-size: 10px; }
    .grid, .announcements { grid-template-columns: 1fr; }
    .hero { padding: 23px 18px; }
    .stats { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); }
    .stat { min-width: 0; padding: 12px 5px; }
    .stat strong { font-size: 20px; }
}
</style>
<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/theme.css">
</head>

<body>

<header class="topbar">
    <div class="brand">
        <div class="logo">🤝</div>
        StudentSphere
    </div>

    <div class="nav-actions">
        <button type="button" class="theme-btn" id="themeToggle">🌙 Dark mode</button>
        <a class="nav-link" href="<%= request.getContextPath() %>/dashboard.jsp">← Dashboard</a>
    </div>
</header>

<main class="container">

    <section class="heading">
        <div class="eyebrow">Campus life · Connections · Growth</div>
        <h1>Clubs &amp; Community</h1>
        <p class="subtitle">Find your people, discover new interests and make campus life memorable.</p>
    </section>

    <section class="hero">
        <div>
            <h2>Find your community ✨</h2>
            <p>Explore student clubs, join communities, discover upcoming events and stay updated with campus announcements.</p>
        </div>

        <div class="stats">
            <div class="stat"><strong><%= clubs.size() %></strong><span>Clubs</span></div>
            <div class="stat"><strong><%= joinedCount %></strong><span>My clubs</span></div>
            <div class="stat"><strong><%= pendingCount %></strong><span>Pending</span></div>
        </div>
    </section>

    <% if ("joined".equals(result)) { %>
        <div class="notice">✅ You have successfully joined the club.</div>
    <% } else if ("request_submitted".equals(result)) { %>
        <div class="notice">📨 Your membership request has been submitted.</div>
    <% } else if ("already_joined".equals(result)) { %>
        <div class="notice">ℹ️ You are already a member of this club.</div>
    <% } else if ("already_pending".equals(result)) { %>
        <div class="notice">ℹ️ Your request is already pending.</div>
    <% } else if ("left".equals(result)) { %>
        <div class="notice">👋 You have left the club.</div>
    <% } else if ("not_joined".equals(result)) { %>
        <div class="notice">You are not currently an active member of this club.</div>
    <% } else if ("registered".equals(result)) { %>
        <div class="notice">🎉 Event registration successful!</div>
    <% } else if ("already_registered".equals(result)) { %>
        <div class="notice">ℹ️ You have already registered for this event.</div>
    <% } else if ("event_full".equals(result)) { %>
        <div class="notice">Sorry, this event has reached its capacity.</div>
    <% } else if ("event_past".equals(result)) { %>
        <div class="notice">Registration is closed because this event has passed.</div>
    <% } else if ("event_not_found".equals(result)) { %>
        <div class="notice">The selected event could not be found.</div>
    <% } else if ("club_created".equals(result)) { %>
        <div class="notice">✅ Club created successfully. You can now manage it.</div>
    <% } else if ("duplicate_club".equals(result)) { %>
        <div class="notice">ℹ️ A club with this name already exists.</div>
    <% } else if ("club_deleted".equals(result)) { %>
        <div class="notice">🗑️ Your club has been deleted successfully.</div>
    <% } else if ("delete_denied".equals(result)) { %>
        <div class="notice">⛔ Only the creator of a club can delete it.</div>
    <% } else if ("invalid_club".equals(result)) { %>
        <div class="notice">Please enter a valid club name and description.</div>
    <% } else if ("error".equals(result)) { %>
        <div class="notice">Something went wrong. Please try again.</div>
    <% } %>

    <div class="section-heading">
        <h2>➕ Create a club</h2>
        <span class="count">Create and manage your community</span>
    </div>

    <section class="card" style="margin-bottom:22px">
        <form method="post" action="<%= request.getContextPath() %>/clubs">
            <input type="hidden" name="action" value="createClub">

            <label class="small" for="clubName">Club name</label>
            <input id="clubName" name="clubName" class="search"
                   type="text" maxlength="100" required
                   placeholder="e.g. Robotics Club">

            <label class="small" for="clubDescription">Description</label>
            <textarea id="clubDescription" name="description"
                      maxlength="1000" rows="3" class="search"
                      style="resize:vertical"
                      placeholder="What is your club about?"></textarea>

            <button type="submit" class="primary-btn">Create club</button>
        </form>
    </section>

    <div class="section-heading">
        <h2>🌟 Discover clubs</h2>
        <span class="count" id="clubCount"><%= clubs.size() %> clubs</span>
    </div>

    <div class="tabs" id="viewTabs">
        <button type="button" class="tab active" data-view="explore">Explore</button>
        <button type="button" class="tab" data-view="joined">My Clubs</button>
        <button type="button" class="tab" data-view="pending">My Requests</button>
    </div>

    <input type="search" class="search" id="clubSearch"
           placeholder="🔍 Search clubs by name or description...">

    <div class="filters" id="filters">
        <button type="button" class="filter active" data-category="All">All</button>
        <button type="button" class="filter" data-category="Tech">💻 Tech</button>
        <button type="button" class="filter" data-category="Arts">🎨 Arts</button>
        <button type="button" class="filter" data-category="Sports">🏏 Sports</button>
        <button type="button" class="filter" data-category="Career">🚀 Career</button>
        <button type="button" class="filter" data-category="Social">🤝 Social</button>
        <button type="button" class="filter" data-category="Community">🌟 Other</button>
    </div>

    <section class="grid" id="clubGrid">

    <% if (clubs.isEmpty()) { %>
        <div class="empty">No clubs have been added yet. Create one above!</div>
    <% } else {
        for (Map<String, Object> club : clubs) {
            int clubId = ((Number) club.get("club_id")).intValue();

            String name = club.get("club_name") == null
                ? "Student Club" : club.get("club_name").toString();

            String description = club.get("description") == null
                || club.get("description").toString().trim().isEmpty()
                ? "Discover activities, connect with students and explore shared interests."
                : club.get("description").toString();

            String category = categoryFor(name);
            String status = membershipStatuses.get(clubId);
            boolean approval = Boolean.TRUE.equals(club.get("requires_approval"));
            int memberCount = ((Number) club.get("member_count")).intValue();

            Object creator = club.get("created_by");
            boolean isCreator = creator != null
                && currentUserId.equals(String.valueOf(creator));
    %>

        <article class="card club-card"
                 data-category="<%= category %>"
                 data-status="<%= status == null ? "NONE" : status %>"
                 data-search="<%= safeText((name + " " + description + " " + category).toLowerCase()) %>">

            <div class="card-top">
                <div class="club-icon"><%= iconFor(name) %></div>
                <span class="badge"><%= category %></span>
            </div>

            <h3><%= safeText(name) %></h3>
            <p class="desc"><%= safeText(description) %></p>

            <div class="meta">
                👥 <%= memberCount %> members
                &nbsp; · &nbsp;
                <%= approval ? "Approval required" : "Open to all" %>
            </div>

            <div class="actions">

            <% if ("JOINED".equals(status)) { %>
                <button type="button" class="secondary-btn" disabled>✓ Joined</button>

                <form method="post" action="<%= request.getContextPath() %>/clubs"
                      onsubmit="return confirm('Are you sure you want to leave this club?');">
                    <input type="hidden" name="action" value="leave">
                    <input type="hidden" name="clubId" value="<%= clubId %>">
                    <button class="danger-btn" type="submit">Leave club</button>
                </form>

            <% } else if ("PENDING".equals(status)) { %>
                <button type="button" class="secondary-btn" disabled>⌛ Request pending</button>

            <% } else { %>
                <form method="post" action="<%= request.getContextPath() %>/clubs">
                    <input type="hidden" name="action" value="join">
                    <input type="hidden" name="clubId" value="<%= clubId %>">

                    <button class="primary-btn" type="submit">
                        <%= approval ? "Request to join" : "Join club" %>
                    </button>
                </form>
            <% } %>

            <% if (isCreator) { %>
                <form method="post" action="<%= request.getContextPath() %>/clubs"
                      onsubmit="return confirm('Delete this club permanently? Its announcements and memberships will also be removed. This cannot be undone.');">

                    <input type="hidden" name="action" value="deleteClub">
                    <input type="hidden" name="clubId" value="<%= clubId %>">

                    <button type="submit" class="danger-btn">🗑️ Delete club</button>
                </form>
            <% } %>

            </div>
        </article>

    <%  }
    } %>

        <div class="empty" id="noClubResults" style="display:none">
            No matching clubs found. Try another search or tab.
        </div>
    </section>

    <div class="section-heading">
        <h2>📅 Upcoming events</h2>
        <span class="count"><%= events.size() %> events</span>
    </div>

    <section class="grid">

    <% if (events.isEmpty()) { %>
        <div class="empty">No upcoming events yet. Check back soon for campus activities.</div>
    <% } else {
        for (Map<String, Object> event : events) {
            int eventId = ((Number) event.get("event_id")).intValue();

            String eventTitle = event.get("title") == null
                ? "Campus Event" : event.get("title").toString();

            int capacity = ((Number) event.get("capacity")).intValue();
            int registered = ((Number) event.get("registered_count")).intValue();
            boolean isRegistered = registeredEventIds.contains(eventId);
            boolean isFull = capacity > 0 && registered >= capacity;

            Object eventDate = event.get("event_date");
            Object eventTime = event.get("event_time");
    %>

        <article class="card">
            <div class="card-top">
                <div class="club-icon">🎉</div>
                <span class="badge"><%= safeText(event.get("category")) %></span>
            </div>

            <h3><%= safeText(eventTitle) %></h3>
            <p class="desc"><%= safeText(event.get("description")) %></p>

            <div class="meta">
                📆 <%= eventDate == null ? "Date to be announced" : dateFormat.format(eventDate) %>
                <br>
                🕒 <%= eventTime == null ? "Time to be announced" : timeFormat.format(eventTime) %>
                <br>
                📍 <%= event.get("venue") == null ? "Venue to be announced" : safeText(event.get("venue")) %>
                <br>
                👥 <%= registered %> registered
                <% if (capacity > 0) { %> / <%= capacity %> seats <% } %>
            </div>

            <div class="actions">
            <% if (isRegistered) { %>
                <button class="secondary-btn" type="button" disabled>✓ Registered</button>
            <% } else if (isFull) { %>
                <button class="secondary-btn" type="button" disabled>Event full</button>
            <% } else { %>
                <form method="post" action="<%= request.getContextPath() %>/clubs">
                    <input type="hidden" name="action" value="registerEvent">
                    <input type="hidden" name="eventId" value="<%= eventId %>">
                    <button type="submit" class="primary-btn">Register for event</button>
                </form>
            <% } %>
            </div>
        </article>

    <%  }
    } %>

    </section>

    <div class="section-heading">
        <h2>📢 Latest announcements</h2>
        <span class="count"><%= announcements.size() %> updates</span>
    </div>

    <section class="announcements">

    <% if (announcements.isEmpty()) { %>
        <div class="empty">No announcements available right now.</div>
    <% } else {
        for (Map<String, Object> item : announcements) {
    %>

        <article class="announcement">
            <div class="ann-icon">📣</div>
            <div>
                <h3><%= safeText(item.get("title")) %></h3>
                <p><%= safeText(item.get("message")) %></p>

                <div class="small">
                    🏷️ <%= item.get("club_name") == null
                        ? "Campus Community" : safeText(item.get("club_name")) %>
                    <br>
                    🕒
                    <%
                        Object createdAt = item.get("created_at");
                        if (createdAt instanceof java.util.Date) {
                            out.print(dateFormat.format(createdAt));
                        }
                    %>
                </div>
            </div>
        </article>

    <%  }
    } %>

    </section>
</main>

<footer class="footer">
    StudentSphere · Connecting students, ideas and opportunities 💜
</footer>

<script>
(function () {
    const body = document.body;
    const themeButton = document.getElementById("themeToggle");

    try {
        if (localStorage.getItem("studentsphere-theme") === "dark") {
            body.classList.add("dark");
        }
    } catch (e) {}

    function updateThemeButton() {
        themeButton.textContent = body.classList.contains("dark")
            ? "☀️ Light mode" : "🌙 Dark mode";
    }

    updateThemeButton();

    themeButton.addEventListener("click", function () {
        body.classList.toggle("dark");
        updateThemeButton();

        try {
            localStorage.setItem(
                "studentsphere-theme",
                body.classList.contains("dark") ? "dark" : "light"
            );
        } catch (e) {}
    });

    const search = document.getElementById("clubSearch");
    const cards = Array.from(document.querySelectorAll(".club-card"));
    const filters = Array.from(document.querySelectorAll(".filter"));
    const tabs = Array.from(document.querySelectorAll(".tab"));
    const noResults = document.getElementById("noClubResults");
    const clubCount = document.getElementById("clubCount");

    let category = "All";
    let view = "explore";

    function applyFilters() {
        const query = search.value.trim().toLowerCase();
        let count = 0;

        cards.forEach(function (card) {
            const matchesSearch =
                card.dataset.search.includes(query);

            const matchesCategory =
                category === "All" || card.dataset.category === category;

            const status = card.dataset.status;

            let matchesView = true;

            if (view === "joined") {
                matchesView = status === "JOINED";
            } else if (view === "pending") {
                matchesView = status === "PENDING";
            }

            const visible =
                matchesSearch && matchesCategory && matchesView;

            card.style.display = visible ? "" : "none";

            if (visible) count++;
        });

        noResults.style.display = count === 0 ? "" : "none";
        clubCount.textContent = count + " clubs";
    }

    search.addEventListener("input", applyFilters);

    filters.forEach(function (button) {
        button.addEventListener("click", function () {
            category = button.dataset.category;

            filters.forEach(function (b) {
                b.classList.toggle("active", b === button);
            });

            applyFilters();
        });
    });

    tabs.forEach(function (button) {
        button.addEventListener("click", function () {
            view = button.dataset.view;

            tabs.forEach(function (b) {
                b.classList.toggle("active", b === button);
            });

            applyFilters();
        });
    });

    applyFilters();
})();
</script>
<script src="<%= request.getContextPath() %>/js/theme.js"></script>
</body>
</html>
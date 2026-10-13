
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List,java.util.Map,java.util.LinkedHashMap,java.math.BigDecimal,java.text.DecimalFormat" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<Map<String, Object>> expenses =
        (List<Map<String, Object>>) request.getAttribute("expenses");

    BigDecimal total = (BigDecimal) request.getAttribute("totalExpenses");
    if (total == null) total = BigDecimal.ZERO;
    if (expenses == null) expenses = new java.util.ArrayList<>();

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    Map<String, BigDecimal> categoryTotals = new LinkedHashMap<>();
    String[] categories = {"Food", "Travel", "Education", "Shopping", "Bills", "Other"};

    for (String category : categories) {
        categoryTotals.put(category, BigDecimal.ZERO);
    }

    for (Map<String, Object> expense : expenses) {
        String category = String.valueOf(expense.get("category"));
        if (!categoryTotals.containsKey(category)) {
            categoryTotals.put(category, BigDecimal.ZERO);
        }

        BigDecimal amount = (BigDecimal) expense.get("amount");
        if (amount != null) {
            categoryTotals.put(category, categoryTotals.get(category).add(amount));
        }
    }

    String userName = (String) session.getAttribute("userName");
    int expenseCount = expenses.size();

    BigDecimal average = expenseCount == 0 ? BigDecimal.ZERO :
        total.divide(BigDecimal.valueOf(expenseCount), 2, java.math.RoundingMode.HALF_UP);

    String[] categoryIcons = {"🍔", "🚌", "📚", "🛍️", "💡", "📦"};
    String[] categoryNames = {"Food", "Travel", "Education", "Shopping", "Bills", "Other"};
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>StudentSphere | Expense Tracker</title>

<style>
:root {
    --bg: #f6f3ff;
    --surface: rgba(255,255,255,.91);
    --surface-solid: #ffffff;
    --text: #252044;
    --muted: #77738f;
    --border: #ebe6fa;
    --primary: #7257e8;
    --primary2: #9676ff;
    --pink: #df78b8;
    --green: #10a879;
    --red: #e45d70;
    --shadow: 0 12px 35px rgba(66,48,130,.08);
}

* { box-sizing: border-box; }

body {
    margin: 0;
    min-height: 100vh;
    font-family: "Segoe UI", Arial, sans-serif;
    color: var(--text);
    background:
        radial-gradient(ellipse at 8% 5%, rgba(175,145,255,.32), transparent 32%),
        radial-gradient(ellipse at 94% 15%, rgba(255,168,216,.28), transparent 29%),
        radial-gradient(ellipse at 75% 90%, rgba(155,177,255,.23), transparent 32%),
        linear-gradient(135deg, #f8f5ff, #f0edff 55%, #fff4fa);
    background-attachment: fixed;
    transition: background .25s, color .25s;
}

body::before {
    content: "";
    position: fixed;
    inset: 0;
    pointer-events: none;
    z-index: -1;
    opacity: .22;
    background-image: radial-gradient(#9986d9 .8px, transparent .8px);
    background-size: 24px 24px;
}

.topbar {
    padding: 17px 5%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 14px;
    flex-wrap: wrap;
    color: white;
    background: linear-gradient(110deg, #30245d, #5841a3 60%, #8658b8);
    box-shadow: 0 7px 25px rgba(49,34,100,.2);
}

.brand {
    display: flex;
    align-items: center;
    gap: 12px;
}

.brand-icon {
    display: grid;
    place-items: center;
    width: 45px;
    height: 45px;
    border-radius: 14px;
    font-size: 23px;
    background: rgba(255,255,255,.16);
    border: 1px solid rgba(255,255,255,.22);
}

.brand h2 { margin: 0; font-size: 20px; }
.brand p { margin: 4px 0 0; font-size: 12px; color: #e0d8ff; }

.top-actions { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }

.top-actions a, .top-actions button {
    text-decoration: none;
    color: white;
    border: 1px solid rgba(255,255,255,.24);
    background: rgba(255,255,255,.12);
    border-radius: 10px;
    padding: 10px 13px;
    font: inherit;
    font-size: 13px;
    cursor: pointer;
    margin: 0;
}

.top-actions a:hover, .top-actions button:hover {
    background: rgba(255,255,255,.22);
}

.container {
    max-width: 1250px;
    margin: 30px auto;
    padding: 0 24px 35px;
}

.page-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 16px;
    margin-bottom: 23px;
}

.page-heading h1 {
    font-size: clamp(25px, 3vw, 34px);
    margin: 0 0 8px;
    letter-spacing: -.7px;
}

.page-heading p { margin: 0; color: var(--muted); line-height: 1.6; }

.welcome-pill {
    padding: 11px 15px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 13px;
    color: var(--muted);
    font-size: 13px;
    box-shadow: var(--shadow);
}

.hero {
    position: relative;
    overflow: hidden;
    color: white;
    padding: 27px 30px;
    border-radius: 22px;
    margin-bottom: 22px;
    background:
        radial-gradient(circle at 90% 10%, rgba(255,255,255,.22), transparent 23%),
        linear-gradient(115deg, #5136c8 0%, #8262ef 55%, #d879bd 115%);
    box-shadow: 0 17px 40px rgba(99,70,196,.22);
}

.hero::after {
    content: "₹";
    position: absolute;
    right: 45px;
    top: -35px;
    font-size: 170px;
    font-weight: 800;
    color: rgba(255,255,255,.09);
    transform: rotate(-12deg);
    pointer-events: none;
}

.hero h2 { margin: 0 0 9px; font-size: 23px; position: relative; z-index: 1; }
.hero p { margin: 0; max-width: 640px; color: #eee8ff; line-height: 1.7; position: relative; z-index: 1; }

.stats {
    display: grid;
    grid-template-columns: repeat(4, minmax(0,1fr));
    gap: 17px;
    margin-bottom: 23px;
}

.stat {
    position: relative;
    overflow: hidden;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 19px;
    padding: 21px;
    box-shadow: var(--shadow);
    transition: transform .22s, box-shadow .22s;
}

.stat:hover, .card:hover {
    transform: translateY(-3px);
    box-shadow: 0 18px 40px rgba(66,48,130,.12);
}

.stat-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
    margin-bottom: 15px;
}

.stat-icon {
    display: grid;
    place-items: center;
    width: 42px;
    height: 42px;
    border-radius: 13px;
    background: #eee8ff;
    font-size: 21px;
}

.stat-label { color: var(--muted); font-size: 13px; }
.stat-value { font-size: clamp(20px, 2vw, 27px); font-weight: 800; overflow-wrap: anywhere; }
.stat-note { font-size: 12px; color: var(--muted); margin-top: 9px; }

.stat.primary {
    color: white;
    border: none;
    background: linear-gradient(135deg, #5c43d5, #9274f6);
}

.stat.primary .stat-label, .stat.primary .stat-note { color: #eee9ff; }
.stat.primary .stat-icon { background: rgba(255,255,255,.17); }

.content-grid {
    display: grid;
    grid-template-columns: minmax(0,1.05fr) minmax(0,1fr);
    gap: 21px;
    align-items: start;
}

.card {
    min-width: 0;
    padding: 23px;
    margin-bottom: 21px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 21px;
    box-shadow: var(--shadow);
    backdrop-filter: blur(12px);
    transition: transform .22s, box-shadow .22s;
}

.card h3 { margin: 0 0 6px; font-size: 18px; }
.card-subtitle { color: var(--muted); font-size: 13px; margin: 0 0 19px; line-height: 1.5; }

label {
    display: block;
    font-size: 13px;
    font-weight: 700;
    margin: 15px 0 7px;
}

input, select {
    width: 100%;
    min-width: 0;
    padding: 12px 13px;
    border: 1px solid var(--border);
    border-radius: 11px;
    font: inherit;
    font-size: 14px;
    color: var(--text);
    background: var(--surface-solid);
    outline: none;
    transition: border .2s, box-shadow .2s;
}

input:focus, select:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(114,87,232,.13);
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 13px;
}

.btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    border: none;
    border-radius: 11px;
    background: linear-gradient(110deg, var(--primary), var(--primary2));
    color: white;
    padding: 12px 16px;
    font: inherit;
    font-weight: 700;
    font-size: 14px;
    cursor: pointer;
    box-shadow: 0 7px 17px rgba(114,87,232,.18);
    transition: transform .2s, opacity .2s;
}

.btn:hover { transform: translateY(-1px); opacity: .93; }
.btn-wide { width: 100%; margin-top: 20px; }

.message {
    padding: 12px 14px;
    margin: 0 0 15px;
    border-radius: 11px;
    background: #fff0f0;
    color: #b42318;
    font-size: 13px;
    line-height: 1.5;
}

.section-title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 12px;
    flex-wrap: wrap;
    margin-bottom: 17px;
}

.count-badge {
    background: #eee8ff;
    color: #6548cf;
    padding: 6px 10px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 700;
}

.chart-total {
    display: flex;
    align-items: center;
    gap: 23px;
    padding: 10px 0 15px;
}

.donut {
    width: 150px;
    height: 150px;
    flex-shrink: 0;
    border-radius: 50%;
    display: grid;
    place-items: center;
    position: relative;
    background: conic-gradient(#ded7f7 0deg 360deg);
}

.donut::before {
    content: "";
    position: absolute;
    width: 100px;
    height: 100px;
    border-radius: 50%;
    background: var(--surface-solid);
}

.donut-center { position: relative; text-align: center; }
.donut-center strong { display: block; font-size: 17px; }
.donut-center span { display: block; font-size: 11px; color: var(--muted); margin-top: 4px; }

.legend { flex: 1; min-width: 0; }
.legend-row {
    display: flex;
    justify-content: space-between;
    gap: 10px;
    font-size: 12px;
    margin: 12px 0;
    align-items: center;
}

.legend-name { display: flex; gap: 8px; align-items: center; min-width: 0; }
.legend-name span:last-child { overflow-wrap: anywhere; }
.legend-value { white-space: nowrap; font-weight: 700; }

.dot { width: 9px; height: 9px; border-radius: 3px; flex-shrink: 0; }
.category-list { margin-top: 13px; }
.category-row { margin: 18px 0; }
.category-info { display: flex; justify-content: space-between; gap: 12px; font-size: 13px; margin-bottom: 8px; }
.category-info span:last-child { color: var(--muted); white-space: nowrap; }
.track { height: 8px; border-radius: 20px; overflow: hidden; background: #e9e5f7; }
.track-fill { height: 100%; border-radius: inherit; transition: width .35s ease; }

.filters {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin: 17px 0 13px;
}

.filter-btn {
    border: 1px solid var(--border);
    color: var(--text);
    background: var(--surface-solid);
    border-radius: 30px;
    padding: 8px 13px;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
}

.filter-btn.active {
    color: white;
    background: var(--primary);
    border-color: var(--primary);
}

.search-box { margin: 0 0 12px; }

.transaction {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 15px 0;
    border-bottom: 1px solid var(--border);
}

.transaction:last-child { border-bottom: none; }

.transaction-icon {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 43px;
    height: 43px;
    border-radius: 14px;
    background: #eee8ff;
    font-size: 20px;
}

.transaction-info { flex: 1; min-width: 0; }
.transaction-info h4 { margin: 0 0 6px; font-size: 14px; overflow-wrap: anywhere; }
.transaction-meta { font-size: 12px; color: var(--muted); line-height: 1.5; overflow-wrap: anywhere; }
.transaction-amount { font-weight: 800; font-size: 14px; white-space: nowrap; }

.delete-form { margin: 0; }
.delete-btn {
    border: none;
    background: transparent;
    color: #a6a0bd;
    font-size: 18px;
    padding: 5px 7px;
    cursor: pointer;
    border-radius: 8px;
}
.delete-btn:hover { color: var(--red); background: #fff0f2; }

.empty {
    text-align: center;
    padding: 27px 12px;
    color: var(--muted);
    font-size: 14px;
    line-height: 1.7;
}

.empty-icon { display: block; font-size: 36px; margin-bottom: 9px; }

.footer { text-align: center; padding: 13px; color: var(--muted); font-size: 12px; }

body.dark {
    --bg: #171528;
    --surface: rgba(35,31,58,.94);
    --surface-solid: #26213f;
    --text: #f2efff;
    --muted: #b4aecf;
    --border: #40375f;
    --shadow: 0 12px 35px rgba(0,0,0,.18);

    background:
        radial-gradient(ellipse at 8% 5%, rgba(105,73,190,.25), transparent 32%),
        radial-gradient(ellipse at 95% 20%, rgba(172,71,140,.16), transparent 29%),
        linear-gradient(135deg, #171528, #211b38 58%, #281c33);
    background-attachment: fixed;
}

body.dark::before { opacity: .08; background-image: radial-gradient(#c4b6ff .8px, transparent .8px); }
body.dark .track { background: #40375c; }
body.dark .stat-icon, body.dark .transaction-icon { background: #3a305d; }
body.dark .count-badge { background: #3b305e; color: #d5c9ff; }
body.dark .filter-btn { background: var(--surface-solid); }
body.dark .filter-btn.active { background: var(--primary); }
body.dark .message { background: #482b3a; color: #ffbdc6; }
body.dark .delete-btn:hover { background: #482b3a; }
body.dark .donut::before { background: var(--surface-solid); }

@media (max-width: 950px) {
    .stats { grid-template-columns: repeat(2, minmax(0,1fr)); }
    .content-grid { grid-template-columns: 1fr; }
}

@media (max-width: 560px) {
    .container { padding: 0 14px 25px; margin-top: 20px; }
    .topbar { padding: 15px; }
    .hero { padding: 23px 20px; }
    .card { padding: 18px; }
    .form-row { grid-template-columns: 1fr; gap: 0; }
    .chart-total { flex-direction: column; }
    .legend { width: 100%; }
    .stats { gap: 10px; }
    .stat { padding: 15px; }
    .stat-icon { width: 35px; height: 35px; }
    .transaction { gap: 8px; }
    .transaction-icon { width: 36px; height: 36px; }
    .transaction-amount { font-size: 12px; }
}
</style>
<link rel="stylesheet"
      href="<%= request.getContextPath() %>/css/theme.css">
</head>

<body>
<header class="topbar">
    <div class="brand">
        <div class="brand-icon">💰</div>
        <div>
            <h2>StudentSphere</h2>
            <p>PERSONAL FINANCE SPACE</p>
        </div>
    </div>
    <div class="top-actions">
        <a href="<%= request.getContextPath() %>/dashboard.jsp">← Dashboard</a>
        <button type="button" id="themeToggle">🌙 Dark mode</button>
    </div>
</header>

<main class="container">
    <section class="page-heading">
        <div>
            <h1>Expense Tracker</h1>
            <p>Make smarter money decisions. Every rupee has a purpose. ✨</p>
        </div>
        <div class="welcome-pill">
            👋 Hello, <%= userName == null ? "Student" : userName.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") %>
        </div>
    </section>

    <section class="hero">
        <h2>Your money, your goals. 💜</h2>
        <p>Track everyday expenses, understand your spending habits and build better financial habits while you study.</p>
    </section>

    <section class="stats">
        <div class="stat primary">
            <div class="stat-top">
                <span class="stat-label">Total recorded spending</span>
                <span class="stat-icon">💳</span>
            </div>
            <div class="stat-value">₹<%= moneyFormat.format(total) %></div>
            <div class="stat-note">Across all saved expenses</div>
        </div>

        <div class="stat">
            <div class="stat-top">
                <span class="stat-label">Transactions</span>
                <span class="stat-icon">🧾</span>
            </div>
            <div class="stat-value"><%= expenseCount %></div>
            <div class="stat-note">Expenses recorded</div>
        </div>

        <div class="stat">
            <div class="stat-top">
                <span class="stat-label">Average per expense</span>
                <span class="stat-icon">📊</span>
            </div>
            <div class="stat-value">₹<%= moneyFormat.format(average) %></div>
            <div class="stat-note">Average transaction amount</div>
        </div>

        <div class="stat">
            <div class="stat-top">
                <span class="stat-label">Top category</span>
                <span class="stat-icon">🎯</span>
            </div>
            <div class="stat-value" id="topCategory">—</div>
            <div class="stat-note">Based on recorded spending</div>
        </div>
    </section>

    <div class="content-grid">
        <div>
            <section class="card">
                <h3>＋ Add an expense</h3>
                <p class="card-subtitle">Record a purchase and keep your spending organized.</p>

                <% if ("empty".equals(request.getParameter("error"))) { %>
                    <p class="message">Please fill in the title, amount and date.</p>
                <% } else if ("invalid".equals(request.getParameter("error"))) { %>
                    <p class="message">Enter a valid positive amount (up to two decimal places) and date.</p>
                <% } %>

                <form action="<%= request.getContextPath() %>/expensetracker" method="post">
                    <label for="title">Expense title *</label>
                    <input id="title" name="title" maxlength="150"
                           placeholder="e.g. Lunch at canteen" required>

                    <div class="form-row">
                        <div>
                            <label for="amount">Amount (₹) *</label>
                            <input id="amount" name="amount" type="number"
                                   min="0.01" max="99999999.99" step="0.01"
                                   placeholder="e.g. 150.00" required>
                        </div>
                        <div>
                            <label for="category">Category</label>
                            <select id="category" name="category">
                                <option value="Food">🍔 Food</option>
                                <option value="Travel">🚌 Travel</option>
                                <option value="Education">📚 Education</option>
                                <option value="Shopping">🛍️ Shopping</option>
                                <option value="Bills">💡 Bills</option>
                                <option value="Other">📦 Other</option>
                            </select>
                        </div>
                    </div>

                    <label for="expenseDate">Expense date *</label>
                    <input id="expenseDate" name="expenseDate" type="date" required>

                    <button class="btn btn-wide" type="submit">＋ Save expense</button>
                </form>
            </section>

            <section class="card">
                <h3>Spending by category</h3>
                <p class="card-subtitle">See how your recorded expenses are distributed.</p>

                <div class="chart-total">
                    <div class="donut" id="donut">
                        <div class="donut-center">
                            <strong>₹<%= moneyFormat.format(total) %></strong>
                            <span>Total recorded</span>
                        </div>
                    </div>
                    <div class="legend" id="legend">
                        <% for (int i = 0; i < categoryNames.length; i++) {
                            BigDecimal catAmount = categoryTotals.get(categoryNames[i]);
                            if (catAmount == null) catAmount = BigDecimal.ZERO;
                        %>
                            <div class="legend-row">
                                <div class="legend-name">
                                    <span class="dot" data-category="<%= categoryNames[i] %>"></span>
                                    <span><%= categoryIcons[i] %> <%= categoryNames[i] %></span>
                                </div>
                                <span class="legend-value">₹<%= moneyFormat.format(catAmount) %></span>
                            </div>
                        <% } %>
                    </div>
                </div>
            </section>

            <section class="card">
                <h3>Category breakdown</h3>
                <p class="card-subtitle">Your spending in each category.</p>

                <div class="category-list">
                    <% for (int i = 0; i < categoryNames.length; i++) {
                        BigDecimal catAmount = categoryTotals.get(categoryNames[i]);
                        if (catAmount == null) catAmount = BigDecimal.ZERO;

                        int percentage = total.compareTo(BigDecimal.ZERO) > 0
                            ? catAmount.multiply(BigDecimal.valueOf(100))
                                .divide(total, 0, java.math.RoundingMode.HALF_UP).intValue()
                            : 0;

                        if (percentage > 100) percentage = 100;
                    %>
                        <div class="category-row">
                            <div class="category-info">
                                <span><%= categoryIcons[i] %> <%= categoryNames[i] %></span>
                                <span>₹<%= moneyFormat.format(catAmount) %> · <%= percentage %>%</span>
                            </div>
                            <div class="track">
                                <div class="track-fill category-bar"
                                     data-category="<%= categoryNames[i] %>"
                                     data-value="<%= percentage %>"
                                     style="width:<%= percentage %>%"></div>
                            </div>
                        </div>
                    <% } %>
                </div>
            </section>
        </div>

        <div>
            <section class="card">
                <div class="section-title">
                    <div>
                        <h3>Recent transactions</h3>
                        <p class="card-subtitle" style="margin:6px 0 0">Your saved expense history.</p>
                    </div>
                    <span class="count-badge"><%= expenseCount %> records</span>
                </div>

                <input class="search-box" type="search" id="searchInput"
                       placeholder="🔎 Search expenses...">

                <div class="filters" id="filters">
                    <button class="filter-btn active" type="button" data-filter="All">All</button>
                    <button class="filter-btn" type="button" data-filter="Food">Food</button>
                    <button class="filter-btn" type="button" data-filter="Travel">Travel</button>
                    <button class="filter-btn" type="button" data-filter="Education">Education</button>
                    <button class="filter-btn" type="button" data-filter="Shopping">Shopping</button>
                    <button class="filter-btn" type="button" data-filter="Bills">Bills</button>
                    <button class="filter-btn" type="button" data-filter="Other">Other</button>
                </div>

                <div id="transactionList">
                    <% if (!expenses.isEmpty()) {
                        for (Map<String, Object> expense : expenses) {
                            String title = String.valueOf(expense.get("title"));
                            String safeTitle = title.replace("&", "&amp;")
                                .replace("<", "&lt;").replace(">", "&gt;")
                                .replace("\"", "&quot;").replace("'", "&#39;");

                            String category = expense.get("category") == null
                                ? "Other" : String.valueOf(expense.get("category"));

                            String safeCategory = category.replace("&", "&amp;")
                                .replace("<", "&lt;").replace(">", "&gt;")
                                .replace("\"", "&quot;");

                            BigDecimal amount = (BigDecimal) expense.get("amount");
                            if (amount == null) amount = BigDecimal.ZERO;

                            String date = String.valueOf(expense.get("expense_date"));
                            String icon = "📦";
                            if ("Food".equals(category)) icon = "🍔";
                            else if ("Travel".equals(category)) icon = "🚌";
                            else if ("Education".equals(category)) icon = "📚";
                            else if ("Shopping".equals(category)) icon = "🛍️";
                            else if ("Bills".equals(category)) icon = "💡";
                    %>
                        <article class="transaction"
                                 data-title="<%= safeTitle.toLowerCase() %>"
                                 data-category="<%= safeCategory %>">
                            <div class="transaction-icon"><%= icon %></div>
                            <div class="transaction-info">
                                <h4><%= safeTitle %></h4>
                                <div class="transaction-meta">
                                    <%= safeCategory %> · <%= date %>
                                </div>
                            </div>
                            <div class="transaction-amount">
                                −₹<%= moneyFormat.format(amount) %>
                            </div>
                            <form class="delete-form"
                                  action="<%= request.getContextPath() %>/expensetracker"
                                  method="post"
                                  onsubmit="return confirm('Delete this expense?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="expenseId"
                                       value="<%= expense.get("expense_id") %>">
                                <button class="delete-btn" type="submit"
                                        title="Delete expense" aria-label="Delete expense">×</button>
                            </form>
                        </article>
                    <%  }
                    } else { %>
                        <div class="empty" id="emptyState">
                            <span class="empty-icon">🪙</span>
                            <strong>No expenses yet</strong><br>
                            Add your first expense using the form.
                        </div>
                    <% } %>
                    <div class="empty" id="noResults" style="display:none">
                        No matching expenses found. Try another search or category.
                    </div>
                </div>
            </section>

            <section class="card">
                <h3>Smart spending insights ✨</h3>
                <p class="card-subtitle">A quick overview based on your actual records.</p>
                <div class="category-info">
                    <span>Number of recorded expenses</span>
                    <strong><%= expenseCount %></strong>
                </div>
                <div class="category-info">
                    <span>Largest category total</span>
                    <strong id="largestCategoryAmount">₹0.00</strong>
                </div>
                <div class="category-info">
                    <span>Average expense amount</span>
                    <strong>₹<%= moneyFormat.format(average) %></strong>
                </div>
                <p class="card-subtitle" style="margin:16px 0 0">
                    Tip: Review your category breakdown regularly to identify where you can save.
                </p>
            </section>
        </div>
    </div>

    <div class="footer">StudentSphere · Spend thoughtfully. Save confidently. 💜</div>
</main>

<script>
(function () {
    const body = document.body;
    const themeButton = document.getElementById("themeToggle");

    function applyTheme(dark) {
        body.classList.toggle("dark", dark);
        themeButton.textContent = dark ? "☀️ Light mode" : "🌙 Dark mode";
        try {
            localStorage.setItem("ss-expense-theme", dark ? "dark" : "light");
        } catch (e) {}
    }

    let savedTheme = "light";
    try {
        savedTheme = localStorage.getItem("ss-expense-theme") || "light";
    } catch (e) {}

    applyTheme(savedTheme === "dark");
    themeButton.addEventListener("click", function () {
        applyTheme(!body.classList.contains("dark"));
    });

    const dateInput = document.getElementById("expenseDate");
    if (dateInput && !dateInput.value) {
        const today = new Date();
        const localDate = today.getFullYear() + "-" +
            String(today.getMonth() + 1).padStart(2, "0") + "-" +
            String(today.getDate()).padStart(2, "0");
        dateInput.value = localDate;
    }

    const palette = {
        Food: "#8b6cf0",
        Travel: "#36a4e8",
        Education: "#e9a13c",
        Shopping: "#e95b8b",
        Bills: "#13b78a",
        Other: "#9c91b8"
    };

    document.querySelectorAll(".dot").forEach(function (dot) {
        dot.style.background = palette[dot.dataset.category] || palette.Other;
    });

    const bars = Array.from(document.querySelectorAll(".category-bar"));
    bars.forEach(function (bar) {
        bar.style.background = palette[bar.dataset.category] || palette.Other;
    });

    let totalForChart = 0;
    const values = [];

    document.querySelectorAll("#legend .legend-row").forEach(function (row) {
        const name = row.querySelector(".legend-name span:last-child").textContent;
        const amountText = row.querySelector(".legend-value").textContent
            .replace("₹", "").replace(/,/g, "").trim();
        const amount = Number(amountText) || 0;
        totalForChart += amount;
        values.push({name: name, amount: amount});
    });

    let angle = 0;
    const segments = [];

    values.forEach(function (item) {
        const category = item.name.replace(/^[^\s]+\s/, "").trim();
        const color = palette[category] || palette.Other;
        const nextAngle = totalForChart > 0
            ? angle + (item.amount / totalForChart) * 360 : angle;

        if (item.amount > 0) {
            segments.push(color + " " + angle + "deg " + nextAngle + "deg");
        }
        angle = nextAngle;
    });

    const donut = document.getElementById("donut");
    if (donut && segments.length) {
        donut.style.background = "conic-gradient(" + segments.join(", ") + ")";
    }

    let topName = "—";
    let topAmount = 0;

    values.forEach(function (item) {
        if (item.amount > topAmount) {
            topAmount = item.amount;
            topName = item.name.replace(/^[^\s]+\s/, "").trim();
        }
    });

    document.getElementById("topCategory").textContent = topName;

    document.getElementById("largestCategoryAmount").textContent =
        "₹" + topAmount.toLocaleString("en-IN", {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });

    const searchInput = document.getElementById("searchInput");
    const filterButtons = document.querySelectorAll(".filter-btn");
    const transactions = document.querySelectorAll(".transaction");
    const noResults = document.getElementById("noResults");
    let activeFilter = "All";

    function filterTransactions() {
        const query = searchInput.value.toLowerCase().trim();
        let visibleCount = 0;

        transactions.forEach(function (item) {
            const title = item.dataset.title || "";
            const category = item.dataset.category || "";
            const matchesSearch = title.includes(query) ||
                category.toLowerCase().includes(query);
            const matchesCategory = activeFilter === "All" ||
                category === activeFilter;

            const show = matchesSearch && matchesCategory;
            item.style.display = show ? "flex" : "none";
            if (show) visibleCount++;
        });

        noResults.style.display =
            transactions.length > 0 && visibleCount === 0 ? "block" : "none";
    }

    searchInput.addEventListener("input", filterTransactions);

    filterButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            activeFilter = button.dataset.filter;

            filterButtons.forEach(function (other) {
                other.classList.toggle("active", other === button);
            });

            filterTransactions();
        });
    });
})();
</script>
<script src="<%= request.getContextPath() %>/js/theme.js"></script>
</body>
</html>

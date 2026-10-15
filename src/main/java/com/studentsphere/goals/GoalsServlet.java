/* goal servlet code*/
package com.studentsphere.goals;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.studentsphere.common.DMConnection;

@WebServlet("/goals")
public class GoalsServlet extends HttpServlet {

    private int getUserId(HttpSession session) {
        return (Integer) session.getAttribute("userId");
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = getUserId(session);

        List<Map<String, Object>> goals = new ArrayList<>();
        List<Map<String, Object>> weeklyActivity = new ArrayList<>();
        List<Map<String, Object>> recentLogs = new ArrayList<>();

        int todayMinutes = 0;
        int yesterdayMinutes = 0;
        int streak = 0;
        int longestStreak = 0;
        int todayCompleted = 0;
        int todayActivities = 0;

        LocalDate today = LocalDate.now();

        try (Connection con = DMConnection.getConnection()) {

            // 1. Load the user's goals
            String goalSql =
                "SELECT goal_id, title, target_date, status " +
                "FROM goals WHERE user_id = ? ORDER BY goal_id DESC";

            try (PreparedStatement ps = con.prepareStatement(goalSql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> goal = new HashMap<>();

                        goal.put("goal_id", rs.getInt("goal_id"));
                        goal.put("title", rs.getString("title"));
                        goal.put("target_date", rs.getDate("target_date"));
                        goal.put("status", rs.getString("status"));

                        goals.add(goal);
                    }
                }
            }

            // 2. Load daily activity for the last seven days
            LocalDate firstDay = today.minusDays(6);

            String dailySql =
                "SELECT activity_date, SUM(minutes_spent) AS total_minutes, " +
                "COUNT(*) AS activity_count, " +
                "SUM(is_completed) AS completed_count " +
                "FROM goal_daily_logs " +
                "WHERE user_id = ? AND activity_date BETWEEN ? AND ? " +
                "GROUP BY activity_date ORDER BY activity_date";

            Map<LocalDate, Map<String, Integer>> byDate = new HashMap<>();

            try (PreparedStatement ps = con.prepareStatement(dailySql)) {
                ps.setInt(1, userId);
                ps.setDate(2, java.sql.Date.valueOf(firstDay));
                ps.setDate(3, java.sql.Date.valueOf(today));

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        LocalDate date = rs.getDate("activity_date")
                                           .toLocalDate();

                        Map<String, Integer> values = new HashMap<>();

                        values.put("minutes", rs.getInt("total_minutes"));
                        values.put("count", rs.getInt("activity_count"));
                        values.put("completed", rs.getInt("completed_count"));

                        byDate.put(date, values);
                    }
                }
            }

            // 3. Include all seven days, even days without activity
            for (int i = 0; i < 7; i++) {
                LocalDate date = firstDay.plusDays(i);

                Map<String, Object> day = new HashMap<>();
                Map<String, Integer> values = byDate.get(date);

                int minutes = values == null ? 0 : values.get("minutes");
                int count = values == null ? 0 : values.get("count");
                int done = values == null ? 0 : values.get("completed");

                day.put("date", date.toString());
                day.put("label", date.getDayOfWeek().toString().substring(0, 3));
                day.put("minutes", minutes);
                day.put("count", count);
                day.put("completed", done);

                weeklyActivity.add(day);

                if (date.equals(today)) {
                    todayMinutes = minutes;
                    todayActivities = count;
                    todayCompleted = done;
                }

                if (date.equals(today.minusDays(1))) {
                    yesterdayMinutes = minutes;
                }
            }

            // 4. Load all distinct activity dates for streak calculation
            String historySql =
                "SELECT DISTINCT activity_date FROM goal_daily_logs " +
                "WHERE user_id = ? AND activity_date <= ? " +
                "ORDER BY activity_date DESC";

            List<LocalDate> activeDates = new ArrayList<>();

            try (PreparedStatement ps = con.prepareStatement(historySql)) {
                ps.setInt(1, userId);
                ps.setDate(2, java.sql.Date.valueOf(today));

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        activeDates.add(
                            rs.getDate("activity_date").toLocalDate()
                        );
                    }
                }
            }

            // 5. Calculate current streak
            // If there is no activity today, yesterday may start the streak
            if (!activeDates.isEmpty()) {

                LocalDate expectedDate;

                if (activeDates.get(0).equals(today)) {
                    expectedDate = today;
                } else {
                    expectedDate = today.minusDays(1);
                }

                for (LocalDate date : activeDates) {
                    if (date.equals(expectedDate)) {
                        streak++;
                        expectedDate = expectedDate.minusDays(1);
                    } else if (date.isBefore(expectedDate)) {
                        break;
                    }
                }
            }

            // 6. Calculate longest streak in recorded history
            int runningStreak = 0;
            LocalDate previousDate = null;

            // Dates are in descending order, so traverse oldest to newest
            for (int i = activeDates.size() - 1; i >= 0; i--) {
                LocalDate date = activeDates.get(i);

                if (previousDate != null
                        && date.equals(previousDate.plusDays(1))) {
                    runningStreak++;
                } else {
                    runningStreak = 1;
                }

                if (runningStreak > longestStreak) {
                    longestStreak = runningStreak;
                }

                previousDate = date;
            }

            // 7. Load the ten most recent activity logs
            String logsSql =
                "SELECT activity_title, activity_date, minutes_spent, " +
                "is_completed, notes FROM goal_daily_logs " +
                "WHERE user_id = ? " +
                "ORDER BY activity_date DESC, log_id DESC LIMIT 10";

            try (PreparedStatement ps = con.prepareStatement(logsSql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> log = new HashMap<>();

                        log.put("activity_title",
                                rs.getString("activity_title"));
                        log.put("activity_date",
                                rs.getDate("activity_date"));
                        log.put("minutes_spent",
                                rs.getInt("minutes_spent"));
                        log.put("is_completed",
                                rs.getBoolean("is_completed"));
                        log.put("notes", rs.getString("notes"));

                        recentLogs.add(log);
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to load personal goals and activity history.", e);
        }

        // 8. Send data to the JSP page
        request.setAttribute("goals", goals);
        request.setAttribute("weeklyActivity", weeklyActivity);
        request.setAttribute("todayMinutes", todayMinutes);
        request.setAttribute("yesterdayMinutes", yesterdayMinutes);
        request.setAttribute("todayActivities", todayActivities);
        request.setAttribute("todayCompleted", todayCompleted);
        request.setAttribute("streak", streak);
        request.setAttribute("longestStreak", longestStreak);
        request.setAttribute("recentLogs", recentLogs);

        request.getRequestDispatcher(
            "/modules/goals/index.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        int userId = getUserId(session);
        String action = request.getParameter("action");

        try (Connection con = DMConnection.getConnection()) {

            // 1. Delete a goal
            if ("delete".equals(action)) {
                String id = request.getParameter("goalId");

                if (validId(id)) {
                    String sql =
                        "DELETE FROM goals WHERE goal_id = ? AND user_id = ?";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(id));
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }

            // 2. Mark a goal complete or in progress
            } else if ("complete".equals(action)
                    || "progress".equals(action)) {

                String id = request.getParameter("goalId");

                String status = "complete".equals(action)
                                ? "Completed" : "In Progress";

                if (validId(id)) {
                    String sql =
                        "UPDATE goals SET status = ? " +
                        "WHERE goal_id = ? AND user_id = ?";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setString(1, status);
                        ps.setInt(2, Integer.parseInt(id));
                        ps.setInt(3, userId);
                        ps.executeUpdate();
                    }
                }

            // 3. Add a daily activity log
            } else if ("log".equals(action)) {

                String title = request.getParameter("activityTitle");
                String minutesText = request.getParameter("minutesSpent");
                String dateText = request.getParameter("activityDate");
                String notes = request.getParameter("notes");
                String completedText = request.getParameter("isCompleted");

                if (title == null || title.trim().isEmpty()
                        || minutesText == null
                        || dateText == null || dateText.trim().isEmpty()) {

                    response.sendRedirect(request.getContextPath()
                        + "/goals?error=activity");
                    return;
                }

                int minutes;
                LocalDate activityDate;

                try {
                    minutes = Integer.parseInt(minutesText);
                    activityDate = LocalDate.parse(dateText);
                } catch (RuntimeException e) {
                    response.sendRedirect(request.getContextPath()
                        + "/goals?error=activity");
                    return;
                }

                if (minutes < 0 || minutes > 1440
                        || activityDate.isAfter(LocalDate.now())
                        || title.trim().length() > 150
                        || (notes != null && notes.length() > 500)) {

                    response.sendRedirect(request.getContextPath()
                        + "/goals?error=activity");
                    return;
                }

                boolean isCompleted = "yes".equals(completedText);

                String sql =
                    "INSERT INTO goal_daily_logs " +
                    "(user_id, activity_title, activity_date, " +
                    "minutes_spent, is_completed, notes) " +
                    "VALUES (?, ?, ?, ?, ?, ?)";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, title.trim());
                    ps.setDate(3, java.sql.Date.valueOf(activityDate));
                    ps.setInt(4, minutes);
                    ps.setBoolean(5, isCompleted);
                    ps.setString(6, notes == null ? "" : notes.trim());
                    ps.executeUpdate();
                }

            // 4. Create a new goal
            } else {
                String title = request.getParameter("title");
                String targetDate = request.getParameter("targetDate");

                if (title == null || title.trim().isEmpty()
                        || title.trim().length() > 150) {

                    response.sendRedirect(request.getContextPath()
                        + "/goals?error=empty");
                    return;
                }

                String sql =
                    "INSERT INTO goals (user_id, title, target_date, status) " +
                    "VALUES (?, ?, ?, 'In Progress')";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, title.trim());

                    if (targetDate == null || targetDate.trim().isEmpty()) {
                        ps.setNull(3, java.sql.Types.DATE);
                    } else {
                        try {
                            LocalDate date = LocalDate.parse(targetDate);
                            ps.setDate(3, java.sql.Date.valueOf(date));
                        } catch (RuntimeException e) {
                            response.sendRedirect(request.getContextPath()
                                + "/goals?error=empty");
                            return;
                        }
                    }

                    ps.executeUpdate();
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to save goal or daily activity.", e);
        }

        response.sendRedirect(request.getContextPath() + "/goals");
    }

    private boolean validId(String id) {
        return id != null && id.matches("\\d+");
    }
}

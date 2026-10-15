/* event servlet */
package com.studentsphere.events;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Time;
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

@WebServlet("/events")
public class EventsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String sql = "SELECT event_id, title, description, event_date, "
                   + "venue, category, event_time, capacity, created_by "
                   + "FROM events ORDER BY event_date ASC";

        List<Map<String, Object>> events = new ArrayList<>();

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> event = new HashMap<>();

                event.put("event_id", rs.getInt("event_id"));
                event.put("title", rs.getString("title"));
                event.put("description", rs.getString("description"));
                event.put("event_date", rs.getDate("event_date"));
                event.put("venue", rs.getString("venue"));
                event.put("category", rs.getString("category"));
                event.put("event_time", rs.getTime("event_time"));
                event.put("capacity", rs.getInt("capacity"));

                int creatorId = rs.getInt("created_by");
                event.put("created_by",
                    rs.wasNull() ? null : creatorId);

                events.add(event);
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to load events.", e);
        }

        request.setAttribute("events", events);
        request.setAttribute("currentUserId", userId);

        request.getRequestDispatcher(
                "/modules/events/index.jsp").forward(request, response);
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

        int userId = (Integer) session.getAttribute("userId");

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String eventDate = request.getParameter("eventDate");
        String venue = request.getParameter("venue");
        String category = request.getParameter("category");
        String eventTime = request.getParameter("eventTime");
        String capacityText = request.getParameter("capacity");

        if (title == null || title.trim().isEmpty()
                || eventDate == null || eventDate.trim().isEmpty()
                || venue == null || venue.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath()
                    + "/events?error=empty");
            return;
        }

        int capacity;

        try {
            capacity = Integer.parseInt(
                    capacityText == null ? "100" : capacityText.trim());

            LocalDate date = LocalDate.parse(eventDate);

            if (capacity < 1 || capacity > 100000) {
                response.sendRedirect(request.getContextPath()
                        + "/events?error=invalid");
                return;
            }

            if (date.isBefore(LocalDate.now())) {
                response.sendRedirect(request.getContextPath()
                        + "/events?error=date");
                return;
            }

        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath()
                    + "/events?error=invalid");
            return;
        }

        String sql = "INSERT INTO events "
                   + "(title, description, event_date, venue, category, "
                   + "event_time, capacity, created_by) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, title.trim());
            ps.setString(2,
                    description == null ? "" : description.trim());
            ps.setDate(3, Date.valueOf(eventDate));
            ps.setString(4, venue.trim());
            ps.setString(5,
                    category == null || category.trim().isEmpty()
                            ? "Other" : category.trim());

            if (eventTime == null || eventTime.trim().isEmpty()) {
                ps.setNull(6, java.sql.Types.TIME);
            } else {
                ps.setTime(6, Time.valueOf(eventTime.trim() + ":00"));
            }

            ps.setInt(7, capacity);
            ps.setInt(8, userId);

            ps.executeUpdate();

        } catch (SQLException e) {
            throw new ServletException("Unable to create the event.", e);
        }

        response.sendRedirect(request.getContextPath()
                + "/events?success=created");
    }
}

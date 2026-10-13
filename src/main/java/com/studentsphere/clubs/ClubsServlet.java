package com.studentsphere.clubs;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.studentsphere.common.DMConnection;

@WebServlet("/clubs")
public class ClubsServlet extends HttpServlet {

    private Integer getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;

        Object value = session.getAttribute("userId");

        if (value instanceof Integer) return (Integer) value;

        if (value instanceof String) {
            try {
                return Integer.parseInt((String) value);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }

    private int parseId(String value) {
        if (value == null || !value.matches("\\d+")) return -1;

        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        Integer userId = getLoggedInUser(request);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String, Object>> clubs = new ArrayList<>();
        List<Map<String, Object>> announcements = new ArrayList<>();
        List<Map<String, Object>> events = new ArrayList<>();
        Map<Integer, String> membershipStatuses = new HashMap<>();
        Set<Integer> registeredEventIds = new HashSet<>();

        int joinedCount = 0;
        int pendingCount = 0;

        try (Connection con = DMConnection.getConnection()) {

            String clubSql =
                "SELECT c.club_id, c.club_name, c.description, c.created_by, " +
                "c.requires_approval, " +
                "(SELECT COUNT(*) FROM club_memberships m " +
                " WHERE m.club_id=c.club_id AND m.status='JOINED') AS member_count, " +
                "m.status AS my_status " +
                "FROM clubs c " +
                "JOIN (SELECT MIN(club_id) AS club_id FROM clubs " +
                "GROUP BY LOWER(TRIM(club_name))) unique_clubs " +
                "ON c.club_id=unique_clubs.club_id " +
                "LEFT JOIN club_memberships m " +
                "ON c.club_id=m.club_id AND m.user_id=? " +
                "ORDER BY c.club_name";

            try (PreparedStatement ps = con.prepareStatement(clubSql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> club = new HashMap<>();
                        int clubId = rs.getInt("club_id");
                        String status = rs.getString("my_status");

                        club.put("club_id", clubId);
                        club.put("club_name", rs.getString("club_name"));
                        club.put("description", rs.getString("description"));
                        club.put("created_by", rs.getObject("created_by"));
                        club.put("requires_approval",
                                 rs.getBoolean("requires_approval"));
                        club.put("member_count", rs.getInt("member_count"));
                        club.put("my_status", status);

                        if (status != null) {
                            membershipStatuses.put(clubId, status);

                            if ("JOINED".equals(status)) joinedCount++;
                            else if ("PENDING".equals(status)) pendingCount++;
                        }

                        clubs.add(club);
                    }
                }
            }

            String announcementSql =
                "SELECT a.announcement_id, a.club_id, a.title, a.message, " +
                "a.created_at, c.club_name FROM announcements a " +
                "LEFT JOIN clubs c ON a.club_id=c.club_id " +
                "ORDER BY a.created_at DESC";

            try (PreparedStatement ps = con.prepareStatement(announcementSql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("announcement_id", rs.getInt("announcement_id"));
                    item.put("club_id", rs.getObject("club_id"));
                    item.put("title", rs.getString("title"));
                    item.put("message", rs.getString("message"));
                    item.put("created_at", rs.getTimestamp("created_at"));
                    item.put("club_name", rs.getString("club_name"));
                    announcements.add(item);
                }
            }

            String eventSql =
                "SELECT e.event_id, e.title, e.description, e.event_date, " +
                "e.venue, e.category, e.event_time, e.capacity, " +
                "(SELECT COUNT(*) FROM registrations r " +
                "WHERE r.event_id=e.event_id) AS registered_count " +
                "FROM events e WHERE e.event_date>=? " +
                "ORDER BY e.event_date, e.event_time";

            try (PreparedStatement ps = con.prepareStatement(eventSql)) {
                ps.setDate(1, java.sql.Date.valueOf(LocalDate.now()));

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> event = new HashMap<>();
                        int eventId = rs.getInt("event_id");

                        event.put("event_id", eventId);
                        event.put("title", rs.getString("title"));
                        event.put("description", rs.getString("description"));
                        event.put("event_date", rs.getDate("event_date"));
                        event.put("venue", rs.getString("venue"));
                        event.put("category", rs.getString("category"));
                        event.put("event_time", rs.getTime("event_time"));
                        event.put("capacity", rs.getInt("capacity"));
                        event.put("registered_count",
                                  rs.getInt("registered_count"));

                        events.add(event);
                    }
                }
            }

            String registeredSql =
                "SELECT event_id FROM registrations WHERE user_id=?";

            try (PreparedStatement ps = con.prepareStatement(registeredSql)) {
                ps.setInt(1, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        registeredEventIds.add(rs.getInt("event_id"));
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to load clubs page.", e);
        }

        request.setAttribute("clubs", clubs);
        request.setAttribute("announcements", announcements);
        request.setAttribute("events", events);
        request.setAttribute("membershipStatuses", membershipStatuses);
        request.setAttribute("registeredEventIds", registeredEventIds);
        request.setAttribute("joinedCount", joinedCount);
        request.setAttribute("pendingCount", pendingCount);

        request.getRequestDispatcher("/modules/clubs/index.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        Integer userId = getLoggedInUser(request);

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        String message = "error";

        try (Connection con = DMConnection.getConnection()) {

            // CREATE CLUB: save the currently logged-in user as creator.
            if ("createClub".equals(action)) {
                String clubName = request.getParameter("clubName");
                String description = request.getParameter("description");

                clubName = clubName == null ? "" : clubName.trim();
                description = description == null ? "" : description.trim();

                if (clubName.isEmpty() || clubName.length() > 100
                        || description.length() > 1000) {
                    message = "invalid_club";
                } else {
                    boolean duplicate = false;

                    String duplicateSql =
                        "SELECT club_id FROM clubs " +
                        "WHERE LOWER(TRIM(club_name))=LOWER(?)";

                    try (PreparedStatement ps =
                             con.prepareStatement(duplicateSql)) {
                        ps.setString(1, clubName);

                        try (ResultSet rs = ps.executeQuery()) {
                            duplicate = rs.next();
                        }
                    }

                    if (duplicate) {
                        message = "duplicate_club";
                    } else {
                        String insertSql =
                            "INSERT INTO clubs " +
                            "(club_name, description, created_by) VALUES (?, ?, ?)";

                        try (PreparedStatement ps =
                                 con.prepareStatement(insertSql)) {
                            ps.setString(1, clubName);
                            ps.setString(2, description);
                            ps.setInt(3, userId);
                            ps.executeUpdate();
                        }

                        message = "club_created";
                    }
                }

            // DELETE CLUB: only the creator can delete their club.
            } else if ("deleteClub".equals(action)) {
                int clubId = parseId(request.getParameter("clubId"));

                if (clubId <= 0) {
                    message = "invalid_club";
                } else {
                    boolean oldAutoCommit = con.getAutoCommit();

                    try {
                        con.setAutoCommit(false);

                        boolean isOwner = false;

                        String ownerSql =
                            "SELECT club_id FROM clubs " +
                            "WHERE club_id=? AND created_by=? FOR UPDATE";

                        try (PreparedStatement ps =
                                 con.prepareStatement(ownerSql)) {
                            ps.setInt(1, clubId);
                            ps.setInt(2, userId);

                            try (ResultSet rs = ps.executeQuery()) {
                                isOwner = rs.next();
                            }
                        }

                        if (!isOwner) {
                            con.rollback();
                            message = "delete_denied";
                        } else {
                            try (PreparedStatement ps = con.prepareStatement(
                                    "DELETE FROM announcements WHERE club_id=?")) {
                                ps.setInt(1, clubId);
                                ps.executeUpdate();
                            }

                            try (PreparedStatement ps = con.prepareStatement(
                                    "DELETE FROM club_memberships WHERE club_id=?")) {
                                ps.setInt(1, clubId);
                                ps.executeUpdate();
                            }

                            try (PreparedStatement ps = con.prepareStatement(
                                    "DELETE FROM clubs " +
                                    "WHERE club_id=? AND created_by=?")) {
                                ps.setInt(1, clubId);
                                ps.setInt(2, userId);

                                if (ps.executeUpdate() == 1) {
                                    con.commit();
                                    message = "club_deleted";
                                } else {
                                    con.rollback();
                                    message = "delete_denied";
                                }
                            }
                        }
                    } catch (SQLException e) {
                        try {
                            con.rollback();
                        } catch (SQLException ignored) {
                        }
                        throw e;
                    } finally {
                        try {
                            con.setAutoCommit(oldAutoCommit);
                        } catch (SQLException ignored) {
                        }
                    }
                }

            // JOIN CLUB
            } else if ("join".equals(action)) {
                int clubId = parseId(request.getParameter("clubId"));

                if (clubId > 0) {
                    boolean approvalRequired = false;
                    boolean clubExists = false;

                    String checkClub =
                        "SELECT requires_approval FROM clubs WHERE club_id=?";

                    try (PreparedStatement ps = con.prepareStatement(checkClub)) {
                        ps.setInt(1, clubId);

                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                clubExists = true;
                                approvalRequired =
                                    rs.getBoolean("requires_approval");
                            }
                        }
                    }

                    if (clubExists) {
                        String currentStatus = null;

                        String checkMembership =
                            "SELECT status FROM club_memberships " +
                            "WHERE club_id=? AND user_id=?";

                        try (PreparedStatement ps =
                                 con.prepareStatement(checkMembership)) {
                            ps.setInt(1, clubId);
                            ps.setInt(2, userId);

                            try (ResultSet rs = ps.executeQuery()) {
                                if (rs.next()) {
                                    currentStatus = rs.getString("status");
                                }
                            }
                        }

                        if ("JOINED".equals(currentStatus)) {
                            message = "already_joined";
                        } else if ("PENDING".equals(currentStatus)) {
                            message = "already_pending";
                        } else {
                            String newStatus =
                                approvalRequired ? "PENDING" : "JOINED";

                            if (currentStatus == null) {
                                String insert =
                                    "INSERT INTO club_memberships " +
                                    "(club_id, user_id, status) VALUES (?, ?, ?)";

                                try (PreparedStatement ps =
                                         con.prepareStatement(insert)) {
                                    ps.setInt(1, clubId);
                                    ps.setInt(2, userId);
                                    ps.setString(3, newStatus);
                                    ps.executeUpdate();
                                }
                            } else {
                                String update =
                                    "UPDATE club_memberships SET status=?, " +
                                    "joined_at=CURRENT_TIMESTAMP " +
                                    "WHERE club_id=? AND user_id=?";

                                try (PreparedStatement ps =
                                         con.prepareStatement(update)) {
                                    ps.setString(1, newStatus);
                                    ps.setInt(2, clubId);
                                    ps.setInt(3, userId);
                                    ps.executeUpdate();
                                }
                            }

                            message = approvalRequired
                                ? "request_submitted" : "joined";
                        }
                    }
                }

            // LEAVE CLUB
            } else if ("leave".equals(action)) {
                int clubId = parseId(request.getParameter("clubId"));

                if (clubId > 0) {
                    String sql =
                        "DELETE FROM club_memberships " +
                        "WHERE club_id=? AND user_id=? AND status='JOINED'";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, clubId);
                        ps.setInt(2, userId);

                        message = ps.executeUpdate() > 0
                            ? "left" : "not_joined";
                    }
                }

            // REGISTER FOR EVENT
            } else if ("registerEvent".equals(action)) {
                int eventId = parseId(request.getParameter("eventId"));

                if (eventId > 0) {
                    boolean eventExists = false;
                    boolean eventFull = false;
                    boolean eventPast = false;

                    String checkEvent =
                        "SELECT event_date, capacity, " +
                        "(SELECT COUNT(*) FROM registrations r " +
                        "WHERE r.event_id=e.event_id) AS total_registered " +
                        "FROM events e WHERE event_id=?";

                    try (PreparedStatement ps =
                             con.prepareStatement(checkEvent)) {
                        ps.setInt(1, eventId);

                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                eventExists = true;

                                java.sql.Date eventDate =
                                    rs.getDate("event_date");

                                int capacity = rs.getInt("capacity");
                                int total = rs.getInt("total_registered");

                                eventPast = eventDate != null
                                    && eventDate.toLocalDate()
                                                .isBefore(LocalDate.now());

                                eventFull = capacity > 0 && total >= capacity;
                            }
                        }
                    }

                    if (!eventExists) {
                        message = "event_not_found";
                    } else if (eventPast) {
                        message = "event_past";
                    } else if (eventFull) {
                        message = "event_full";
                    } else {
                        boolean alreadyRegistered = false;

                        String checkRegistration =
                            "SELECT registration_id FROM registrations " +
                            "WHERE event_id=? AND user_id=?";

                        try (PreparedStatement ps =
                                 con.prepareStatement(checkRegistration)) {
                            ps.setInt(1, eventId);
                            ps.setInt(2, userId);

                            try (ResultSet rs = ps.executeQuery()) {
                                alreadyRegistered = rs.next();
                            }
                        }

                        if (alreadyRegistered) {
                            message = "already_registered";
                        } else {
                            String insert =
                                "INSERT INTO registrations (event_id, user_id) " +
                                "VALUES (?, ?)";

                            try (PreparedStatement ps =
                                     con.prepareStatement(insert)) {
                                ps.setInt(1, eventId);
                                ps.setInt(2, userId);
                                ps.executeUpdate();
                            }

                            message = "registered";
                        }
                    }
                }
            }

        } catch (SQLException e) {
            throw new ServletException(
                "Unable to process club or event action.", e);
        }

        response.sendRedirect(
            request.getContextPath() + "/clubs?result=" + message);
    }
}
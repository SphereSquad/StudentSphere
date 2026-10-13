
package com.studentsphere.studyplanner;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.studentsphere.common.DMConnection;

@WebServlet("/studyplanner")
public class StudyPlannerServlet extends HttpServlet {

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

        String sql = "SELECT task_id, title, description, due_date, status "
                   + "FROM tasks WHERE user_id = ? ORDER BY due_date ASC";

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                // Copy rows before closing the database connection
                java.util.List<java.util.Map<String, Object>> taskList =
                        new java.util.ArrayList<>();

                while (rs.next()) {
                    java.util.Map<String, Object> task =
                            new java.util.HashMap<>();

                    task.put("task_id", rs.getInt("task_id"));
                    task.put("title", rs.getString("title"));
                    task.put("description", rs.getString("description"));
                    task.put("due_date", rs.getString("due_date"));
                    task.put("status", rs.getString("status"));

                    taskList.add(task);
                }

                request.setAttribute("tasks", taskList);
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to load study tasks.", e);
        }

        request.getRequestDispatcher(
                "/modules/studyplanner/index.jsp").forward(request, response);
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

        int userId = (Integer) session.getAttribute("userId");
        String action = request.getParameter("action");

        try (Connection con = DMConnection.getConnection()) {

            // Mark a task as completed
            if ("complete".equals(action)) {

                String taskId = request.getParameter("taskId");

                if (taskId != null && taskId.matches("\\d+")) {
                    String sql = "UPDATE tasks SET status = 'Completed' "
                               + "WHERE task_id = ? AND user_id = ?";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(taskId));
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }

            // Delete a task
            } else if ("delete".equals(action)) {

                String taskId = request.getParameter("taskId");

                if (taskId != null && taskId.matches("\\d+")) {
                    String sql = "DELETE FROM tasks "
                               + "WHERE task_id = ? AND user_id = ?";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(taskId));
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }

            // Add a new task
            } else {
                String title = request.getParameter("title");
                String description = request.getParameter("description");
                String dueDate = request.getParameter("dueDate");

                if (title == null || title.trim().isEmpty()
                        || dueDate == null || dueDate.trim().isEmpty()) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/studyplanner?error=empty");
                    return;
                }

                String sql = "INSERT INTO tasks "
                           + "(user_id, title, description, due_date, status) "
                           + "VALUES (?, ?, ?, ?, 'Pending')";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, title.trim());
                    ps.setString(3,
                            description == null ? "" : description.trim());
                    ps.setDate(4, java.sql.Date.valueOf(dueDate));
                    ps.executeUpdate();
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to update study tasks.", e);
        }

        response.sendRedirect(request.getContextPath() + "/studyplanner");
    }
}

package com.studentsphere.profile;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.LinkedHashSet;
import java.util.Set;

import com.studentsphere.common.DMConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/save-skills")
public class SaveSkillsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp");
            return;
        }

        int userId =
            ((Number) session.getAttribute("userId")).intValue();

        String[] submittedSkills = request.getParameterValues("skills");

        Set<String> skills = new LinkedHashSet<>();

        if (submittedSkills != null) {
            for (String skill : submittedSkills) {
                if (skill != null) {
                    skill = skill.trim();

                    if (!skill.isEmpty() && skill.length() <= 100) {
                        skills.add(skill);
                    }
                }
            }
        }

        try (Connection con = DMConnection.getConnection()) {

            con.setAutoCommit(false);

            try {
                // Remove this student's previous selections
                try (PreparedStatement delete = con.prepareStatement(
                        "DELETE FROM student_skills WHERE user_id = ?")) {

                    delete.setInt(1, userId);
                    delete.executeUpdate();
                }

                // Save the newly selected skills
                try (PreparedStatement insert = con.prepareStatement(
                        "INSERT INTO student_skills (user_id, skill_name) VALUES (?, ?)")) {

                    for (String skill : skills) {
                        insert.setInt(1, userId);
                        insert.setString(2, skill);
                        insert.addBatch();
                    }

                    if (!skills.isEmpty()) {
                        insert.executeBatch();
                    }
                }

                con.commit();

            } catch (Exception e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true);
            }

            response.sendRedirect(
                request.getContextPath()
                + "/modules/profile/profile.jsp?skillsUpdated=1");

        } catch (Exception e) {
            throw new ServletException("Unable to save student skills.", e);
        }
    }
}

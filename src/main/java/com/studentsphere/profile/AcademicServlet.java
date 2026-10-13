
package com.studentsphere.profile;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.studentsphere.common.DMConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/academic-profile")
public class AcademicServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = ((Number) session.getAttribute("userId")).intValue();

        String branch = request.getParameter("branch");
        String semesterText = request.getParameter("semester");
        String cgpaText = request.getParameter("cgpa");
        String attendanceText = request.getParameter("attendance");

        try {
            if (branch == null || branch.trim().isEmpty()
                    || semesterText == null || semesterText.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath()
                        + "/modules/profile/academic.jsp?error=empty");
                return;
            }

            branch = branch.trim();
            if (branch.length() > 100) {
                response.sendRedirect(request.getContextPath()
                        + "/modules/profile/academic.jsp?error=invalid");
                return;
            }

            int semester = Integer.parseInt(semesterText);
            if (semester < 1 || semester > 12) {
                response.sendRedirect(request.getContextPath()
                        + "/modules/profile/academic.jsp?error=invalid");
                return;
            }

            BigDecimal cgpa = null;
            if (cgpaText != null && !cgpaText.trim().isEmpty()) {
                cgpa = new BigDecimal(cgpaText.trim());
                if (cgpa.compareTo(BigDecimal.ZERO) < 0
                        || cgpa.compareTo(new BigDecimal("10.00")) > 0) {
                    response.sendRedirect(request.getContextPath()
                            + "/modules/profile/academic.jsp?error=invalid");
                    return;
                }
            }

            BigDecimal attendance = null;
            if (attendanceText != null && !attendanceText.trim().isEmpty()) {
                attendance = new BigDecimal(attendanceText.trim());
                if (attendance.compareTo(BigDecimal.ZERO) < 0
                        || attendance.compareTo(new BigDecimal("100.00")) > 0) {
                    response.sendRedirect(request.getContextPath()
                            + "/modules/profile/academic.jsp?error=invalid");
                    return;
                }
            }

            String sql = "INSERT INTO student_academics "
                    + "(user_id, branch, semester, cgpa, attendance) "
                    + "VALUES (?, ?, ?, ?, ?) "
                    + "ON DUPLICATE KEY UPDATE branch=VALUES(branch), "
                    + "semester=VALUES(semester), cgpa=VALUES(cgpa), "
                    + "attendance=VALUES(attendance)";

            try (Connection con = DMConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, userId);
                ps.setString(2, branch);
                ps.setInt(3, semester);

                if (cgpa == null) ps.setNull(4, java.sql.Types.DECIMAL);
                else ps.setBigDecimal(4, cgpa);

                if (attendance == null) ps.setNull(5, java.sql.Types.DECIMAL);
                else ps.setBigDecimal(5, attendance);

                ps.executeUpdate();
            }

            response.sendRedirect(request.getContextPath()
                    + "/modules/profile/academic.jsp?updated=1");

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath()
                    + "/modules/profile/academic.jsp?error=invalid");
        } catch (Exception e) {
            throw new ServletException("Unable to save academic details.", e);
        }
    }
}

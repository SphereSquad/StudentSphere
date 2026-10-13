
package com.studentsphere.profile;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import com.studentsphere.common.DMConnection;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

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

        Object id = session.getAttribute("userId");
        int userId = ((Number) id).intValue();

        String name = request.getParameter("name");

        if (name == null || name.trim().isEmpty()) {
            response.sendRedirect(
                request.getContextPath()
                + "/modules/profile/profile.jsp?error=empty");
            return;
        }

        name = name.trim();

        if (name.length() > 100) {
            response.sendRedirect(
                request.getContextPath()
                + "/modules/profile/profile.jsp?error=length");
            return;
        }

        String sql = "UPDATE users SET name = ? WHERE user_id = ?";

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setInt(2, userId);

            int updated = ps.executeUpdate();

            if (updated > 0) {
                session.setAttribute("userName", name);

                response.sendRedirect(
                    request.getContextPath()
                    + "/modules/profile/profile.jsp?updated=1");
            } else {
                response.sendRedirect(
                    request.getContextPath()
                    + "/modules/profile/profile.jsp?error=update");
            }

        } catch (Exception e) {
            throw new ServletException(
                "Unable to update profile.", e);
        }
    }
}
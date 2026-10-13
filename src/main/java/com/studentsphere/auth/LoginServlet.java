
package com.studentsphere.auth;

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
import com.studentsphere.common.PasswordUtil;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null
                || email.trim().isEmpty() || password.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?error=invalid");
            return;
        }

        String sql = "SELECT user_id, name, email, password_hash "
                   + "FROM users WHERE email = ?";

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim());

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    String storedPassword = rs.getString("password_hash");

                    if (PasswordUtil.verifyPassword(
                            password, storedPassword)) {

                        HttpSession session = request.getSession();
                        session.setAttribute(
                                "userId", rs.getInt("user_id"));
                        session.setAttribute(
                                "userName", rs.getString("name"));
                        session.setAttribute(
                                "userEmail", rs.getString("email"));

                        response.sendRedirect(
                                request.getContextPath()
                                + "/dashboard.jsp");
                        return;
                    }
                }
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?error=invalid");

        } catch (SQLException e) {
            throw new ServletException("Login failed.", e);
        }
    }
}

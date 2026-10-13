
package com.studentsphere.auth;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.studentsphere.common.DMConnection;
import com.studentsphere.common.PasswordUtil;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (name == null || email == null || password == null
                || name.trim().isEmpty()
                || email.trim().isEmpty()
                || password.length() < 8) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/register.jsp?error=invalid");
            return;
        }

        String sql = "INSERT INTO users (name, email, password_hash) "
                   + "VALUES (?, ?, ?)";

        String hashedPassword = PasswordUtil.hashPassword(password);

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name.trim());
            ps.setString(2, email.trim());
            ps.setString(3, hashedPassword);

            ps.executeUpdate();

            response.sendRedirect(
                    request.getContextPath()
                    + "/login.jsp?registered=1");

        } catch (SQLException e) {

            if ("23000".equals(e.getSQLState())) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/register.jsp?error=duplicate");
            } else {
                throw new ServletException(
                        "Registration failed.", e);
            }
        }
    }
}

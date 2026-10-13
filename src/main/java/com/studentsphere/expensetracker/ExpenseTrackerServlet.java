
package com.studentsphere.expensetracker;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

@WebServlet("/expensetracker")
public class ExpenseTrackerServlet extends HttpServlet {

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

        String sql = "SELECT expense_id, title, amount, category, expense_date "
                   + "FROM expenses WHERE user_id = ? "
                   + "ORDER BY expense_date DESC, expense_id DESC";

        List<Map<String, Object>> expenses = new ArrayList<>();
        BigDecimal total = BigDecimal.ZERO;

        try (Connection con = DMConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> expense = new HashMap<>();

                    expense.put("expense_id", rs.getInt("expense_id"));
                    expense.put("title", rs.getString("title"));
                    expense.put("amount", rs.getBigDecimal("amount"));
                    expense.put("category", rs.getString("category"));
                    expense.put("expense_date", rs.getDate("expense_date"));

                    BigDecimal amount = rs.getBigDecimal("amount");
                    if (amount != null) {
                        total = total.add(amount);
                    }

                    expenses.add(expense);
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to load expenses.", e);
        }

        request.setAttribute("expenses", expenses);
        request.setAttribute("totalExpenses", total);

        request.getRequestDispatcher(
                "/modules/expensetracker/index.jsp")
                .forward(request, response);
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

            if ("delete".equals(action)) {

                String id = request.getParameter("expenseId");

                if (id != null && id.matches("\\d+")) {
                    String sql = "DELETE FROM expenses "
                               + "WHERE expense_id = ? AND user_id = ?";

                    try (PreparedStatement ps = con.prepareStatement(sql)) {
                        ps.setInt(1, Integer.parseInt(id));
                        ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }

            } else {

                String title = request.getParameter("title");
                String amountText = request.getParameter("amount");
                String category = request.getParameter("category");
                String expenseDate = request.getParameter("expenseDate");

                if (title == null || title.trim().isEmpty()
                        || amountText == null || amountText.trim().isEmpty()
                        || expenseDate == null || expenseDate.trim().isEmpty()) {

                    response.sendRedirect(request.getContextPath()
                            + "/expensetracker?error=empty");
                    return;
                }

                BigDecimal amount;

                try {
                    amount = new BigDecimal(amountText.trim());
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath()
                            + "/expensetracker?error=invalid");
                    return;
                }

                if (amount.compareTo(BigDecimal.ZERO) <= 0
                        || amount.scale() > 2
                        || amount.precision() > 10) {
                    response.sendRedirect(request.getContextPath()
                            + "/expensetracker?error=invalid");
                    return;
                }

                String sql = "INSERT INTO expenses "
                           + "(user_id, title, amount, category, expense_date) "
                           + "VALUES (?, ?, ?, ?, ?)";

                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, userId);
                    ps.setString(2, title.trim());
                    ps.setBigDecimal(3, amount);
                    ps.setString(4,
                            category == null || category.trim().isEmpty()
                                    ? "Other" : category.trim());
                    ps.setDate(5, java.sql.Date.valueOf(expenseDate));

                    ps.executeUpdate();
                }
            }

        } catch (SQLException e) {
            throw new ServletException("Unable to save expense.", e);
        } catch (IllegalArgumentException e) {
            response.sendRedirect(request.getContextPath()
                    + "/expensetracker?error=invalid");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/expensetracker");
    }
}


package com.studentsphere.common;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DMConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/studentsphere";

    private static final String USER = "root";

    private static final String PASSWORD = "admin";

    public static Connection getConnection() throws SQLException {

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                    "MySQL Connector/J driver not found.", e);
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}

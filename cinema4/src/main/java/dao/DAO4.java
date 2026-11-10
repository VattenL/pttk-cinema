package dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

// Một kết nối dùng chung; mọi giao dịch khoá trên DAO4.class
public abstract class DAO4 {
    protected static Connection con;

    public DAO4() {
        synchronized (DAO4.class) {
            try {
                if (con == null || !con.isValid(2)) {
                    try (InputStream in = DAO4.class.getClassLoader().getResourceAsStream("db.properties")) {
                        Properties p = new Properties();
                        p.load(in);
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        con = DriverManager.getConnection(p.getProperty("db.url"),
                                p.getProperty("db.user"), p.getProperty("db.password"));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

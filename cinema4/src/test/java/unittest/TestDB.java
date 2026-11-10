package unittest;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Properties;

final class TestDB {

    private TestDB() {
    }

    static void execute(String... sqls) throws Exception {
        Properties p = new Properties();
        try (InputStream in = TestDB.class.getClassLoader().getResourceAsStream("db.properties")) {
            p.load(in);
        }
        try (Connection con = DriverManager.getConnection(p.getProperty("db.url"),
                p.getProperty("db.user"), p.getProperty("db.password"));
             Statement st = con.createStatement()) {
            for (String sql : sqls) {
                st.execute(sql);
            }
        }
    }
}

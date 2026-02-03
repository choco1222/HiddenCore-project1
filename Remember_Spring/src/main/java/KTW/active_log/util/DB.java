package KTW.active_log.util; //복사본 삭제 확인

import java.sql.Connection;
import java.sql.DriverManager;

public class DB {

    private static final String URL =
        "jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
    private static final String USER = "root"; //여기에계정
    private static final String PASS = "12345";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public static Connection getConnection() throws Exception {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}

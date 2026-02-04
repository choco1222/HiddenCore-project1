package connect;

import java.sql.Connection;
import java.sql.DriverManager;

public class conDB {

	private static final String URL =
			"jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
	private static final String USER = "root";
	private static final String PASS = "12345";

	static {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public static Connection getConnection() throws Exception {
		Connection con = DriverManager.getConnection(URL, USER, PASS);
		return con;
	}

	/*
	public static void main(String[] args) {
		try {
			Connection conn = getCon();
			System.out.println("✅ DB 연결 성공");
			conn.close();
		} catch (Exception e) {
			System.out.println("❌ DB 연결 실패");
			e.printStackTrace();
		}
	}*/
}

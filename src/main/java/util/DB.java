package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DB {

	private static final String URL = "jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
	private static final String USER = "root";
	private static final String PASS = "1234";

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

	public static void main(String[] args) {

		try {
			Connection conn =DB.getConnection();
			System.out.println("✅ DB 연결 성공!");
			conn.close();
		} catch (Exception e) {
			System.out.println("❌ DB 연결 실패");
			e.printStackTrace();
		}

	}

}

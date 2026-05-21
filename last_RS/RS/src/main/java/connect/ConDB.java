package connect;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ConDB {

	private static final String URL = "jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
	private static final String USER = "root"; // 여기에계정
	private static final String PASS = "12345";

	public static Connection getCon() throws Exception {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			return DriverManager.getConnection(URL, USER, PASS);
		} catch (Exception e) {
			System.out.println("ERR: Can't CONNECTION");
			e.printStackTrace();
			return null;
		}
	}
}
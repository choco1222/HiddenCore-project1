package controller;

import java.sql.*;

public class Board_DAO {

	private String url = "jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
	private String user = "root";
	private String pass = "12345";

	public int insertLog(String userId, String eventType) {
		String sql = "INSERT INTO activelog " + "(log_id, user_id, event_type, event_count, event_time) "
				+ "VALUES (?, ?, ?, 1, CURRENT_TIMESTAMP)";
		
		
		int result = 0;

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			try (Connection conn = DriverManager.getConnection(url, user, pass);
					PreparedStatement pstmt = conn.prepareStatement(sql)) {

				String logId = "L" + java.util.UUID.randomUUID();

				pstmt.setString(1, logId);
				pstmt.setString(2, userId);
				pstmt.setString(3, eventType);

				result = pstmt.executeUpdate();
				System.out.println("✅ 저장 성공: " + userId + " / " + eventType);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}

}

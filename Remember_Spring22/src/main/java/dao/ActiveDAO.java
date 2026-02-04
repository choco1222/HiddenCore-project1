package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

public class ActiveDAO {
 
    private String url = "jdbc:mysql://localhost:3306/memory_spring?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Seoul";
    private String user = "root";
    private String pass = "12345";

    public int insertLog(String event_Type) {
        // [핵심 쿼리] 있으면 업데이트, 없으면 인서트!
        String sql = "INSERT INTO activelog (log_id, user_id, event_type, event_count) " +
                     "VALUES (?, ?, ?, 1) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "event_count = event_count + 1, event_time = CURRENT_TIMESTAMP";
        int result = 0;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, user, pass);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                String log_id = "L" + (System.currentTimeMillis() / 1000); // 10분 로직을 위해 ID를 단순화하거나 조절 가능
                pstmt.setString(1, log_id);      
                pstmt.setString(2, "user01");     
                pstmt.setString(3, event_Type); 
                
                result = pstmt.executeUpdate();
                System.out.println("✅ 카운트 반영 성공: " + event_Type);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    
    
    }
//////////////////////////////////////////////////////////////////////////////////////
    public boolean isDuplicate(String type) {
        // DB에서 오늘 날짜와 type이 일치하는 데이터가 있는지 확인하는 코드
        // 일단 에러 안 나게 하려면 return false; 라도 적어두세요!
        return false; 
    }
	
}
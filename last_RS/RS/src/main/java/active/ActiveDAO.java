package active;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import connect.ConDB;

public class ActiveDAO {

    public int insertLog(int user_id, String event_Type) {
        String sql = "INSERT INTO activelog (log_id, user_id, routine_id, event_type, event_count) " + 
                     "VALUES (?, ?, ?, ?, 1) " + 
                     "ON DUPLICATE KEY UPDATE event_count = event_count + 1, event_time = CURRENT_TIMESTAMP";
        int result = 0;

        try (Connection conn = ConDB.getCon();
             PreparedStatement pstmt = (conn != null) ? conn.prepareStatement(sql) : null) {

            if (pstmt == null) {
                System.out.println("❌ DB 연결 실패 (ConDB 확인)");
                return 0;
            }

            String log_id = "L" + System.currentTimeMillis();
            
            // routine_id 조회 (Meal_*, Med_*는 찾고, 나머지는 NULL)
            Integer routineId = getRoutineId(user_id, event_Type);

            pstmt.setString(1, log_id);
            pstmt.setInt(2, user_id);
            
            if (routineId != null) {
                pstmt.setInt(3, routineId);
            } else {
                pstmt.setNull(3, Types.INTEGER);
            }
            
            String finalType = (event_Type != null && event_Type.length() > 15) 
                ? event_Type.substring(0, 15) 
                : event_Type;
            pstmt.setString(4, finalType);

            result = pstmt.executeUpdate();
            if (result > 0) {
                System.out.println("✅ DB 저장 성공: " + finalType + " (routine_id=" + routineId + ")");
            }

        } catch (Exception e) {
            System.out.println("❌ DAO 실행 중 에러 발생:");
            e.printStackTrace();
        }
        return result;
    }
    
    /**
     * Meal_*, Med_*는 routine 테이블에서 조회
     * 나머지는 NULL 반환
     */
    private Integer getRoutineId(int user_id, String event_Type) {
        if (event_Type == null) return null;
        
        // Brush_, Mood_, Outing → NULL
        if (event_Type.startsWith("Brush_") || event_Type.startsWith("Mood_") || 
            event_Type.startsWith("Outing_") || event_Type.equals("외출복귀")) {
            return null;
        }
        
        // Meal_ 또는 Med_ → routine 테이블 조회
        if (!event_Type.startsWith("Meal_") && !event_Type.startsWith("Med_")) {
            return null;
        }
        
        // routine_type 매핑
        String routineType = null;
        if (event_Type.startsWith("Meal_")) {
            routineType = event_Type; // "Meal_breakfast" 등
        } else if (event_Type.startsWith("Med_")) {
            // Med_morning → Meal_breakfast
            if (event_Type.contains("morning")) routineType = "Meal_breakfast";
            else if (event_Type.contains("lunch")) routineType = "Meal_lunch";
            else if (event_Type.contains("dinner")) routineType = "Meal_dinner";
        }
        
        if (routineType == null) return null;
        
        // DB 조회
        String sql = "SELECT routine_id FROM routine WHERE user_id = ? AND routine_type = ? LIMIT 1";
        try (Connection conn = ConDB.getCon();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, user_id);
            pstmt.setString(2, routineType);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int rid = rs.getInt("routine_id");
                    System.out.println("✅ routine_id 찾음: " + event_Type + " → " + routineType + " (id=" + rid + ")");
                    return rid;
                } else {
                    System.out.println("⚠️ routine 없음: user_id=" + user_id + ", type=" + routineType);
                }
            }
        } catch (Exception e) {
            System.out.println("❌ routine_id 조회 실패: " + e.getMessage());
        }
        return null;
    }
}

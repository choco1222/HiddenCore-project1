package daily_analysis;

import java.util.ArrayList;
import java.util.List;

import connect.conDB;

/**
 * DAO (Data Access Object) - 데이터 접근 객체
 * 데이터베이스에서 데이터를 조회하는 역할
 * 현재는 더미 데이터를 반환하지만, 실제로는 DB 연결 및 쿼리 실행
 */
public class DailyReportDAO {

	
    /**
     * ACTIVE_LOG 테이블에서 데이터 조회
     * @param userId 사용자 ID
     * @return 활동 로그 리스트
     */
    public static List<DailyReportDTO.activelog> getActiveLogs(String userId) {
    	
        List<DailyReportDTO.activelog> logs = new ArrayList<>();
        
        // 2024-01-15부터 2024-01-21까지의 데이터
        String[] dates = {"2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20", "2024-01-21"};
        
        // 2024-01-15
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-15", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-15", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-15", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-15", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-15", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-15", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-15", "점심", true));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-15", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-15", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-15", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-15", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-15", "저녁", true));
        logs.add(new DailyReportDTO.activelog(userId, "외출복귀", "2024-01-15", null, false));
        
        // 2024-01-16
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-16", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-16", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-16", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-16", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-16", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-16", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-16", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-16", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-16", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-16", "저녁", true));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-16", "저녁", true));
        
        // 2024-01-17
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-17", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-17", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-17", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-17", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-17", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-17", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-17", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-17", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-17", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-17", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-17", "저녁", true));
        logs.add(new DailyReportDTO.activelog(userId, "외출복귀", "2024-01-17", null, false));
        
        // 2024-01-18
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-18", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-18", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-18", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-18", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-18", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-18", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-18", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-18", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-18", "저녁", false));
        
        // 2024-01-19
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-19", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-19", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-19", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-19", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-19", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-19", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-19", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-19", "점심", true));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-19", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-19", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-19", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "외출복귀", "2024-01-19", null, false));
        
        // 2024-01-20
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-20", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-20", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-20", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-20", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-20", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-20", "점심", true));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-20", "점심", true));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-20", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-20", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-20", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-20", "점심", false));
        
        // 2024-01-21
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-21", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-21", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "식사", "2024-01-21", "저녁", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-21", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-21", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "복약", "2024-01-21", "점심", true));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-21", "아침", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-21", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-21", "아침", true));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-21", "점심", false));
        logs.add(new DailyReportDTO.activelog(userId, "양치", "2024-01-21", "저녁", false));
        
        return logs;
    }
    
    /**
     * GAME_LOG 테이블에서 데이터 조회
     * @param userId 사용자 ID
     * @return 게임 로그 리스트
     */
    public static List<DailyReportDTO.game_log> getGameLogs(String userId) {
        List<DailyReportDTO.game_log> logs = new ArrayList<>();
        
        // 2024-01-15
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 75, "2024-01-15"));
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "중", 65, "2024-01-15"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 80, "2024-01-15"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "중", 70, "2024-01-15"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 85, "2024-01-15"));
        
        // 2024-01-16
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 70, "2024-01-16"));
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "상", 55, "2024-01-16"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 75, "2024-01-16"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "중", 60, "2024-01-16"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 80, "2024-01-16"));
        
        // 2024-01-17
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "중", 68, "2024-01-17"));
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 72, "2024-01-17"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 78, "2024-01-17"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "중", 65, "2024-01-17"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 82, "2024-01-17"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "상", 50, "2024-01-17"));
        
        // 2024-01-18
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 80, "2024-01-18"));
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "중", 70, "2024-01-18"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 85, "2024-01-18"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "중", 75, "2024-01-18"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 90, "2024-01-18"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "중", 68, "2024-01-18"));
        
        // 2024-01-19
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 65, "2024-01-19"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 70, "2024-01-19"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "중", 60, "2024-01-19"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 75, "2024-01-19"));
        
        // 2024-01-20
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 78, "2024-01-20"));
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "중", 72, "2024-01-20"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 82, "2024-01-20"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 88, "2024-01-20"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "중", 70, "2024-01-20"));
        
        // 2024-01-21
        logs.add(new DailyReportDTO.game_log(userId, "게임1", "하", 73, "2024-01-21"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "하", 77, "2024-01-21"));
        logs.add(new DailyReportDTO.game_log(userId, "게임2", "상", 45, "2024-01-21"));
        logs.add(new DailyReportDTO.game_log(userId, "게임3", "하", 83, "2024-01-21"));
        
        return logs;
    }
    
    /**
     * 사용자의 루틴 설정 정보 조회
     * @param userId 사용자 ID
     * @return 루틴 설정 정보 리스트 (DB 테이블 구조 그대로)
     */
    public static List<DailyReportDTO.routine> getRoutineConfig(String userId) {
        List<DailyReportDTO.routine> routines = new ArrayList<>();
        
        // TODO: 실제 DB 연결 코드로 교체 필요
        // 예시 구현:
        /*
        try {
            // DB 연결 (실제 연결 정보로 교체 필요)
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/dbname", "username", "password");
            
            String sql = "SELECT user_id, routine_type, routine_time FROM routine WHERE user_id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                String routineType = rs.getString("routine_type");
                String routineTime = rs.getString("routine_time");
                routines.add(new DailyReportDTO.routine(userId, routineType, routineTime));
            }
            
            rs.close();
            pstmt.close();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
            // 에러 발생 시 빈 리스트 반환 또는 기본값 설정
        }
        */
        
        // 현재는 더미 데이터 반환 (실제 DB 연결 시 위 코드로 교체)
        // 더미 데이터: 식사(아침 08:00, 저녁 19:00), 복약(아침 08:30, 저녁 19:30), 양치(저녁 21:00)
        routines.add(new DailyReportDTO.routine(userId, "밥", "08:00"));
        routines.add(new DailyReportDTO.routine(userId, "밥", "19:00"));
        routines.add(new DailyReportDTO.routine(userId, "약", "08:30"));
        routines.add(new DailyReportDTO.routine(userId, "약", "19:30"));
        routines.add(new DailyReportDTO.routine(userId, "양치", "21:00"));
        
        return routines;
    }
    
}

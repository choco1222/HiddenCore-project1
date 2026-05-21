package notify;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import connect.ConDB;

public class RoutineDAO {

    // routine 테이블에서 user_id의 모든 루틴 가져오기
    public List<RoutineRow> findByUser(int userId) {
        List<RoutineRow> list = new ArrayList<>();

        String sql =
            "SELECT routine_type, routine_time, is_drug " +
            "FROM routine " +
            "WHERE user_id = ?";

        try (Connection conn = ConDB.getCon();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            // ✅ DB user_id = INT
            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoutineRow r = new RoutineRow();
                    r.routine_type = safeStr(rs.getString("routine_type"));
                    r.routine_time = safeTimeStr(rs.getString("routine_time")); // "HH:mm:ss" 예상
                    r.is_drug = rs.getBoolean("is_drug");
                    list.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private String safeStr(String s) {
        return (s == null) ? "" : s.trim();
    }

    // TIME 컬럼은 보통 "HH:mm:ss" 로 오지만 혹시 공백/널 방어
    private String safeTimeStr(String s) {
        if (s == null) return "";
        return s.trim();
    }

    // 알림/루틴 용 최소 DTO
    public static class RoutineRow {
        public String routine_type;
        public String routine_time;
        public boolean is_drug;
    }
}

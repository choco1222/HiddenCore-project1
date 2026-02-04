package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import connect.ConDB;

public class RoutineDAO {

    // routine 테이블에서 user_id의 모든 루틴 가져오기
    public List<RoutineRow> findByUser(String userId) {
        List<RoutineRow> list = new ArrayList<>();

        String sql = "SELECT user_id, routine_type, routine_time " +
                     "FROM routine WHERE user_id = ?";

        try (Connection conn = ConDB.getCon();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoutineRow r = new RoutineRow();
                    r.user_id = rs.getString("user_id");
                    r.routine_type = rs.getString("routine_type");
                    r.routine_time = rs.getString("routine_time"); // "08:00" 또는 "30"
                    list.add(r);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 간단 DTO (필요한 값만)
    public static class RoutineRow {
        public String user_id;
        public String routine_type;
        public String routine_time;
    }
}

package notify;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Date;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

import connect.ConDB;

public class ActiveLogDAO {

    private static final DateTimeFormatter HHMMSS = DateTimeFormatter.ofPattern("HH:mm:ss");

    // ✅ 오늘 해당 event_type 기록 존재 여부
    public boolean existsToday(int userId, String eventType, String yyyyMmDd) {
        String sql =
            "SELECT COUNT(*) AS cnt " +
            "FROM activelog " +
            "WHERE user_id = ? " +
            "  AND event_type = ? " +
            "  AND DATE(event_time) = ?";

        try (Connection con = ConDB.getCon();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, eventType);
            ps.setDate(3, Date.valueOf(yyyyMmDd)); // ✅ String 대신 Date 바인딩

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("cnt") > 0;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    // ✅ 추가: 오늘 해당 event_type의 최소 event_time 반환 (없으면 null)
    public String getFirstEventTimeToday(int userId, String eventType, String yyyyMmDd) {
        String sql =
            "SELECT DATE_FORMAT(MIN(event_time), '%Y-%m-%d %H:%i:%s') AS t " +
            "FROM activelog " +
            "WHERE user_id = ? " +
            "  AND event_type = ? " +
            "  AND DATE(event_time) = ?";

        try (Connection con = ConDB.getCon();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setString(2, eventType);
            ps.setDate(3, Date.valueOf(yyyyMmDd)); // ✅ String 대신 Date 바인딩

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getString("t"); // null 가능
            }
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /**
     * ✅ start ~ end 사이에 event_type 기록이 있었는지 (재알림 스킵 판단용)
     * - user_id는 INT로 통일
     * - LocalTime은 HH:mm:ss로 포맷 통일
     */
    public boolean existsEventBetween(Connection con, int userId, String eventType,
                                     LocalTime start, LocalTime end) throws Exception {

        String sql =
            "SELECT COUNT(*) AS cnt " +
            "FROM activelog " +
            "WHERE user_id = ? " +
            "  AND event_type = ? " +
            "  AND event_time >= TIMESTAMP(CURDATE(), ?) " +
            "  AND event_time <= TIMESTAMP(CURDATE(), ?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, eventType);

            // ✅ 무조건 HH:mm:ss
            ps.setString(3, start.format(HHMMSS));
            ps.setString(4, end.format(HHMMSS));

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("cnt") > 0;
            }
        }
    }
}

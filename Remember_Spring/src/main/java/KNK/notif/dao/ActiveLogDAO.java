package notif.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalTime;

public class ActiveLogDAO {

    // start ~ end 사이에 event_type 기록이 있었는지 (재알림 스킵 판단용)
    public boolean existsEventBetween(Connection con, String userId, String eventType,
                                      LocalTime start, LocalTime end) throws Exception {

        String sql =
            "SELECT COUNT(*) AS cnt " +
            "FROM activelog " +
            "WHERE user_id = ? " +
            "  AND event_type = ? " +
            "  AND event_time >= TIMESTAMP(CURDATE(), ?) " +
            "  AND event_time <= TIMESTAMP(CURDATE(), ?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setString(2, eventType);
            ps.setString(3, start.toString()); // HH:mm:ss
            ps.setString(4, end.toString());

            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("cnt") > 0;
            }
        }
    }
}

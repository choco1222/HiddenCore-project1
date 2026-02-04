package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalTime;

import connect.ConDB;

public class ActiveLogDAO {
	// ↓↓↓ 이 메서드만 추가 ↓↓↓
	public boolean existsToday(String userId, String eventType, String yyyyMmDd) {
	    String sql =
	        "SELECT COUNT(*) AS cnt " +
	        "FROM activelog " +
	        "WHERE user_id = ? " +
	        "  AND event_type = ? " +
	        "  AND DATE(event_time) = ?";

	    try (Connection con = ConDB.getCon();
	         PreparedStatement ps = con.prepareStatement(sql)) {

	        ps.setString(1, userId);
	        ps.setString(2, eventType);
	        ps.setString(3, yyyyMmDd);

	        try (ResultSet rs = ps.executeQuery()) {
	            rs.next();
	            return rs.getInt("cnt") > 0;
	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	        return false;
	    }
	}


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

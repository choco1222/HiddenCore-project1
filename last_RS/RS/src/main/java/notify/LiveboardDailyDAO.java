package notify;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

import connect.ConDB;

public class LiveboardDailyDAO {

    // =========================
    // 오늘 activelog 기준 집계 (JOIN 없음)
    // - event_type 별 COUNT, 마지막 시간 MAX
    // =========================
    public static Map<String, Map<String, String>> getTodayActivity(int userId) {

        Map<String, Map<String, String>> res = new HashMap<>();

        // 기본값(프론트에서 기대하는 키들)
        res.put("Meal_breakfast", mk("0", ""));
        res.put("Meal_lunch", mk("0", ""));
        res.put("Meal_dinner", mk("0", ""));
        res.put("Drug", mk("0", ""));

        String sql =
            "SELECT event_type, " +
            "       COUNT(*) AS cnt, " +
            "       DATE_FORMAT(MAX(event_time), '%Y-%m-%d %H:%i:%s') AS lastTime " +
            "  FROM activelog " +
            " WHERE user_id = ? " +
            "   AND event_time >= CONCAT(CURDATE(),' 00:00:00') " +
            "   AND event_time <  CONCAT(DATE_ADD(CURDATE(), INTERVAL 1 DAY),' 00:00:00') " +
            " GROUP BY event_type";

        try (Connection conn = ConDB.getCon();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            int drugCountSum = 0;
            String drugLastTime = "";

            try (ResultSet rs = ps.executeQuery()) {
            	while (rs.next()) {
            	    String type = rs.getString("event_type");
            	    int cnt  = rs.getInt("cnt");
            	    String last = rs.getString("lastTime");
            	    if (last == null) last = "";

            	    switch (type) {
            	        case "Meal_breakfast":
            	        case "Meal_lunch":
            	        case "Meal_dinner":
            	            res.put(type, mk(String.valueOf(cnt), last));
            	            break;

            	        case "Med_morning":
            	        case "Med_lunch":
            	        case "Med_dinner":
            	        case "Med_Taking":
            	        case "Drug":
            	            drugCountSum += cnt;
            	            if (last != null && !last.isEmpty() && (drugLastTime.isEmpty() || last.compareTo(drugLastTime) > 0)) {
            	                drugLastTime = last;
            	            }
            	            break;

            	        case "Brush_morning":
            	            res.put("Meal_breakfast", mk(String.valueOf(cnt), last));
            	            break;
            	        case "Brush_lunch":
            	            res.put("Meal_lunch", mk(String.valueOf(cnt), last));
            	            break;
            	        case "Brush_dinner":
            	            res.put("Meal_dinner", mk(String.valueOf(cnt), last));
            	            break;

            	        default:
            	            break;
            	    }
            	}
            }

            res.put("Drug", mk(String.valueOf(drugCountSum), drugLastTime));
        } catch (Exception e) {
            e.printStackTrace();
        }

        return res;
    }

    // =========================
    // 복약 루틴 존재 여부 (원하면 이것도 제거 가능)
    // =========================
    public static boolean hasDrugRoutine(int userId) {
        // 루틴 아예 안 쓰겠다면 true 고정으로 해도 됨
        return true;
    }

    /**
     * 오늘 기분 기록 1건 조회 (가장 최근 Mood_* 1건)
     */
    public static Map<String, String> getTodayMood(int userId) {
        String sql =
            "SELECT event_type, DATE_FORMAT(event_time, '%Y-%m-%d %H:%i:%s') AS lastTime " +
            "  FROM activelog " +
            " WHERE user_id = ? " +
            "   AND event_time >= CONCAT(CURDATE(),' 00:00:00') " +
            "   AND event_time <  CONCAT(DATE_ADD(CURDATE(), INTERVAL 1 DAY),' 00:00:00') " +
            "   AND event_type LIKE 'Mood_%' " +
            " ORDER BY event_time DESC LIMIT 1";

        try (Connection conn = ConDB.getCon();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String eventType = rs.getString("event_type");
                    String time = rs.getString("lastTime");
                    if (time == null) time = "";
                    String value = (eventType != null && eventType.startsWith("Mood_"))
                        ? eventType.substring("Mood_".length())
                        : (eventType != null ? eventType : "");
                    return Map.of("value", value, "time", time);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return Map.of("value", "", "time", "");
    }

    public static int getTodayGameCount(int userId) {
        String sql =
            "SELECT COUNT(*) FROM game_log " +
            " WHERE user_id = ? AND DATE(played_at) = CURDATE()";

        try (Connection conn = ConDB.getCon();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private static Map<String, String> mk(String c, String t) {
        return Map.of(
            "count", c == null ? "0" : c,
            "lastTime", t == null ? "" : t
        );
    }
}

package report;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import connect.ConDB;

/**
 * [이게 뭔지] DAO - DB에서 activelog, game_log 조회. [뭘 썼는지] ConDB로 Connection, PreparedStatement/ResultSet.
 * [어디서] activelog, game_log 테이블. [어디로] ActivelogRow/GameLogRow 리스트로 서블릿·Service에 반환.
 */
public class DailyReportDAO {

	/**
	 * [이게 뭔지] activelog 한 행을 담는 내부 클래스. 리포트 계산용. [뭘 썼는지] routineType = routine.routine_type(아침/점심/저녁) from JOIN.
	 * [어디서] ResultSet에서 채움. [어디로] getActiveLogs 반환값, DailyReportService.getDailyReportMap 인자.
	 */
	public static class ActivelogRow {
		public int user_id;          // ActiveDTO.user_Id, activelog.user_id(INT)와 동일
		public String event_type;    // ActiveDTO.event_Type
		public String event_time;    // ActiveDTO.event_Time (날짜/시각 문자열)
		public String routineType;  // routine.routine_type (아침/점심/저녁). routine_id로 JOIN.
		public String timeSlot;      // JSON 출력용. routineType과 동일 값.
		public boolean isDuplicate;  // 동일 (event_time, event_type, routineType) 조합 2번째부터 true.
		public String mood;          // event_type에서 추출(기분:기쁨, Mood_happy 등). 월간 보고서 기분 비율 차트용.

		public ActivelogRow(int user_id, String event_type, String event_time, String routineType, boolean isDuplicate) {
			this(user_id, event_type, event_time, routineType, isDuplicate, null);
		}

		public ActivelogRow(int user_id, String event_type, String event_time, String routineType, boolean isDuplicate, String mood) {
			this.user_id = user_id;
			this.event_type = event_type;
			this.event_time = event_time;
			this.routineType = routineType;
			this.timeSlot = routineType;
			this.isDuplicate = isDuplicate;
			this.mood = mood;
		}
	}

	/** event_type에서 기분 한글 추출 (기분:기쁨, Mood_happy 등). */
	private static String moodFromEventType(String rawEventType) {
		if (rawEventType == null) return null;
		if (rawEventType.startsWith("기분:") && rawEventType.length() > 3)
			return rawEventType.substring(3);
		if (rawEventType.startsWith("Mood_")) {
			switch (rawEventType) {
				case "Mood_happy":   return "기쁨";
				case "Mood_neutral": return "평범";
				case "Mood_sad":     return "슬픔";
				case "Mood_angry":   return "화남";
				case "Mood_tired":   return "피곤";
				case "Mood_anxious": return "불안";
				default: return null;
			}
		}
		return null;
	}

	/**
	 * [이게 뭔지] activelog + routine JOIN으로 해당 user_id의 전체 활동 로그 조회. 시간대는 routine.routine_type 사용.
	 * 기분은 event_type(기분:기쁨, Mood_happy 등)에서 추출.
	 */
	public static List<ActivelogRow> getActiveLogs(String userId) {
		List<ActivelogRow> logs = new ArrayList<>();
		String sql = "SELECT a.user_id, a.event_type, a.event_time, r.routine_type "
				+ "FROM activelog a LEFT JOIN routine r ON a.routine_id = r.routine_id "
				+ "WHERE a.user_id = ? ORDER BY a.event_time, a.event_type";

		int userIdInt = 1;
		try {
			userIdInt = Integer.parseInt(userId);
		} catch (NumberFormatException e) {
			System.err.println("Invalid userId, using default: 1");
		}

		try (Connection conn = ConDB.getCon();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, userIdInt);
			try (ResultSet rs = pstmt.executeQuery()) {
				readActiveLogs(rs, logs);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return logs;
	}

	/**
	 * [이게 뭔지] ResultSet → ActivelogRow. DB routine_type(Meal_breakfast 등) → 리포트용 식사/복약, 아침/점심/저녁으로 매핑.
	 */
	private static void readActiveLogs(ResultSet rs, List<ActivelogRow> logs) throws Exception {
		Set<String> seen = new HashSet<>();
		while (rs.next()) {
			java.sql.Timestamp timestamp = rs.getTimestamp("event_time");
			String eventTime = null;
			if (timestamp != null) {
				eventTime = timestamp.toString().substring(0, 10);
			}

			String rawEventType = rs.getString("event_type");
			String rawRoutineType = rs.getString("routine_type");

			// 외출: Service의 hasOuting/외출복귀 필터와 맞춤
			if ("Outing_start".equals(rawEventType) || "Outing_return".equals(rawEventType)) {
				String key = eventTime + "|외출복귀|";
				boolean duplicate = seen.contains(key);
				seen.add(key);
				String m = moodFromEventType(rawEventType);
				logs.add(new ActivelogRow(rs.getInt("user_id"), "외출복귀", eventTime, null, duplicate, m));
				continue;
			}

			// 기분: event_type "기분:기쁨" 또는 "Mood_happy" 등 → 리포트용 "기분"
			if (rawEventType != null && (rawEventType.startsWith("기분:") || rawEventType.startsWith("Mood_"))) {
				String m = moodFromEventType(rawEventType);
				String key = eventTime + "|기분|";
				boolean duplicate = seen.contains(key);
				seen.add(key);
				logs.add(new ActivelogRow(rs.getInt("user_id"), "기분", eventTime, null, duplicate, m));
				continue;
			}

			// DB routine_type → 리포트용 event_type(식사/복약/양치), routineType(아침/점심/저녁)
			// routine_id가 NULL이면 rawRoutineType이 null → activelog.event_type만으로 매핑 (더미 데이터 등)
			String displayEventType = rawEventType;
			String displayRoutineType = null;
			String source = rawRoutineType != null ? rawRoutineType : rawEventType;
			if (source != null) {
				switch (source) {
					case "Meal_breakfast":
						displayEventType = "식사";
						displayRoutineType = "아침";
						break;
					case "Meal_lunch":
						displayEventType = "식사";
						displayRoutineType = "점심";
						break;
					case "Meal_dinner":
						displayEventType = "식사";
						displayRoutineType = "저녁";
						break;
					case "Drug":
						displayEventType = "복약";
						if (timestamp != null) {
							int hour = timestamp.toLocalDateTime().getHour();
							if (hour >= 0 && hour < 11) displayRoutineType = "아침";
							else if (hour >= 11 && hour < 16) displayRoutineType = "점심";
							else displayRoutineType = "저녁";
						}
						break;
					case "Med_morning":
						displayEventType = "복약";
						displayRoutineType = "아침";
						break;
					case "Med_lunch":
						displayEventType = "복약";
						displayRoutineType = "점심";
						break;
					case "Med_dinner":
						displayEventType = "복약";
						displayRoutineType = "저녁";
						break;
					case "Med_Taking":
						displayEventType = "복약";
						if (timestamp != null) {
							int hour = timestamp.toLocalDateTime().getHour();
							if (hour >= 0 && hour < 11) displayRoutineType = "아침";
							else if (hour >= 11 && hour < 16) displayRoutineType = "점심";
							else displayRoutineType = "저녁";
						}
						break;
					case "Brush_breakfast":
					case "Brush_morning":
						displayEventType = "양치";
						displayRoutineType = "아침";
						break;
					case "Brush_lunch":
						displayEventType = "양치";
						displayRoutineType = "점심";
						break;
					case "Brush_dinner":
						displayEventType = "양치";
						displayRoutineType = "저녁";
						break;
					default:
						// Awake, Sleep 등: activities에 없어서 카운트 안 됨. 시각으로만 슬롯 추정
						if (timestamp != null) {
							int hour = timestamp.toLocalDateTime().getHour();
							if (hour >= 6 && hour < 11) displayRoutineType = "아침";
							else if (hour >= 11 && hour < 16) displayRoutineType = "점심";
							else displayRoutineType = "저녁";
						}
						break;
				}
			}
			if (displayRoutineType == null && timestamp != null) {
				int hour = timestamp.toLocalDateTime().getHour();
				if (hour >= 6 && hour < 11) displayRoutineType = "아침";
				else if (hour >= 11 && hour < 16) displayRoutineType = "점심";
				else displayRoutineType = "저녁";
			}

			String key = eventTime + "|" + displayEventType + "|" + displayRoutineType;
			boolean duplicate = seen.contains(key);
			seen.add(key);
			String m = moodFromEventType(rawEventType);
			logs.add(new ActivelogRow(rs.getInt("user_id"), displayEventType, eventTime, displayRoutineType, duplicate, m));
		}
	}

	/**
	 * [이게 뭔지] game_log 한 행. [어디서] game_log 테이블 컬럼. [어디로] getGameLogs 반환, Service에서 일별 게임 평균 계산.
	 */
	/** GameDTO / game_log 테이블과 동일 타입 */
	public static class GameLogRow {
		public int user_id;           // GameDTO.user_id
		public String game_type;      // GameDTO.game_type
		public String game_level;    // GameDTO.game_level
		public String play_time;      // GameDTO.play_time
		public int score;            // GameDTO.score
		public java.time.LocalDateTime playedAt; // GameDTO.playedAt

		public GameLogRow(int user_id, String game_type, String game_level, String play_time, int score, java.time.LocalDateTime playedAt) {
			this.user_id = user_id;
			this.game_type = game_type;
			this.game_level = game_level;
			this.play_time = play_time;
			this.score = score;
			this.playedAt = playedAt;
		}
	}

	/**
	 * [이게 뭔지] game_log 테이블에서 해당 user_id의 전체 게임 로그 조회.
	 * [어디서] game_log (user_id, game_type, game_level, score, total_score, played_at). [어디로] List<GameLogRow> → 서블릿/Service.
	 */
	public static List<GameLogRow> getGameLogs(String userId) {
		List<GameLogRow> logs = new ArrayList<>();
		String sql = "SELECT user_id, game_type, game_level, play_time, score, played_at FROM game_log WHERE user_id = ? ORDER BY played_at";

		int userIdInt = 1;
		try {
			userIdInt = Integer.parseInt(userId);
		} catch (NumberFormatException e) {
			System.err.println("Invalid userId, using default: 1");
		}

		try (Connection conn = ConDB.getCon();
			 PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, userIdInt);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					java.sql.Timestamp ts = rs.getTimestamp("played_at");
					java.time.LocalDateTime playedAt = (ts != null) ? ts.toLocalDateTime() : null;
					logs.add(new GameLogRow(
							rs.getInt("user_id"),
							rs.getString("game_type"),
							rs.getString("game_level"),
							rs.getString("play_time"),
							rs.getInt("score"),
							playedAt
					));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return logs;
	}

	/**
	 * [이게 뭔지] game_log 리스트를 JSON 배열 문자열로 변환. notify.JsonUtil에 gameLogsToJson이 없어 report 내부에서 제공.
	 * [어디로] MonthlyReportServlet, WeeklyReportServlet에서 activeLogsJson과 함께 JSP에 전달.
	 */
	public static String gameLogsToJson(List<GameLogRow> logs) {
		if (logs == null || logs.isEmpty()) {
			return "[]";
		}
		StringBuilder json = new StringBuilder();
		json.append("[");
		for (int i = 0; i < logs.size(); i++) {
			if (i > 0) json.append(",");
			GameLogRow g = logs.get(i);
			if (g == null) continue;
			// 주간/월간 보고서에서 날짜 필터 매칭용으로 yyyy-MM-dd만 전달 (클라이언트 dates 배열과 동일 형식)
			String playedAtStr = (g.playedAt != null) ? g.playedAt.toLocalDate().toString() : null;
			json.append("{");
			json.append("\"user_id\":").append(g.user_id).append(",");
			json.append("\"game_type\":").append(esc(g.game_type)).append(",");
			json.append("\"game_level\":").append(esc(g.game_level)).append(",");
			json.append("\"play_time\":").append(esc(g.play_time)).append(",");
			json.append("\"score\":").append(g.score).append(",");
			json.append("\"played_at\":").append(esc(playedAtStr));
			json.append("}");
		}
		json.append("]");
		return json.toString();
	}

	/** ActivelogRow 리스트를 JSON 문자열로 변환. 주간/월간 보고서 활동별 상세 분석용 (event_type, routineType 문자열 값 정확히 전달). */
	public static String activeLogsToJson(List<ActivelogRow> logs) {
		if (logs == null || logs.isEmpty()) {
			return "[]";
		}
		StringBuilder json = new StringBuilder();
		json.append("[");
		for (int i = 0; i < logs.size(); i++) {
			if (i > 0) json.append(",");
			ActivelogRow log = logs.get(i);
			if (log == null) continue;
			json.append("{");
			json.append("\"user_id\":").append(log.user_id).append(",");
			json.append("\"event_type\":\"").append(escapeJson(log.event_type)).append("\",");   // "식사" 형태로 파싱되도록
			json.append("\"event_time\":\"").append(escapeJson(log.event_time)).append("\",");
			json.append("\"timeSlot\":\"").append(escapeJson(log.timeSlot)).append("\",");
			json.append("\"routineType\":\"").append(escapeJson(log.timeSlot)).append("\",");
			json.append("\"isDuplicate\":").append(log.isDuplicate);
			if (log.mood != null && !log.mood.isEmpty()) {
				json.append(",\"mood\":\"").append(escapeJson(log.mood)).append("\"");
			}
			json.append("}");
		}
		json.append("]");
		return json.toString();
	}

	/** JSON 문자열 값 내부만 이스케이프 (따옴표는 호출부에서 붙임 → 파싱 시 "식사" 로 나옴) */
	private static String escapeJson(String s) {
		if (s == null) return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
	}

	private static String esc(String s) {
		if (s == null) return "\"\"";
		return "\"" + escapeJson(s) + "\"";
	}

}

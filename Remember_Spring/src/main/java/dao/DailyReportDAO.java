package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import dto.DailyReportDTO;

/**
 * DAO - DB에서 조회/저장 시 무엇을 어디서 불러오는지 주석으로 명시
 */
public class DailyReportDAO {

	/** activelog 조회 결과 한 행 (리포트 계산용). DTO에는 timeSlot만 두고, 여기서만 사용 */
	public static class ActivelogRow {
		public String user_id;
		public String event_type;
		public String event_time;
		public String timeSlot;
		public boolean isDuplicate;

		public ActivelogRow(String user_id, String event_type, String event_time, String timeSlot,
				boolean isDuplicate) {
			this.user_id = user_id;
			this.event_type = event_type;
			this.event_time = event_time;
			this.timeSlot = timeSlot;
			this.isDuplicate = isDuplicate;
		}
	}

	/**
	 * [불러오는 것] activelog 테이블에서 해당 사용자(user_id)의 전체 활동 로그 - 사용 목적:
	 * timeSlot(아침/점심/저녁)만 따로 쓸 때 사용 - 불러오는 컬럼: user_id, event_type, event_time,
	 * time_slot (또는 timeSlot) - isDuplicate: DB 컬럼 아님. 동일 (event_time, event_type,
	 * time_slot) 조합이 2번째 나올 때부터 true 로 설정 - 정렬: event_time, event_type, time_slot 순
	 * - 반환: ActivelogRow 리스트 (리포트 계산용). DTO의 TimeSlotRecord 는 timeSlot 만 담을 때만 사용
	 */
	public static List<ActivelogRow> getActiveLogs(String userId) {
		List<ActivelogRow> logs = new ArrayList<>();
		String sql = "SELECT user_id, event_type, event_time, time_slot FROM activelog WHERE user_id = ? ORDER BY event_time, event_type, time_slot";
		try (Connection conn = ConDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userId);
			try (ResultSet rs = pstmt.executeQuery()) {
				Set<String> seen = new HashSet<>();
				while (rs.next()) {
					String eventTime = rs.getDate("event_time") != null ? rs.getDate("event_time").toString() : null;
					if (eventTime == null)
						eventTime = rs.getString("event_time");
					String timeSlot = rs.getString("time_slot");
					if (timeSlot == null)
						timeSlot = rs.getString("timeSlot");
					String key = eventTime + "|" + rs.getString("event_type") + "|" + timeSlot;
					boolean duplicate = seen.contains(key);
					seen.add(key);
					logs.add(new ActivelogRow(rs.getString("user_id"), rs.getString("event_type"), eventTime, timeSlot,
							duplicate));
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return logs;
	}

	/**
	 * [불러오는 것] daily_analysis 테이블에서 해당 사용자(user_id) + 날짜(analysis_date) 1건 - 불러오는
	 * 컬럼: analysis_id, user_id, analysis_date, daily_score, active_score,
	 * game_score_avg, status_level, is_save_bool - 조건: user_id = ? AND
	 * analysis_date = ? - 반환: 1건이면 DailyAnalysis, 없으면 null
	 */
	public static dao.DailyAnalysis getDailyAnalysis(String userId, String analysisDate) {
		String sql = "SELECT analysis_id, user_id, analysis_date, daily_score, active_score, game_score_avg, status_level, is_save_bool "
				+ "FROM daily_analysis WHERE user_id = ? AND analysis_date = ?";
		try (Connection conn = ConDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, userId);
			pstmt.setString(2, analysisDate);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					DailyReportDTO.DailyAnalysis a = new DailyReportDTO.DailyAnalysis();
					a.analysis_id = rs.getString("analysis_id");
					a.user_id = rs.getString("user_id");
					a.analysis_date = rs.getDate("analysis_date") != null ? rs.getDate("analysis_date").toString()
							: analysisDate;
					a.daily_score = rs.getInt("daily_score");
					a.active_score = rs.getInt("active_score");
					a.game_score_avg = rs.getInt("game_score_avg");
					a.status_level = rs.getString("status_level");
					a.is_save_bool = rs.getInt("is_save_bool");
					return a;
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;
	}

	/**
	 * [저장/수정하는 것] daily_analysis 테이블에 1건 INSERT 또는 (user_id + analysis_date 중복 시)
	 * UPDATE - 넣는 컬럼: analysis_id, user_id, analysis_date, daily_score,
	 * active_score, game_score_avg, status_level, is_save_bool - UNIQUE 기준: user_id
	 * + analysis_date - ON DUPLICATE KEY UPDATE 시 위 컬럼들만 갱신
	 */
	public static void saveOrUpdateDailyAnalysis(DailyReportDTO.DailyAnalysis a) {
		String sql = "INSERT INTO daily_analysis (analysis_id, user_id, analysis_date, daily_score, active_score, game_score_avg, status_level, is_save_bool) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?) "
				+ "ON DUPLICATE KEY UPDATE daily_score = VALUES(daily_score), active_score = VALUES(active_score), "
				+ "game_score_avg = VALUES(game_score_avg), status_level = VALUES(status_level), is_save_bool = VALUES(is_save_bool)";
		try (Connection conn = ConDB.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, a.analysis_id);
			pstmt.setString(2, a.user_id);
			pstmt.setString(3, a.analysis_date);
			pstmt.setInt(4, a.daily_score);
			pstmt.setInt(5, a.active_score);
			pstmt.setInt(6, a.game_score_avg);
			pstmt.setString(7, a.status_level != null ? a.status_level : "");
			pstmt.setInt(8, a.is_save_bool);
			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}

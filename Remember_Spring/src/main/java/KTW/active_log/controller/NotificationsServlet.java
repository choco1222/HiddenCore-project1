package controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import util.DB;

@WebServlet("/api/notifications")
public class NotificationsServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
		req.setCharacterEncoding("UTF-8");
		resp.setContentType("application/json; charset=UTF-8");

		// 1) 세션
		HttpSession session = req.getSession(false);
		String userId = (session == null) ? null : (String) session.getAttribute("user_id");

		// 2) 파라미터
		if (userId == null) {
			userId = req.getParameter("user_id");
		}

		// 3) 시연용 기본값 (⭐ 이 줄이 핵심)
		if (userId == null) {
			userId = "U001"; // ← DB에 넣어둘 환자 user_id
		}

		// sinceId는 “최근에 본 이벤트 시간(ms)” 용도로 쓰자 (실시간 기록 알림에 유용)
		long sinceMs = parseLong(req.getParameter("sinceId"), 0);

		try (Connection con = DB.getConnection()) {
			// ✅ 2) 내 role, linked_user_id 조회
			UserInfo me = getUserInfo(con, userId);

			// 알림 대상(환자 기준으로 계산)
			// - 환자 로그인: target = 본인
			// - 보호자 로그인: target = linked_user_id(환자)
			String targetPatientId = "보호자".equals(me.role) ? me.linkedUserId : userId;

			List<Notif> items = new ArrayList<>();

			// A) 환자 루틴 리마인드(환자/보호자 둘 다 “환자 기준”으로 계산 가능)
			items.addAll(buildRoutineReminders(con, targetPatientId));

			// B) 보호자면: 환자 실시간 기록 발생 알림(최근 이벤트)
			if ("보호자".equals(me.role)) {
				items.addAll(buildRecentActiveLogs(con, targetPatientId, sinceMs));
			}

			// C) 보호자면: 위험 단계 알림
			if ("보호자".equals(me.role)) {
				items.addAll(buildStatusLevelAlert(con, targetPatientId));
			}

			// unreadCount는 그냥 items 개수로(시연용)
			String json = toJson(items.size(), items);
			resp.getWriter().write(json);

		} catch (Exception e) {
			e.printStackTrace();
			resp.setStatus(500);
			resp.getWriter().write("{\"unreadCount\":0,\"items\":[]}");
		}
	}

	// -------------------- 알림 생성 로직 --------------------

	private static final DateTimeFormatter HHMM_OPT = DateTimeFormatter.ofPattern("HH:mm[:ss]");

	private List<Notif> buildRoutineReminders(Connection con, String patientId) throws Exception {
		List<Notif> out = new ArrayList<>();

		String sql = "SELECT routine_type, routine_time FROM routine WHERE user_id = ?";
		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, patientId);

			try (ResultSet rs = ps.executeQuery()) {
				LocalTime now = LocalTime.now();

				while (rs.next()) {
					String type = rs.getString("routine_type"); // 밥/약/양치
					String timeStr = rs.getString("routine_time"); // '08:00' or '08:00:00'

					if (type == null || timeStr == null)
						continue;

					LocalTime rt;
					try {
						rt = LocalTime.parse(timeStr.trim(), HHMM_OPT);
					} catch (Exception e) {
						continue;
					}

					// ✅ "루틴 시간 + 30분"이 지났을 때만 알림 후보
					if (now.isBefore(rt.plusMinutes(30)))
						continue;

					// ✅ rt±30분 범위에 기록이 있으면 '했다'로 간주 → 알림 X
					boolean doneAround = hasEventInWindow(con, patientId, type, rt.minusMinutes(30),
							rt.plusMinutes(30));
					if (doneAround)
						continue;

					long ms = System.currentTimeMillis();

					// ⭐ key에 "type + time + 오늘"을 넣어야 (양치 2회 같은 경우) 각각 관리 가능
					String key = "ROUTINE_LATE_" + patientId + "_" + type + "_" + rt.toString() + "_" + todayKey();

					out.add(new Notif(key, ms, "루틴 미체크",
							type + " (" + rt.format(DateTimeFormatter.ofPattern("HH:mm")) + ") 아직 체크 안 했어요!"));
				}
			}
		}

		return out;
	}

	// sinceMs 이후에 발생한 ACTIVE_LOG를 보호자에게 알림
	private List<Notif> buildRecentActiveLogs(Connection con, String patientId, long sinceMs) throws Exception {
		List<Notif> out = new ArrayList<>();

		String sql = "SELECT event_type, event_time " + "FROM activelog "
				+ "WHERE user_id = ? AND event_time > FROM_UNIXTIME(?/1000) " + "ORDER BY event_time ASC";

		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, patientId);
			ps.setLong(2, sinceMs);
			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					String type = rs.getString("event_type");
					Timestamp ts = rs.getTimestamp("event_time");
					long ms = (ts == null) ? System.currentTimeMillis() : ts.getTime();

					String key = "ACTIVE_" + patientId + "_" + ms + "_" + (type == null ? "" : type);
					out.add(new Notif(key, ms, "환자 활동", "환자가 [" + type + "] 기록을 남겼어요."));
				}
			}
		}
		return out;
	}

	// 오늘/최신 분석이 주의/위험이면 알림
	private List<Notif> buildStatusLevelAlert(Connection con, String patientId) throws Exception {
		List<Notif> out = new ArrayList<>();

		String sql = "SELECT status_level, analysis_date " + "FROM DAILY_ANALYSIS " + "WHERE user_id = ? "
				+ "ORDER BY analysis_date DESC";

		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, patientId);
			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next())
					return out;

				String level = rs.getString("status_level");
				Date d = rs.getDate("analysis_date");
				if (level == null)
					return out;

				if ("주의".equals(level) || "위험".equals(level)) {
					long now = System.currentTimeMillis();
					String key = "STATUS_" + patientId + "_" + (d == null ? todayKey() : d.toString());
					out.add(new Notif(key, now, "상태 경고", "환자 상태가 [" + level + "] 단계예요."));
				}
			}
		}
		return out;
	}

	private boolean hasEventInWindow(Connection con, String userId, String routineType, LocalTime start, LocalTime end)
			throws Exception {

		String eventType = mapRoutineToEvent(routineType);

		String sql = "SELECT COUNT(*) AS cnt " + "FROM activelog " + "WHERE user_id = ? " + "  AND event_type = ? "
				+ "  AND event_time >= TIMESTAMP(CURDATE(), ?) " + "  AND event_time <= TIMESTAMP(CURDATE(), ?)";

		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, userId);
			ps.setString(2, eventType);
			ps.setString(3, start.toString()); // 'HH:mm:ss' 형태로 들어가도 MySQL이 처리함
			ps.setString(4, end.toString());

			try (ResultSet rs = ps.executeQuery()) {
				rs.next();
				return rs.getInt("cnt") > 0;
			}
		}
	}

	// routine_type(밥/약/양치) ↔ activelog.event_type(식사/약복용/양치) 매핑
	private String mapRoutineToEvent(String routineType) {
		if ("밥".equals(routineType))
			return "식사";
		if ("약".equals(routineType))
			return "약복용";
		if ("양치".equals(routineType))
			return "양치";
		return routineType;
	}

	private UserInfo getUserInfo(Connection con, String userId) throws Exception {
		String sql = "SELECT role, linked_user_id FROM users WHERE user_id = ?";
		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, userId);
			try (ResultSet rs = ps.executeQuery()) {
				if (!rs.next())
					return new UserInfo(null, null);
				return new UserInfo(rs.getString("role"), rs.getString("linked_user_id"));
			}
		}
	}

	// -------------------- JSON 출력(라이브러리 없이) --------------------

	private String toJson(int unreadCount, List<Notif> items) {
		StringBuilder sb = new StringBuilder();
		sb.append("{\"unreadCount\":").append(unreadCount).append(",\"items\":[");
		for (int i = 0; i < items.size(); i++) {
			Notif n = items.get(i);
			if (i > 0)
				sb.append(",");
			sb.append("{").append("\"key\":\"").append(esc(n.key)).append("\",").append("\"id\":").append(n.id)
					.append(",").append("\"title\":\"").append(esc(n.title)).append("\",").append("\"body\":\"")
					.append(esc(n.body)).append("\"").append("}");
		}
		sb.append("]}");
		return sb.toString();
	}

	private String esc(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ");
	}

	private long parseLong(String s, long def) {
		try {
			return Long.parseLong(s);
		} catch (Exception e) {
			return def;
		}
	}

	private String todayKey() {
		// YYYYMMDD 형태
		Calendar c = Calendar.getInstance();
		int y = c.get(Calendar.YEAR);
		int m = c.get(Calendar.MONTH) + 1;
		int d = c.get(Calendar.DAY_OF_MONTH);
		return String.format("%04d%02d%02d", y, m, d);
	}

	// -------------------- 내부 클래스 --------------------
	static class UserInfo {
		final String role;
		final String linkedUserId;

		UserInfo(String role, String linkedUserId) {
			this.role = role;
			this.linkedUserId = linkedUserId;
		}
	}

	static class Notif {
		final String key; // 중복방지용 고유키
		final long id; // sinceId 비교용(시간 ms)
		final String title;
		final String body;

		Notif(String key, long id, String title, String body) {
			this.key = key;
			this.id = id;
			this.title = title;
			this.body = body;
		}
	}
}

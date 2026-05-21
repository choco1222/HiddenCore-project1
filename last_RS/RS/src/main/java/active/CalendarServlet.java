package active;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Calendar;
import connect.ConDB;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/active/CalendarServlet")
public class CalendarServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		Calendar today = Calendar.getInstance();
		String yearParam = request.getParameter("year");
		String monthParam = request.getParameter("month");

		int year = yearParam != null ? Integer.parseInt(yearParam) : today.get(Calendar.YEAR);
		int month = monthParam != null ? Integer.parseInt(monthParam) : (today.get(Calendar.MONTH) + 1);

		Calendar cal = Calendar.getInstance();
		cal.set(year, month - 1, 1);
		int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK);
		int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

		request.setAttribute("year", year);
		request.setAttribute("month", month);
		request.setAttribute("firstDayOfWeek", firstDayOfWeek);
		request.setAttribute("daysInMonth", daysInMonth);
		request.setAttribute("prevYear", (month == 1) ? year - 1 : year);
		request.setAttribute("prevMonth", (month == 1) ? 12 : month - 1);
		request.setAttribute("nextYear", (month == 12) ? year + 1 : year);
		request.setAttribute("nextMonth", (month == 12) ? 1 : month + 1);
		request.setAttribute("todayYear", today.get(Calendar.YEAR));
		request.setAttribute("todayMonth", today.get(Calendar.MONTH) + 1);
		request.setAttribute("todayDay", today.get(Calendar.DATE));

		// userId 가져오기
		HttpSession session = request.getSession(false);
		Integer userId = null;
		if (session != null && session.getAttribute("userId") != null) {
			userId = (Integer) session.getAttribute("userId");
		}
		
		// DB에서 해당 월의 기분 데이터 조회 → JSON으로 JSP에 전달
		String moodDataJson = "[]";
		if (userId != null) {
			moodDataJson = getMoodDataJson(userId, year, month);
		}
		request.setAttribute("moodDataJson", moodDataJson);

		request.getRequestDispatcher("/active/calendarView.jsp").forward(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
	
	/**
	 * 해당 월의 기분 데이터를 DB에서 조회해 JSON 문자열로 반환
	 * [{"date":"2026-02-13","mood":"happy","time":"14:30"}]
	 */
	private String getMoodDataJson(int userId, int year, int month) {
		StringBuilder json = new StringBuilder("[");
		
		String sql = "SELECT DATE(event_time) AS dt, " +
		             "       event_type, " +
		             "       TIME_FORMAT(event_time, '%H:%i') AS tm " +
		             "  FROM activelog " +
		             " WHERE user_id = ? " +
		             "   AND YEAR(event_time) = ? " +
		             "   AND MONTH(event_time) = ? " +
		             "   AND event_type LIKE 'Mood_%' " +
		             " ORDER BY event_time";
		
		try (Connection conn = ConDB.getCon();
		     PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, userId);
			pstmt.setInt(2, year);
			pstmt.setInt(3, month);
			
			try (ResultSet rs = pstmt.executeQuery()) {
				boolean first = true;
				while (rs.next()) {
					if (!first) json.append(",");
					first = false;
					
					String date = rs.getString("dt");
					String eventType = rs.getString("event_type");
					String time = rs.getString("tm");
					
					// Mood_happy → happy
					String mood = eventType != null && eventType.startsWith("Mood_") 
					              ? eventType.substring("Mood_".length()) 
					              : "neutral";
					
					json.append("{");
					json.append("\"date\":\"").append(escapeJson(date)).append("\",");
					json.append("\"mood\":\"").append(escapeJson(mood)).append("\",");
					json.append("\"time\":\"").append(escapeJson(time)).append("\"");
					json.append("}");
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		json.append("]");
		return json.toString();
	}
	
	private String escapeJson(String s) {
		if (s == null) return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}
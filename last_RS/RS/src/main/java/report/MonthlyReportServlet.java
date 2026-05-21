package report;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

import javax.servlet.RequestDispatcher;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * [이게 뭔지] Controller(서블릿) - 월간 리포트 요청 처리.
 * [뭘 썼는지] HttpServlet, @WebServlet("/report/monthly"). [어디서] 클라이언트 GET /report/monthly. [어디로] monthly.jsp로 포워드, activeLogsJson/gameLogsJson 전달.
 */
@WebServlet("/report/monthly")
public class MonthlyReportServlet extends HttpServlet {

	/**
	 * [이게 뭔지] GET 처리 - 날짜/사용자 파라미터 받아 activelog·game_log 조회 후 JSON으로 JSP에 전달.
	 * [어디서] date, userId는 세션 우선, 없으면 쿼리 파라미터. [어디로] date, userId, activeLogsJson, gameLogsJson → monthly.jsp.
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// [이게 뭔지] 조회 기준 날짜. [어디서] request.getParameter("date"). 없으면 오늘.
		String date = request.getParameter("date");
		String userId = null;
		Object sessionUserId = request.getSession().getAttribute("userId");
		if (sessionUserId != null) {
			userId = String.valueOf(sessionUserId);
		}
		if (userId == null || userId.isEmpty()) {
			userId = request.getParameter("userId");
		}
		if (userId == null || userId.isEmpty()) {
			userId = "527645721"; // 더미 사용자(환자1) 기준. 로그인 시 세션에서 조회됨.
		}

		if (date == null || date.isEmpty()) {
			date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}

		// [이게 뭔지] activelog 조회 결과 리스트. [어디서] DailyReportDAO.getActiveLogs → activelog 테이블.
		List<DailyReportDAO.ActivelogRow> activeLogs = DailyReportDAO.getActiveLogs(userId);
		// [이게 뭔지] game_log 조회 결과 리스트. [어디서] DailyReportDAO.getGameLogs → game_log 테이블.
		List<DailyReportDAO.GameLogRow> gameLogs = DailyReportDAO.getGameLogs(userId);

		// [이게 뭔지] activelog/game_log를 JSON 문자열로. [뭘 썼는지] DailyReportDAO. [어디로] request 속성 → JSP의 script type="application/json" 내용.
		String activeLogsJson = DailyReportDAO.activeLogsToJson(activeLogs);
		String gameLogsJson = DailyReportDAO.gameLogsToJson(gameLogs);

		request.setAttribute("date", date);
		request.setAttribute("userId", userId);
		request.setAttribute("activeLogsJson", activeLogsJson);
		request.setAttribute("gameLogsJson", gameLogsJson);

		// [이게 뭔지] 월간 보고서 JSP로 포워드. [어디로] /report/monthly.jsp.
		RequestDispatcher dispatcher = request.getRequestDispatcher("/report/monthly.jsp");
		dispatcher.forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}

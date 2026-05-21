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
 * [이게 뭔지] Controller(서블릿) - 주간 리포트 요청 처리.
 * [뭘 썼는지] HttpServlet, @WebServlet("/report/weekly"). [어디서] 클라이언트 GET /report/weekly. [어디로] weekly.jsp로 포워드, activeLogsJson/gameLogsJson 전달.
 */
@WebServlet("/report/weekly")
public class WeeklyReportServlet extends HttpServlet {

	/**
	 * [이게 뭔지] GET 처리 - date/userId 받아 activelog·game_log 조회 후 JSON으로 JSP에 전달.
	 * [어디서] date, userId는 세션 우선, 없으면 쿼리 파라미터. [어디로] weekly.jsp, activeLogsJson, gameLogsJson.
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
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

		// [이게 뭔지] activelog 목록. [어디서] DailyReportDAO.getActiveLogs → activelog 테이블.
		List<DailyReportDAO.ActivelogRow> activeLogs = DailyReportDAO.getActiveLogs(userId);
		// [이게 뭔지] game_log 목록. [어디서] DailyReportDAO.getGameLogs → game_log 테이블.
		List<DailyReportDAO.GameLogRow> gameLogs = DailyReportDAO.getGameLogs(userId);

		// [이게 뭔지] JSON 문자열. [뭘 썼는지] DailyReportDAO. [어디로] request 속성 → weekly.jsp의 script type="application/json".
		String activeLogsJson = DailyReportDAO.activeLogsToJson(activeLogs);
		String gameLogsJson = DailyReportDAO.gameLogsToJson(gameLogs);

		request.setAttribute("date", date);
		request.setAttribute("userId", userId);
		request.setAttribute("activeLogsJson", activeLogsJson);
		request.setAttribute("gameLogsJson", gameLogsJson);

		RequestDispatcher dispatcher = request.getRequestDispatcher("/report/weekly.jsp");
		dispatcher.forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}

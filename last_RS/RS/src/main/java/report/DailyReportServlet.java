package report;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import notify.JsonUtil;
import notify.RoutineDAO;

/**
 * [이게 뭔지] Controller(서블릿) - 일간 보고서 요청 처리 및 화면 제어.
 * [뭘 썼는지] HttpServlet 상속, @WebServlet으로 URL 매핑.
 * [어디서/어디로] 클라이언트가 /report/daily 로 GET 요청 → 이 서블릿이 처리 → daily.jsp로 포워드.
 * [기타] 일간 보고서는 취침 1시간 전부터만 열람 가능(루틴 Sleep 기준). DAILY_REPORT_ALWAYS_VISIBLE=true면 항상 열람 가능(개발/테스트용).
 */
@WebServlet("/report/daily")
public class DailyReportServlet extends HttpServlet {

	/** [이게 뭔지] 일간 보고서 항상 열람 허용 플래그. [뭘 썼는지] true=언제든 열람, false=취침 1시간 전만 허용. [기타] 운영 시 false 권장. */
	private static final boolean DAILY_REPORT_ALWAYS_VISIBLE = true;

	/**
	 * [이게 뭔지] GET 요청 처리 - 일간 보고서 데이터 준비 후 JSP로 포워드.
	 * [어디서] date, userId는 request 파라미터에서. [어디로] date, userId, reportAllowed, reportDataJson 등은 request 속성으로 JSP에 전달.
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// [이게 뭔지] 조회할 날짜. [어디서] URL 쿼리 파라미터 "date" (예: ?date=2026-02-06). 없으면 아래에서 오늘 날짜로 설정.
		String date = request.getParameter("date");
		// [이게 뭔지] 사용자 ID. [어디서] URL 쿼리 "userId". [어디로] DAO/Service 호출 시 사용, request 속성으로 JSP에도 전달.
		// request 파라미터 말고 세션에서 조회
		String userId = null;
		Object sessionUserId = request.getSession().getAttribute("userId");
		if (sessionUserId != null) {
			userId = String.valueOf(sessionUserId);
		}
		if (userId == null || userId.isEmpty()) {
			userId = "527645721"; // 로그인 안 된 경우 더미 사용자(환자1). 로그인 시 세션에서 조회됨.
		}

		if (date == null || date.isEmpty()) {
			// [뭘 썼는지] LocalDate.now(), DateTimeFormatter - 오늘 날짜를 yyyy-MM-dd 문자열로. [어디로] date 변수에 대입.
			date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}

		// [이게 뭔지] JSP에서 쓸 날짜/사용자ID. [어디로] request 속성 → daily.jsp의 ${date}, ${userId}로 전달.
		request.setAttribute("date", date);
		request.setAttribute("userId", userId);

		// [이게 뭔지] 열람 허용 여부. [뭘 썼는지] DAILY_REPORT_ALWAYS_VISIBLE이면 true, 아니면 취침 1시간 전 구간만 허용. [어디로] reportAllowed 속성으로 JSP 전달.
		boolean allowed = DAILY_REPORT_ALWAYS_VISIBLE ? true : isWithinAllowedTime(userId);
		request.setAttribute("reportAllowed", allowed);

		if (!allowed) {
			// [이게 뭔지] 열람 불가 시 보여줄 메시지. [어디로] reportNotAllowedMessage 속성 → daily.jsp에서 표시.
			request.setAttribute("reportNotAllowedMessage",
					"일간 보고서는 취침 1시간 전부터 열람할 수 있습니다.");
			// [이게 뭔지] 포워드. [뭘 썼는지] RequestDispatcher - 같은 요청/응답을 daily.jsp로 넘김. [어디로] /report/daily.jsp.
			RequestDispatcher dispatcher = request.getRequestDispatcher("/report/reportMain.jsp");
			dispatcher.forward(request, response);
			return;
		}

		// [이게 뭔지] activelog 테이블 조회 결과. [뭘 썼는지] DailyReportDAO.getActiveLogs - DB에서 가져옴. [어디서] activelog 테이블.
		List<DailyReportDAO.ActivelogRow> activeLogs = DailyReportDAO.getActiveLogs(userId);

		// [이게 뭔지] game_log 테이블 조회 결과. [어디서] game_log 테이블. [어디로] DailyReportService.getDailyReportMap 인자로 전달.
		List<DailyReportDAO.GameLogRow> gameLogs = DailyReportDAO.getGameLogs(userId);

		// [이게 뭔지] 일간 리포트 한 건 분량의 Map. [뭘 썼는지] DailyReportService - activeLogs(routineType), gameLogs로 계산. [어디로] JSON 문자열로 변환 후 JSP.
		java.util.Map<String, Object> reportData = DailyReportService.getDailyReportMap(date, userId, activeLogs, gameLogs);

		// [이게 뭔지] 리포트 데이터 JSON 문자열. [뭘 썼는지] JsonUtil.mapToJson. [어디로] reportDataJson 속성 → daily.jsp의 script 태그 내용으로 출력.
		String reportDataJson = JsonUtil.mapToJson(reportData);
		request.setAttribute("reportDataJson", reportDataJson);

		RequestDispatcher dispatcher = request.getRequestDispatcher("/report/reportMain.jsp");
		dispatcher.forward(request, response);
	}

	/**
	 * [이게 뭔지] 현재 시각이 루틴의 취침(Sleep) 1시간 전 ~ 취침 시각 사이인지 판단.
	 * [뭘 썼는지] notify.RoutineDAO.findByUser로 routine 테이블에서 Sleep 시각 조회.
	 * [어디서] routine 테이블의 Sleep 값. 없으면 기본 22:00 기준. [어디로] boolean 반환 → doGet에서 reportAllowed 계산에 사용.
	 */
	private boolean isWithinAllowedTime(String userId) {
		try {
			int userIdInt = 1;
			try {
				userIdInt = Integer.parseInt(userId);
			} catch (NumberFormatException e) {
				return false;
			}

			// [이게 뭔지] notify.RoutineDAO.findByUser로 루틴 목록 조회 후 Sleep 시각 추출. (selectRoutineMap 없음)
			List<notify.RoutineDAO.RoutineRow> routines = new RoutineDAO().findByUser(userIdInt);
			String sleepTimeStr = null;
			for (notify.RoutineDAO.RoutineRow r : routines) {
				if (r != null && "Sleep".equalsIgnoreCase(r.routine_type)) {
					sleepTimeStr = (r.routine_time != null) ? r.routine_time.trim() : null;
					break;
				}
			}
			// routine_time은 "HH:mm:ss" 형태 → "HH:mm"만 사용
			if (sleepTimeStr != null && sleepTimeStr.length() >= 5) {
				sleepTimeStr = sleepTimeStr.substring(0, 5);
			}

			int sleepHour = 22;
			int sleepMinute = 0;
			if (sleepTimeStr != null && !sleepTimeStr.isEmpty()) {
				// [뭘 썼는지] "HH:mm" 형태 파싱. split(":")로 시/분 추출. [어디로] sleepHour, sleepMinute.
				String[] parts = sleepTimeStr.trim().split(":");
				if (parts.length >= 1) sleepHour = Integer.parseInt(parts[0]);
				if (parts.length >= 2) sleepMinute = Integer.parseInt(parts[1]);
			}

			// [이게 뭔지] 취침 시각, 허용 시작 시각(1시간 전). [뭘 썼는지] LocalTime. [어디로] 현재 시각과 비교.
			LocalTime sleepTime = LocalTime.of(sleepHour, sleepMinute);
			LocalTime allowedStart = sleepTime.minusHours(1);
			LocalTime now = LocalTime.now();

			// [이게 뭔지] 같은 날 안에 있는 경우 (예: 21:00~22:00). [어디로] return 값 계산.
			if (!allowedStart.isAfter(sleepTime)) {
				return !now.isBefore(allowedStart) && !now.isAfter(sleepTime);
			}
			// [기타] 자정을 넘기는 경우 (예: 23:30~00:30).
			return !now.isBefore(allowedStart) || !now.isAfter(sleepTime);
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		// [이게 뭔지] POST도 동일하게 GET 로직 사용. [어디로] doGet 호출.
		doGet(request, response);
	}
}

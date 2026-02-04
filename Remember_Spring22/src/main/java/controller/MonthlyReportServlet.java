package controller;

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

import dao.DailyReportDAO;
import util.JsonUtil;

/**
 * Controller (서블릿) - 월간 리포트 요청 처리
 */
@WebServlet("/monthly")
public class MonthlyReportServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String date = request.getParameter("date");
		String userId = request.getParameter("userId");

		if (userId == null || userId.isEmpty()) {
			userId = "user1"; // 기본값
		}

		if (date == null || date.isEmpty()) {
			date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}

		// DAO: activelog 조회(ActivelogRow, timeSlot 사용)
		List<DailyReportDAO.ActivelogRow> activeLogs = DailyReportDAO.getActiveLogs(userId);

		String activeLogsJson = JsonUtil.activeLogsToJson(activeLogs);
		String gameLogsJson = "[]";

		request.setAttribute("date", date);
		request.setAttribute("userId", userId);
		request.setAttribute("activeLogsJson", activeLogsJson);
		request.setAttribute("gameLogsJson", gameLogsJson);

		RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/monthly.jsp");
		dispatcher.forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
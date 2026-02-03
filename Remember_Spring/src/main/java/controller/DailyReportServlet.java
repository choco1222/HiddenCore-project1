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
import dto.DailyReportDTO;
import service.DailyReportService;

/**
 * Controller (서블릿) - 요청 처리 및 흐름 제어 HTTP 요청을 받아서 처리하고 JSP로 전달하는 역할
 */
@WebServlet("/daily")
public class DailyReportServlet extends HttpServlet {

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String date = request.getParameter("date");
		String userId = request.getParameter("userId");

		if (userId == null || userId.isEmpty()) {
			userId = "user1"; // 기본값
		}

		if (date == null || date.isEmpty()) {
			// 오늘 날짜를 기본값으로 설정
			date = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));
		}

		// DAO: DailyAnalysis + activelog 조회(ActivelogRow, timeSlot 사용)
		List<DailyReportDAO.ActivelogRow> activeLogs = DailyReportDAO.getActiveLogs(userId);

		// Service: activeLogs(timeSlot)만 사용
		java.util.Map<String, Object> reportData = DailyReportService.getDailyReportMap(date, userId, activeLogs);

		// daily_analysis 테이블에 저장 (analysis_id 20자 이내)
		String analysisId = "DA" + date.replace("-", "") + (userId.length() > 8 ? userId.substring(0, 8) : userId);
		if (analysisId.length() > 20)
			analysisId = analysisId.substring(0, 20);
		DailyReportDTO.DailyAnalysis analysis = new DailyReportDTO.DailyAnalysis(analysisId, userId, date,
				(Integer) reportData.get("daily_score"), (Integer) reportData.get("active_score"),
				(Integer) reportData.get("game_score_avg"), (String) reportData.get("status_level"), 1 // is_save_bool:
																										// 1=정상(저장된 보고서)
		);
		DailyReportDAO.saveOrUpdateDailyAnalysis(analysis);

		reportData.put("analysis_id", analysis.analysis_id);
		reportData.put("is_save_bool", analysis.is_save_bool);

		// Utility를 통해 JSON 변환
		String reportDataJson = JsonUtil.mapToJson(reportData);

		// JSP로 전달
		request.setAttribute("date", date);
		request.setAttribute("userId", userId);
		request.setAttribute("reportDataJson", reportDataJson);
		request.setAttribute("dailyAnalysis", analysis);

		RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/daily.jsp");
		dispatcher.forward(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}
}
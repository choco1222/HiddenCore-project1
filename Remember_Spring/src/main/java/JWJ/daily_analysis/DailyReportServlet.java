package daily_analysis;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

/**
 * Controller (서블릿) - 요청 처리 및 흐름 제어
 * HTTP 요청을 받아서 처리하고 JSP로 전달하는 역할
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
        
        // DAO를 통해 데이터 조회
        List<DailyReportDTO.activelog> activeLogs = DailyReportDAO.getActiveLogs(userId);
        List<DailyReportDTO.game_log> gameLogs = DailyReportDAO.getGameLogs(userId);
        List<DailyReportDTO.routine> routineList = DailyReportDAO.getRoutineConfig(userId);
        
        // Service를 통해 비즈니스 로직 처리 (리포트 계산)
        java.util.Map<String, Object> reportData = DailyReportService.getDailyReportMap(date, userId, activeLogs, gameLogs, routineList);
        
        // Utility를 통해 JSON 변환
        String reportDataJson = JsonUtil.mapToJson(reportData);
        
        // JSP로 전달
        request.setAttribute("date", date);
        request.setAttribute("userId", userId);
        request.setAttribute("reportDataJson", reportDataJson);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/daily.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

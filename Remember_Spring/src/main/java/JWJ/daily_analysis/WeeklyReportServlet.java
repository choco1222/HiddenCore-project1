package JWJ.daily_analysis;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.List;

/**
 * Controller (서블릿) - 주간 리포트 요청 처리
 */
@WebServlet("/weekly")
public class WeeklyReportServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String date = request.getParameter("date");
        String userId = request.getParameter("userId");
        
        if (userId == null || userId.isEmpty()) {
            userId = "user1"; // 기본값
        }
        
        if (date == null || date.isEmpty()) {
            date = "2024-01-21"; // 기본값
        }
        
        // DAO를 통해 데이터 조회
        List<DailyReportDTO.activelog> activeLogs = DailyReportDAO.getActiveLogs(userId);
        List<DailyReportDTO.game_log> gameLogs = DailyReportDAO.getGameLogs(userId);
        
        // Utility를 통해 JSON 변환
        String activeLogsJson = JsonUtil.activeLogsToJson(activeLogs);
        String gameLogsJson = JsonUtil.gameLogsToJson(gameLogs);
        
        // JSP로 전달
        request.setAttribute("date", date);
        request.setAttribute("userId", userId);
        request.setAttribute("activeLogsJson", activeLogsJson);
        request.setAttribute("gameLogsJson", gameLogsJson);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/jsp/weekly.jsp");
        dispatcher.forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}

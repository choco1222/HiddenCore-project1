package controller;

import java.io.IOException;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/saveLog")
public class Care extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");

        String eventType = request.getParameter("type");
        String time = request.getParameter("time");

        HttpSession session = request.getSession(false);
        String userId = (session == null) ? null : (String) session.getAttribute("user_id");

        // 1) type은 필수
        if (eventType == null || eventType.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "type 누락");
            return;
        }

        // 2) 테스트용 userId (로그인 없으면 강제 부여) - 나중에 지우고 아래꺼 쓸거임
        if (userId == null || userId.trim().isEmpty()) {
            userId = "U001";
        }
        
        /*
        if (userId == null || userId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
            return;
        }
        */

        System.out.println("🧪 saveLog | userId=" + userId + ", eventType=" + eventType + ", time=" + time);

        Board_DAO dao = new Board_DAO();
        int result = dao.insertLog(userId, eventType);

        if (result > 0) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "DB 저장 실패");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doPost(request, response);
    }
}

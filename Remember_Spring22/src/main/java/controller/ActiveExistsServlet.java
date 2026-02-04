package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.ActiveLogDAO;

/**
 * GET /api/active/exists?event_type=Meal_breakfast&date=2026-02-04
 * user_id는 세션 또는 user_id 파라미터로 받음
 *
 * 응답 예:
 * {"exists":true}
 */
@WebServlet("/api/active/exists")
public class ActiveExistsServlet extends HttpServlet {

    private final ActiveLogDAO activeLogDAO = new ActiveLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        String userId = getUserId(req);
        String eventType = req.getParameter("event_type");
        String date = req.getParameter("date"); // "YYYY-MM-DD"

        if (userId == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"no user_id\"}");
            return;
        }
        if (eventType == null || eventType.isEmpty() || date == null || date.isEmpty()) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"missing event_type or date\"}");
            return;
        }

        boolean exists = activeLogDAO.existsToday(userId, eventType, date);
        resp.getWriter().write("{\"exists\":" + exists + "}");
    }

    private String getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        String userId = null;

        if (session != null) userId = (String) session.getAttribute("user_id");
        if (userId == null) userId = req.getParameter("user_id");

        return userId;
    }
}

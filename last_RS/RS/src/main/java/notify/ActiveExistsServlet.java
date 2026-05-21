package notify;

import java.io.IOException;
import java.sql.Date;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/api/active/exists")
public class ActiveExistsServlet extends HttpServlet {

    private final ActiveLogDAO activeLogDAO = new ActiveLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        Integer userId = getUserId(req);   // ✅ int 기준
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

        // ✅ date 형식 검증 (YYYY-MM-DD)
        try {
            Date.valueOf(date);
        } catch (IllegalArgumentException e) {
            resp.setStatus(400);
            resp.getWriter().write("{\"error\":\"invalid date format (YYYY-MM-DD)\"}");
            return;
        }

        boolean exists = activeLogDAO.existsToday(userId, eventType, date);
        resp.getWriter().write("{\"exists\":" + exists + "}");
    }

    private Integer getUserId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);

        // 1) 세션 우선
        if (session != null) {
            Object v = session.getAttribute("userId");
            if (v instanceof Integer) return (Integer) v;

            // 과거 호환: String으로 들어온 경우
            if (v instanceof String) {
                try { return Integer.parseInt((String) v); }
                catch (NumberFormatException e) { return null; }
            }
        }

        // 2) 파라미터 fallback
        String p = req.getParameter("userId");
        if (p != null && !p.isEmpty()) {
            try { return Integer.parseInt(p); }
            catch (NumberFormatException e) { return null; }
        }

        return null;
    }
}

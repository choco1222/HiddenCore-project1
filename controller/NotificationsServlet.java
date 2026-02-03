package controller;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import connect.ConDB;
import notif.dao.ActiveLogDAO;
import notif.dao.RoutineDAO;
import notif.dto.NotifDTO;
import notif.service.NotificationService;
import notif.util.JsonUtil;

@WebServlet("/api/notifications")
public class NotificationsServlet extends HttpServlet {

    private final NotificationService service =
        new NotificationService(new RoutineDAO(), new ActiveLogDAO());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        String userId = (session == null) ? null : (String) session.getAttribute("user_id");
        if (userId == null) userId = req.getParameter("user_id");
        if (userId == null) userId = "U001"; // 시연용

        long sinceMs = parseLong(req.getParameter("sinceMs"), 0);

        try (Connection con = ConDB.getConnection()) {
            List<NotifDTO> items = service.build(con, userId, sinceMs);
            resp.getWriter().write(JsonUtil.toJson(items.size(), items));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
            resp.getWriter().write("{\"unreadCount\":0,\"items\":[]}");
        }
    }

    private long parseLong(String s, long def) {
        try { return Long.parseLong(s); } catch (Exception e) { return def; }
    }
}

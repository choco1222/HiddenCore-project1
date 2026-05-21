package active;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/active/saveLog")
public class Care extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1️⃣ 세션에서 userId (없으면 요청 파라미터로 폴백 - Context path 변경 시 쿠키 미전달 대비)
        HttpSession session = request.getSession(false);
        Integer userId = null;

        if (session != null && session.getAttribute("userId") != null) {
            userId = (Integer) session.getAttribute("userId");
        } else {
            String param = request.getParameter("userId");
            if (param == null) param = request.getParameter("user_id");
            if (param != null && !param.isEmpty()) {
                try {
                    userId = Integer.parseInt(param.trim());
                    System.out.println("⚠️ 세션 없음 → 파라미터 userId 사용: " + userId);
                } catch (NumberFormatException e) {
                    System.out.println("❌ 잘못된 userId 파라미터: " + param);
                }
            }
        }

        if (userId == null) {
            System.out.println("❌ 로그인 세션 없음, userId 파라미터도 없음");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 3️⃣ 이벤트 타입
        String eventType = request.getParameter("type");
        if (eventType == null || eventType.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "type 없음");
            return;
        }

        // 4️⃣ DB 저장
        ActiveDAO dao = new ActiveDAO();
        int result = dao.insertLog(userId, eventType);

        if (result > 0) {
            response.setStatus(HttpServletResponse.SC_OK);
        } else {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}

package notify;

import notify.RoutineDAO;
import notify.RoutineDAO.RoutineRow;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * GET /api/routine - user_id는 세션(user_id) 우선 - 없으면 ?user_id=123 같은 파라미터로 받음
 *
 * 응답 예: [ {"routine_type":"Meal_breakfast","routine_time":"08:00:00"},
 * {"routine_type":"Drug","routine_time":"09:00:00"} ]
 */
@WebServlet("/api/routine")
public class RoutineServlet extends HttpServlet {

	private final RoutineDAO routineDAO = new RoutineDAO();

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		req.setCharacterEncoding("UTF-8");
		resp.setContentType("application/json; charset=UTF-8");

		Integer userId = getUserId(req); // ✅ int 기준
		if (userId == null) {
			resp.setStatus(401);
			resp.getWriter().write("{\"error\":\"no user_id\"}");
			return;
		}

		// ✅ DAO도 findByUser(int userId) 로 바꾸는 게 정석
		List<RoutineRow> list = routineDAO.findByUser(userId);

		// JSON 직접 조립(간단 버전)
		StringBuilder sb = new StringBuilder();
		sb.append("[");

		for (int i = 0; i < list.size(); i++) {
			RoutineRow r = list.get(i);

			sb.append("{")
			  .append("\"routine_type\":\"").append(escape(r.routine_type)).append("\",")
			  .append("\"routine_time\":\"").append(escape(r.routine_time)).append("\",")
			  .append("\"is_drug\":").append(r.is_drug)
			  .append("}");


			if (i < list.size() - 1)
				sb.append(",");
		}

		sb.append("]");
		resp.getWriter().write(sb.toString());
	}

	private Integer getUserId(HttpServletRequest req) {
		HttpSession session = req.getSession(false);

		// 1) 세션 우선
		if (session != null) {
			Object v = session.getAttribute("userId");
			if (v instanceof Integer)
				return (Integer) v;

			// 과거 코드 호환: 세션에 String으로 들어간 경우도 처리
			if (v instanceof String) {
				try {
					return Integer.parseInt((String) v);
				} catch (NumberFormatException e) {
					return null;
				}
			}
		}

		// 2) 파라미터 fallback
		String p = req.getParameter("userId");
		if (p != null && !p.isEmpty()) {
			try {
				return Integer.parseInt(p);
			} catch (NumberFormatException e) {
				return null;
			}
		}

		return null;
	}

	// 아주 최소한의 이스케이프 (따옴표/역슬래시)
	private String escape(String s) {
		if (s == null)
			return "";
		return s.replace("\\", "\\\\").replace("\"", "\\\"");
	}
}

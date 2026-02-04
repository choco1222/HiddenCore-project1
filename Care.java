package active_log;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/saveLog")
public class Care extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    String type = request.getParameter("type");
	    board_DAO dao1 = new board_DAO();

	
		request.setCharacterEncoding("UTF-8");

		String eventType = request.getParameter("type");
		String time = request.getParameter("time");

		System.out.println("type = " + eventType);
		System.out.println("time = " + time);

		if (eventType == null || eventType.trim().isEmpty()) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST);
			return;
		}

		board_DAO dao = new board_DAO();
		int result = dao.insertLog(eventType);

		if (result > 0) {
			response.setStatus(HttpServletResponse.SC_OK);
		} else {
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}

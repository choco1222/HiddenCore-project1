package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/saveLog")
public class CareServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
	}
	
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    String type = request.getParameter("type");
	    ActiveDAO dao1 = new ActiveDAO();

	 // 이 아래 두 줄이 핵심입니다.
	    boolean check = dao1.isDuplicate(type); 
	    response.getWriter().print(check);
		
		request.setCharacterEncoding("UTF-8");

		String eventType = request.getParameter("type");
		String time = request.getParameter("time");

		System.out.println("type = " + eventType);
		System.out.println("time = " + time);

		if (eventType == null || eventType.trim().isEmpty()) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST);
			return;
		}

		ActiveDAO dao = new ActiveDAO();
		int result = dao.insertLog(eventType);

		if (result > 0) {
			response.setStatus(HttpServletResponse.SC_OK);
		} else {
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
		}
	}
}
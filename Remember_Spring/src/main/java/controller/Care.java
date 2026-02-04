package controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.ActiveDAO;

@WebServlet("/saveLog")
public class Care extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String type = request.getParameter("type");
		ActiveDAO dao1 = new ActiveDAO();

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
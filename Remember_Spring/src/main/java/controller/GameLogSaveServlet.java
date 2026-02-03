package controller;

import java.io.IOException;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import dao.GameDAO;
import dto.GameDTO;

@WebServlet("/GameLogSave.do")
public class GameLogSaveServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/plain; charset=UTF-8");

		try {
			HttpSession session = request.getSession(false);
			if (session == null || session.getAttribute("user_id") == null) {
				response.getWriter().write("no_login");
				return;
			}

			String userId = (String) session.getAttribute("user_id");

			String gameType = request.getParameter("game_type");
			String gameLevel = request.getParameter("game_level");
			String playTime = request.getParameter("play_time");
			String scoreStr = request.getParameter("score");

			if (gameType == null || gameLevel == null || scoreStr == null) {
				response.getWriter().write("bad_request");
				return;
			}

			int score = Integer.parseInt(scoreStr);

			GameDTO dto = new GameDTO();
			dto.setUser_id(userId);
			dto.setGame_type(gameType);
			dto.setGame_level(gameLevel);
			dto.setPlay_time(playTime);
			dto.setScore(score);
			dto.setPlayedAt(LocalDateTime.now());

			GameDAO dao = new GameDAO();
			dao.insertGameLog(dto);

			response.getWriter().write("ok");

		} catch (Exception e) {
			e.printStackTrace();
			response.getWriter().write("fail");
		}
	}
}
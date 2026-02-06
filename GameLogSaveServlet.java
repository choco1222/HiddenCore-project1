package project;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/GameLogSaveServlet.do")
public class GameLogSaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        System.out.println("서블릿 진입 성공!"); // 1번 확인
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        try {
            // ✅ 테스트용: 로그인 구현 전까지 임시로 user_id 세션 주입
            HttpSession session = request.getSession();
            if (session.getAttribute("user_id") == null) {
                session.setAttribute("user_id", 1001); // 테스트 ID
            }

            int userId = (Integer) session.getAttribute("user_id");

            String gameType = request.getParameter("game_type");
            String gameLevel = request.getParameter("game_level");
            String playTime = request.getParameter("play_time");
            String scoreStr = request.getParameter("score");

            if (gameType == null || gameLevel == null || scoreStr == null) {
                response.getWriter().write("bad_request");
                return;
            }

            int score = Integer.parseInt(scoreStr);

            // ✅ game_id 생성 (중복 방지)
            String gameId = gameType.toUpperCase() + "_" + System.currentTimeMillis();

            GameDTO dto = new GameDTO();
            dto.setGame_id(gameId);
            dto.setUser_id(userId);
            dto.setGame_type(gameType);
            dto.setGame_level(gameLevel);
            dto.setPlay_time(playTime);
            dto.setScore(score);
            dto.setPlayedAt(LocalDateTime.now());

            GameDAO dao = new GameDAO();
            
            // 1️⃣ 게임 로그 저장
            boolean ok = dao.insertGameLog(dto);
            
            if (ok) {
                // 2️⃣ 오늘 날짜의 해당 게임 타입 평균 점수 계산 및 업데이트
                LocalDate today = LocalDate.now();
                dao.updateDailyAverageScore(userId, gameType, today);
                System.out.println("평균 점수 업데이트 완료!");
            }

            response.getWriter().write(ok ? "ok" : "fail");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("fail");
        }
    }
}
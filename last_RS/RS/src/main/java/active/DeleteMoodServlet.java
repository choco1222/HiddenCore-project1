package active;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import connect.ConDB;

@WebServlet("/active/deleteMood")
public class DeleteMoodServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 세션에서 userId 가져오기
        HttpSession session = request.getSession(false);
        Integer userId = null;
        if (session != null && session.getAttribute("userId") != null) {
            userId = (Integer) session.getAttribute("userId");
        }

        if (userId == null) {
            System.out.println("❌ 기분 삭제 실패: 로그인 세션 없음");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        // 삭제할 날짜
        String date = request.getParameter("date");
        if (date == null || date.isEmpty()) {
            System.out.println("❌ 기분 삭제 실패: date 파라미터 없음");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "date 없음");
            return;
        }

        // DB에서 해당 날짜의 Mood_* 이벤트 삭제
        String sql = "DELETE FROM activelog " +
                     " WHERE user_id = ? " +
                     "   AND DATE(event_time) = ? " +
                     "   AND event_type LIKE 'Mood_%'";

        try (Connection conn = ConDB.getCon();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, date);
            
            int deleted = pstmt.executeUpdate();
            System.out.println("✅ 기분 삭제 완료: user_id=" + userId + ", date=" + date + ", 삭제 건수=" + deleted);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("{\"success\":true,\"deleted\":" + deleted + "}");
            
        } catch (Exception e) {
            System.out.println("❌ 기분 삭제 중 에러:");
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}

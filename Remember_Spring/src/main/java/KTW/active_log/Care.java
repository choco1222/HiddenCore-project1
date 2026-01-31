package KTW.active_log;

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
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response); 
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
   
        request.setCharacterEncoding("UTF-8");

      
        String event_Type = request.getParameter("type");
     
        System.out.println("서버에 도착한 event_Type: " + event_Type);

        if (event_Type != null && !event_Type.isEmpty()) {
         
            Board_DAO dao = new Board_DAO();
            int result = dao.insertLog(event_Type); 
         
            Board_DAO dao1 = new Board_DAO();
            dao1.insertLog(event_Type); // 여기서 eventType은 JS에서 받아온 값!
            
            if (result > 0) {
                System.out.println("✅ DB 저장 성공: " + event_Type);
                response.setStatus(HttpServletResponse.SC_OK); // 성공 응답
            } else {
                System.out.println("❌ DB 저장 실패 (DAO 로직 확인 필요)");
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            }
        } else {
            System.out.println("❌ eventType이 null입니다. JS 전송 이름을 확인하세요.");
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
}

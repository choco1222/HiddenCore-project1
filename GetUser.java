package active_log;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/getUser")
public class GetUser extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain; charset=UTF-8");
        
        String userId = (String) request.getSession().getAttribute("user_id");

        if (userId == null) {
            userId = "guest"; 
        }

        response.getWriter().write(userId); 
    }
}
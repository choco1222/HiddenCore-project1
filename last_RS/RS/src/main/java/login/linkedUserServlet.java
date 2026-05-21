package login;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/login/patientIdInput")
public class linkedUserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doPost(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("linkedUserServlet");
        // CharSet "UTF-8"
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        int patientId = Integer.parseInt(request.getParameter("patientId"));
        System.out.println(userId + ", " + patientId);

        UserDAO dao = new UserDAO();
        
        if(dao.checkDuplicateUserId(patientId)) {
        	if(dao.linkPatient(userId, patientId)) {
                session.setAttribute("linkedSuccess", "회원 연동이 완료되었습니다!");
				session.setAttribute("patinetName", new UserDAO().getUserById(patientId).getName());
                System.out.println("SUCCESS");
                response.sendRedirect(request.getContextPath() + "/notify/guard.jsp");
        	} else {
        		System.out.println("Falied - 연동오류");
        		session.setAttribute("linkedError", "연동 중 오류가 발생했습니다.");
            	response.sendRedirect(request.getContextPath() + "/login/patientIdInput.jsp");
        	}
        } else {
        	System.out.println("Falied - 유저 아이디 확인X");
    		session.setAttribute("linkedError", "유저 정보를 찾을 수 없습니다.");
        	response.sendRedirect(request.getContextPath() + "/login/patientIdInput.jsp");
        }
        		
	}

}

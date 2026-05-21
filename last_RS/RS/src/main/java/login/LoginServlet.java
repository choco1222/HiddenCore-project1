package login;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 로그인 처리 서블릿 환자와 보호자를 구분하여 적절한 페이지로 리다이렉트
 */
@WebServlet("/auth/login")
public class LoginServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		// 한글 인코딩 설정
		request.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");

		// 로그인 파라미터 받기
		String loginId = request.getParameter("loginId");
		String loginPassword = request.getParameter("loginPassword");

		// 세션 생성
		HttpSession session = request.getSession();

		try {
			// 사용자 인증 (DB 조회)
			UserDTO user = authenticateUser(loginId, loginPassword);

			if (user == null) {
				// 로그인 실패
				session.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
				response.sendRedirect(request.getContextPath() + "/login/login.jsp");
				return;
			}

			// 로그인 성공 - 세션에 사용자 정보 저장
			session.setAttribute("userId", user.getUserId());
			System.out.println("Session 저장 - userId: " + user.getUserId());
			session.setAttribute("userName", user.getName());
			if(user.getName() != null)
					System.out.println(user.getName());
			else System.out.println("null");
			session.setAttribute("userRole", user.getRole());

			// 역할에 따른 페이지 분기
			if ("환자".equals(user.getRole())) {
				// 환자 로그인
				handlePatientLogin(request, response, session, user);
			} else if ("보호자".equals(user.getRole())) {
				// 보호자 로그인
				handleCaregiverLogin(request, response, session, user);
			} else {
				// 알 수 없는 역할
				session.invalidate();
				response.sendRedirect(request.getContextPath() + "/login/login.jsp");
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.setAttribute("loginError", "로그인 처리 중 오류가 발생했습니다.");
			response.sendRedirect(request.getContextPath() + "/login/login.jsp");
		}
		
		String keepLogin = request.getParameter("keepLogin");
		if ("on".equals(keepLogin)) {
		    // 쿠키 저장 (7일)
		    Cookie cookie = new Cookie("savedId", loginId);
		    cookie.setMaxAge(7 * 24 * 60 * 60);
		    response.addCookie(cookie);
		}
	}

	/**
	 * 환자 로그인 처리
	 */
	private void handlePatientLogin(HttpServletRequest request, HttpServletResponse response, HttpSession session,
			UserDTO user) throws IOException {

		// 루틴 입력 완료 여부 확인
		boolean routineCompleted = checkRoutineCompleted(user.getUserId());

		if (routineCompleted) {
			// 루틴 입력 완료 - 메인 페이지로
			response.sendRedirect(request.getContextPath() + "/active/main.jsp");
		} else {
			// 루틴 미입력 - 루틴 입력 페이지로
			response.sendRedirect(request.getContextPath() + "/login/routineInput.jsp");
		}
	}

	/**
	 * 보호자 로그인 처리
	 */
	private void handleCaregiverLogin(HttpServletRequest request, HttpServletResponse response, HttpSession session,
			UserDTO user) throws IOException {

		// 연결된 환자 ID 확인
		Integer linkedPatientId = getLinkedPatientId(user.getUserId());

		if (linkedPatientId != null) {
			// 환자 ID 등록 완료 - 보호자 메인 페이지로
			session.setAttribute("linkedPatientId", user.getLinkedUserId());
			session.setAttribute("patinetName", new UserDAO().getUserById(user.getLinkedUserId()).getName());			
			response.sendRedirect(request.getContextPath() + "/notify/guard.jsp");
		} else {
			// 환자 ID 미등록 - 환자 ID 입력 페이지로
			response.sendRedirect(request.getContextPath() + "/login/patientIdInput.jsp");
		}
	}

	/**
	 * 사용자 인증 (DB 조회)
	 */
	private UserDTO authenticateUser(String loginId, String loginPassword) {
		UserDAO userDAO = new UserDAO();
		return userDAO.authenticateUser(loginId, loginPassword);
	}

	/**
	 * 환자의 루틴 입력 완료 여부 확인 TODO: 실제 루틴 테이블과 연동 필요
	 */
	private boolean checkRoutineCompleted(int userId) {
		boolean hasRoutine = new RoutineDAO().hasRoutine(userId);
		System.out.println("☑️유저 루틴 등록:" + hasRoutine);
		return hasRoutine;
	}

	/**
	 * 보호자의 Linked ID조회
	 */
	private Integer getLinkedPatientId(int caregiverId) {
		UserDAO userDAO = new UserDAO();
		UserDTO user = userDAO.getUserById(caregiverId);

		if (user != null) {
			return user.getLinkedUserId();
		}

		return null;
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doPost(request, response);
	}
}

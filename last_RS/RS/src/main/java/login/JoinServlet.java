package login;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 회원가입 처리
 * joinStep0, 1 -> JoinProcess
 */
@WebServlet("/login/join")
public class JoinServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // CharSet "UTF-8"
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        
        // request Form Data : id, pass, role, name, phone, email
        String loginId = request.getParameter("joinId");
        String password = request.getParameter("joinPassword");
        String passwordConfirm = request.getParameter("joinPasswordConfirm");
        String name = request.getParameter("userName");
        String birthdate = request.getParameter("birthDate");
        String phone = request.getParameter("phone");
        String emailId = request.getParameter("emailId");
        String emailDomain = request.getParameter("emailDomain");
        String userRole = request.getParameter("userRole").equals("patient") ? "환자" : "보호자";
        
        // Get role in Session
        HttpSession session = request.getSession();        
        try {
            // 입력값 검증
            if (loginId == null || loginId.isEmpty() || 
                password == null || password.isEmpty() ||
                name == null || name.isEmpty() ||
                phone == null || phone.isEmpty()) {
                
                session.setAttribute("joinError", "필수 항목을 모두 입력해주세요.");
                response.sendRedirect(request.getContextPath() + "/login/joinStep1.jsp");
                return;
            }
            
            // 비밀번호 확인
            if (!password.equals(passwordConfirm)) {
                session.setAttribute("joinError", "비밀번호가 일치하지 않습니다.");
                response.sendRedirect(request.getContextPath() + "/login/joinStep1.jsp");
                return;
            }
            
            // 이메일 조합
            String email = null;
            if (emailId != null && !emailId.isEmpty() && 
                emailDomain != null && !emailDomain.isEmpty()) {
                email = emailId + "@" + emailDomain;
            }
            
            // 비밀번호 암호화
            String hashedPassword = PasswordUtil.hashPassword(password);
            if (hashedPassword == null) {
                session.setAttribute("joinError", "비밀번호 암호화에 실패했습니다.");
                response.sendRedirect(request.getContextPath() + "/login/joinStep1.jsp");
                return;
            }
            
            // UserDTO 생성
            UserDTO userDTO = new UserDTO();
            userDTO.setLoginId(loginId);
            userDTO.setPassword(hashedPassword);  // password to hash
            userDTO.setRole(userRole);
            userDTO.setName(name);
            userDTO.setPhone(phone);
            userDTO.setEmail(email);
            userDTO.setBirthdate(birthdate);
            
            UserDAO userDAO = new UserDAO();
            
            // 아이디 중복 체크
            if (userDAO.checkDuplicateId(loginId)) {
                session.setAttribute("joinError", "이미 사용 중인 아이디입니다.");
                response.sendRedirect(request.getContextPath() + "/login/joinStep1.jsp");
                return;
            }
            
            // 회원 등록
            boolean success = userDAO.insertUser(userDTO);
            
            if (success) {
                // 환자인 경우 설문조사로, 보호자인 경우 로그인으로
                if ("환자".equals(userRole)) {
                    // 가입한 사용자의 ID를 세션에 저장 (설문 결과 저장용)
                    // 평문 비밀번호로 인증 (아직 암호화 안 된 상태에서 가입 직후)
                    UserDTO registeredUser = userDAO.authenticateUser(loginId, password);
                    if (registeredUser != null) {
                        session.setAttribute("userId", registeredUser.getUserId());
                        session.setAttribute("userName", registeredUser.getName());
                    }
                    response.sendRedirect(request.getContextPath() + "/login/surveyIntro.jsp");
                } else {
                    session.removeAttribute("userRole");
                    session.setAttribute("joinSuccess", "회원가입이 완료되었습니다!");
                    response.sendRedirect(request.getContextPath() + "/login/login.jsp");
                }
            } else {
                // 입력한 값들을 request에 저장
                request.setAttribute("joinError", "회원가입에 실패했습니다. 다시 시도해주세요.");
                request.setAttribute("joinId", loginId);
                request.setAttribute("userName", name);
                request.setAttribute("phone", phone);
                request.setAttribute("emailId", emailId);
                
                // forward로 다시 joinStep1.jsp로
                request.getRequestDispatcher("/login/joinStep1.jsp").forward(request, response);
                return;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // 입력한 값들을 request에 저장
            request.setAttribute("joinError", "회원가입 처리 중 오류가 발생했습니다.");
            request.setAttribute("joinId", loginId);
            request.setAttribute("userName", name);
            request.setAttribute("phone", phone);
            request.setAttribute("emailId", emailId);
            
            // forward로 다시 joinStep1.jsp로
            request.getRequestDispatcher("/login/joinStep1.jsp").forward(request, response);
            return;
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}

package controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 로그인 처리 서블릿
 * 환자와 보호자를 구분하여 적절한 페이지로 리다이렉트
 * [loginProc.java]
      ↓ 인증 성공
      ├─ 환자
      │   ├─ 루틴 완료 → KTW/jsp/index.jsp
      │   └─ 루틴 미완료 → routineInput.jsp
      │
      └─ 보호자
          ├─ 환자 연결됨 → ctrl + F ) INPUT PAGE
          └─ 환자 미연결 → patientIdInput.jsp
 */
@WebServlet("/loginProc")
public class loginProc extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
    		throws ServletException, IOException {
    	doPost(request, response);
    }

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
            // TODO: 사용자 정보 조회
            
            // 사용자 인증 (DB 조회)
            UserInfo user = authenticateUser(loginId, loginPassword);
            
            if (user == null) {
                // 로그인 실패
                session.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
                response.sendRedirect("KNY/login.jsp");
                return;
            }
            
            // 로그인 성공 - 세션에 사용자 정보 저장
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userName", user.getUserName());
            session.setAttribute("userRole", user.getUserRole());
            
            // 역할에 따른 페이지 분기
            if (user.getUserRole() == 0) {
                // 환자 로그인
                handlePatientLogin(request, response, session, user);
            } else if (user.getUserRole() > 0) {
                // 보호자 로그인
                handleCaregiverLogin(request, response, session, user);
            } else {
                // 알 수 없는 역할
                session.invalidate();
                response.sendRedirect("KNY/login.jsp");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("loginError", "로그인 처리 중 오류가 발생했습니다.");
            response.sendRedirect("KNY/login.jsp");
        }
    }
    
    /**
     * 환자 로그인 처리
     */
    private void handlePatientLogin(HttpServletRequest request, HttpServletResponse response, 
                                    HttpSession session, UserInfo user) throws IOException {
        
        // 루틴 입력 완료 여부 확인
        boolean routineCompleted = checkRoutineCompleted(user.getUserId());
        
        if (routineCompleted) {
            // 루틴 입력 완료 - 메인 페이지로
            response.sendRedirect("KTW/jsp/index.jsp");
        } else {
            // 루틴 미입력 - 루틴 입력 페이지로
            response.sendRedirect("KNY/routineInput.jsp");
        }
    }
    
    /**
     * 보호자 로그인 처리
     */
    private void handleCaregiverLogin(HttpServletRequest request, HttpServletResponse response, 
                                      HttpSession session, UserInfo user) throws IOException {
        
        // 연결된 환자 ID 확인
        int linkedPatientId = getLinkedPatientId(user.getUserId());
        
        if (linkedPatientId != 0) {
            // 환자 ID 등록 완료 - 보호자 메인 페이지로
            session.setAttribute("linkedPatientId", linkedPatientId);
            response.sendRedirect("KNK/caregiver.jsp"); // INPUT PAGE
        } else {
            // 환자 ID 미등록 - 환자 ID 입력 페이지로
            response.sendRedirect("KNY/patientIdInput.jsp");
        }
    }
    
    /**
     * 사용자 인증 (DB 조회)
     */
    private UserInfo authenticateUser(String loginId, String loginPassword) {
        // TODO
        // SELECT user_id, user_name, user_role, password 
        // FROM users 
        // WHERE login_id = ? AND is_active = 1
        
        if ("test_patient".equals(loginId) && "t1234!".equals(loginPassword)) {
            return new UserInfo(1, "환자이름");
        } else if ("test_caregiver".equals(loginId) && "t1234!".equals(loginPassword)) {
            return new UserInfo(2, "보호자이름", 1);
        }
        
        return null; // 인증 실패
    }
    
    /**
     * 환자의 루틴 입력 완료 여부 확인
     */
    private boolean checkRoutineCompleted(int userId) {
        // TODO
        // SELECT COUNT(*) FROM patient_routines WHERE user_id = ?
        
        return false; // 기본값: 루틴 미입력
    }
    
    /**
     * 보호자에게 연결된 환자 ID 조회
     */
    private int getLinkedPatientId(int caregiverId) {
        // TODO    	
        // SELECT patient_id FROM caregiver_patient_link 
        // WHERE caregiver_id = ? AND is_active = 1
        
        return 0; // 기본값: 연결된 환자 없음
    }
    
    
    /**
     * 사용자 정보 입력
     */
    private class UserInfo {
        private int userId;
        private String userName;
        private int userRole = -1;// 0:Patient 1:careGiver
        private int targetId; 

        //Constructor
        public UserInfo(int userId, String userName) {
            this.userId = userId;
            this.userName = userName;
            this.userRole = 0;
        }

        public UserInfo(int userId, String userName, int targetId) {
            this.userId = userId;
            this.userName = userName;
            this.userRole = 1;
            this.targetId = targetId;
        }

		public int getUserId() {
			return userId;
		}

		public void setUserId(int userId) {
			this.userId = userId;
		}

		public String getUserName() {
			return userName;
		}

		public void setUserName(String userName) {
			this.userName = userName;
		}

		public int getUserRole() {
			return userRole;
		}

		public void setUserRole(int userRole) {
			this.userRole = userRole;
		}

		public int getTargetId() {
			return targetId;
		}

		public void setTargetId(int targetId) {
			this.targetId = targetId;
		}
        
    }
}

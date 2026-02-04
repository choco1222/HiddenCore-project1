<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="survey-wrapper">
            <div class="question-area">
                <h1 class="question-title">로그인</h1>
                <p class="question-description">로그인하여 서비스에 접속하세요</p>
                
                <%
                    String loginError = (String) session.getAttribute("loginError");
                    if (loginError != null) {
                        session.removeAttribute("loginError");
                %>
                <div class="error-message">
                    <%= loginError %>
                </div>
                <%
                    }
                %>
            </div>

            <form class="auth-form" id="loginForm" method="post" action="/Remember_Spring/loginProc" onsubmit="return validateLogin()">
                <div class="answer-area">
                    <!-- 아이디 입력 -->
                    <div class="form-group">
                        <label for="loginId" class="form-label">아이디</label>
                        <input type="text" id="loginId" name="loginId" class="form-input" required>
                    </div>

                    <!-- 비밀번호 입력 -->
                    <div class="form-group">
                        <label for="loginPassword" class="form-label">비밀번호</label>
                        <input type="password" id="loginPassword" name="loginPassword" class="form-input" required>
                        <p class="form-hint">6~16자 영문, 특수문자를 사용해주세요.</p>
                    </div>
                </div>

                <div class="button-container">
                    <button type="submit" class="btn btn-primary btn-large">로그인</button>
                </div>

                <!-- 회원가입 링크 -->
                <a href="joinStep0.jsp" class="link-text">회원가입</a>

                <!-- 구분선 -->
                <div class="divider"></div>

                <!-- SNS 로그인 -->
                <div class="sns-section">
                    <p class="sns-title">SNS로 로그인하세요!</p>
                    <div class="sns-buttons">
                        <button type="button" class="sns-btn" onclick="snsLogin('kakao')">
                            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 60 60'%3E%3Ccircle cx='30' cy='30' r='30' fill='%23FFE812'/%3E%3Cpath d='M30 17c-7.2 0-13 4.4-13 9.9 0 3.5 2.3 6.6 5.8 8.4l-1.5 5.5c-.1.4.3.7.6.5l6.4-4.2c.6.1 1.1.1 1.7.1 7.2 0 13-4.4 13-9.9S37.2 17 30 17z' fill='%23371D1E'/%3E%3C/svg%3E" alt="카카오톡">
                        </button>
                        <button type="button" class="sns-btn" onclick="snsLogin('naver')">
                            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 60 60'%3E%3Ccircle cx='30' cy='30' r='30' fill='%2303C75A'/%3E%3Cpath d='M33 30l-6-9h-5v18h6V30l6 9h5V21h-6z' fill='white'/%3E%3C/svg%3E" alt="네이버">
                        </button>
                        <button type="button" class="sns-btn" onclick="snsLogin('instagram')">
                            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 60 60'%3E%3Cdefs%3E%3ClinearGradient id='ig' x1='0' y1='1' x2='1' y2='0'%3E%3Cstop offset='0' stop-color='%23FFC107'/%3E%3Cstop offset='.5' stop-color='%23F44336'/%3E%3Cstop offset='1' stop-color='%239C27B0'/%3E%3C/linearGradient%3E%3C/defs%3E%3Ccircle cx='30' cy='30' r='30' fill='url(%23ig)'/%3E%3Cpath d='M30 22c-4.4 0-8 3.6-8 8s3.6 8 8 8 8-3.6 8-8-3.6-8-8-8zm0 13c-2.8 0-5-2.2-5-5s2.2-5 5-5 5 2.2 5 5-2.2 5-5 5z' fill='white'/%3E%3Ccircle cx='38.5' cy='21.5' r='1.5' fill='white'/%3E%3Cpath d='M35 17h-10c-4.4 0-8 3.6-8 8v10c0 4.4 3.6 8 8 8h10c4.4 0 8-3.6 8-8V25c0-4.4-3.6-8-8-8zm5 18c0 2.8-2.2 5-5 5H25c-2.8 0-5-2.2-5-5V25c0-2.8 2.2-5 5-5h10c2.8 0 5 2.2 5 5v10z' fill='white'/%3E%3C/svg%3E" alt="인스타그램">
                        </button>
                        <button type="button" class="sns-btn" onclick="snsLogin('facebook')">
                            <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 60 60'%3E%3Ccircle cx='30' cy='30' r='30' fill='%231877F2'/%3E%3Cpath d='M34 31v-4h-4v-3c0-1.1.9-2 2-2h2v-4h-2c-3.3 0-6 2.7-6 6v3h-3v4h3v12h5V31h4z' fill='white'/%3E%3C/svg%3E" alt="페이스북">
                        </button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <script src="../../assets/js/auto-script.js"></script>
</body>
</html>

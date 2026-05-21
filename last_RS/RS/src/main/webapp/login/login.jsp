<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>기억해 봄 - 로그인</title>
    <link rel="icon" href="login/Logo.png" type="image/png">
    <base href="${pageContext.request.contextPath}/">
    <link rel="stylesheet" href="assets/css/login.css">
</head>
<body>
    <div class="app-frame">
    <div class="login-container">
        <!-- 로고 -->
        <div class="logo-area">
            <img src="login/Logo.png" 
                 alt="기억해 봄" 
                 class="logo-img">
        </div>

        <!-- 에러 메시지 -->
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
    <c:if test = "${not empty sessionScope.loginError}">
    	<script>
        	alert('${sessionScope.loginError}');
    	</script>
    	<c:remove var="loginError" scope="session"/>
	</c:if>

	<c:if test="${not empty sessionScope.joinSuccess}">
	    <script>
        	alert('${sessionScope.joinSuccess}');
    	</script>
    	<c:remove var="joinSuccess" scope="session"/>
	</c:if>

        <!-- 로그인 폼 -->
        <form class="login-form" 
              method="post" 
              action="auth/login">
            
            <!-- 아이디 입력 -->
            <div class="input-group">
                <input type="text" 
                       id="loginId" 
                       name="loginId" 
                       class="input-field" 
                       placeholder="아이디 또는 전화번호" 
                       required>
            </div>
            

            <!-- 비밀번호 입력 -->
            <div class="input-group">
                <input type="password" 
                       id="loginPassword" 
                       name="loginPassword" 
                       class="input-field" 
                       placeholder="비밀번호" 
                       required>
            </div>

            <!-- 로그인 상태 유지 -->
            <div class="checkbox-group">
                <label class="checkbox-wrapper">
                    <input type="checkbox" 
                           id="keepLogin" 
                           name="keepLogin" 
                           class="checkbox-input">
                    <span class="checkbox-label">로그인 상태 유지</span>
                </label>
            </div>

            <!-- 로그인 버튼 -->
            <button type="submit" class="login-button">로그인</button>
        </form>

        <!-- 하단 링크 -->
        <div class="links-area">
            <a href="login/findId.jsp" class="link">아이디 찾기</a>
            <div class="link-divider"></div>
            <a href="login/findPassword.jsp" class="link">비밀번호 찾기</a>
            <div class="link-divider"></div>
            <a href="login/joinStep0.jsp" class="link signup">회원가입</a>
        </div>
    </div>
    </div>
</body>
</html>

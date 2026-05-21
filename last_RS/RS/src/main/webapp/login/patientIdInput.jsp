<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>환자 등록</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body>
    <div class="app-frame">
    <div class="container">
        <div class="survey-wrapper">
            <div class="question-area">
                <h1 class="question-title">환자의 회원번호를<br>입력해주세요</h1>
                <p class="question-description">환자가 가입 시 받은 회원번호를 입력하세요</p>
            </div>

            <form class="auth-form" action="${pageContext.request.contextPath}/login/patientIdInput">
            <input type="hidden" name="userRole" value="${param.userRole}">
    			
                <div class="answer-area">
                    <div class="form-group">
                        <label for="patientId" class="form-label">환자 회원번호</label>
                        <input type="text" id="patientId" name="patientId" class="form-input" 
                               placeholder="예: 20250201001"
                               pattern="[0-9]{8,11}"
                               title="숫자를 입력해주세요"
                               required>
                        <p class="form-hint">환자가 전달한 회원번호를 입력하세요</p>
                    </div>
                </div>

                <div class="button-container">
                    <button type="submit" class="btn btn-primary btn-large">등록하기</button>
                </div>
            </form>
        </div>
    </div>
    </div>
</body>
</html>
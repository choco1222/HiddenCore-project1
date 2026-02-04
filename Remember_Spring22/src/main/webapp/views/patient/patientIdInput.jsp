<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>환자 등록</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
    <div class="container">
        <div class="survey-wrapper">
            <div class="question-area">
                <h1 class="question-title">환자의 회원번호를<br>입력해주세요</h1>
                <p class="question-description">환자가 가입 시 받은 회원번호를 입력하세요</p>
            </div>

            <form class="auth-form" onsubmit="handlePatientIdSubmit(event)">
                <div class="answer-area">
                    <div class="form-group">
                        <label for="patientId" class="form-label">환자 회원번호</label>
                        <input type="text" id="patientId" name="patientId" class="form-input" 
                               placeholder="예: 20250201001"
                               pattern="[0-9]{11}"
                               title="11자리 숫자를 입력해주세요"
                               required>
                        <p class="form-hint">환자가 전달한 11자리 회원번호를 입력하세요</p>
                    </div>
                </div>

                <div class="button-container">
                    <button type="submit" class="btn btn-primary btn-large">등록하기</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function handlePatientIdSubmit(event) {
            event.preventDefault();
            
            const patientId = document.getElementById('patientId').value;
            
            if (patientId.length !== 11) {
                alert('11자리 회원번호를 정확히 입력해주세요.');
                return;
            }
            
            // 백엔드에서 환자 ID 검증 필요
            sessionStorage.setItem('linkedPatientId', patientId);
            
            // 검증 성공 시 보호자 메인으로 이동
            window.location.href = 'guardian.jsp';
        }
    </script>
</body>
</html>

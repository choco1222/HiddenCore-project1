<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>설문 완료</title>
    <link rel="stylesheet" href="./css/style.css">
</head>
<body>
    <div class="container">
        <div class="survey-wrapper">
            <div class="completion-content">
                <div class="completion-icon">✓</div>
                <h1 class="completion-title">간단한 인지 검사를<br>시작할게요.</h1>
                <p class="completion-subtitle">3분이면 돼요.</p>
                
                <div class="button-container">
                    <button class="btn btn-primary btn-large" onclick="startSurvey()">시작하기</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function startSurvey() {
            window.location.href = 'survey.jsp';
        }
    </script>
</body>
</html>

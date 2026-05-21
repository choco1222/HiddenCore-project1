<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>역할 선택</title>
    <link rel="stylesheet" href="../assets/css/style.css">
</head>
<body class="page-join-step0">
    <div class="app-frame app-frame-center">
    <div class="container">
        <div class="survey-wrapper">
            <div class="question-area" style="border-bottom: none; padding-bottom: 1rem;">
                <h1 class="question-title">어떤 역할로 가입하시겠어요?</h1>
            </div>

            <div class="answer-area">
                <div class="role-selection">
                    <!-- 환자 선택 카드 -->
                    <button type="button" class="role-card role-patient" onclick="selectRole('patient')">
                        <div class="role-icon">
                            <svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 24 24"><path fill="#22B14C" d="M22 9.95v4.11a1.78 1.78 0 0 1-1.78 1.78h-4.39v4.39a1.73 1.73 0 0 1-.52 1.25a1.8 1.8 0 0 1-1.26.52H9.94a1.8 1.8 0 0 1-1.26-.52a1.8 1.8 0 0 1-.52-1.25v-4.39H3.78A1.78 1.78 0 0 1 2 14.06V9.95a1.78 1.78 0 0 1 1.78-1.78h4.38V3.78a1.8 1.8 0 0 1 1.103-1.646A1.8 1.8 0 0 1 9.94 2H14a1.8 1.8 0 0 1 1.26.52a1.77 1.77 0 0 1 .52 1.26v4.39h4.39c.472.003.924.19 1.26.52A1.78 1.78 0 0 1 22 9.95"/></svg>
                        </div>
                        <h2 class="role-title">환자 본인</h2>
                        <p class="role-description">나의 건강 기록을 직접 관리하고<br>일상을 기록해보세요</p>
                    </button>

                    <!-- 보호자 선택 카드 -->
                    <button type="button" class="role-card role-caregiver" onclick="selectRole('caregiver')">
                        <div class="role-icon">
							<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 640 640"><path fill="#71533E" d="M334.3 51.4c-9-4.5-19.6-4.5-28.6 0l-256 128c-15.8 7.9-22.2 27.1-14.3 42.9s27.1 22.2 42.9 14.3L320 115.8l241.7 120.8c15.8 7.9 35 1.5 42.9-14.3s1.5-35-14.3-42.9zM320 336c30.9 0 56-25.1 56-56s-25.1-56-56-56s-56 25.1-56 56s25.1 56 56 56m0 48c-53 0-96 43-96 96v32c0 17.7 14.3 32 32 32h128c17.7 0 32-14.3 32-32v-32c0-53-43-96-96-96m-128-64c0-26.5-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48s48-21.5 48-48m352 0c0-26.5-21.5-48-48-48s-48 21.5-48 48s21.5 48 48 48s48-21.5 48-48m-400 80c-44.2 0-80 35.8-80 80v33.1c0 17 13.8 30.9 30.9 30.9h87.8c-4.3-9.8-6.7-20.6-6.7-32v-48c0-18.4 3.5-36 9.8-52.2c-12.2-7.5-26.5-11.8-41.8-11.8m313.4 144h87.8c17 0 30.9-13.8 30.9-30.9V480c0-44.2-35.8-80-80-80c-15.3 0-29.6 4.3-41.8 11.8c6.3 16.2 9.8 33.8 9.8 52.2v48c0 11.4-2.4 22.2-6.7 32"/></svg>
                        </div>
                        <h2 class="role-title">보호자</h2>
                        <p class="role-description">환자의 상태를 실시간으로 확인하세요</p>
                    </button>
                </div>
            </div>
        </div>
    </div>
    </div>

    <script>
        function selectRole(role) {
        	window.location.href = 'joinStep1.jsp?userRole=' + role;
        }
    </script>
</body>
</html>

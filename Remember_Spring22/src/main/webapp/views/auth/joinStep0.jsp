<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>역할 선택</title>
    <link rel="stylesheet" href="../../assets/css/style.css">
</head>
<body>
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
                            <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <rect x="32" y="10" width="16" height="40" rx="2" fill="#4CAF50"/>
                                <rect x="10" y="32" width="60" height="16" rx="2" fill="#4CAF50"/>
                            </svg>
                        </div>
                        <h2 class="role-title">환자 본인</h2>
                        <p class="role-description">나의 건강 기록을 직접 관리하고<br>일상을 기록해보세요</p>
                    </button>

                    <!-- 보호자 선택 카드 -->
                    <button type="button" class="role-card role-caregiver" onclick="selectRole('caregiver')">
                        <div class="role-icon">
                            <svg width="80" height="80" viewBox="0 0 80 80" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <circle cx="30" cy="25" r="12" fill="#2D3748"/>
                                <ellipse cx="30" cy="55" rx="18" ry="15" fill="#2D3748"/>
                                <circle cx="52" cy="32" r="9" fill="#2D3748"/>
                                <ellipse cx="52" cy="55" rx="13" ry="11" fill="#2D3748"/>
                            </svg>
                        </div>
                        <h2 class="role-title">보호자</h2>
                        <p class="role-description">환자의 상태를 실시간으로 확인하세요</p>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        function selectRole(role) {
            sessionStorage.setItem('userRole', role);
            window.location.href = 'joinStep1.jsp';
        }
    </script>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가입 완료</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <link rel="stylesheet" href="../assets/css/surveyComplete.css">
</head>
<body>
    <div class="app-frame">
    <div class="container">
        <div class="survey-wrapper">
            <div class="completion-message">
                <div class="success-icon">✓</div>
                <h1 class="completion-title">가입이 완료되었습니다!</h1>
                <p class="completion-description">하루의 일정을 공유해보세요!</p>
            </div>

            <!-- 회원번호 표시 -->
            <div class="member-id-section">
                <label class="member-id-label">회원번호</label>
                <div class="member-id-display">
                    <span id="memberId" class="member-id-text">로딩중...</span>
                    <button class="icon-btn" onclick="copyMemberId()" title="복사">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                        </svg>
                    </button>
                </div>
            </div>

         

            <!-- 로그인 버튼 -->
            <div class="button-container">
                <button class="btn btn-primary btn-large" onclick="goToLogin()">로그인하러 가기</button>
            </div>
        </div>
    </div>
    </div>

    <script>
        // 회원번호 표시 (세션에서 가져온 userId)
        document.addEventListener('DOMContentLoaded', function() {
            <%
                Integer userId = (Integer) session.getAttribute("userId");
                if (userId != null) {
            %>
                const memberId = '<%= userId %>';
                document.getElementById('memberId').textContent = memberId;
                sessionStorage.setItem('memberId', memberId);
            <%
                } else {
            %>
                // 세션에 userId가 없으면 임시 생성
                const memberId = generateMemberId();
                document.getElementById('memberId').textContent = memberId;
                sessionStorage.setItem('memberId', memberId);
            <%
                }
            %>
        });

        function generateMemberId() {
            const date = new Date();
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            const random = String(Math.floor(Math.random() * 1000)).padStart(3, '0');
            return year + month + day + random;
        }

        function copyMemberId() {
            const memberIdText = document.getElementById('memberId').textContent;
            navigator.clipboard.writeText(memberIdText).then(function() {
                alert('회원번호가 복사되었습니다!');
            }).catch(function() {
                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = memberIdText;
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);
                alert('회원번호가 복사되었습니다!');
            });
        }

        function shareKakao() {
            const memberId = document.getElementById('memberId').textContent;
            const message = '제 회원번호는 ' + memberId + ' 입니다. 하루 일정을 함께 관리해요!';
            
            // 실제 카카오톡 공유 API 연동 필요
            alert('카카오톡 공유 기능\n\n' + message);
            
            // 실제 구현 시:
            // Kakao.Share.sendDefault({ ... });
        }

        function shareSMS() {
            const memberId = document.getElementById('memberId').textContent;
            const message = '제 회원번호는 ' + memberId + ' 입니다. 하루 일정을 함께 관리해요!';
            
            // SMS 공유
            window.location.href = 'sms:?body=' + encodeURIComponent(message);
        }

        function goToLogin() {
            sessionStorage.clear();
            window.location.href = 'login.jsp';
        }
    </script>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>가입 완료</title>
    <link rel="stylesheet" href="./css/style.css">
    <link rel="stylesheet" href="./css/surveyComplete.css">
</head>
<body>
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
                    <span id="memberId" class="member-id-text">20250201001</span>
                    <button class="icon-btn" onclick="copyMemberId()" title="복사">
                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
                            <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
                        </svg>
                    </button>
                </div>
            </div>

            <!-- 공유하기 버튼 -->
            <div class="share-section">
                <p class="share-label">공유하기</p>
                <div class="share-buttons">
                    <button class="share-btn kakao" onclick="shareKakao()">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 3C6.5 3 2 6.6 2 11c0 2.8 1.9 5.3 4.7 6.7l-1.2 4.4c-.1.3.2.6.5.4l5.1-3.4c.3 0 .6.1.9.1 5.5 0 10-3.6 10-8S17.5 3 12 3z"/>
                        </svg>
                        <span>카카오톡</span>
                    </button>
                    <button class="share-btn sms" onclick="shareSMS()">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                        </svg>
                        <span>문자</span>
                    </button>
                </div>
            </div>

            <!-- 로그인 버튼 -->
            <div class="button-container">
                <button class="btn btn-primary btn-large" onclick="goToLogin()">로그인하러 가기</button>
            </div>
        </div>
    </div>

    <script>
        // 회원번호 생성 (실제로는 백엔드에서 받아옴)
        document.addEventListener('DOMContentLoaded', function() {
            const memberId = sessionStorage.getItem('memberId') || generateMemberId();
            document.getElementById('memberId').textContent = memberId;
            sessionStorage.setItem('memberId', memberId);
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

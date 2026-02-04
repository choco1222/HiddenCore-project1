<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>월간 분석 보고서</title>
    <link rel="stylesheet" href="../../assets/css/common.css">
    <link rel="stylesheet" href="../../assets/css/monthly.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <header>
            <h1>월간 분석 보고서</h1>
            <div class="header-buttons">
                <a href="${pageContext.request.contextPath}/" class="nav-btn-small" style="text-decoration: none;">메인 메뉴</a>
            </div>
        </header>
        <main>
            <div class="date-selector">
                <label for="monthlyDateInput">날짜 선택 (선택일 전날부터 역으로 한 달 기간):</label>
                <input type="date" id="monthlyDateInput" value="${date}">
                <button id="loadMonthlyReportBtn" type="button">조회</button>
            </div>
            <div id="monthlyReportContent"></div>
            
            <c:if test="${not empty activeLogsJson or not empty gameLogsJson}">
            <script type="application/json" id="activeLogsJsonData">
                <c:out value="${activeLogsJson}" escapeXml="false"/>
            </script>
            <script type="application/json" id="gameLogsJsonData">
                <c:out value="${gameLogsJson}" escapeXml="false"/>
            </script>
            <script>
                // 서버에서 전달된 JSON 데이터를 JavaScript 객체로 변환
                var LOCAL_DATA = {
                    activeLog: [],
                    gameLog: []
                };
                
                try {
                    var activeLogsScript = document.getElementById('activeLogsJsonData');
                    if (activeLogsScript) {
                        var activeLogsText = activeLogsScript.textContent || activeLogsScript.innerText;
                        LOCAL_DATA.activeLog = JSON.parse(activeLogsText.trim());
                        console.log('활동 로그 로드 성공:', LOCAL_DATA.activeLog.length, '개');
                    }
                } catch (e) {
                    console.error('활동 로그 JSON 파싱 오류:', e);
                    LOCAL_DATA.activeLog = [];
                }
                
                try {
                    var gameLogsScript = document.getElementById('gameLogsJsonData');
                    if (gameLogsScript) {
                        var gameLogsText = gameLogsScript.textContent || gameLogsScript.innerText;
                        LOCAL_DATA.gameLog = JSON.parse(gameLogsText.trim());
                        console.log('게임 로그 로드 성공:', LOCAL_DATA.gameLog.length, '개');
                    }
                } catch (e) {
                    console.error('게임 로그 JSON 파싱 오류:', e);
                    LOCAL_DATA.gameLog = [];
                }
            </script>
            </c:if>
        </main>
    </div>

    <script src="../../assets/js/monthly.js"></script>
    <script>
        // 월간 리포트 로드 함수
        function loadMonthlyReport() {
            const dateInput = document.getElementById('monthlyDateInput').value;
            const contentDiv = document.getElementById('monthlyReportContent');
            
            if (!dateInput) {
                contentDiv.innerHTML = '<p style="color: red;">날짜를 선택해주세요.</p>';
                return;
            }
            
            // 서블릿으로 요청하여 데이터 새로고침
            window.location.href = '${pageContext.request.contextPath}/monthly?date=' + dateInput;
        }
        
        // 페이지 로드 시 자동으로 리포트 표시
        window.addEventListener('DOMContentLoaded', function() {
            // 조회 버튼 이벤트 리스너 등록
            var loadBtn = document.getElementById('loadMonthlyReportBtn');
            if (loadBtn) {
                loadBtn.addEventListener('click', loadMonthlyReport);
            }
            
            // 날짜가 없으면 오늘 날짜로 설정
            const dateInput = document.getElementById('monthlyDateInput');
            if (!dateInput.value) {
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                dateInput.value = year + '-' + month + '-' + day;
            }
            
            // 함수가 로드될 때까지 대기
            function tryDisplayReport() {
                if (typeof calculateMonthlyReportLocal === 'undefined' || typeof displayMonthlyReport === 'undefined') {
                    setTimeout(tryDisplayReport, 100);
                    return;
                }
                
                // 데이터 확인
                if (!LOCAL_DATA || !LOCAL_DATA.activeLog || !LOCAL_DATA.gameLog || 
                    LOCAL_DATA.activeLog.length === 0 || LOCAL_DATA.gameLog.length === 0) {
                    // 데이터가 없으면 서블릿으로 요청
                    if (dateInput.value) {
                        loadMonthlyReport();
                    }
                    return;
                }
                
                // 리포트 표시
                const date = dateInput.value;
                if (date) {
                    try {
                        const selectedDate = new Date(date);
                        if (!isNaN(selectedDate.getTime())) {
                            const data = calculateMonthlyReportLocal(selectedDate);
                            displayMonthlyReport(data);
                        } else {
                            document.getElementById('monthlyReportContent').innerHTML = '<p style="color: red;">유효하지 않은 날짜입니다.</p>';
                        }
                    } catch (error) {
                        console.error('리포트 계산 오류:', error);
                        document.getElementById('monthlyReportContent').innerHTML = '<p style="color: red;">리포트 계산 중 오류가 발생했습니다: ' + error.message + '</p>';
                    }
                }
            }
            
            // 리포트 표시 시도
            tryDisplayReport();
        });
    </script>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주간 분석 보고서</title>
    <link rel="stylesheet" href="../../assets/css/common.css">
    <link rel="stylesheet" href="../../assets/css/weekly.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <header>
            <h1>주간 분석 보고서</h1>
            <div class="header-buttons">
                <a href="${pageContext.request.contextPath}/" class="nav-btn-small" style="text-decoration: none;">메인 메뉴</a>
                <a href="${pageContext.request.contextPath}/daily" class="nav-btn-small" style="text-decoration: none;">일간 보고서 보기</a>
            </div>
        </header>
        <main>
            <div class="date-selector">
                <label for="weeklyDateInput">날짜 선택 (선택일 전날 역으로 7일간):</label>
                <input type="date" id="weeklyDateInput" value="${date}">
                <button onclick="loadWeeklyReport()">조회</button>
            </div>
            <div id="weeklyReportContent"></div>
            
            <c:if test="${not empty activeLogsJson or not empty gameLogsJson}">
            <script type="application/json" id="weeklyActiveLogsJsonData">
                <c:out value="${not empty activeLogsJson ? activeLogsJson : '[]'}" escapeXml="false"/>
            </script>
            <script type="application/json" id="weeklyGameLogsJsonData">
                <c:out value="${not empty gameLogsJson ? gameLogsJson : '[]'}" escapeXml="false"/>
            </script>
            </c:if>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/weekly.js"></script>
    <script>
        // 서버에서 전달된 JSON 데이터를 JavaScript 객체로 변환
        var LOCAL_DATA = { activeLog: [], gameLog: [] };
        (function() {
            try {
                var activeEl = document.getElementById('weeklyActiveLogsJsonData');
                if (activeEl) {
                    var text = activeEl.textContent || activeEl.innerText;
                    LOCAL_DATA.activeLog = JSON.parse(text.trim());
                }
            } catch (e) { console.error('활동 로그 JSON 파싱 오류:', e); }
            try {
                var gameEl = document.getElementById('weeklyGameLogsJsonData');
                if (gameEl) {
                    var text = gameEl.textContent || gameEl.innerText;
                    LOCAL_DATA.gameLog = JSON.parse(text.trim());
                }
            } catch (e) { console.error('게임 로그 JSON 파싱 오류:', e); }
        })();

        // 주간 리포트 로드 함수 재정의 (서블릿으로 요청)
        window.loadWeeklyReport = function() {
            const startDate = document.getElementById('weeklyDateInput').value;
            const contentDiv = document.getElementById('weeklyReportContent');
            
            if (!startDate) {
                contentDiv.innerHTML = '<p style="color: red;">날짜를 선택해주세요.</p>';
                return;
            }
            
            window.location.href = '${pageContext.request.contextPath}/weekly?date=' + startDate;
        };
        
        window.addEventListener('DOMContentLoaded', function() {
            const dateInput = document.getElementById('weeklyDateInput');
            if (!dateInput.value) {
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                dateInput.value = year + '-' + month + '-' + day;
            }
            
            function tryDisplayReport() {
                if (typeof calculateWeeklyReportLocal === 'undefined' || typeof displayWeeklyReport === 'undefined') {
                    setTimeout(tryDisplayReport, 100);
                    return;
                }
                if (!LOCAL_DATA.activeLog || !LOCAL_DATA.gameLog ||
                    (LOCAL_DATA.activeLog.length === 0 && LOCAL_DATA.gameLog.length === 0)) {
                    if (dateInput.value) loadWeeklyReport();
                    return;
                }
                const date = dateInput.value;
                if (date) {
                    try {
                        const data = calculateWeeklyReportLocal(date);
                        displayWeeklyReport(data);
                    } catch (error) {
                        document.getElementById('weeklyReportContent').innerHTML = '<p style="color: red;">리포트 계산 중 오류가 발생했습니다.</p>';
                    }
                }
            }
            tryDisplayReport();
        });
    </script>
</body>
</html>
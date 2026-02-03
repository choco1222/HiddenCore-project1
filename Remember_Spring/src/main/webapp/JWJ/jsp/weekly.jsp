<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>주간 분석 보고서</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/weekly.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <div class="container">
        <header>
            <h1>주간 분석 보고서</h1>
            <div class="header-buttons">
                <a href="${pageContext.request.contextPath}/jsp/index.jsp" class="nav-btn-small" style="text-decoration: none;">메인 메뉴</a>
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
            
            <script>
                // 서버에서 전달된 JSON 데이터를 JavaScript 객체로 변환
                <c:set var="activeLogsJson" value="${not empty activeLogsJson ? activeLogsJson : '[]'}" />
                <c:set var="gameLogsJson" value="${not empty gameLogsJson ? gameLogsJson : '[]'}" />
                const LOCAL_DATA = {
                    activeLog: ${activeLogsJson},
                    gameLog: ${gameLogsJson}
                };
                
            </script>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/weekly.js"></script>
    <script>
        // 주간 리포트 로드 함수 재정의 (서블릿으로 요청)
        window.loadWeeklyReport = function() {
            const startDate = document.getElementById('weeklyDateInput').value;
            const contentDiv = document.getElementById('weeklyReportContent');
            
            if (!startDate) {
                contentDiv.innerHTML = '<p style="color: red;">날짜를 선택해주세요.</p>';
                return;
            }
            
            // 서블릿으로 요청하여 데이터 새로고침
            window.location.href = '${pageContext.request.contextPath}/weekly?date=' + startDate;
        };
        
        // 페이지 로드 시 자동으로 리포트 표시
        window.addEventListener('DOMContentLoaded', function() {
            // 날짜가 없으면 오늘 날짜로 설정
            const dateInput = document.getElementById('weeklyDateInput');
            if (!dateInput.value) {
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                dateInput.value = year + '-' + month + '-' + day;
            }
            
            if (typeof calculateWeeklyReportLocal === 'undefined' || typeof displayWeeklyReport === 'undefined') {
                // 서블릿에서 데이터가 없으면 서블릿으로 요청
                if (typeof LOCAL_DATA === 'undefined' || !LOCAL_DATA.activeLog || !LOCAL_DATA.gameLog) {
                    if (dateInput.value) {
                        loadWeeklyReport();
                    }
                    return;
                }
                setTimeout(function() {
                    if (typeof LOCAL_DATA !== 'undefined' && LOCAL_DATA.activeLog && LOCAL_DATA.gameLog) {
                        const date = document.getElementById('weeklyDateInput').value;
                        if (date && typeof calculateWeeklyReportLocal !== 'undefined' && typeof displayWeeklyReport !== 'undefined') {
                            try {
                                const data = calculateWeeklyReportLocal(date);
                                displayWeeklyReport(data);
                            } catch (error) {
                                document.getElementById('weeklyReportContent').innerHTML = '<p style="color: red;">리포트 계산 중 오류가 발생했습니다.</p>';
                            }
                        }
                    }
                }, 100);
                return;
            }
            
            // 서블릿에서 데이터가 없으면 서블릿으로 요청
            if (typeof LOCAL_DATA === 'undefined' || !LOCAL_DATA.activeLog || !LOCAL_DATA.gameLog) {
                if (dateInput.value) {
                    loadWeeklyReport();
                }
                return;
            }
            
            if (typeof LOCAL_DATA !== 'undefined' && LOCAL_DATA.activeLog && LOCAL_DATA.gameLog) {
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
        });
    </script>
</body>
</html>

<%--
  [이게 뭔지] 일간 루틴 보고서 화면. [뭘 썼는지] JSP, JSTL(c), 서버에서 넣은 reportDataJson.
  [어디서] DailyReportServlet이 request에 date, userId, reportAllowed, reportDataJson 넣고 포워드. [어디로] 조회 시 /report/daily?date= 로 서블릿 재요청.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>일간 루틴 보고서</title>
    <%-- [이게 뭔지] 공통/일간 CSS. [어디서] contextPath 기준 assets/css. --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/daily.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>일간 루틴 보고서</h1>
            <div class="header-buttons">
                <a href="${pageContext.request.contextPath}/report/reportMain.jsp" class="nav-btn-small" style="text-decoration: none;">메인 메뉴</a>
               </div>
        </header>
        <main>
           <div class="date-selector">
                <label for="dailyDateInput">날짜 선택:</label>
                <input type="date" id="dailyDateInput" value="${date}">
                <button id="loadReportBtn" type="button">조회</button>
            </div>
            
            <%-- [이게 뭔지] 열람 불가일 때만 표시. [어디서] reportAllowed, reportNotAllowedMessage - DailyReportServlet에서 설정. --%>
            <c:if test="${reportAllowed == false}">
                <div class="report-not-allowed" style="margin: 30px auto; padding: 24px; max-width: 400px; text-align: center; background: #fff8e6; border: 1px solid #ffc107; border-radius: 8px;">
                    <p style="margin: 0 0 12px 0; font-size: 1.1rem; color: #856404;"><strong>⏰ 열람 가능 시간이 아닙니다</strong></p>
                    <p style="margin: 0; color: #856404;">${reportNotAllowedMessage}</p>
                </div>
            </c:if>
            
            <%-- [이게 뭔지] 리포트 본문 영역. JS에서 displayDailyReport()로 채움. --%>
            <div id="dailyReportContent">
                <%-- [이게 뭔지] 서버에서 받은 리포트 JSON. [어디서] reportDataJson - 서블릿이 JsonUtil.mapToJson한 값. [뭘 썼는지] script type="application/json"으로 DOM에 넣어 JS가 getElementById로 파싱. --%>
                <c:if test="${reportAllowed != false and not empty reportDataJson}">
                    <script type="application/json" id="reportDataJson"><c:out value="${reportDataJson}" escapeXml="false"/>
                    </script>
                </c:if>
            </div>
        </main>
    </div>

    <script>
        // [이게 뭔지] 일간 리포트 화면 렌더. [뭘 썼는지] data = 서버에서 받은 reportDataJson 파싱 결과. [어디로] dailyReportContent innerHTML.
        function displayDailyReport(data) {
            const contentDiv = document.getElementById('dailyReportContent');
            // [어디서] data - DailyReportService.getDailyReportMap 결과(JSON). score는 "최고에요"/"잘했어요"/"노력해요".
            var score = data.score != null ? data.score : '-';
            let scoreClass = '';
            if (data.score === '최고에요') scoreClass = 'score-excellent';
            else if (data.score === '잘했어요') scoreClass = 'score-good';
            else scoreClass = 'score-need-effort';
            // [이게 뭔지] 일간 분석 요약용 값. [어디서] 서버 result의 daily_score, active_score, game_score_avg 등.
            var dailyScore = data.daily_score != null ? data.daily_score : data.completionRate;
            var activeScore = data.active_score != null ? data.active_score : data.completionRate;
            var gameScoreAvg = data.game_score_avg != null ? data.game_score_avg : 0;
            var isSaveBool = data.is_save_bool != null ? data.is_save_bool : 1;
            var analysisId = data.analysis_id || '';
            
            var completionRate = data.completionRate != null ? data.completionRate : 0;
            let html = '<div class="score-display ' + scoreClass + '">' +
                '<h2>' + score + '</h2>' +
                '<div class="completion-rate">완료율: ' + completionRate + '%</div>' +
                '</div>' +
                '<div class="daily-analysis-summary">' +
                '<h3>📋 일간 분석 요약</h3>' +
                '<div class="analysis-row">' +
                '<span class="analysis-badge ' + (isSaveBool === 1 ? 'badge-normal' : 'badge-abnormal') + '">보고서: ' + (isSaveBool === 1 ? '정상' : '비정상') + '</span>' +
                (analysisId ? '<span class="analysis-id">ID: ' + analysisId + '</span>' : '') +
                '</div>' +
                '<div class="analysis-scores">' +
                '<span>종합 일일 점수(daily_score): <strong>' + dailyScore + '</strong>점</span>' +
                '<span>활동 점수(active_score): <strong>' + activeScore + '</strong>점</span>' +
                '<span>게임 평균(game_score_avg): <strong>' + gameScoreAvg + '</strong>점</span>' +
                '</div>' +
                '</div>' +
                '<table class="report-table">' +
                '<thead>' +
                '<tr><th>활동</th><th>아침</th><th>점심</th><th>저녁</th></tr>' +
                '</thead>' +
                '<tbody>';
            
            // activities 데이터가 JSON 문자열인 경우 파싱, 없으면 빈 객체
            let activities = data.activities;
            if (activities == null) {
                activities = {};
            } else if (typeof activities === 'string') {
                try {
                    activities = JSON.parse(activities);
                } catch (e) {
                    activities = {};
                }
            }
            if (typeof activities !== 'object' || activities === null) {
                activities = {};
            }
            
            Object.entries(activities).forEach(function(entry) {
                var name = entry[0];
                var activity = entry[1];
                
                // null 체크 함수
                function formatTimeSlot(count, completed) {
                    if (count === null || completed === null) {
                        return '-';
                    }
                    return count + '회 ' + (completed ? '✅' : '❌');
                }
                
                function getTimeSlotClass(completed) {
                    if (completed === null) return '';
                    return completed ? 'completed' : 'not-completed';
                }
                
                html += '<tr>' +
                    '<td>' + name + '</td>' +
                    '<td class="' + getTimeSlotClass(activity.morningCompleted) + '">' +
                    formatTimeSlot(activity.morning, activity.morningCompleted) +
                    '</td>' +
                    '<td class="' + getTimeSlotClass(activity.lunchCompleted) + '">' +
                    formatTimeSlot(activity.lunch, activity.lunchCompleted) +
                    '</td>' +
                    '<td class="' + getTimeSlotClass(activity.dinnerCompleted) + '">' +
                    formatTimeSlot(activity.dinner, activity.dinnerCompleted) +
                    '</td>' +
                    '</tr>';
            });
            
            html += '</tbody></table>';
            
            if (data.missedActivities && data.missedActivities.length > 0) {
                html += '<div class="missed-activities">' +
                    '<h3>💡 오늘 놓친 루틴</h3>' +
                    '<ul>';
                data.missedActivities.forEach(function(a) {
                    html += '<li>' + a + '</li>';
                });
                html += '</ul></div>';
            } else {
                html += '<div class="missed-activities" style="background: #d4edda; border-left-color: #28a745;">' +
                    '<h3 style="color: #155724;">✅ 오늘 모든 루틴을 완료하셨습니다!</h3>' +
                    '</div>';
            }
            
            if (data.hasOuting) {
                html += '<div style="margin-top: 20px; padding: 15px; background: linear-gradient(135deg, #FFE294 0%, #FFF0C7 100%); border-radius: 8px; text-align: center; color: #8B6914;">' +
                    '<h3 style="margin: 0; font-size: 1.2rem;">🌟 오늘 외출하셨네요! 좋은 하루 보내셨나요? 🌟</h3>' +
                    '</div>';
            }
            
            if (data.gameAverages && typeof data.gameAverages === 'object' && Object.keys(data.gameAverages).length > 0) {
                html += '<div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;">' +
                    '<h3 style="margin-bottom: 15px; color: #8B6914;">🎮 게임 평균 점수</h3>' +
                    '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">';
                Object.entries(data.gameAverages).forEach(function(entry) {
                    var gameType = entry[0];
                    var avgScore = entry[1];
                    html += '<div style="padding: 15px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); text-align: center;">' +
                        '<div style="font-size: 0.9rem; color: #666; margin-bottom: 5px;">' + gameType + '</div>' +
                        '<div style="font-size: 1.5rem; font-weight: bold; color: #8B6914;">' + avgScore + '점</div>' +
                        '</div>';
                });
                html += '</div></div>';
            }
            
            contentDiv.innerHTML = html;
        }
        
        // [이게 뭔지] 일간 리포트 재조회. [뭘 썼는지] dailyDateInput 값. [어디로] /report/daily?date= 로 이동 → DailyReportServlet이 새 데이터 넣고 이 JSP 다시 렌더.
        function loadDailyReport() {
            const date = document.getElementById('dailyDateInput').value;
            if (!date) {
                document.getElementById('dailyReportContent').innerHTML = '<p style="color: red;">날짜를 선택해주세요.</p>';
                return;
            }
            window.location.href = '${pageContext.request.contextPath}/report/daily?date=' + date;
        }
        
        // [이게 뭔지] 페이지 로드 시: 버튼 연결, 서버 JSON 파싱 후 표시 또는 자동 조회.
        window.addEventListener('DOMContentLoaded', function() {
            // 조회 버튼 클릭 시 loadDailyReport 호출
            var loadBtn = document.getElementById('loadReportBtn');
            if (loadBtn) {
                loadBtn.addEventListener('click', loadDailyReport);
            }
            
            // [이게 뭔지] 서버에서 넣은 reportDataJson 스크립트 태그 내용 파싱. [어디서] JSP의 id="reportDataJson" script. [어디로] window.reportDataFromServer.
            var scriptTag = document.getElementById('reportDataJson');
            if (scriptTag) {
                try {
                    var jsonStr = scriptTag.textContent || scriptTag.innerText;
                    window.reportDataFromServer = JSON.parse(jsonStr.trim());
                    console.log('데이터 로드 성공:', window.reportDataFromServer);
                } catch (e) {
                    console.error('JSON 파싱 오류:', e);
                    console.error('JSON 텍스트:', scriptTag.textContent);
                    var contentDiv = document.getElementById('dailyReportContent');
                    if (contentDiv) {
                        contentDiv.innerHTML = '<p style="color: red;">데이터를 불러올 수 없습니다: ' + e.message + '</p>';
                    }
                    return;
                }
            }
            
            // 서버에서 전달된 데이터가 있으면 displayDailyReport로 자동 표시
            if (window.reportDataFromServer) {
                try {
                    displayDailyReport(window.reportDataFromServer);
                } catch (e) {
                    console.error('데이터 표시 오류:', e);
                    document.getElementById('dailyReportContent').innerHTML = '<p style="color: red;">데이터를 표시할 수 없습니다: ' + e.message + '</p>';
                }
            } else {
                // JSP 직접 접근 등으로 데이터 없을 때: 날짜 없으면 오늘로 설정 후 loadDailyReport() 호출해 서블릿 요청
                const dateInput = document.getElementById('dailyDateInput');
                if (!dateInput.value) {
                    const today = new Date();
                    const year = today.getFullYear();
                    const month = String(today.getMonth() + 1).padStart(2, '0');
                    const day = String(today.getDate()).padStart(2, '0');
                    dateInput.value = year + '-' + month + '-' + day;
                }
                // 날짜가 설정되어 있으면 자동으로 데이터 로드
                if (dateInput.value) { 
                    loadDailyReport();
                }
            }
        });
    </script>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>보고서 보기 - 기억해, 봄</title>
  <link rel="stylesheet" href="<%= ctx %>/assets/css/active.css">
  <style>
    /* 기억 보기 프레임 = main.jsp와 동일(크기·위치), 스크롤로 본문 확인 */
    body.report-page {
      margin: 0;
      padding: 0;
      background: #FFDF7C;
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      font-family: 'Dunggeunmo', sans-serif;
    }
    body.report-page .app-frame {
      overflow-x: hidden;
      overflow-y: auto;
    }

    /* 상단 헤더+날짜 스트립: 탭보다 앞에 (달력이 가려지지 않도록) */
    .report-top-header {
      position: relative;
      z-index: 5;
      width: 100%;
      line-height: 0;
      overflow: hidden;
      border-radius: 20px 20px 0 0;
    }
    .report-top-header .header-bg {
      display: block;
      width: 100%;
      height: auto;
      vertical-align: top;
    }
    .report-top-header .header-content {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      padding: 28px 24px 20px;
      box-sizing: border-box;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    .report-top-header .header-row {
      display: flex;
      align-items: center;
      gap: 14px;
      margin-top: 8px;
    }
    .report-top-header .back-link {
      display: inline-block;
      font-size: 50.23px;
      line-height: 1;
      color: #EFEAE2;
      text-decoration: none;
      flex-shrink: 0;
      font-family: inherit;
    }
    .report-top-header .header-title {
      margin: 0;
      font-size: 50px;
      font-weight: 700;
      color: #EFEAE2;
      font-family: 'Dunggeunmo', sans-serif;
      letter-spacing: -0.02em;
      line-height: 1.15;
    }
    .report-top-header .report-date-strip {
      padding-top: 8px;
    }
    /* 월 화 수 목 금 (위) / 날짜 (아래) - 목업처럼 두 줄로 뚜렷이 */
    .report-date-strip {
      display: flex;
      justify-content: space-between;
      align-items: stretch;
      padding: 0 4px;
      cursor: pointer;
      -webkit-tap-highlight-color: transparent;
      gap: 0;
    }
    .report-date-strip .date-col {
      flex: 1;
      text-align: center;
      min-width: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }
    .report-date-strip .date-col .day-name {
      display: block;
      font-size: 17px;
      font-weight: 700;
      margin-bottom: 8px;
      color: #EFEAE2;
      line-height: 1.2;
    }
    .report-date-strip .date-col .day-num {
      display: block;
      font-size: 24px;
      font-weight: 700;
      color: #EFEAE2;
      line-height: 1.2;
    }
    .report-date-strip .date-col.today .day-num {
      text-decoration: underline;
    }

    /* 달력 모달 (날짜 선택) - 항상 맨 앞에 */
    .report-calendar-overlay {
      display: none;
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: rgba(0,0,0,0.5);
      z-index: 9999;
      justify-content: center;
      align-items: center;
      padding: 20px;
      box-sizing: border-box;
    }
    .report-calendar-overlay.show {
      display: flex;
    }
    .report-calendar-modal {
      background: #fff;
      border-radius: 20px;
      padding: 20px;
      max-width: 360px;
      width: 100%;
      max-height: 90vh;
      overflow-y: auto;
    }
    .report-calendar-modal .cal-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .report-calendar-modal .cal-month-title {
      font-size: 18px;
      font-weight: 700;
      color: #574444;
    }
    .report-calendar-modal .cal-nav {
      background: none;
      border: none;
      padding: 8px 12px;
      cursor: pointer;
      font-size: 18px;
      color: #574444;
    }
    .report-calendar-modal .cal-grid {
      display: grid;
      grid-template-columns: repeat(7, 1fr);
      gap: 4px;
    }
    .report-calendar-modal .cal-weekday {
      text-align: center;
      font-size: 12px;
      font-weight: 700;
      color: #8d7b75;
      padding: 6px 0;
    }
    .report-calendar-modal .cal-day {
      aspect-ratio: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 14px;
      border-radius: 10px;
      cursor: pointer;
      color: #574444;
    }
    .report-calendar-modal .cal-day.other-month {
      color: #bbb;
    }
    .report-calendar-modal .cal-day.today {
      background: #FDE6A5;
      font-weight: 700;
    }
    .report-calendar-modal .cal-day:hover {
      background: #f0e0a0;
    }
    .report-calendar-modal .cal-day.selected {
      background: #694A49;
      color: #fff;
    }

    /* 일간/주간/월간 탭: Background.png 뒤에 reportBtn2.png, 링크는 투명 오버레이 */
    .report-tabs {
      position: sticky;
      top: 0;
      z-index: 2;
      padding: 0 16px 14px;
      background: #FDF8EE;
      box-sizing: border-box;
    }
    /* reportBtn2.png와 같은 영역에 배치해 끝(날카로운 부분) 정확히 맞춤 */
    .report-tabs .report-tabs-row {
      position: relative;
      margin: 0 -16px;
      width: calc(100% + 32px);
      max-width: none;
    }
    .report-tabs .report-tabs-background {
      position: absolute;
      top: -34px;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 0;
      pointer-events: none;
      background-image: url('<%= ctx %>/assets/images/report/Background.png');
      background-repeat: no-repeat;
      background-position: center bottom;
      background-size: 100% 100%;
    }
    .report-tabs .report-tabs-bg {
      position: relative;
      z-index: 1;
      line-height: 0;
      pointer-events: none;
    }
    .report-tabs .report-tabs-bg img {
      width: 100%;
      height: auto;
      display: block;
      vertical-align: top;
    }
    .report-tabs .report-tabs-inner {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      display: flex;
      pointer-events: none;
    }
    .report-tabs .report-tabs-inner a,
    .report-tabs .report-tabs-inner button {
      flex: 1;
      pointer-events: auto;
      cursor: pointer;
      text-decoration: none;
      background: none;
      border: none;
      font-size: 0;
      line-height: 0;
      text-indent: -9999px;
      overflow: hidden;
    }

    /* 콘텐츠 영역: report subject.png 목업, 프레임 색상 FFFBEF */
    .report-content-wrap {
      position: relative;
      z-index: 1;
      min-height: 60vh;
      padding: 20px 20px 80px;
      background: #FFFBEF;
      border-radius: 0 0 20px 20px;
      border: 2px solid #FFFBEF;
      box-shadow: inset 0 0 0 1px rgba(110, 92, 92, 0.25);
    }

    /* btn 밑: Group 34339.png 프레임 (크기 키움), 안에 일간 보고서 + 1~8 텍스트 */
    .report-daily-frame {
      background: url('<%= ctx %>/assets/images/report/Group 34339.png') no-repeat center top;
      background-size: 100% 100%;
      border-radius: 20px;
      padding: 32px 24px 40px;
      margin-bottom: 20px;
      font-size: 1.08rem;
    }
    .report-daily-frame .report-daily-title {
      font-size: 22px;
      font-weight: 700;
      color: #574444;
      margin: 0 0 24px 0;
      text-align: center;
    }
    /* 1. 노력해요 완료율 (활동에 따라 변경) */
    .report-completion-rate {
      margin: 30px 0 16px 0;
      font-size: 33px;
      font-weight: 700;
      color: #574444;
      text-align: center;
    }
    .report-completion-rate #reportCompletionRate {
      color: #4a7cbf;
    }
    /* 2. 요약 (summaryTable.png) */
    .report-summary-wrap {
      width: 400px;
      max-width: 100%;
      height: 294px;
      min-height: 294px;
      margin: 54px auto 20px;
      background: url('<%= ctx %>/assets/images/report/summaryTable.png') no-repeat center;
      background-size: 100% 100%;
      border-radius: 20px;
      padding: 24px 28px;
      box-sizing: border-box;
    }
    .report-summary-wrap .report-summary-title { font-size: 38px; font-weight: 700; color: #574444; margin: 0 0 20px 0; }
    .report-summary-wrap .report-score-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; font-size: 30px; color: #574444; }
    .report-summary-wrap .report-score-row .value { font-size: 34px; font-weight: 700; color: #4a7cbf; }

    /* 3. 식사/양치/복약 카드 (Group 34292, 34293, 34294) w400 h174 */
    .report-routine-card {
      width: 400px;
      max-width: 100%;
      height: 174px;
      min-height: 174px;
      margin: 30px auto 20px;
      background-repeat: no-repeat;
      background-position: center top;
      background-size: 100% 100%;
      border-radius: 20px;
      padding: 44px 20px 16px;
      box-sizing: border-box;
    }
    .report-routine-card.report-routine-meal { background-image: url('<%= ctx %>/assets/images/report/Group%2034292.png'); }
    .report-routine-card.report-routine-brush { background-image: url('<%= ctx %>/assets/images/report/Group%2034293.png'); }
    .report-routine-card.report-routine-med { background-image: url('<%= ctx %>/assets/images/report/Group%2034294.png'); }
    .report-routine-card .report-routine-content {
      background: rgba(255, 251, 239, 0.92);
      border-radius: 12px;
      padding: 10px 14px;
      margin-top: 20px;
    }
    .report-routine-card .report-routine-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 8px;
      text-align: center;
    }
    .report-routine-card .report-routine-grid .label { font-size: 15px; color: #574444; margin-bottom: 4px; }
    .report-routine-card .report-routine-grid .count { font-size: 18px; font-weight: 700; }
    .report-routine-card .report-routine-grid .count.done { color: #2e7d32; }
    .report-routine-card .report-routine-grid .count.miss { color: #c62828; }

    /* 6. 오늘 놓친 루틴 (routineCheck.png) - 캡처본처럼, 항상 보이게 */
    .report-missed-wrap {
      width: 400px;
      max-width: 100%;
      margin: 30px auto 20px;
      background-color: #FFFDF9;
      background-image: url('<%= ctx %>/assets/images/report/routineCheck.png');
      background-repeat: no-repeat;
      background-position: center top;
      background-size: 100% 100%;
      border-radius: 20px;
      padding: 24px 28px 28px;
      box-sizing: border-box;
      min-height: 140px;
      border: 1px solid #FADBB2;
    }
    .report-missed-wrap .report-missed-title {
      font-size: 20px;
      font-weight: 700;
      color: #574444;
      margin: 0 0 14px 0;
    }
    .report-missed-wrap .report-missed-list {
      list-style: none;
      padding: 0;
      margin: 0;
      font-size: 16px;
      color: #574444;
      line-height: 1.6;
    }
    .report-missed-wrap .report-missed-list li {
      padding: 4px 0;
    }

    /* 1~8 공통: PNG 틀만 쓰는 카드 스타일 (텍스트는 HTML) */
    .report-card-wrap {
      background: #FFFBEF;
      border: 2px solid #FDE6A5;
      border-radius: 16px;
      padding: 18px 20px;
      margin-bottom: 14px;
      box-shadow: 0 2px 8px rgba(253, 230, 165, 0.25);
    }
    .report-card-wrap .card-title {
      font-size: 18px;
      font-weight: 700;
      color: #574444;
      margin: 0 0 14px 0;
    }
    .report-score-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 6px 0;
      font-size: 16px;
      color: #574444;
    }
    .report-score-row .value {
      font-weight: 700;
      color: #4a7cbf;
    }
    /* 2. summaryTable = 식사/양치/복약 한 줄 요약 테이블 */
    .report-table-wrap {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 12px;
      margin-bottom: 14px;
    }
    .report-table-wrap .report-card-wrap {
      margin-bottom: 0;
    }
    .report-routine-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 10px;
      text-align: center;
      margin-top: 10px;
    }
    .report-routine-grid .label { font-size: 14px; color: #574444; margin-bottom: 4px; }
    .report-routine-grid .count { font-size: 18px; font-weight: 700; }
    .report-routine-grid .count.done { color: #2e7d32; }
    .report-routine-grid .count.miss { color: #c62828; }
    /* 6. 놓친 루틴 리스트 */
    .report-missed-list {
      list-style: none;
      padding: 0;
      margin: 0;
      font-size: 15px;
      color: #574444;
    }
    .report-missed-list li { padding: 4px 0; }
    /* 7. 게임 평균 점수 (제목 + PNG 카드 3개) - 캡처본처럼 */
    .report-game-section {
      width: 400px;
      max-width: 100%;
      margin: 30px auto 20px;
    }
    .report-game-section .report-game-title {
      font-size: 18px;
      font-weight: 700;
      color: #574444;
      margin: 0 0 12px 0;
    }
    .report-game-row {
      display: flex;
      gap: 12px;
      margin-top: 0;
      margin-bottom: 0;
    }
    .report-game-card {
      flex: 1;
      min-height: 100px;
      background-repeat: no-repeat;
      background-position: center top;
      background-size: 100% 100%;
      border-radius: 14px;
      padding: 10px;
      text-align: center;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: flex-end;
      box-sizing: border-box;
    }
    .report-game-card.report-game-1 { background-image: url('<%= ctx %>/assets/images/report/게임.png'); }
    .report-game-card.report-game-2 { background-image: url('<%= ctx %>/assets/images/report/게임1.png'); }
    .report-game-card.report-game-3 { background-image: url('<%= ctx %>/assets/images/report/게임2.png'); }
    .report-game-card .game-name { font-size: 12px; color: #574444; margin-bottom: 4px; display: block; }
    .report-game-card .game-score { font-size: 22px; font-weight: 700; color: #4a7cbf; }
  </style>
</head>
<body class="report-page">

<div class="app-frame">

  <!-- 상단 (Z-index: 2): Header+Calendar1.png 크기 그대로, 목업과 동일 -->
  <div class="report-top-header">
    <img src="<%= ctx %>/assets/images/report/Header+Calendar1.png" alt="" class="header-bg">
    <div class="header-content">
      <div class="header-row">
        <%
          String from = request.getParameter("from");
          String backUrl = ctx + "/active/main.jsp";
          if ("guard".equals(from)) {
            backUrl = ctx + "/notify/guard.jsp";
          }
        %>
        <a href="<%= backUrl %>" class="back-link" aria-label="뒤로">◀</a>
        <h1 class="header-title">보고서 보기</h1>
      </div>
      <div class="report-date-strip" id="reportDateStrip" role="button" aria-label="날짜 선택">
      <div class="date-col" data-offset="-2"><span class="day-name"></span><span class="day-num"></span></div>
      <div class="date-col" data-offset="-1"><span class="day-name"></span><span class="day-num"></span></div>
      <div class="date-col today" data-offset="0"><span class="day-name"></span><span class="day-num"></span></div>
      <div class="date-col" data-offset="1"><span class="day-name"></span><span class="day-num"></span></div>
      <div class="date-col" data-offset="2"><span class="day-name"></span><span class="day-num"></span></div>
    </div>
    </div>
  </div>

  <!-- 달력 모달 (날짜 클릭 시 표시) -->
  <div class="report-calendar-overlay" id="reportCalendarOverlay">
    <div class="report-calendar-modal">
      <div class="cal-header">
        <button type="button" class="cal-nav" id="calPrevMonth" aria-label="이전 달">◀</button>
        <span class="cal-month-title" id="calMonthTitle"></span>
        <button type="button" class="cal-nav" id="calNextMonth" aria-label="다음 달">▶</button>
      </div>
      <div class="cal-grid" id="calWeekdays"></div>
      <div class="cal-grid" id="calDays"></div>
    </div>
  </div>

  <!-- 일간/주간/월간 탭 (Z-index: 2, sticky) -->
  <div class="report-tabs">
    <div class="report-tabs-row">
      <div class="report-tabs-background" aria-hidden="true"></div>
      <div class="report-tabs-bg" aria-hidden="true"><img src="<%= ctx %>/assets/images/report/reportBtn2.png" alt="" width="100%" height="auto"></div>
    </div>
    <div class="report-tabs-inner">
      <a href="<%= ctx %>/report/daily" class="active">일간 보고서</a>
      <a href="<%= ctx %>/report/weekly">주간 보고서</a>
      <a href="<%= ctx %>/report/monthly">월간 보고서</a>
    </div>
  </div>

  <!-- 콘텐츠 영역: report subject.png 목업, 프레임 FFFBEF -->
  <div class="report-content-wrap" id="reportContent">

    <!-- Group 34339.png 프레임 안: 하나씩 추가 -->
    <div class="report-daily-frame">
      

      <!-- 1. 노력해요 완료율 % -->
      <p class="report-completion-rate">노력해요 완료율 : <span id="reportCompletionRate">0</span>%</p>

      <!-- 2. 요약 (summaryTable.png) -->
      <div class="report-summary-wrap">
        <div class="report-summary-title">요약</div>
        <div class="report-score-row"><span>종합일일 점수 :</span><span class="value" id="reportSummaryTotal">0</span> 점</div>
        <div class="report-score-row"><span>활동 점수 :</span><span class="value" id="reportActivityScore">0</span> 점</div>
        <div class="report-score-row"><span>게임 평균 :</span><span class="value" id="reportGameAvg">0</span> 점</div>
      </div>

      <!-- 3. 식사 (Group 34292) w400 h174 -->
      <div class="report-routine-card report-routine-meal">
        <div class="report-routine-content">
          <div class="report-routine-grid">
            <div><div class="label">아침</div><div class="count done" id="reportMealMorning">0회</div></div>
            <div><div class="label">점심</div><div class="count miss" id="reportMealLunch">0회</div></div>
            <div><div class="label">저녁</div><div class="count done" id="reportMealDinner">0회</div></div>
          </div>
        </div>
      </div>
      <!-- 4. 양치 (Group 34293) w400 h174 -->
      <div class="report-routine-card report-routine-brush">
        <div class="report-routine-content">
          <div class="report-routine-grid">
            <div><div class="label">아침</div><div class="count miss" id="reportBrushMorning">0회</div></div>
            <div><div class="label">점심</div><div class="count miss" id="reportBrushLunch">0회</div></div>
            <div><div class="label">저녁</div><div class="count done" id="reportBrushDinner">0회</div></div>
          </div>
        </div>
      </div>
      <!-- 5. 복약 (Group 34294) w400 h174 -->
      <div class="report-routine-card report-routine-med">
        <div class="report-routine-content">
          <div class="report-routine-grid">
            <div><div class="label">아침</div><div class="count done" id="reportMedMorning">0회</div></div>
            <div><div class="label">점심</div><div class="count miss" id="reportMedLunch">0회</div></div>
            <div><div class="label">저녁</div><div class="count done" id="reportMedDinner">0회</div></div>
          </div>
        </div>
      </div>

      <!-- 6. 오늘 놓친 루틴 (routineCheck.png) -->
      <div class="report-missed-wrap">
        <div class="report-missed-title">오늘 놓친 루틴</div>
        <ul class="report-missed-list" id="reportMissedList">
          <li>식사 : 점심</li>
          <li>복약: 아침, 점심</li>
          <li>양치: 아침, 점심, 저녁</li>
        </ul>
      </div>

      <!-- 7. 게임 평균 점수 (제목 + 게임1/게임2/게임 PNG, 각 평균 점수) -->
      <div class="report-game-section">
        <div class="report-game-title">게임 평균 점수</div>
        <div class="report-game-row">
          <div class="report-game-card report-game-1">
            <span class="game-name" id="reportGame1Name">단어 맞추기</span>
            <span class="game-score" id="reportGame1Score">0</span>
          </div>
          <div class="report-game-card report-game-2">
            <span class="game-name" id="reportGame2Name">카드 게임</span>
            <span class="game-score" id="reportGame2Score">0</span>
          </div>
          <div class="report-game-card report-game-3">
            <span class="game-name" id="reportGame3Name">색상 맞추기</span>
            <span class="game-score" id="reportGame3Score">0</span>
          </div>
        </div>
            </div>
    </div>

  </div>

</div>

<%-- 서버에서 전달한 일간 보고서 데이터 (DailyReportServlet 포워드 시 사용) --%>
<%
  Object reportDataJsonAttr = request.getAttribute("reportDataJson");
  String reportDataJsonStr = (reportDataJsonAttr != null) ? reportDataJsonAttr.toString() : "";
  if (reportDataJsonStr.contains("</script>")) {
    reportDataJsonStr = reportDataJsonStr.replace("</script>", "<\\/script>");
  }
%>
<script type="application/json" id="reportDataJson"><%= reportDataJsonStr %></script>

<script>
(function() {
  var ctx = '<%= ctx %>';
  var DAY_NAMES = ['일','월','화','수','목','금','토'];

  function toDate(y, m, d) {
    var dt = new Date(y, m - 1, d);
    return dt;
  }
  function formatDate(d) {
    var y = d.getFullYear(), m = d.getMonth() + 1, day = d.getDate();
    return { y: y, m: m, d: day };
  }
  function addDays(d, delta) {
    var r = new Date(d);
    r.setDate(r.getDate() + delta);
    return r;
  }

  var reportCenterDate = new Date();
  var serverDate = '<%= request.getAttribute("date") != null ? request.getAttribute("date") : "" %>';
  if (serverDate) {
    var p = serverDate.split('-').map(Number);
    if (p.length === 3) reportCenterDate = new Date(p[0], p[1] - 1, p[2]);
  }

  function renderDateStrip() {
    var strip = document.getElementById('reportDateStrip');
    if (!strip) return;
    var today = new Date();
    today.setHours(0,0,0,0);
    for (var i = -2; i <= 2; i++) {
      var d = addDays(reportCenterDate, i);
      var col = strip.querySelector('.date-col[data-offset="' + i + '"]');
      if (!col) continue;
      col.querySelector('.day-name').textContent = DAY_NAMES[d.getDay()];
      col.querySelector('.day-num').textContent = d.getDate();
      col.classList.toggle('today', d.getTime() === today.getTime());
    }
  }

  var calYear, calMonth;
  function openCalendar() {
    calYear = reportCenterDate.getFullYear();
    calMonth = reportCenterDate.getMonth() + 1;
    renderCalendar();
    document.getElementById('reportCalendarOverlay').classList.add('show');
  }
  function closeCalendar() {
    document.getElementById('reportCalendarOverlay').classList.remove('show');
  }
  function renderCalendar() {
    document.getElementById('calMonthTitle').textContent = calYear + '년 ' + calMonth + '월';
    var first = new Date(calYear, calMonth - 1, 1);
    var last = new Date(calYear, calMonth, 0);
    var firstDay = first.getDay();
    var daysInMonth = last.getDate();
    var today = new Date();
    today.setHours(0,0,0,0);

    var weekdaysHtml = '';
    ['일','월','화','수','목','금','토'].forEach(function(w) {
      weekdaysHtml += '<div class="cal-weekday">' + w + '</div>';
    });
    document.getElementById('calWeekdays').innerHTML = weekdaysHtml;

    var cells = [];
    for (var i = 0; i < firstDay; i++) {
      var prevMonth = new Date(calYear, calMonth - 1, -firstDay + i + 1);
      cells.push({ day: prevMonth.getDate(), other: true, date: prevMonth });
    }
    for (var d = 1; d <= daysInMonth; d++) {
      var date = new Date(calYear, calMonth - 1, d);
      date.setHours(0,0,0,0);
      cells.push({ day: d, other: false, date: date });
    }
    var rest = 7 - (cells.length % 7);
    if (rest < 7) {
      for (var j = 0; j < rest; j++) {
        var nextDate = new Date(calYear, calMonth, j + 1);
        cells.push({ day: nextDate.getDate(), other: true, date: nextDate });
      }
    }

    var daysHtml = '';
    cells.forEach(function(cell) {
      var isToday = cell.date.getTime() === today.getTime();
      var cls = 'cal-day' + (cell.other ? ' other-month' : '') + (isToday ? ' today' : '');
      daysHtml += '<div class="' + cls + '" data-date="' + cell.date.getFullYear() + '-' + (cell.date.getMonth()+1) + '-' + cell.date.getDate() + '">' + cell.day + '</div>';
    });
    document.getElementById('calDays').innerHTML = daysHtml;
  }
  document.getElementById('calDays').addEventListener('click', function(e) {
    var dayEl = e.target.closest('.cal-day');
    if (!dayEl || dayEl.classList.contains('other-month')) return;
    var str = dayEl.getAttribute('data-date');
    if (!str) return;
    var parts = str.split('-').map(Number);
    var y = parts[0], m = parts[1], d = parts[2];
    var dateParam = y + '-' + String(m).padStart(2, '0') + '-' + String(d).padStart(2, '0');
    closeCalendar();
    location.href = ctx + '/report/daily?date=' + dateParam;
  });

  /* 보고서 보기 밑 달력 영역 클릭 시 달력 모달만 열어서 날짜 선택 */
  document.getElementById('reportDateStrip').addEventListener('click', function() {
    openCalendar();
  });
  document.getElementById('calPrevMonth').onclick = function() {
    calMonth--;
    if (calMonth < 1) { calMonth = 12; calYear--; }
    renderCalendar();
  };
  document.getElementById('calNextMonth').onclick = function() {
    calMonth++;
    if (calMonth > 12) { calMonth = 1; calYear++; }
    renderCalendar();
  };
  document.getElementById('reportCalendarOverlay').addEventListener('click', function(e) {
    if (e.target === this) closeCalendar();
  });

  renderDateStrip();

  // 일간 보고서 텍스트 채우기 (reportDataJson 있으면 적용)
  function fillReportContent(data) {
    if (!data) return;
    var el = function(id) { return document.getElementById(id); };
    var completionRate = data.completionRate != null ? Number(data.completionRate) : (data.daily_score != null ? Number(data.daily_score) : 0);
    if (el('reportCompletionRate')) el('reportCompletionRate').textContent = Math.round(completionRate);
    if (data.daily_score != null && el('reportSummaryTotal')) el('reportSummaryTotal').textContent = data.daily_score;
    if (data.active_score != null && el('reportActivityScore')) el('reportActivityScore').textContent = data.active_score;
    if (data.game_score_avg != null && el('reportGameAvg')) el('reportGameAvg').textContent = data.game_score_avg;
    var activities = data.activities || {};
    var meal = activities['식사'] || {}, brush = activities['양치'] || {}, med = activities['복약'] || {};
    function setCount(id, n, completed) {
      var e = el(id);
      if (!e) return;
      e.textContent = (n != null ? n : 0) + '회';
      e.classList.toggle('done', completed);
      e.classList.toggle('miss', !completed);
    }
    setCount('reportMealMorning', meal.morning, meal.morningCompleted);
    setCount('reportMealLunch', meal.lunch, meal.lunchCompleted);
    setCount('reportMealDinner', meal.dinner, meal.dinnerCompleted);
    setCount('reportBrushMorning', brush.morning, brush.morningCompleted);
    setCount('reportBrushLunch', brush.lunch, brush.lunchCompleted);
    setCount('reportBrushDinner', brush.dinner, brush.dinnerCompleted);
    setCount('reportMedMorning', med.morning, med.morningCompleted);
    setCount('reportMedLunch', med.lunch, med.lunchCompleted);
    setCount('reportMedDinner', med.dinner, med.dinnerCompleted);
    // 6. 오늘 놓친 루틴
    var missed = data.missedActivities || [];
    var byName = {};
    missed.forEach(function(s) {
      var idx = s.indexOf(' - ');
      var name = idx >= 0 ? s.substring(0, idx) : s;
      var time = idx >= 0 ? s.substring(idx + 3) : '';
      if (!byName[name]) byName[name] = [];
      if (time) byName[name].push(time);
    });
    var listEl = el('reportMissedList');
    if (listEl) {
      var listHtml = '';
      ['식사','복약','양치'].forEach(function(name) {
        if (byName[name] && byName[name].length) listHtml += '<li>' + name + ' : ' + byName[name].join(', ') + '</li>';
      });
      listEl.innerHTML = listHtml || '<li>없음</li>';
    }
    // 7. 게임 평균 점수 (각 게임별)
    var gameAvgs = data.gameAverages || {};
    var gameLabelMap = { 'word': '단어 맞추기', 'WORD_GAME': '단어 맞추기', 'card': '카드 게임', 'CARD_GAME': '카드 게임', 'color': '색상 맞추기', 'COLOR_GAME': '색상 맞추기' };
    var keys = Object.keys(gameAvgs);
    for (var g = 0; g < 3; g++) {
      var nameEl = el('reportGame' + (g + 1) + 'Name');
      var scoreEl = el('reportGame' + (g + 1) + 'Score');
      var key = keys[g];
      var label = key ? (gameLabelMap[key] || key) : ['단어 맞추기', '카드 게임', '색상 맞추기'][g];
      var score = key && gameAvgs[key] != null ? Math.round(gameAvgs[key]) : '0';
      if (nameEl) nameEl.textContent = label;
      if (scoreEl) scoreEl.textContent = score;
    }
  }

  var jsonEl = document.getElementById('reportDataJson');
  if (jsonEl && jsonEl.textContent) {
    try {
      var reportData = JSON.parse(jsonEl.textContent.trim());
      fillReportContent(reportData);
    } catch (e) { console.warn('reportDataJson parse error', e); }
  }

  // 일간·주간·월간 공유 날짜: 현재 선택 날짜를 탭 링크에 넣고 sessionStorage에 저장
  function getReportDateStr() {
    var d = reportCenterDate;
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }
  var reportDateStr = getReportDateStr();
  try { sessionStorage.setItem('reportSelectedDate', reportDateStr); } catch (e) {}
  var tabAnchors = document.querySelectorAll('.report-tabs-inner a');
  tabAnchors.forEach(function(a) {
    var h = a.getAttribute('href') || '';
    if (h.indexOf('/report/daily') !== -1) a.setAttribute('href', ctx + '/report/daily?date=' + reportDateStr);
    else if (h.indexOf('/report/weekly') !== -1) a.setAttribute('href', ctx + '/report/weekly?date=' + reportDateStr);
    else if (h.indexOf('/report/monthly') !== -1) a.setAttribute('href', ctx + '/report/monthly?date=' + reportDateStr);
  });

  var path = window.location.pathname || '';
  document.querySelectorAll('.report-tabs a').forEach(function(a) {
    var href = a.getAttribute('href') || '';
    var linkPath = href.indexOf(ctx) === 0 ? href.slice(ctx.length).split('?')[0] : href.split('?')[0];
    if (path.indexOf(linkPath) !== -1) a.classList.add('active');
    else a.classList.remove('active');
  });
})();
</script>
</body>
</html>

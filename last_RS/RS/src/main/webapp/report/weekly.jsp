<%--
  주간 보고서: reportMain과 동일 프레임, reportBtn21.png 탭, Group 34339 안에 report subject1.png 디자인.
  WeeklyReportServlet → activeLogsJson, gameLogsJson 전달.
--%>
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
  <title>주간 보고서 - 기억해, 봄</title>
  <link rel="stylesheet" href="<%= ctx %>/assets/css/active.css">
  <link rel="stylesheet" href="<%= ctx %>/assets/css/weekly.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
  <style>
    body.report-page { margin: 0; padding: 0; background: #FFDF7C; min-height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Dunggeunmo', sans-serif; }
    body.report-page .app-frame { overflow-x: hidden; overflow-y: auto; }
    /* 일간 보고서 달력 버전과 동일 (공통 스타일) */
    .report-top-header { position: relative; z-index: 5; width: 100%; line-height: 0; overflow: hidden; border-radius: 20px 20px 0 0; }
    .report-top-header .header-bg { display: block; width: 100%; height: auto; vertical-align: top; }
    .report-top-header .header-content { position: absolute; top: 0; left: 0; right: 0; bottom: 0; padding: 28px 24px 20px; box-sizing: border-box; display: flex; flex-direction: column; justify-content: space-between; }
    .report-top-header .header-row { display: flex; align-items: center; gap: 14px; margin-top: 8px; }
    .report-top-header .back-link { display: inline-block; font-size: 50.23px; line-height: 1; color: #EFEAE2; text-decoration: none; flex-shrink: 0; }
    .report-top-header .header-title { margin: 0; font-size: 50px; font-weight: 700; color: #EFEAE2; font-family: 'Dunggeunmo', sans-serif; letter-spacing: -0.02em; line-height: 1.15; }
    .report-top-header .report-date-strip { padding-top: 8px; }
    .report-date-strip { display: flex; justify-content: space-between; align-items: stretch; padding: 0 4px; cursor: pointer; -webkit-tap-highlight-color: transparent; gap: 0; }
    .report-date-strip .date-col { flex: 1; text-align: center; min-width: 0; display: flex; flex-direction: column; align-items: center; justify-content: center; }
    .report-date-strip .date-col .day-name { display: block; font-size: 17px; font-weight: 700; margin-bottom: 8px; color: #EFEAE2; line-height: 1.2; }
    .report-date-strip .date-col .day-num { display: block; font-size: 24px; font-weight: 700; color: #EFEAE2; line-height: 1.2; }
    .report-date-strip .date-col.today .day-num { text-decoration: underline; }
    .report-calendar-overlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center; padding: 20px; box-sizing: border-box; }
    .report-calendar-overlay.show { display: flex; }
    .report-calendar-modal { background: #fff; border-radius: 20px; padding: 20px; max-width: 360px; width: 100%; max-height: 90vh; overflow-y: auto; }
    .report-calendar-modal .cal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
    .report-calendar-modal .cal-month-title { font-size: 18px; font-weight: 700; color: #574444; }
    .report-calendar-modal .cal-nav { background: none; border: none; padding: 8px 12px; cursor: pointer; font-size: 18px; color: #574444; }
    .report-calendar-modal .cal-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 4px; }
    .report-calendar-modal .cal-weekday { text-align: center; font-size: 12px; font-weight: 700; color: #8d7b75; padding: 6px 0; }
    .report-calendar-modal .cal-day { aspect-ratio: 1; display: flex; align-items: center; justify-content: center; font-size: 14px; border-radius: 10px; cursor: pointer; color: #574444; }
    .report-calendar-modal .cal-day.other-month { color: #bbb; }
    .report-calendar-modal .cal-day.today { background: #FDE6A5; font-weight: 700; }
    .report-calendar-modal .cal-day:hover { background: #f0e0a0; }
    .report-calendar-modal .cal-day.selected { background: #694A49; color: #fff; }
    .report-tabs { position: sticky; top: 0; z-index: 2; padding: 0 16px 14px; background: #FDF8EE; box-sizing: border-box; }
    .report-tabs .report-tabs-row { position: relative; margin: 0 -16px; width: calc(100% + 32px); }
    .report-tabs .report-tabs-background { position: absolute; top: -34px; left: 0; right: 0; bottom: 0; z-index: 0; pointer-events: none; background: url('<%= ctx %>/assets/images/report/Background.png') no-repeat center bottom; background-size: 100% 100%; }
    .report-tabs .report-tabs-bg { position: relative; z-index: 1; line-height: 0; pointer-events: none; }
    .report-tabs .report-tabs-bg img { width: 100%; height: auto; display: block; }
    .report-tabs .report-tabs-inner { position: absolute; top: 0; left: 0; right: 0; bottom: 0; display: flex; pointer-events: none; }
    .report-tabs .report-tabs-inner a { flex: 1; pointer-events: auto; cursor: pointer; text-decoration: none; background: none; border: none; font-size: 0; line-height: 0; text-indent: -9999px; overflow: hidden; }
    .report-content-wrap { position: relative; z-index: 1; min-height: 60vh; padding: 20px 20px 80px; background: #FFFBEF; border-radius: 0 0 20px 20px; border: 2px solid #FFFBEF; box-shadow: inset 0 0 0 1px rgba(110, 92, 92, 0.25); }
    .report-daily-frame { background: url('<%= ctx %>/assets/images/report/Group 34339.png') no-repeat center top; background-size: 100% 100%; border-radius: 20px; padding: 32px 24px 40px; margin-bottom: 20px; font-size: 1.08rem; }
    .report-daily-frame .report-daily-title { font-size: 22px; font-weight: 700; color: #574444; margin: 0 0 24px 0; text-align: center; }
    /* report subject1 스타일 */
    .weekly-summary-card { background: linear-gradient(135deg, #FFE294 0%, #FFF0C7 100%); border-radius: 16px; padding: 18px 20px; margin-bottom: 16px; text-align: center; color: #8B6914; font-weight: 600; font-size: 1.05rem; }
    .weekly-card { background: #fff; border: 2px solid #FDE6A5; border-radius: 16px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 8px rgba(253, 230, 165, 0.25); }
    .weekly-card h3 { margin: 0 0 8px 0; font-size: 18px; font-weight: 700; color: #574444; }
    .weekly-card .date-range { font-size: 14px; color: #666; margin-bottom: 12px; }
    .weekly-detail-section { margin-bottom: 20px; }
    .weekly-detail-section:last-child { margin-bottom: 0; }
    .weekly-detail-section .activity-name { font-size: 17px; font-weight: 700; color: #574444; margin-bottom: 12px; }
    .weekly-time-row { margin-bottom: 12px; }
    .weekly-time-row .time-label { font-size: 14px; color: #574444; margin-bottom: 4px; }
    .weekly-progress-bar { height: 20px; border-radius: 10px; overflow: hidden; background: #f0f0f0; display: flex; margin-bottom: 6px; }
    .weekly-progress-bar .seg-done { background: #28a745; }
    .weekly-progress-bar .seg-dup { background: #ffc107; }
    .weekly-progress-bar .seg-miss { background: #dc3545; }
    .weekly-metrics { font-size: 13px; color: #574444; }
    .weekly-metrics span { margin-right: 12px; }
    .weekly-weak { color: #c62828; font-weight: 600; font-size: 14px; margin-top: 8px; }
    /* 활동별 상세 분석 목업 (활동별 상세 분석 식사.png 기준) - 식사/복약/양치 각각 적용 */
    .mr-activity-card { background: #fff; border-radius: 16px; padding: 20px; margin-bottom: 16px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); border: 1px solid #f0e6dc; }
    .mr-activity-title { font-size: 20px; font-weight: 700; color: #574444; margin: 0 0 16px 0; }
    .mr-time-row { margin-bottom: 14px; }
    .mr-time-row:last-of-type { margin-bottom: 0; }
    .mr-time-label { font-size: 15px; font-weight: 700; color: #574444; margin-bottom: 6px; }
    /* 바: 뒤에 Background.png, 맨 밑에 누락 R.png 깔고 그 위에 총 클릭(y) + 중복(green) 올림 → 틈 나도 흰색 안 보임 */
    .mr-bar-wrap { height: 24px; border-radius: 999px; overflow: hidden; position: relative; background: url('<%= ctx %>/assets/images/mr/Background.png') no-repeat center; background-size: 100% 100%; border: 2px solid #4C4444; box-sizing: border-box; }
    .mr-bar-layer-miss { position: absolute; left: 0; top: 0; right: 0; bottom: 0; z-index: 1; background: url('<%= ctx %>/assets/images/mr/R.png') no-repeat center; background-size: 100% 100%; }
    .mr-bar-layer-total { position: absolute; left: 0; top: 0; bottom: 0; z-index: 2; min-width: 0; }
    .mr-seg-total { display: flex; justify-content: flex-start; align-items: center; width: 100%; height: 100%; min-height: 0; background: url('<%= ctx %>/assets/images/mr/y.png') no-repeat center; background-size: 100% 100%; min-width: 0; flex-shrink: 0; }
    .mr-seg-dup-inner { background: url('<%= ctx %>/assets/images/mr/green.png') no-repeat center; background-size: 100% 100%; align-self: center; height: 70%; min-width: 0; flex-shrink: 0; border-radius: 999px; }
    .mr-metrics { font-size: 13px; color: #574444; margin-top: 6px; display: flex; flex-wrap: wrap; gap: 12px 16px; align-items: center; }
    .mr-metrics span { display: inline-flex; align-items: center; gap: 6px; }
    .mr-metrics .mr-icon { display: inline-block; width: 14px; height: 14px; border: 2px solid transparent; border-radius: 2px; flex-shrink: 0; }
    .mr-metrics .mr-icon-clicks { background: #FFF6DB; border-color: #FFF6DB; }
    .mr-metrics .mr-icon-dup { background: #D9EDCC; border-color: #b8d9a4; }
    .mr-metrics .mr-icon-miss { background: #F7C5C5; border-color: #e8a8a8; }
    .mr-weak { font-size: 15px; font-weight: 700; margin-top: 12px; }
    .mr-weak .mr-weak-label { color: #574444; }
    .mr-weak .mr-weak-list { color: #EE7777; }
    #weeklyReportContent { min-height: 200px; }
  </style>
</head>
<body class="report-page">

<div class="app-frame">
  <div class="report-top-header">
    <img src="<%= ctx %>/assets/images/report/Header+Calendar1.png" alt="" class="header-bg">
    <div class="header-content">
      <div class="header-row">
        <a href="<%= ctx %>/active/main.jsp" class="back-link" aria-label="뒤로">◀</a>
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

  <!-- 주간 탭: reportBtn21.png (주간 선택 상태) -->
  <div class="report-tabs">
    <div class="report-tabs-row">
      <div class="report-tabs-background" aria-hidden="true"></div>
      <div class="report-tabs-bg" aria-hidden="true"><img src="<%= ctx %>/assets/images/report/reportBtn21.png" alt="" width="100%" height="auto"></div>
    </div>
    <div class="report-tabs-inner">
      <a href="<%= ctx %>/report/daily">일간 보고서</a>
      <a href="<%= ctx %>/report/weekly" class="active">주간 보고서</a>
      <a href="<%= ctx %>/report/monthly">월간 보고서</a>
    </div>
  </div>

  <div class="report-content-wrap">
    <div class="report-daily-frame">
      
      <div id="weeklyReportContent"></div>
    </div>
  </div>
</div>

<c:if test="${not empty activeLogsJson or not empty gameLogsJson}">
<script type="application/json" id="weeklyActiveLogsJsonData"><c:out value="${not empty activeLogsJson ? activeLogsJson : '[]'}" escapeXml="false"/></script>
<script type="application/json" id="weeklyGameLogsJsonData"><c:out value="${not empty gameLogsJson ? gameLogsJson : '[]'}" escapeXml="false"/></script>
</c:if>

<script src="<%= ctx %>/assets/js/weekly.js?v=20260210"></script>
<script>
(function() {
  var ctx = '<%= ctx %>';
  window.LOCAL_DATA = { activeLog: [], gameLog: [] };
  var LOCAL_DATA = window.LOCAL_DATA;
  try {
    var activeEl = document.getElementById('weeklyActiveLogsJsonData');
    if (activeEl) LOCAL_DATA.activeLog = JSON.parse((activeEl.textContent || activeEl.innerText).trim());
  } catch (e) { console.warn('activeLogsJson parse', e); }
  try {
    var gameEl = document.getElementById('weeklyGameLogsJsonData');
    if (gameEl) LOCAL_DATA.gameLog = JSON.parse((gameEl.textContent || gameEl.innerText).trim());
  } catch (e) { console.warn('gameLogsJson parse', e); }

  function getSharedDate() {
    var p = new URLSearchParams(location.search);
    var urlDate = p.get('date');
    if (urlDate) return urlDate;
    try { var s = sessionStorage.getItem('reportSelectedDate'); if (s) return s; } catch (e) {}
    return '';
  }
  var initialDate = getSharedDate();
  if (!initialDate) initialDate = '<c:out value="${date}"/>';
  if (!initialDate) {
    var t = new Date();
    initialDate = t.getFullYear() + '-' + String(t.getMonth() + 1).padStart(2, '0') + '-' + String(t.getDate()).padStart(2, '0');
  }
  try { sessionStorage.setItem('reportSelectedDate', initialDate); } catch (e) {}
  var weekEndDate = initialDate;

  var tabLinks = document.querySelectorAll('.report-tabs-inner a');
  var dateParam = initialDate ? '?date=' + encodeURIComponent(initialDate) : '';
  if (tabLinks[0]) tabLinks[0].setAttribute('href', ctx + '/report/daily' + dateParam);
  if (tabLinks[1]) tabLinks[1].setAttribute('href', ctx + '/report/weekly' + dateParam);
  if (tabLinks[2]) tabLinks[2].setAttribute('href', ctx + '/report/monthly' + dateParam);

  function toLocalDateStr(d) {
    var y = d.getFullYear(), m = String(d.getMonth() + 1).padStart(2, '0'), day = String(d.getDate()).padStart(2, '0');
    return y + '-' + m + '-' + day;
  }
  function formatDateRange(dateStr) {
    var p = dateStr.split('-').map(Number);
    return p[0] + '/' + p[1] + '/' + p[2];
  }

  function openCalendar() {
    document.getElementById('reportCalendarOverlay').classList.add('show');
    renderCal();
  }
  function closeCalendar() { document.getElementById('reportCalendarOverlay').classList.remove('show'); }
  function renderCal() {
    var d = new Date(weekEndDate);
    var y = d.getFullYear(), m = d.getMonth() + 1;
    document.getElementById('calMonthTitle').textContent = y + '년 ' + m + '월';
    var first = new Date(y, m - 1, 1), last = new Date(y, m, 0), firstDay = first.getDay(), daysInMonth = last.getDate();
    var weekdays = ['일','월','화','수','목','금','토'];
    document.getElementById('calWeekdays').innerHTML = weekdays.map(function(w) { return '<div class="cal-weekday">' + w + '</div>'; }).join('');
    var cells = [];
    for (var i = 0; i < firstDay; i++) cells.push({ day: new Date(y, m - 1, -firstDay + i + 1).getDate(), other: true, date: new Date(y, m - 1, -firstDay + i + 1) });
    for (var d_ = 1; d_ <= daysInMonth; d_++) cells.push({ day: d_, other: false, date: new Date(y, m - 1, d_) });
    var rest = 7 - (cells.length % 7);
    if (rest < 7) for (var j = 0; j < rest; j++) cells.push({ day: new Date(y, m, j + 1).getDate(), other: true, date: new Date(y, m, j + 1) });
    var today = new Date(); today.setHours(0,0,0,0);
    document.getElementById('calDays').innerHTML = cells.map(function(c) {
      var isToday = c.date.getTime() === today.getTime();
      var dt = c.date.getFullYear() + '-' + (c.date.getMonth()+1) + '-' + c.date.getDate();
      return '<div class="cal-day' + (c.other ? ' other-month' : '') + (isToday ? ' today' : '') + '" data-date="' + dt + '">' + c.day + '</div>';
    }).join('');
  }
  document.getElementById('reportDateStrip').onclick = openCalendar;
  document.getElementById('calPrevMonth').onclick = function() { var d = new Date(weekEndDate); d.setMonth(d.getMonth() - 1); weekEndDate = toLocalDateStr(d); renderCal(); };
  document.getElementById('calNextMonth').onclick = function() { var d = new Date(weekEndDate); d.setMonth(d.getMonth() + 1); weekEndDate = toLocalDateStr(d); renderCal(); };
  document.getElementById('calDays').addEventListener('click', function(e) {
    var el = e.target.closest('.cal-day');
    if (!el || el.classList.contains('other-month')) return;
    var picked = el.getAttribute('data-date');
    try { sessionStorage.setItem('reportSelectedDate', picked); } catch (e) {}
    closeCalendar();
    location.href = ctx + '/report/weekly?date=' + encodeURIComponent(picked);
  });
  document.getElementById('reportCalendarOverlay').addEventListener('click', function(e) { if (e.target === this) closeCalendar(); });

  var DAY_NAMES = ['일','월','화','수','목','금','토'];
  function renderDateStrip() {
    var strip = document.getElementById('reportDateStrip');
    if (!strip) return;
    var center = new Date(weekEndDate);
    var today = new Date(); today.setHours(0,0,0,0);
    for (var i = -2; i <= 2; i++) {
      var d = new Date(center); d.setDate(d.getDate() + i);
      var col = strip.querySelector('.date-col[data-offset="' + i + '"]');
      if (!col) continue;
      col.querySelector('.day-name').textContent = DAY_NAMES[d.getDay()];
      col.querySelector('.day-num').textContent = d.getDate();
      col.classList.toggle('today', d.getTime() === today.getTime());
    }
  }

  function showReport() {
    var content = document.getElementById('weeklyReportContent');
    if (typeof calculateWeeklyReportLocal === 'undefined' || typeof displayWeeklyReportSubject1 === 'undefined') {
      content.innerHTML = '<p style="color:#666; padding:24px; text-align:center;">데이터를 불러오는 중...</p>';
      setTimeout(showReport, 200);
      return;
    }
    if (!LOCAL_DATA.activeLog && !LOCAL_DATA.gameLog) {
      content.innerHTML = '<p style="color:#555; padding:24px; text-align:center;">해당 기간 데이터가 없습니다. 날짜를 선택해 주세요.</p>';
      return;
    }
    try {
      var data = calculateWeeklyReportLocal(weekEndDate);
      displayWeeklyReportSubject1(data);
      if (typeof renderWeeklyActivityChart !== 'undefined') renderWeeklyActivityChart(data.activityDailyCounts);
      if (typeof renderWeeklyGameChart !== 'undefined') renderWeeklyGameChart(data.gameDailyAverages);
    } catch (err) {
      content.innerHTML = '<p style="color:red; padding:24px;">오류: ' + err.message + '</p>';
      console.error(err);
    }
  }

  renderDateStrip();
  showReport();
})();
</script>
</body>
</html>

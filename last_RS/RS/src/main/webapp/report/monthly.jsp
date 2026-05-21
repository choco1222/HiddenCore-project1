<%--
  월간 보고서: 일간/주간과 동일한 달력 고정 (Header+Calendar1, 5칸 날짜 스트립, 달력 모달), reportBtn22 탭.
  MonthlyReportServlet → date, activeLogsJson, gameLogsJson 전달.
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
  <title>월간 보고서 - 기억해, 봄</title>
  <link rel="stylesheet" href="<%= ctx %>/assets/css/active.css">
  <link rel="stylesheet" href="<%= ctx %>/assets/css/monthly.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.2.0/dist/chartjs-plugin-datalabels.min.js"></script>
  <style>
    body.report-page { margin: 0; padding: 0; background: #FFDF7C; min-height: 100vh; display: flex; justify-content: center; align-items: center; font-family: 'Dunggeunmo', sans-serif; }
    body.report-page .app-frame { overflow-x: hidden; overflow-y: auto; }
    /* 일간 보고서 달력 버전과 동일 (공통 스타일) */
    .report-top-header { position: relative; z-index: 5; width: 100%; line-height: 0; overflow: hidden; border-radius: 20px 20px 0 0; }
    .report-top-header .header-bg { display: block; width: 100%; height: auto; vertical-align: top; border-radius: 20px 20px 0 0; }
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
    .report-content-wrap { position: relative; z-index: 1; min-height: 60vh; padding: 20px 20px 80px; background: #FFFBEF; border-radius: 0 0 20px 20px; }
    #monthlyReportContent { min-height: 200px; }
  </style>
</head>
<body class="report-page">

<div class="app-frame">

  <!-- 달력 모달 (일간과 동일, 맨 앞) -->
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

  <!-- 상단 헤더 + 날짜 스트립 (일간과 동일) -->
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

  <!-- 월간 탭: reportBtn22.png (월간 선택 상태) -->
  <div class="report-tabs">
    <div class="report-tabs-row">
      <div class="report-tabs-background" aria-hidden="true"></div>
      <div class="report-tabs-bg" aria-hidden="true"><img src="<%= ctx %>/assets/images/report/reportBtn22.png" alt="" width="100%" height="auto"></div>
    </div>
    <div class="report-tabs-inner">
      <a href="<%= ctx %>/report/daily">일간 보고서</a>
      <a href="<%= ctx %>/report/weekly">주간 보고서</a>
      <a href="<%= ctx %>/report/monthly" class="active">월간 보고서</a>
    </div>
  </div>

  <div class="report-content-wrap">
    <input type="hidden" id="monthlyDateInput" value="${date}">
    <div id="monthlyReportContent"></div>
  </div>
</div>

<c:if test="${not empty activeLogsJson or not empty gameLogsJson}">
<script type="application/json" id="activeLogsJsonData"><c:out value="${not empty activeLogsJson ? activeLogsJson : '[]'}" escapeXml="false"/></script>
<script type="application/json" id="gameLogsJsonData"><c:out value="${not empty gameLogsJson ? gameLogsJson : '[]'}" escapeXml="false"/></script>
</c:if>

<script src="<%= ctx %>/assets/js/monthly.js?v=20260210e"></script>
<script>
(function() {
  var ctx = '<%= ctx %>';
  window.CTX = ctx;
  window.contextPath = ctx;
  window.LOCAL_DATA = { activeLog: [], gameLog: [] };
  try {
    var activeEl = document.getElementById('activeLogsJsonData');
    if (activeEl) LOCAL_DATA.activeLog = JSON.parse((activeEl.textContent || activeEl.innerText).trim());
  } catch (e) { }
  try {
    var gameEl = document.getElementById('gameLogsJsonData');
    if (gameEl) LOCAL_DATA.gameLog = JSON.parse((gameEl.textContent || gameEl.innerText).trim());
  } catch (e) { }

  var dateInput = document.getElementById('monthlyDateInput');
  function getSharedDate() {
    var p = new URLSearchParams(location.search);
    var urlDate = p.get('date');
    if (urlDate) return urlDate;
    try { var s = sessionStorage.getItem('reportSelectedDate'); if (s) return s; } catch (e) {}
    return '';
  }
  var initialDate = getSharedDate();
  if (!initialDate) initialDate = dateInput.value || '';
  if (!initialDate) {
    var t = new Date();
    initialDate = t.getFullYear() + '-' + String(t.getMonth() + 1).padStart(2, '0') + '-' + String(t.getDate()).padStart(2, '0');
  }
  try { sessionStorage.setItem('reportSelectedDate', initialDate); } catch (e) {}
  dateInput.value = initialDate;

  var tabLinks = document.querySelectorAll('.report-tabs-inner a');
  var dateParam = initialDate ? '?date=' + encodeURIComponent(initialDate) : '';
  if (tabLinks[0]) tabLinks[0].setAttribute('href', ctx + '/report/daily' + dateParam);
  if (tabLinks[1]) tabLinks[1].setAttribute('href', ctx + '/report/weekly' + dateParam);
  if (tabLinks[2]) tabLinks[2].setAttribute('href', ctx + '/report/monthly' + dateParam);

  var DAY_NAMES = ['일','월','화','수','목','금','토'];
  function getCenterDate() {
    var s = dateInput.value;
    if (!s) return new Date();
    var p = s.split('-').map(Number);
    return new Date(p[0], p[1] - 1, p[2]);
  }
  function renderDateStrip() {
    var strip = document.getElementById('reportDateStrip');
    if (!strip) return;
    var center = getCenterDate();
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
  function toStr(d) {
    return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0') + '-' + String(d.getDate()).padStart(2, '0');
  }
  function openCalendar() {
    document.getElementById('reportCalendarOverlay').classList.add('show');
    renderCal();
  }
  function closeCalendar() { document.getElementById('reportCalendarOverlay').classList.remove('show'); }
  function renderCal() {
    var center = getCenterDate();
    var y = center.getFullYear(), m = center.getMonth() + 1;
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
      var dt = toStr(c.date);
      return '<div class="cal-day' + (c.other ? ' other-month' : '') + (isToday ? ' today' : '') + '" data-date="' + dt + '">' + c.day + '</div>';
    }).join('');
  }
  document.getElementById('reportDateStrip').onclick = openCalendar;
  document.getElementById('calPrevMonth').onclick = function() { var d = getCenterDate(); d.setMonth(d.getMonth() - 1); dateInput.value = toStr(d); renderDateStrip(); renderCal(); };
  document.getElementById('calNextMonth').onclick = function() { var d = getCenterDate(); d.setMonth(d.getMonth() + 1); dateInput.value = toStr(d); renderDateStrip(); renderCal(); };
  document.getElementById('calDays').addEventListener('click', function(e) {
    var el = e.target.closest('.cal-day');
    if (!el || el.classList.contains('other-month')) return;
    var picked = el.getAttribute('data-date');
    try { sessionStorage.setItem('reportSelectedDate', picked); } catch (e) {}
    closeCalendar();
    window.location.href = ctx + '/report/monthly?date=' + encodeURIComponent(picked);
  });
  document.getElementById('reportCalendarOverlay').addEventListener('click', function(e) { if (e.target === this) closeCalendar(); });

  function tryDisplayReport() {
    if (typeof calculateMonthlyReportLocal === 'undefined' || typeof displayMonthlyReport === 'undefined') {
      setTimeout(tryDisplayReport, 100);
      return;
    }
    if (!LOCAL_DATA.activeLog || LOCAL_DATA.activeLog.length === 0) {
      document.getElementById('monthlyReportContent').innerHTML = '<p style="color:#555; padding:24px; text-align:center;">해당 기간 데이터가 없습니다. 날짜를 선택해 주세요.</p>';
      return;
    }
    var dateStr = dateInput.value;
    if (!dateStr) return;
    try {
      var selectedDate = new Date(dateStr);
      if (isNaN(selectedDate.getTime())) return;
      var data = calculateMonthlyReportLocal(selectedDate);
      displayMonthlyReport(data);
    } catch (err) {
      document.getElementById('monthlyReportContent').innerHTML = '<p style="color:red; padding:24px;">오류: ' + err.message + '</p>';
    }
  }

  renderDateStrip();
  tryDisplayReport();
})();
</script>
</body>
</html>

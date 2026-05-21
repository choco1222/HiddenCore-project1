<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>달력 - 기억해, 봄</title>
<link rel="stylesheet" href="<%= ctx %>/assets/css/active.css">
<style>
/* 캘린더 var1.png 목업 기준: 연한 베이지 배경, 달력 그리드, Feel 아이콘, 홈으로 버튼 */
body.calendar-view-page {
  margin: 0;
  padding: 0;
  background: #FFDF7C;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  font-family: 'Dunggeunmo', sans-serif;
}
.calendar-view-page .app-frame {
  width: 100%;
  max-width: 440px;
  height: 100vh;
  max-height: 956px;
  min-height: 560px;
  background: #FDF8EE;
  position: relative;
  overflow: hidden;
}
@media (min-width: 441px) {
  .calendar-view-page .app-frame {
    height: 956px;
    border-radius: 28px;
    box-shadow: 0 12px 40px rgba(0,0,0,0.12);
  }
}

/* 상단: 뒤로가기 + 달력 */
/* 헤더·제목 = calendar.jsp 기분 기록 페이지와 동일 위치·크기 */
.calendar-view-header {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 71px 24px 0;
  position: relative;
  z-index: 1;
}
.calendar-view-header .back-btn {
  font-size: 26px;
  color: #574444;
  text-decoration: none;
  background: none;
  border: none;
  padding: 0;
  cursor: pointer;
  flex-shrink: 0;
}
.calendar-view-header .calendar-view-title {
  font-size: 55px;
  font-weight: 700;
  color: #574444;
  line-height: 1.2;
  font-family: 'Dunggeunmo', sans-serif;
}

/* 월 네비: ◀ 2월 ▶ (달력 부분 전체 100px 아래로) */
.month-nav {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 24px;
  padding: 8px 24px 20px;
  margin-top: 100px;
  position: relative;
  z-index: 1;
}
.month-nav .nav-btn {
  font-size: 24px;
  color: #574444;
  background: none;
  border: none;
  padding: 4px 12px;
  cursor: pointer;
}
.month-nav .month-label {
  font-size: 28px;
  font-weight: 700;
  color: #574444;
  min-width: 80px;
  text-align: center;
}

/* 요일 헤더 */
.day-headers {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  padding: 0 16px 8px;
  position: relative;
  z-index: 1;
}
.day-headers span {
  text-align: center;
  font-size: 14px;
  font-weight: 700;
  color: #574444;
}
.day-headers .sun { color: #c75c5c; }
.day-headers .sat { color: #6b9dc4; }

/* 달력 그리드 */
.calendar-grid-wrap {
  padding: 0 16px 140px;
  position: relative;
  z-index: 1;
}
.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 6px;
}
.calendar-day {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  padding: 6px 0 8px;
  min-height: 56px;
  border-radius: 12px;
  cursor: pointer;
  transition: background 0.2s;
}
.calendar-day.empty {
  visibility: hidden;
  cursor: default;
}
.calendar-day.today {
  background: #FDE6A5;
}
.calendar-day .day-number {
  font-size: 14px;
  font-weight: 700;
  color: #574444;
  margin-bottom: 4px;
}
.calendar-day .mood-icon-wrap {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e8e4dc;
}
.calendar-day .mood-icon {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

/* 홈으로 버튼 = 달력 보기 버튼과 동일 위치(화면 하단, 풀 위) */
.calendar-view-page .report-area {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 0 24px 100px;
  z-index: 1;
}
.calendar-view-page .report-btn {
  display: block;
  width: 100%;
  min-height: 100px;
  aspect-ratio: 4 / 1;
  position: relative;
  background-color: transparent;
  background-size: contain;
  background-repeat: no-repeat;
  background-position: center;
  border: none;
  outline: none;
  box-shadow: none;
  cursor: pointer;
  text-decoration: none;
}
.calendar-view-page .report-btn .card-bg-text {
  position: absolute;
  top: 45%;
  left: 50%;
  transform: translate(-50%, -50%);
  font-size: 30px;
  font-weight: 700;
  color: #7A4B3A;
  pointer-events: none;
}

/* 하단 풀 */
.calendar-view-page .grass {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: auto;
  pointer-events: none;
  z-index: 0;
  object-fit: cover;
  object-position: bottom;
}
</style>
</head>
<body class="calendar-view-page">

<div class="app-frame">

  <header class="calendar-view-header">
    <a href="<%= ctx %>/active/calendar.jsp" class="back-btn" aria-label="뒤로">◀</a>
    <h1 class="calendar-view-title">달력</h1>
  </header>

  <div class="month-nav">
    <button type="button" class="nav-btn" onclick="location.href='<%= ctx %>/active/CalendarServlet?year=${prevYear}&month=${prevMonth}'" aria-label="이전 달">◀</button>
    <span class="month-label">${month}월</span>
    <button type="button" class="nav-btn" onclick="location.href='<%= ctx %>/active/CalendarServlet?year=${nextYear}&month=${nextMonth}'" aria-label="다음 달">▶</button>
  </div>

  <div class="day-headers">
    <span class="sun">일</span>
    <span>월</span>
    <span>화</span>
    <span>수</span>
    <span>목</span>
    <span>금</span>
    <span class="sat">토</span>
  </div>

  <div class="calendar-grid-wrap">
    <div class="calendar-grid">
      <c:if test="${firstDayOfWeek > 1}">
        <c:forEach var="i" begin="1" end="${firstDayOfWeek - 1}">
          <div class="calendar-day empty"></div>
        </c:forEach>
      </c:if>
      <c:forEach var="day" begin="1" end="${daysInMonth}">
        <c:set var="isToday" value="${year == todayYear && month == todayMonth && day == todayDay}" />
        <div class="calendar-day ${isToday ? 'today' : ''}" id="day-${day}" data-day="${day}">
          <span class="day-number">${day}</span>
          <div class="mood-icon-wrap">
            <img class="mood-icon" data-day="${day}" src="<%= ctx %>/assets/images/calender/Feel=None.png" alt="">
          </div>
        </div>
      </c:forEach>
    </div>
  </div>

  <div class="report-area">
    <a href="<%= ctx %>/active/main.jsp" class="card card-bg report-btn"
      style="background-image: url('<%= ctx %>/assets/images/main01/보고서.png');">
      <span class="card-bg-text">홈으로</span>
    </a>
  </div>

  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">

</div>

<script>
(function() {
  var ctx = '<%= ctx %>';
  var moodToFile = {
    happy: 'Feel=happy.png',
    neutral: 'Feel=calm.png',
    sad: 'Feel=sad.png',
    angry: 'Feel=Angry.png',
    tired: 'Feel=tired.png',
    anxious: 'Feel=Lonely.png',
    // 구버전 호환
    joy: 'Feel=happy.png',
    pain: 'Feel=sad.png',
    normal: 'Feel=calm.png'
  };
  var currentYear = ${year};
  var currentMonth = ${month};

  function applyMoodIcons() {
    // DB에서 조회한 기분 데이터 (서버에서 전달)
    var dbMoodData = ${moodDataJson};
    console.log('[calendar] DB 기분 데이터:', dbMoodData);
    
    // localStorage 데이터도 병합 (오늘 기록용)
    var localMoodData = JSON.parse(localStorage.getItem('moodData')) || [];
    
    // DB 데이터 우선 적용
    dbMoodData.forEach(function(record) {
      var parts = record.date.split('-').map(Number);
      var rYear = parts[0], rMonth = parts[1], rDay = parts[2];
      if (rYear !== currentYear || rMonth !== currentMonth) return;
      var cell = document.getElementById('day-' + rDay);
      if (!cell) return;
      var img = cell.querySelector('.mood-icon');
      if (!img) return;
      var file = moodToFile[record.mood] || 'Feel=None.png';
      img.src = ctx + '/assets/images/calender/' + file;
      cell.setAttribute('data-has-mood', 'true');
    });
    
    // localStorage 데이터도 적용 (DB에 없는 것만)
    localMoodData.forEach(function(record) {
      var parts = record.date.split('-').map(Number);
      var rYear = parts[0], rMonth = parts[1], rDay = parts[2];
      if (rYear !== currentYear || rMonth !== currentMonth) return;
      var cell = document.getElementById('day-' + rDay);
      if (!cell) return;
      var img = cell.querySelector('.mood-icon');
      if (!img || img.src.indexOf('Feel=None.png') === -1) return; // 이미 DB에서 설정됨
      var file = moodToFile[record.mood] || 'Feel=None.png';
      img.src = ctx + '/assets/images/calender/' + file;
      cell.setAttribute('data-has-mood', 'true');
    });
  }
  
  // 기분 아이콘 클릭 시 삭제
  function onDayClick(e) {
    var cell = e.currentTarget;
    var hasMood = cell.getAttribute('data-has-mood') === 'true';
    if (!hasMood) return;
    
    var day = parseInt(cell.getAttribute('data-day'));
    var dateStr = currentYear + '-' + String(currentMonth).padStart(2, '0') + '-' + String(day).padStart(2, '0');
    
    if (!confirm(dateStr + ' 기분 기록을 삭제하시겠습니까?')) return;
    
    // localStorage에서 삭제
    var localMoodData = JSON.parse(localStorage.getItem('moodData')) || [];
    var filtered = localMoodData.filter(function(r) { return r.date !== dateStr; });
    localStorage.setItem('moodData', JSON.stringify(filtered));
    
    // DB에서도 삭제 요청 (서버에 DELETE API 필요)
    fetch(ctx + '/active/deleteMood', {
      method: 'POST',
      credentials: 'same-origin',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
      body: 'date=' + encodeURIComponent(dateStr)
    }).then(function() {
      console.log('[calendar] 기분 삭제 완료:', dateStr);
      location.reload();
    }).catch(function(err) {
      console.error('[calendar] 기분 삭제 실패:', err);
      location.reload();
    });
  }

  document.addEventListener('DOMContentLoaded', function() {
    applyMoodIcons();
    // 각 날짜 셀에 클릭 이벤트 추가
    document.querySelectorAll('.calendar-day:not(.empty)').forEach(function(cell) {
      cell.addEventListener('click', onDayClick);
    });
  });
})();
</script>
</script>
</body>
</html>

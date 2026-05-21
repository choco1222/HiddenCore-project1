<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>기분 기록</title>
  <link rel="stylesheet" href="<%= ctx %>/assets/css/active.css" />
  <style>
    /* main.jsp·game_main.jsp와 동일: 프레임·배경·폰트 */
    body.calendar-page {
      padding: 0 !important;
      margin: 0 !important;
      background: #FFDF7C !important;
      display: flex !important;
      justify-content: center !important;
      align-items: center !important;
      min-height: 100vh !important;
      font-family: 'Dunggeunmo', sans-serif !important;
    }
    body.calendar-page .app-frame {
      width: 100% !important;
      max-width: 440px !important;
      height: 100vh !important;
      max-height: 956px !important;
      min-height: 560px !important;
      background: #FFFBEF !important;
      position: relative !important;
      overflow: hidden !important;
    }
    @media (min-width: 441px) {
      body.calendar-page .app-frame {
        height: 956px !important;
        border-radius: 28px !important;
        box-shadow: 0 12px 40px rgba(0,0,0,0.12) !important;
      }
    }
    /* 뒤로가기·기분 기록·오늘 하루 어떠셨나요? 색상 = main.jsp 기억해, 봄과 동일 */
    .app-frame .food-screen .back-btn,
    .app-frame .food-header .back-btn {
      position: static !important;
      background: none !important;
      padding: 0 !important;
      border: none !important;
      box-shadow: none !important;
      font-size: 26px !important;
      color: #574444 !important;
      text-decoration: none !important;
      cursor: pointer !important;
    }
    .app-frame .food-screen .food-title {
      font-size: 55px !important;
      font-weight: 700 !important;
      color: #574444 !important;
      line-height: 1.2 !important;
      font-family: 'Dunggeunmo', sans-serif !important;
    }
    /* 오늘 하루 어떠셨나요? 위치 = 식사 화면 안내문과 동일 */
    .app-frame .food-screen .food-instruction {
      font-size: 30px !important;
      color: #574444 !important;
      line-height: 1.5 !important;
      margin-top: 14px !important;
      padding: 0 24px 28px !important;
      font-family: 'Dunggeunmo', sans-serif !important;
    }
    /* 기분 버튼 영역 = main.jsp card-grid와 동일한 크기·위치, 간격만 축소 */
    .mood-btns {
      position: relative !important;
      z-index: 1 !important;
      display: grid !important;
      grid-template-columns: 1fr 1fr !important;
      gap: 4px !important;
      padding: 5px 24px 24px !important;
    }
    .mood-btns .card.card-bg {
      aspect-ratio: 1 !important;
      min-height: 140px !important;
      background-color: transparent !important;
      background-size: contain !important;
      background-repeat: no-repeat !important;
      background-position: center !important;
      border: none !important;
      outline: none !important;
      box-shadow: none !important;
      cursor: pointer !important;
      display: block !important;
      position: relative !important;
      padding: 0 !important;
    }
    /* 기분 버튼 텍스트 위치 */
    .mood-btns .card-bg-text {
      position: absolute !important;
      top: 25px !important;
      left: 25px !important;
      display: block !important;
      font-size: 30px !important;
      font-weight: 700 !important;
      line-height: 1.2 !important;
      color: #7A4B3A !important;
      pointer-events: none !important;
    }
    /* 달력 보기 = main.jsp 보고서.png와 동일 구조 */
    .calendar-page .report-area {
      padding: 0 24px 100px !important;
      margin-top: -6px !important;
      position: relative !important;
      z-index: 1 !important;
    }
    .calendar-page .report-btn {
      display: block !important;
      width: 100% !important;
      min-height: 100px !important;
      aspect-ratio: 4 / 1 !important;
      background-color: transparent !important;
      background-size: contain !important;
      background-repeat: no-repeat !important;
      background-position: center !important;
      border: none !important;
      outline: none !important;
      box-shadow: none !important;
      cursor: pointer !important;
      text-decoration: none !important;
    }
    .calendar-page .report-btn .card-bg-text {
      top: 45% !important;
      left: 50% !important;
      transform: translate(-50%, -50%) !important;
      font-size: 30px !important;
      font-weight: 700 !important;
      color: #7A4B3A !important;
    }
  </style>
</head>
<body class="calendar-page">

<div class="app-frame">

  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg1">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg2">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

  <div class="food-screen">
    <div class="food-header">
      <a href="<%= ctx %>/active/main.jsp" class="back-btn" aria-label="뒤로">◀</a>
      <h2 class="food-title">기분 기록</h2>
    </div>
    <p class="food-instruction">오늘 하루 어떠셨나요?</p>

    <div class="mood-btns">
      <button type="button" class="card card-bg" aria-label="기쁨" data-mood="joy"
        style="background-image: url('<%= ctx %>/assets/images/calender/기쁨.png');">
        <span class="card-bg-text">기쁨</span>
      </button>
      <button type="button" class="card card-bg" aria-label="슬픔" data-mood="sad"
        style="background-image: url('<%= ctx %>/assets/images/calender/슬품.png');">
        <span class="card-bg-text">슬픔</span>
      </button>
      <button type="button" class="card card-bg" aria-label="아픔" data-mood="pain"
        style="background-image: url('<%= ctx %>/assets/images/calender/아픔.png');">
        <span class="card-bg-text">아픔</span>
      </button>
      <button type="button" class="card card-bg" aria-label="화남" data-mood="angry"
        style="background-image: url('<%= ctx %>/assets/images/calender/화남.png');">
        <span class="card-bg-text">화남</span>
      </button>
      <button type="button" class="card card-bg" aria-label="피곤" data-mood="tired"
        style="background-image: url('<%= ctx %>/assets/images/calender/피곤.png');">
        <span class="card-bg-text">피곤</span>
      </button>
      <button type="button" class="card card-bg" aria-label="평범" data-mood="normal"
        style="background-image: url('<%= ctx %>/assets/images/calender/평범.png');">
        <span class="card-bg-text">평범</span>
      </button>
    </div>

    <div class="report-area">
      <a href="<%= ctx %>/active/CalendarServlet" class="card card-bg report-btn"
        style="background-image: url('<%= ctx %>/assets/images/main01/보고서.png');">
        <span class="card-bg-text">달력 보기</span>
      </a>
    </div>
  </div>

  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">

</div>

<script>
(function() {
  var ctx = '<%= ctx %>';
  document.querySelectorAll('.mood-btns .card.card-bg').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var mood = this.getAttribute('data-mood');
      var label = this.getAttribute('aria-label');
      var emojiMap = { joy: '😊', sad: '😢', pain: '😣', angry: '😠', tired: '😴', normal: '😐' };
      var emoji = emojiMap[mood] || '😐';
      var today = new Date();
      var dateStr = today.getFullYear() + '-' + String(today.getMonth() + 1).padStart(2, '0') + '-' + String(today.getDate()).padStart(2, '0');
      var moodData = JSON.parse(localStorage.getItem('moodData')) || [];
      var idx = moodData.findIndex(function(r) { return r.date === dateStr; });
      var record = { date: dateStr, mood: mood, emoji: emoji };
      if (idx >= 0) moodData[idx] = record; else moodData.push(record);
      localStorage.setItem('moodData', JSON.stringify(moodData));
      var moodTypeMap = { joy: 'Mood_happy', sad: 'Mood_sad', pain: 'Mood_anxious', angry: 'Mood_angry', tired: 'Mood_tired', normal: 'Mood_neutral' };
      var eventType = moodTypeMap[mood] || 'Mood_neutral';
      var timeStr = today.getHours() + ':' + String(today.getMinutes()).padStart(2, '0');
      fetch(ctx + '/active/saveLog', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: 'type=' + encodeURIComponent(eventType) + '&time=' + encodeURIComponent(timeStr)
      }).catch(function() {});
      location.href = ctx + '/active/CalendarServlet';
    });
  });
})();
</script>
</body>
</html>

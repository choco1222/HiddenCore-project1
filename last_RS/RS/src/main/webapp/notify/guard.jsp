<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>기억해, 봄 - 보호자</title>
<link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/main01/flower%201.png">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/active.css">
<style>
  /* 보호자 메인화면 목업 전용 */
  .app-frame { background: #FDF5EC; }
  #guard-home .guard-summary-card {
    position: relative;
    z-index: 2;
    background: #fff;
    border-radius: 24px;
    padding: 24px 20px;
    margin: 0 24px 24px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.08);
  }
  .guard-summary-title {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 20px;
    font-weight: 700;
    color: #574444;
    margin-bottom: 12px;
  }
  .guard-summary-title .doc-icon {
    width: 24px;
    height: 24px;
    object-fit: contain;
  }
  .guard-summary-date {
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 15px;
    color: #574444;
    margin-bottom: 20px;
  }
  .guard-summary-date .cal-icon {
    width: 20px;
    height: 20px;
    object-fit: contain;
  }
  .guard-record-list { list-style: none; }
  .guard-record-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 0;
    font-size: 16px;
    color: #574444;
    border-bottom: 1px solid rgba(87,68,68,0.08);
  }
  .guard-record-item:last-child { border-bottom: none; }
  .guard-record-item .item-icon {
    width: 24px;
    height: 24px;
    object-fit: contain;
    flex-shrink: 0;
  }
  .guard-record-item .item-label { font-weight: 500; min-width: 48px; }
  .guard-record-item .item-value { font-weight: 700; }
  .guard-record-item .item-muted { color: #8b8682; font-weight: 400; font-size: 14px; }
  .guard-actions {
    display: flex;
    gap: 12px;
    margin-top: 24px;
  }
  .guard-actions button {
    flex: 1;
    padding: 14px 20px;
    border-radius: 16px;
    border: none;
    cursor: pointer;
    font-weight: 700;
    font-size: 16px;
    font-family: 'Dunggeunmo', sans-serif;
  }
  .guard-btn-refresh { background: #111827; color: #fff; }
  /* 헤더(기억해 봄 ~ 날짜) 포함 전체 100px 아래에서 시작 */
  #guard-home { padding-top: 100px; }
  /* guard 전용 헤더 위치 미세 조정: 위로 20px, 오른쪽으로 15px */
  #guard-home .header {
    position: relative;
    top: -20px;
    left: 15px;
  }
  /* 상단메뉴.png 버튼만 왼쪽으로 이동 */
  #guard-home .menu-btn {
    transform: translateX(-30px);
  }
</style>
</head>
<body>

<div class="app-frame">
  <!-- 하단 풀 (main.jsp와 동일) -->
  <img src="${pageContext.request.contextPath}/assets/images/main01/풀.png" alt="" class="grass">

  <!-- ================= 보호자 메인 (목업 구조 = main.jsp 헤더 + 오늘 기록 요약 카드) ================= -->
  <div id="guard-home" class="screen active">
    <header class="header">
      <div class="title-row">
        <div class="logo-circle">
          <img src="${pageContext.request.contextPath}/assets/images/main01/flower%201.png" alt="">
        </div>
        <span class="title-text">기억해, 봄</span>
        <button type="button" class="menu-btn" onclick="showScreen('mypage')" aria-label="메뉴">
          <img src="${pageContext.request.contextPath}/assets/images/main01/상단%20메뉴.png" alt="" class="menu-img">
        </button>
      </div>
      <p class="greeting">
        <span id="guard-user-name">${userName}</span> 보호자님, 안녕하세요!
      </p>
      <p id="guard-live-date" class="date-text"></p>
    </header>

    <!-- 오늘 기록 요약 카드 (목업: 흰 카드, 문서 아이콘 + 제목, 캘린더 + 대시, 리스트) -->
    <div class="guard-summary-card">
      <div class="guard-summary-title">
        <span class="doc-icon" style="font-size:22px;">📋</span>
        <span>오늘 기록 요약</span>
      </div>
      <div class="guard-summary-date">
        <span>📅</span>
        <span id="live-date">-</span>
      </div>
      <ul class="guard-record-list">
        <li class="guard-record-item">
          <img src="${pageContext.request.contextPath}/assets/images/mainnext/breakfast.png" alt="" class="item-icon">
          <span class="item-label">아침:</span>
          <span class="item-value"><span id="live-breakfast">0</span>회</span>
          <span class="item-muted">(마지막 <span id="live-breakfast-time">--:--</span>)</span>
        </li>
        <li class="guard-record-item">
          <img src="${pageContext.request.contextPath}/assets/images/mainnext/lunch.png" alt="" class="item-icon">
          <span class="item-label">점심:</span>
          <span class="item-value"><span id="live-lunch">0</span>회</span>
          <span class="item-muted">(마지막 <span id="live-lunch-time">--:--</span>)</span>
        </li>
        <li class="guard-record-item">
          <img src="${pageContext.request.contextPath}/assets/images/mainnext/dinner.png" alt="" class="item-icon">
          <span class="item-label">저녁:</span>
          <span class="item-value"><span id="live-dinner">0</span>회</span>
          <span class="item-muted">(마지막 <span id="live-dinner-time">--:--</span>)</span>
        </li>
        <li class="guard-record-item">
          <span class="item-icon">💊</span>
          <span class="item-label">복약:</span>
          <span class="item-value"><span id="live-drug">0</span>회</span>
          <span class="item-muted">(마지막 <span id="live-drug-time">--:--</span>)</span>
        </li>
        <li class="guard-record-item">
          <span class="item-icon">😊</span>
          <span class="item-label">기분:</span>
          <span class="item-value"><span id="live-mood">-</span></span>
        </li>
        <li class="guard-record-item">
          <img src="${pageContext.request.contextPath}/assets/images/main01/게임.png" alt="" class="item-icon" style="width:22px;height:22px;">
          <span class="item-label">게임:</span>
          <span class="item-value"><span id="live-game">0</span>회</span>
        </li>
      </ul>
      <div class="guard-actions">
        <button id="guard-refresh-btn" class="guard-btn-refresh" type="button">새로고침</button>
      </div>
    </div>

    <!-- 보고서 버튼: main.jsp와 동일 (배경 PNG + 기억 보기 텍스트) -->
    <div class="report-area">
      <button type="button" class="card card-bg report-btn"
        style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/보고서.png');"
        onclick="location.href=(window.CTX||'')+'/report/reportMain.jsp?from=guard'">
        <span class="card-bg-text">기억 보기</span>
      </button>
    </div>
  </div>

  <!-- 마이페이지 (main.jsp와 동일 구조) -->
  <div id="mypage" class="screen">
    <div class="mypage-box">
      <h2 class="mypage-box-title">마이페이지 준비 중</h2>
      <p class="mypage-box-desc">현재 기능을 개발하고 있습니다.<br>곧 더 멋진 모습으로 찾아올게요!</p>
      <button type="button" class="mypage-box-btn" onclick="showScreen('home')">홈으로 돌아가기</button>
    </div>
  </div>
</div>

<%
Object linked = session.getAttribute("linkedPatientId");
Object me = session.getAttribute("userId");
%>
<script>
  window.CTX = "<%=request.getContextPath()%>";
  window.userId = <%= (linked != null ? linked.toString() : "null") %>;
  console.log("[guard] me=", <%= (me!=null?me.toString():"null") %>, "linked=", window.userId);

  function showScreen(id) {
    var targetId = id === 'home' ? 'guard-home' : id;
    document.querySelectorAll('.screen').forEach(function(el) { el.classList.remove('active'); });
    var el = document.getElementById(targetId);
    if (el) el.classList.add('active');
  }
</script>

<script>
document.addEventListener("DOMContentLoaded", function() {
  var now = new Date();
  var opts = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
  var dateStr = now.toLocaleDateString('ko-KR', opts);
  var el = document.getElementById('guard-live-date');
  if (el) el.textContent = dateStr;
  var liveDateEl = document.getElementById('live-date');
  if (liveDateEl && liveDateEl.textContent === '-') liveDateEl.textContent = dateStr;
});
</script>

<script src="${pageContext.request.contextPath}/assets/js/liveboard.js"></script>
<script>
(function() {
  function onRefreshClick() {
    console.log('[guard] 새로고침 버튼 클릭');
    var btn = document.getElementById('guard-refresh-btn');
    if (!btn) {
      console.error('[guard] 새로고침 버튼을 찾을 수 없음');
      return;
    }
    if (!window.LiveBoard || typeof window.LiveBoard.loadDaily !== 'function') {
      console.error('[guard] LiveBoard.loadDaily가 없음');
      return;
    }
    console.log('[guard] userId:', window.userId);
    btn.disabled = true;
    btn.textContent = '새로고침 중...';
    window.LiveBoard.loadDaily()
      .then(function() {
        console.log('[guard] 새로고침 성공');
      })
      .catch(function(err) {
        console.error('[guard] 새로고침 실패:', err);
      })
      .finally(function() {
        btn.disabled = false;
        btn.textContent = '새로고침';
      });
  }
  document.addEventListener("DOMContentLoaded", function() {
    console.log('[guard] DOMContentLoaded - LiveBoard 초기화');
    var btn = document.getElementById('guard-refresh-btn');
    if (btn) {
      console.log('[guard] 새로고침 버튼 이벤트 등록');
      btn.addEventListener('click', onRefreshClick);
    } else {
      console.error('[guard] 새로고침 버튼을 찾을 수 없음');
    }
    if (window.LiveBoard && typeof window.LiveBoard.loadDaily === 'function') {
      console.log('[guard] 최초 데이터 로드 시작');
      window.LiveBoard.loadDaily();
    } else {
      console.error('[guard] LiveBoard가 초기화되지 않음');
    }
  });
})();
</script>

</body>
</html>

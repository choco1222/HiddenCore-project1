<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>기억해, 봄</title>
<link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/main01/flower%201.png">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/active.css">
</head>
<body>

<div class="app-frame">

    <!-- 배경 벡터 (main01) -->
    <img src="${pageContext.request.contextPath}/assets/images/main01/Vector.png" alt="" class="bg bg1">
    <img src="${pageContext.request.contextPath}/assets/images/main01/Vector1.png" alt="" class="bg bg2">
    <!-- Vector.png: 외출·게임 버튼 뒤쪽 배경 -->
    <img src="${pageContext.request.contextPath}/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
    <!-- Vector1.png: 식사 버튼 뒤쪽 배경 -->
    <img src="${pageContext.request.contextPath}/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

    <!-- ================= 메인 화면 ================= -->
    <div id="home" class="screen active">

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
                <span id="user-id-display">${userName}</span>님, 안녕하세요!
            </p>
            <p id="live-date" class="date-text"></p>
        </header>

        <!-- 카드 영역: 버튼 배경 = PNG, 텍스트만 오버레이 (식사와 동일 구조) -->
        <div class="card-grid">
            <button type="button" class="card card-bg" onclick="showScreen('food')"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/식사.png');">
                <span class="card-bg-text">식사</span>
            </button>
            <button type="button" class="card card-bg" onclick="handleMedicineClick()"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/알약.png');">
                <span class="card-bg-text">알약</span>
            </button>
            <button type="button" class="card card-bg" onclick="showScreen('outing')"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/양치.png');">
                <span class="card-bg-text">양치</span>
            </button>
            <button type="button" class="card card-bg" onclick="showScreen('bathroom')"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/외출.png');">
                <span class="card-bg-text">외출</span>
            </button>
            <button type="button" class="card card-bg"
                onclick="location.href=(window.CTX||'')+'/active/calendar.jsp'"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/기분.png');">
                <span class="card-bg-text">기분</span>
            </button>
            <button type="button" class="card card-bg"
                onclick="location.href=(window.CTX||'')+'/game/game_main.jsp'"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/게임.png');">
                <span class="card-bg-text">게임</span>
            </button>
        </div>

        <!-- 기억 보기: 다른 버튼과 동일 구조(배경 PNG + 텍스트 오버레이) -->
        <div class="report-area">
            <button type="button" class="card card-bg report-btn"
                style="background-image: url('${pageContext.request.contextPath}/assets/images/main01/보고서.png');"
                onclick="location.href=(window.CTX||'')+'/report/reportMain.jsp?from=main'">
                <span class="card-bg-text">기억 보기</span>
            </button>
        </div>

    </div>

    <!-- ================= 기존 기능 화면들 (원본 유지) ================= -->

    <!-- 식사 (디자인: 헤더 + 안내문 + 아침/점심/저녁 카드, mainnext 아이콘) -->
    <div id="food" class="screen food-screen">
        <div class="food-header">
            <button class="back-btn" onclick="showScreen('home')"><svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24"><path fill="#574444" d="M16 6a1 1 0 0 0-1.6-.8l-8 6a1 1 0 0 0 0 1.6l8 6A1 1 0 0 0 16 18z"/></svg></button>
            <h2 class="food-title">식사</h2>
        </div>
        <p class="food-instruction">식사를 마친 후,<br>"식사 체크" 버튼을 눌러주세요.</p>

        <div class="meal-cards">
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/breakfast.png" alt="" class="meal-icon meal-icon--breakfast">
                <h3>아침 식사</h3>
                <button id="breakfast-btn" class="meal-check-btn" onclick="checkItem('breakfast-btn')">체크하기</button>
            </div>
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/lunch.png" alt="" class="meal-icon meal-icon--lunch">
                <h3>점심 식사</h3>
                <button id="lunch-btn" class="meal-check-btn" onclick="checkItem('lunch-btn')">체크하기</button>
            </div>
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/dinner.png" alt="" class="meal-icon meal-icon--dinner">
                <h3>저녁 식사</h3>
                <button id="dinner-btn" class="meal-check-btn" onclick="checkItem('dinner-btn')">체크하기</button>
            </div>
        </div>
        <!-- 식사 화면 하단 풀 (메인과 동일 배경) -->
        <img src="${pageContext.request.contextPath}/assets/images/main01/풀.png" alt="" class="grass food-grass">
    </div>

    <!-- 양치 (식사 페이지와 동일 구조, 나중에 텍스트만 변경) -->
    <div id="outing" class="screen food-screen">
        <div class="food-header">
            <button class="back-btn" onclick="showScreen('home')"><svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24"><path fill="#574444" d="M16 6a1 1 0 0 0-1.6-.8l-8 6a1 1 0 0 0 0 1.6l8 6A1 1 0 0 0 16 18z"/></svg></button>
            <h2 class="food-title">양치</h2>
        </div>
        <p class="food-instruction">양치는 잊지 않으셨나요?<br>양치 시간을 기록해주세요.</p>

        <div class="meal-cards">
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/breakfast.png" alt="" class="meal-icon meal-icon--breakfast">
                <h3>아침 양치</h3>
                <button id="brush-breakfast-btn" class="meal-check-btn" onclick="checkItem('brush-breakfast-btn')">체크하기</button>
            </div>
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/lunch.png" alt="" class="meal-icon meal-icon--lunch">
                <h3>점심 양치</h3>
                <button id="brush-lunch-btn" class="meal-check-btn" onclick="checkItem('brush-lunch-btn')">체크하기</button>
            </div>
            <div class="meal-card">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/dinner.png" alt="" class="meal-icon meal-icon--dinner">
                <h3>저녁 양치</h3>
                <button id="brush-dinner-btn" class="meal-check-btn" onclick="checkItem('brush-dinner-btn')">체크하기</button>
            </div>
        </div>
        <img src="${pageContext.request.contextPath}/assets/images/main01/풀.png" alt="" class="grass food-grass">
    </div>

    <!-- 외출/복귀 (목업: 외출복귀(외출).png 기준, mainnext/외출.png 사용) -->
    <div id="bathroom" class="screen outing-screen">
        <div class="outing-header">
            <button class="back-btn" onclick="showScreen('home')"><svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24"><path fill="#574444" d="M16 6a1 1 0 0 0-1.6-.8l-8 6a1 1 0 0 0 0 1.6l8 6A1 1 0 0 0 16 18z"/></svg></button>
            <h2 class="outing-title">외출/복귀</h2>
        </div>
        <p class="outing-info">외출하시나요?<br>가스불, 전등불, 나가실 때 문단속<br>한번 더 확인해주세요.</p>

        <div class="outing-card-wrap">
        <div id="status-card" class="outing-card">
            <div class="outing-icon-wrap">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/외출.png" alt="" class="outing-icon outing-icon--out">
                <img src="${pageContext.request.contextPath}/assets/images/mainnext/복귀.png" alt="" class="outing-icon outing-icon--return">
            </div>
            <span id="status-text" class="outing-home-label">집</span>
            <p id="outing-time" class="outing-return-time">귀가 시간: 오후 06:10</p>
            <button type="button" class="outing-btn" id="outing-toggle-btn" onclick="toggleOuting()">외출하기</button>
        </div>
        </div>
        <img src="${pageContext.request.contextPath}/assets/images/main01/풀.png" alt="" class="grass food-grass">
    </div>

    <!-- 기분 -->
    <div id="record" class="screen">
        <div class="sub-header">
            <button class="back-btn" onclick="showScreen('home')"><svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 24 24"><path fill="#574444" d="M16 6a1 1 0 0 0-1.6-.8l-8 6a1 1 0 0 0 0 1.6l8 6A1 1 0 0 0 16 18z"/></svg></button>
            <h2>오늘 기분</h2>
        </div>
    </div>

    <!-- 마이페이지 (guard.jsp와 동일) -->
    <div id="mypage" class="screen">
        <div class="mypage-box">
            <h2 class="mypage-box-title">마이페이지 준비 중</h2>
            <p class="mypage-box-desc">현재 기능을 개발하고 있습니다.<br>곧 더 멋진 모습으로 찾아올게요!</p>
            <button type="button" class="mypage-box-btn" onclick="showScreen('home')">홈으로 돌아가기</button>
        </div>
    </div>

    <!-- 하단 풀 (main01) -->
    <img src="${pageContext.request.contextPath}/assets/images/main01/풀.png" alt="" class="grass">

</div>

<!-- ================= 약 복용 팝업 (원본 기능 복구) ================= -->
<!-- 알약 전용 팝업 (동일 스타일) -->
<div id="med-popup"
 style="display:none; position:fixed; top:50%; left:50%;
 transform:translate(-50%,-50%);
 background:rgba(0,0,0,0.85); color:white;
 padding:25px 50px; border-radius:50px;
 font-size:1.3rem; font-weight:bold; z-index:9999;">
 💊 약을 복용하셨습니다!
</div>

<!-- 식사/양치/외출 알림용 팝업 (알약과 동일 스타일) -->
<div id="toast-popup"
 style="display:none; position:fixed; top:50%; left:50%;
 transform:translate(-50%,-50%);
 background:rgba(0,0,0,0.85); color:white;
 padding:25px 50px; border-radius:50px;
 font-size:1.3rem; font-weight:bold; z-index:9999;">
 <span id="toast-popup-text"></span>
</div>



<script>
    // 1. 서버 경로 설정
    window.contextPath = '<%=request.getContextPath()%>';
    window.CTX = "${pageContext.request.contextPath}";
    
   
</script>

   <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>

   <!-- 0️⃣ userId 주입 -->
   <script>
    window.userId = '<%=(session.getAttribute("userId") != null) ? session.getAttribute("userId") : "101"%>';
    console.log("현재 접속 유저 ID (int):", window.userId);
</script>



   <!-- 1️⃣ Alarm 로드 -->
   <script src="<%=request.getContextPath()%>/assets/js/alarmScheduler.js"></script>

   <!-- 2️⃣ 페이지 로드시 자동 실행 -->
   <script>
document.addEventListener("DOMContentLoaded", async () => {

// ✅ userId 없으면 테스트용 (실서비스면 제거)
if (!window.userId) {
 console.warn("⚠️ userId 없음 → 테스트용 userId=101 사용");
 window.userId = 101;
}

// Alarm 초기화
Alarm.init({
 ctx: "<%=request.getContextPath()%>",
 debug: true,
 retryMinutes: 30,     // 30분 (0.1667분)
 pillRetryMinutes: 30 // 30분 테스트할때는 0.1667 10초
});

// 브라우저 알림 미지원
if (!("Notification" in window)) {
 console.warn("[Alarm] Notification 미지원 브라우저");
 return;
}

// ✅ 이미 허용된 경우 → 즉시 시작
if (Notification.permission === "granted") {
 console.log("[Alarm] permission granted → start()");
 Alarm.start(window.userId);
 return;
}

// ⚠️ 아직 물어본 적 없는 경우 → 자동 요청 시도
if (Notification.permission === "default") {
 try {
   const p = await Notification.requestPermission();
   console.log("[Alarm] permission result:", p);

   if (p === "granted") {
     Alarm.start(window.userId);
   } else {
     console.warn("[Alarm] permission not granted");
   }
 } catch (e) {
   // ❗ 여기로 오면 "사용자 제스처 필요"에 막힌 것
   console.warn("[Alarm] requestPermission blocked by browser policy");
 }
 return;
}

// ❌ 차단된 경우
if (Notification.permission === "denied") {
 console.warn("[Alarm] Notification permission denied");
}
});
</script>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const dateEl = document.getElementById('live-date');
    const today = new Date();
    const days = ['일','월','화','수','목','금','토'];
    dateEl.innerText =
        today.getFullYear() + "년 " +
        String(today.getMonth()+1).padStart(2,'0') + "월 " +
        String(today.getDate()).padStart(2,'0') + "일 (" +
        days[today.getDay()] + ")";
});
</script>
<script>
function showToast(msg) {
    var el = document.getElementById('toast-popup');
    var textEl = document.getElementById('toast-popup-text');
    if (el && textEl) {
        textEl.textContent = msg || '';
        el.style.display = 'block';
        setTimeout(function() { el.style.display = 'none'; }, 1200);
    }
}
function handleMedicineClick() {
    const popup = document.getElementById('med-popup');
    popup.style.display = 'block';
    setTimeout(() => popup.style.display = 'none', 1200);

    const timeString = new Date().toLocaleTimeString("ko-KR", {
        hour: "2-digit",
        minute: "2-digit",
        hour12: true
    });

    const ctx = window.contextPath || "";
    const uId = window.userId;

    fetch(`${ctx}/RS/active/saveLog`, {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "type=Med_Taking&time=" +
              encodeURIComponent(timeString) +
              "&userId=" + uId
    });
}
</script>
</body>
</html>

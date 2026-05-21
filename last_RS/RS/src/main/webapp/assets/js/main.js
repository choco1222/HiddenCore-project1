// [1] 변수 및 유틸리티 선언 (맨 위에서 딱 한 번만!)
if (typeof getToday === 'undefined') {
    var getToday = () => new Date().toISOString().split('T')[0];
}

if (typeof storage === 'undefined') {
    var storage = {
        set: (key, val) => localStorage.setItem(key, JSON.stringify(val)),
        get: (key) => JSON.parse(localStorage.getItem(key)) || []
    };
}

// [2] 서버 전송 함수
function sendToServer(type, time, userId = window.userId) {
  let eventName = (type || "").length > 30 ? type.substring(0, 30) : (type || "");
  const ctx = window.CTX || window.contextPath || "";
  const url = ctx + "/active/saveLog";

  console.log("🔍 [sendToServer] 요청 정보:");
  console.log("  - CTX:", window.CTX);
  console.log("  - contextPath:", window.contextPath);
  console.log("  - 최종 URL:", url);
  console.log("  - type:", eventName);
  console.log("  - userId:", userId);

  fetch(url, {
    method: "POST",
    credentials: "same-origin",
    headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
    body:
      `type=${encodeURIComponent(eventName)}` +
      `&time=${encodeURIComponent(time || "")}` +
      `&userId=${encodeURIComponent(userId ?? "")}` +
      `&user_id=${encodeURIComponent(userId ?? "")}`
  })
  .then(async (res) => {
    const txt = await res.text().catch(() => "");
    console.log("[saveLog] 응답:", res.status, txt);
    if (!res.ok) {
      console.error("❌ HTTP 에러:", res.status, res.statusText);
      console.error("❌ 응답 내용:", txt);
      throw new Error("HTTP " + res.status);
    }
  })
  .catch((err) => {
    console.error("❌ 전송 실패:", err);
    console.error("❌ 에러 상세:", err.message, err.stack);
  });
}


// [3] 나머지 함수들 (checkItem, toggleOuting 등은 그대로 두시면 됩니다)
function checkItem(buttonId) {
    const today = getToday();
    const btn = document.getElementById(buttonId);
    if (!btn) return;

    const checkedItems = storage.get('checkedItems');
    const existingEntry = checkedItems.find(item => item.date === today && item.id === buttonId);

    if (existingEntry) {
        if (typeof showToast === 'function') showToast('[' + existingEntry.time + ']에 이미 완료하셨습니다! 😊');
        else alert('[' + existingEntry.time + ']에 이미 완료하셨습니다! 😊');
        return;
    }

    const now = new Date();
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    const typeMapping = {
        'breakfast-btn': 'Meal_breakfast', 'lunch-btn': 'Meal_lunch', 'dinner-btn': 'Meal_dinner',
        'medicine-morning-btn': 'Med_morning', 'medicine-noon-btn': 'Med_lunch', 'medicine-evening-btn': 'Med_dinner',
        'outing-morning-btn': 'Brush_morning', 'outing-noon-btn': 'Brush_lunch', 'outing-evening-btn': 'Brush_dinner',
        'brush-breakfast-btn': 'Brush_breakfast', 'brush-lunch-btn': 'Brush_lunch', 'brush-dinner-btn': 'Brush_dinner'
    };

    const koMapping = {
        'breakfast-btn': '식사', 'lunch-btn': '식사', 'dinner-btn': '식사',
        'medicine-morning-btn': '복약', 'medicine-noon-btn': '복약', 'medicine-evening-btn': '복약',
        'outing-morning-btn': '양치', 'outing-noon-btn': '양치', 'outing-evening-btn': '양치',
        'brush-breakfast-btn': '양치', 'brush-lunch-btn': '양치', 'brush-dinner-btn': '양치'
    };

    const englishType = typeMapping[buttonId] || buttonId;
    const koreanName = koMapping[buttonId] || "기록";

    checkedItems.push({ date: today, id: buttonId, time: timeString });
    storage.set('checkedItems', checkedItems);
    sendToServer(englishType, timeString);

    btn.classList.add('checked');
    if (typeof showToast === 'function') showToast('[' + timeString + '] ' + koreanName + ' 기록이 완료되었습니다!');
    else alert('[' + timeString + '] ' + koreanName + ' 기록이 완료되었습니다!');
}

// ... (toggleOuting, checkMood, showScreen 등 아래 함수들은 주신 그대로 사용)

// 외출/복귀 토글
function toggleOuting() {
    const statusCard = document.getElementById('status-card');
    const statusText = document.getElementById('status-text');
    const outingBtn = document.getElementById('outing-toggle-btn');
    const outingTime = document.getElementById('outing-time');
    const now = new Date();
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    if (!statusCard.classList.contains('out')) {
        statusCard.classList.add('out');
        statusText.innerText = "외출 중";
        outingBtn.innerText = "집에 도착";
        outingTime.innerText = `출발 시간: ${timeString}`;
        sendToServer("Outing_start", timeString);
        if (typeof showToast === 'function') showToast('[' + timeString + '] 외출 기록이 완료되었습니다! 🚶');
        else alert('[' + timeString + '] 외출 기록이 완료되었습니다! 🚶');
    } else {
        statusCard.classList.remove('out');
        statusText.innerText = "집";
        outingBtn.innerText = "외출하기";
        outingTime.innerText = `귀가 시간: ${timeString}`;
        sendToServer("Outing_return", timeString);
        if (typeof showToast === 'function') showToast('[' + timeString + '] 귀가 기록이 완료되었습니다! 🏠');
        else alert('[' + timeString + '] 귀가 기록이 완료되었습니다! 🏠');
    }
}

// 기분 체크 후 캘린더 이동
function checkMood(moodName, emoji) {
    const now = new Date();
    const today = now.toISOString().split('T')[0];
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    let moodData = storage.get('moodData');
    moodData = moodData.filter(item => item.date !== today);
    moodData.push({ date: today, mood: moodName, emoji: emoji, time: timeString });
    storage.set('moodData', moodData);

    const moodMapping = { '기쁨': 'Mood_happy', '평범': 'Mood_neutral', '슬픔': 'Mood_sad', '화남': 'Mood_angry', '피곤': 'Mood_tired', '불안': 'Mood_anxious' };
    sendToServer(moodMapping[moodName] || moodName, timeString);

    alert(`[${timeString}] 기분 기록 완료!`);
    location.href = (window.contextPath || window.CTX || "") + "/active/CalendarServlet";
}

function updateDate() {
    const now = new Date();
    const dateOptions = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
    const dateString = now.toLocaleDateString('ko-KR', dateOptions);
    const liveDateElement = document.getElementById('live-date');
    if (liveDateElement) liveDateElement.innerText = dateString;
}
updateDate();

function showScreen(screenId) {
    const screens = document.querySelectorAll('.screen');
    screens.forEach(s => s.classList.remove('active'));
    const target = document.getElementById(screenId);
    if (target) target.classList.add('active');
}

function resetData() {
    if (confirm("오늘의 기록을 모두 삭제하고 초기화할까요?")) {
        localStorage.clear();
        location.reload();
    }
}
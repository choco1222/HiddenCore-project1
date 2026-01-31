// [1] 날짜 및 저장 유틸리티
const getToday = () => new Date().toISOString().split('T')[0];

// 로컬 저장소 유틸 (브라우저 새로고침 시 UI 유지용)
const storage = {
    set: (key, val) => localStorage.setItem(key, JSON.stringify(val)),
    get: (key) => JSON.parse(localStorage.getItem(key)) || []
};

// [자바 연결 핵심 함수] 서버로 데이터 전송
function sendToServer(type, time) {
    fetch('/remember_Spring/saveLog' ,{  
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body: `type=${encodeURIComponent(type)}&time=${encodeURIComponent(time)}`
    })
    .then(response => {
        if (!response.ok) throw new Error('서버 응답 에러 (상태코드: ' + response.status + ')');
        console.log(`✅ 서버 저장 완료: ${type}`);
    })
    .catch(error => {
        console.error('❌ 서버 전송 실패:', error);
    });
}

// [3] 식사, 약, 양치 체크 기능 (수정됨)
function checkItem(buttonId) {
    const today = getToday();
    const btn = document.getElementById(buttonId);
    const checkedItems = storage.get('checkedItems');

    const existingEntry = checkedItems.find(item => item.date === today && item.id === buttonId);

    if (existingEntry) {
        const itemName = btn.innerText.replace('✓', '').trim();
        alert(`[${existingEntry.time}]에 ${itemName} 완료하셨습니다! 😊`);
        return;
    }

    const now = new Date();
    const timeString = now.toLocaleTimeString('ko-KR', { 
        hour: '2-digit', minute: '2-digit', hour12: true 
    });

    // 1. 로컬 저장 (UI 유지용)
    checkedItems.push({ date: today, id: buttonId, time: timeString });
    storage.set('checkedItems', checkedItems);

    // 2. ★자바 서버로 전송 (DB 저장용)★
    const itemName = btn.innerText.replace('✓', '').trim();
    sendToServer(itemName, timeString);

    btn.classList.add('checked');
    alert(`[${timeString}] 기록이 완료되었습니다.`);
}


// [5] 외출/복귀 토글 기능
function toggleOuting() {
    const statusCard = document.getElementById('status-card');
    const statusText = document.getElementById('status-text');
    const statusIcon = document.getElementById('status-icon');
    const outingBtn = document.getElementById('outing-toggle-btn');
    const outingTime = document.getElementById('outing-time');

    const now = new Date();
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    if (!statusCard.classList.contains('out')) {
        // 외출 상태로 변경
        statusCard.classList.add('out');
        statusText.innerText = "외출 중";
        statusIcon.innerText = "🚶";
        outingBtn.innerText = "집에 도착";
        outingBtn.classList.add('return');
        outingTime.innerText = `출발 시간: ${timeString}`;
        sendToServer("외출 시작", timeString);
    } else {
        // 복귀 상태로 변경
        statusCard.classList.remove('out');
        statusText.innerText = "집";
        statusIcon.innerText = "🏠";
        outingBtn.innerText = "외출하기";
        outingBtn.classList.remove('return');
        outingTime.innerText = `귀가 시간: ${timeString}`;
        sendToServer("귀가 완료", timeString);
    }
}

// [6] 데이터 초기화 (임시 기능)
function resetData() {
    if (confirm("오늘의 모든 기록을 초기화할까요?")) {
        localStorage.removeItem('checkedItems');
        localStorage.removeItem('moodData');
        location.reload(); // 새로고침하여 상태 반영
    }
}
// [기분 기록 함수 수정]
function checkMood(moodName, emoji) {
    const today = getToday();
    let moodData = JSON.parse(localStorage.getItem('moodData')) || [];
    const alreadyDone = moodData.find(item => item.date === today);

    if (alreadyDone) {
        alert(`이미 오늘 기분을 [${alreadyDone.mood} ${alreadyDone.emoji}]라고 기록하셨습니다!`);
        return;
    }

    const now = new Date();
    const time = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    // 1. 로컬 저장
    moodData.push({ date: today, mood: moodName, emoji: emoji, time: time });
    localStorage.setItem('moodData', JSON.stringify(moodData));

    // 2. ★자바 서버로 전송★
    sendToServer(`기분:${moodName}`, time);

    alert(`[${time}] 오늘의 기분(${moodName})이 잘 기록되었습니다!`);
}

// ------------------------------------------------------------------------------------------------------------------------------//

function updateDate() {
    const now = new Date();
    const dateOptions = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
    const dateString = now.toLocaleDateString('ko-KR', dateOptions);
    const liveDateElement = document.getElementById('live-date');
    if(liveDateElement) liveDateElement.innerText = dateString;
}
updateDate();

// [화면 전환 함수] 버튼 클릭 시 해당 화면만 보여줌
function showScreen(screenId) {
    // 1. 모든 화면(.screen)을 찾아 숨깁니다.
    const screens = document.querySelectorAll('.screen');
    screens.forEach(screen => {
        screen.classList.remove('active');
    });

    // 2. 클릭한 버튼에 해당하는 화면(id)만 찾아서 보여줍니다.
    const targetScreen = document.getElementById(screenId);
    if (targetScreen) {
        targetScreen.classList.add('active');
    } else {
        console.error("해당 화면을 찾을 수 없습니다: " + screenId);
    }
}









// 삭제할 코드

// [데이터 초기화] - index.jsp 4번 소스 관련
function resetData() {
    if (confirm("오늘의 기록을 모두 삭제하고 초기화할까요?")) {
        localStorage.clear();
        location.reload();
    }
}
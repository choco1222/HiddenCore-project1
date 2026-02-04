let isMedActive = false;
let isMedSuccess = false;
// [1] 날짜 및 저장 유틸리티
const getToday = () => new Date().toISOString().split('T')[0];

// 로컬 저장소 유틸 (브라우저 새로고침 시 UI 유지용)
const storage = {
	set: (key, val) => localStorage.setItem(key, JSON.stringify(val)),
	get: (key) => JSON.parse(localStorage.getItem(key)) || []
};

// [자바 연결 핵심 함수] 서버로 데이터 전송
// [수정된 전송 함수] userId 매개변수 추가
function sendToServer(type, time, userId = "guest") { // 기본값 guest
    fetch('/remember_Spring/saveLog', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        // ★ body에 userId를 추가해서 보냅니다!
        body: `type=${encodeURIComponent(type)}&time=${encodeURIComponent(time)}&userId=${encodeURIComponent(userId)}`
    })
    .then(response => {
        if (!response.ok) throw new Error('서버 응답 에러');
        console.log(`✅ 서버 저장 완료: ${type} (유저: ${userId})`);
    })
    .catch(error => console.error('❌ 서버 전송 실패:', error));
}

// [3] 식사, 약, 양치 체크 기능 (알림에 시간 추가)
function checkItem(buttonId) {
    const today = getToday();
    const btn = document.getElementById(buttonId);
    if (!btn) return;

    const checkedItems = storage.get('checkedItems');
    const existingEntry = checkedItems.find(item => item.date === today && item.id === buttonId);

    if (existingEntry) {
        alert(`[${existingEntry.time}]에 이미 완료하셨습니다! 😊`);
        return;
    }

    const now = new Date();
    // 오전/오후가 표시되는 시간 형식
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    // 1. SQL 저장용 영문 매핑
    const typeMapping = {
        'breakfast-btn': 'Meal_breakfast',
        'lunch-btn': 'Meal_lunch',
        'dinner-btn': 'Meal_dinner',
        'medicine-morning-btn': 'Med_morning',
        'medicine-noon-btn': 'Med_lunch',
        'medicine-evening-btn': 'Med_dinner',
        'outing-morning-btn': 'Brush_morning', 
        'outing-noon-btn': 'Brush_lunch',
        'outing-evening-btn': 'Brush_dinner'
    };

    // 2. 사용자 알림용 한글 매핑
    const koMapping = {
        'breakfast-btn': '식사',
        'lunch-btn': '식사',
        'dinner-btn': '식사',
        'medicine-morning-btn': '복약',
        'medicine-noon-btn': '복약',
        'medicine-evening-btn': '복약',
        'brush-morning-btn': '양치',
        'brush-lunch-btn': '양치',
        'brush-dinner-btn': '양치'
    };

	// [A] 식사 버튼 클릭 시 감시 타이머 가동
// [A] 식사 버튼 클릭 시 감시 타이머 가동
const mealButtons = ['breakfast-btn', 'lunch-btn', 'dinner-btn'];
if (mealButtons.includes(buttonId)) {
    isMedActive = false; 
    isMedSuccess = false; 
    const mealType = buttonId.split('-')[0]; 

    // 1단계: 30분 대기
    setTimeout(() => {
        isMedActive = true; 
        alert(`🔔 식사 후 30분 경과! 10분 내로 약을 복용하세요.`);

        // 2단계: 10분 감시 시작
        setTimeout(() => {
            // [수정 포인트] 성공이면 "0", 실패면 "1"
            const finalValue = isMedSuccess ? "0" : "1"; 
            const finalType = isMedSuccess ? `MED_TRUE_${mealType}` : `MED_FALSE_${mealType}`;
            
            // 서버(SQL)로 전송
            sendToServer(finalType, finalValue); 
            
            console.log(`감시 종료. 결과: ${finalType}, 보낸 값: ${finalValue}`);
            isMedActive = false; 
        }, 600000); // 10분

    }, 1800000); // 30분
}

// [B] 약 버튼 클릭 시 '성공'으로 기록 변경
if (buttonId.includes('medicine')) {
    if (isMedActive) {
        isMedSuccess = true;
    }
}
	
    const englishType = typeMapping[buttonId] || buttonId;
    const koreanName = koMapping[buttonId] || "기록";

    // 데이터 저장 및 전송
    checkedItems.push({ date: today, id: buttonId, time: timeString });
    storage.set('checkedItems', checkedItems);
    sendToServer(englishType, timeString);

    btn.classList.add('checked');
    // ★ 알림창에 시간(timeString)이 나오도록 수정했습니다.
    alert(`[${timeString}] ${koreanName} 기록이 완료되었습니다!`);
    
    
    
    
}

// [5] 외출/복귀 토글 기능 (영문 전송 버전)
function toggleOuting() {
	const statusCard = document.getElementById('status-card');
	const statusText = document.getElementById('status-text');
	const outingBtn = document.getElementById('outing-toggle-btn');
	const outingTime = document.getElementById('outing-time');

	const now = new Date();
	const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

	if (!statusCard.classList.contains('out')) {
		// 외출 상태로 변경 (SQL에는 OUTING_start 전송)
		statusCard.classList.add('out');
		statusText.innerText = "외출 중";
		outingBtn.innerText = "집에 도착";
		outingTime.innerText = `출발 시간: ${timeString}`;
		
        sendToServer("OUTING_start", timeString);
        alert(`[${timeString}] 외출 기록이 완료되었습니다! 안전히 다녀오세요. 🚶`);
	} else {
		// 복귀 상태로 변경 (SQL에는 OUTING_return 전송)
		statusCard.classList.remove('out');
		statusText.innerText = "집";
		outingBtn.innerText = "외출하기";
		outingTime.innerText = `귀가 시간: ${timeString}`;
		
        sendToServer("OUTING_return", timeString);
        alert(`[${timeString}] 귀가 기록이 완료되었습니다! 고생하셨습니다. 🏠`);
        
        
        
	}
}

// [5] 외출/복귀 토글 기능 (영문 매핑 및 시간 알림 추가)
function toggleOuting() {
	const statusCard = document.getElementById('status-card');
	const statusText = document.getElementById('status-text');
	const outingBtn = document.getElementById('outing-toggle-btn');
	const outingTime = document.getElementById('outing-time');

	const now = new Date();
	// 알림창과 화면 표시용 시간 (오전/오후 포함)
	const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

	if (!statusCard.classList.contains('out')) {
		// 1. 외출 상태로 변경
		statusCard.classList.add('out');
		statusText.innerText = "외출 중";
		outingBtn.innerText = "집에 도착";
		outingTime.innerText = `출발 시간: ${timeString}`;
		
        // ★ 서버에는 영어로 전송 ★
        sendToServer("Outing_start", timeString);
        
        // ★ 사용자에게는 한글과 시간 알림 ★
        alert(`[${timeString}] 외출 기록이 완료되었습니다! 조심히 다녀오세요. 🚶`);
	} else {
		// 2. 복귀 상태로 변경
		statusCard.classList.remove('out');
		statusText.innerText = "집";
		outingBtn.innerText = "외출하기";
		outingTime.innerText = `귀가 시간: ${timeString}`;
		
        // ★ 서버에는 영어로 전송 ★
        sendToServer("Outing_return", timeString);
        
        // ★ 사용자에게는 한글과 시간 알림 ★
        alert(`[${timeString}] 귀가 기록이 완료되었습니다! 고생하셨습니다. 🏠`);
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
// [기분 기록 함수] - 서버는 영어로, 알림은 한글+시간으로!
function checkMood(moodName, emoji) {
    const now = new Date();
    const today = now.toISOString().split('T')[0];
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    let moodData = JSON.parse(localStorage.getItem('moodData')) || [];
    
    // [살짝 추가] 오늘 날짜 기록이 이미 있으면 지우기 (중복 방지 핵심)
    moodData = moodData.filter(item => item.date !== today);

    moodData.push({ date: today, mood: moodName, emoji: emoji, time: timeString });
    localStorage.setItem('moodData', JSON.stringify(moodData));

    const moodMapping = { '기쁨': 'Mood_happy', '평범': 'Mood_neutral', '슬픔': 'Mood_sad', '화남': 'Mood_angry', '피곤': 'Mood_tired', '불안': 'Mood_anxious' };
    sendToServer(moodMapping[moodName] || moodName, timeString);

    alert(`[${timeString}] 기록 완료!`);
    
    // [수정] 404 방지용 상대 경로 (가장 안전함) **위치확인
   location.href = ../../../../controller/CalendarServlet";; 
}
// ------------------------------------------------------------------------------------------------------------------------------//
// ★ 파일명이 아니라 서블릿을 호출해야 함!
   
function updateDate() {
	const now = new Date();
	const dateOptions = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' };
	const dateString = now.toLocaleDateString('ko-KR', dateOptions);
	const liveDateElement = document.getElementById('live-date');
	if (liveDateElement) liveDateElement.innerText = dateString;
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


function sendLog(type) {
	const currentHour = new Date().getHours();
	console.log("현재 시간(시): " + currentHour); // F12 콘솔창에 뜹니다.
	console.log("보내는 타입: " + type);

	if (type === '기분') {
		if (currentHour < 18) {
			alert("지금은 " + currentHour + "시입니다. 18시 이후에만 가능해요!");
			return;
		}
	}

	// 서버 전송 부분 (URL과 파라미터 이름을 꼭 확인하세요!)
	fetch('saveLog?type=' + type, { method: 'POST' })
		.then(response => {
			if (response.ok) alert(type + " 기록 완료!");
			else alert("서버 저장 실패!");
		});
}


// 페이지 로드 시 실행되는 함수
window.onload = function() {
    fetch('getUser') // GET 방식은 기본값이므로 추가 설정 없이 호출 가능
        .then(response => response.text()) // 글자 그대로 받기
        .then(userName => {
            // 화면 상단에 이름이 들어갈 요소가 있다고 가정 (예: <span id="user-name"></span>)
            const nameElement = document.getElementById('user-name');
            if (nameElement) {
                nameElement.innerText = userName + "님";
            }
            console.log("접속 유저: " + userName);
        })
        .catch(error => console.error('이름 불러오기 실패:', error));
};

window.onload = function() {
    fetch('../../../../controller/GetUser') // 경로 확인!
        .then(response => response.text())
        .then(userName => {
            // index.jsp에 있는 id 이름과 똑같이 맞춰야 함!
            const nameElement = document.getElementById('user-id-display');
            if (nameElement) {
                nameElement.innerText = userName; // '님'은 html에 있으니 이름만 넣기
            }
            console.log("접속 유저: " + userName);
        })
        .catch(error => console.error('이름 불러오기 실패:', error));
};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// 삭제할 코드

// [데이터 초기화] - index.jsp 4번 소스 관련
function resetData() {
	if (confirm("오늘의 기록을 모두 삭제하고 초기화할까요?")) {
		localStorage.clear();
		location.reload();
	}
}
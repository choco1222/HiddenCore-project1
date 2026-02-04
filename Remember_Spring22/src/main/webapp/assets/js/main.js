// [1] 날짜 및 저장 유틸리티
const getToday = () => new Date().toISOString().split('T')[0];

// 로컬 저장소 유틸 (브라우저 새로고침 시 UI 유지용)
const storage = {
	set: (key, val) => localStorage.setItem(key, JSON.stringify(val)),
	get: (key) => JSON.parse(localStorage.getItem(key)) || []
};

// [자바 연결 핵심 함수] 서버로 데이터 전송
function sendToServer(type, time) {
	fetch('/remember_Spring/saveLog', {
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


	if (buttonId === 'breakfast-btn') {
        isMedActive = false; // 아직은 감시 구간 아님
        isMedSuccess = false;

        setTimeout(() => {
            // 30분 경과 시점: 이제부터 10분간 감시 시작
            isMedActive = true; 
            
            // 10분(600000ms) 뒤에 최종 결과 확인 및 서버 전송
            setTimeout(() => {
                const finalResult = isMedSuccess; // 10분 동안 눌렀으면 true, 아니면 false
                sendToServer(finalResult ? "MED_TRUE" : "MED_FALSE", new Date().toLocaleTimeString());
                isMedActive = false; // 감시 종료
            }, 600000); 

        }, 1800000); // 30분 대기
    }

    // 2. 약 버튼 클릭 시: '감시 구간' 안에서 눌렀을 때만 success를 true로 변경
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
	const today = getToday();
	let moodData = JSON.parse(localStorage.getItem('moodData')) || [];
	const alreadyDone = moodData.find(item => item.date === today);

	if (alreadyDone) {
		alert(`이미 오늘 기분을 [${alreadyDone.mood} ${alreadyDone.emoji}]라고 기록하셨습니다!`);
		return;
	}

	const now = new Date();
	const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

	// --- ★ 기분 영문 매핑 테이블 ★ ---
	const moodMapping = {
		'기쁨': 'Mood_happy',
		'평범': 'Mood_neutral',
		'슬픔': 'Mood_sad',
		'화남': 'Mood_angry',
		'피곤': 'Mood_tired',
		'불안': 'Mood_anxious'
	};

	// 매핑된 영문 값이 없으면 기본값으로 전송
	const englishMood = moodMapping[moodName] || `MOOD_${moodName}`;

	// 1. 로컬 저장 (UI 유지용은 한글로 유지)
	moodData.push({ date: today, mood: moodName, emoji: emoji, time: timeString });
	localStorage.setItem('moodData', JSON.stringify(moodData));

	// 2. ★ 서버로는 영어 전송 ★
	sendToServer(englishMood, timeString);

	// 3. 알림 및 화면 이동
	alert(`[${timeString}] 오늘의 기분(${moodName} ${emoji})이 기록되었습니다!`);
	
	if (typeof showScreen === 'function') {
		showScreen('emergency'); // 기록 후 달력/분석 화면으로 이동
	}
}
// ------------------------------------------------------------------------------------------------------------------------------//

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


// 기분 기록 후 달력에 표시하기 위한 예시 로직
function renderCalendar(moodData) {
    // moodData는 [{date: '2026-02-03', mood: 'MOOD_happy'}, ...] 형태
    moodData.forEach(item => {
        const dateDay = item.date.split('-')[2]; // '03' 추출
        const cell = document.querySelector(`.calendar-cell[data-date="${dateDay}"]`);
        
        if (cell) {
            // 해당 날짜 칸에 이모지 추가
            const emojiSpan = document.createElement('span');
            emojiSpan.innerText = getEmoji(item.mood); // MOOD_happy -> 😊
            cell.appendChild(emojiSpan);
        }
    });
}








function checkMood(moodName, emoji) {
    const today = getToday(); // yyyy-mm-dd
    const now = new Date();
    const day = now.getDate(); // 오늘 날짜 (숫자)
    const timeString = now.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', hour12: true });

    // 1. 영문 매핑 (DB 저장용)
    const moodMapping = {
        '기쁨': 'Mood_happy',
        '평범': 'Mood_neutral',
        '슬픔': 'Mood_sad',
        '화남': 'Mood_angry',
        '피곤': 'Mood_tired'
    };
    const englishMood = moodMapping[moodName] || `MOOD_${moodName}`;

    // 2. 서버 전송
    sendToServer(englishMood, timeString);

    // 3. 로컬 저장 (달력에 즉시 반영하기 위함)
    let moodData = JSON.parse(localStorage.getItem('moodData')) || [];
    moodData.push({ date: today, mood: englishMood, emoji: emoji, time: timeString, korName: moodName });
    localStorage.setItem('moodData', JSON.stringify(moodData));

    alert(`[${timeString}] 오늘의 기분(${moodName})이 기록되었습니다!`);

    // 4. 달력 화면으로 이동
    showScreen('calendar-screen'); 

    // 5. ★ 중요: 방금 저장한 데이터를 포함해서 달력을 새로 그림
    renderCalendar(); 
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




// 삭제할 코드

// [데이터 초기화] - index.jsp 4번 소스 관련
function resetData() {
	if (confirm("오늘의 기록을 모두 삭제하고 초기화할까요?")) {
		localStorage.clear();
		location.reload();
	}
}
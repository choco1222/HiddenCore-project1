// Survey navigation
let currentSection = 1;
const totalSections = 4;

// Canvas for clock drawing
let canvas, ctx, isDrawing = false;

// 랜덤 설문 데이터
let correctWords = [];  // 정답 단어
let clockTime = '';     // 시계 시간 (5분 단위)

// 단어 풀 (25개)
const wordPool = [
    '비행기', '자동차', '기차', '버스', '배',
    '연필', '지우개', '공책', '볼펜', '가위',
    '소나무', '은행나무', '단풍나무', '백합', '장미',
    '사과', '바나나', '포도', '딸기', '수박',
    '강아지', '고양이', '토끼', '호랑이', '코끼리'
];

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeSurvey();  // 설문 초기화 (랜덤 생성)
    initializeCanvas();
    updateProgress();
    startTimer();
});

/**
 * ============= 문제 제출 =============
 * 설문 초기화 - 랜덤 단어 및 시계 시간 생성
 * 1. 랜덤 단어 3개 선택
 * 2. 랜덤 시간 생성(5분)
 * 3. UI 업데이트
 */
function initializeSurvey() {
    correctWords = getRandomWords(3);
    console.log('=== 설문 초기화 ===');
    console.log('정답 단어:', correctWords);
    
    clockTime = getRandomClockTime();
    console.log('시계 시간:', clockTime);
    
    updateWordDisplay();
    updateClockQuestion();
}

/**
 * 랜덤 단어 3개 선택
 */
function getRandomWords(count) {
    const shuffled = [...wordPool].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, count);
}

/**
 * 랜덤 시계 시간 생성 (5분 단위)
 */
function getRandomClockTime() {
	let hours, minutes, angle = 0;
	
	while(angle < 30){
    hours = Math.floor(Math.random() * 12) + 1;
    minutes = Math.floor(Math.random() * 12) * 5;
	
	const hourAngle = ((hours % 12) * 30 + (minutes % 60) * 0.5) % 360;
	const minuteAngle = (minutes * 6) % 360;
	angle = Math.abs(hourAngle - minuteAngle)
	if(angle > 180)
		angle = 360 - angle;
	}
	
    const minuteText = minutes === 0 ? '' : ' ' + minutes + '분';
    return hours + '시 ' + minuteText;
}

/**
 * Q1: 단어 표시 업데이트
 */
function updateWordDisplay() {
    const wordList = document.querySelector('#section1 .word-list');
    if (wordList) {
        wordList.innerHTML = correctWords.map(word => 
            `<span class="word-item">${word}</span>`
        ).join('');
    }
}

/**
 * Q3: 시계 문제 업데이트
 */
function updateClockQuestion() {
    const clockTitle = document.querySelector('#section3 .question-title');
    if (clockTitle) {
        clockTitle.textContent = `${clockTime}을(를) 나타내는 시계를 그려주세요`;
    }
}

/**
 * Q2, Q4: 선택지 생성 (정답 3개 + 오답 7개 = 10개)
 */
function generateWordOptions(sectionId) {
    // 정답이 아닌 단어들
    const wrongWords = wordPool.filter(word => !correctWords.includes(word));
    
    // 랜덤하게 7개 선택
    const shuffledWrong = wrongWords.sort(() => Math.random() - 0.5).slice(0, 7);
    
    // 정답 3개 + 오답 7개 = 총 10개, 섞기
    const allOptions = [...correctWords, ...shuffledWrong].sort(() => Math.random() - 0.5);
    
    const container = document.querySelector(`#${sectionId} .word-selection`);
    if (!container) return;
    
    // 기존 체크박스 name 확인
    const name = sectionId === 'section2' ? 'word1' : 'word2';
    
    container.innerHTML = allOptions.map(word => `
        <label class="word-option">
            <input type="checkbox" name="${name}" value="${word}" onchange="checkWordLimit('${name}')">
            <span class="word-label">${word}</span>
        </label>
    `).join('');
}

function startTimer() {
    let seconds = 3;
    const nextBtn = document.getElementById('nextBtn1');
    const timerText = document.getElementById('timerText');
    const nextText = document.getElementById('nextText');
    
    const timer = setInterval(() => {
        seconds--;
        
        if (seconds > 0) {
            timerText.textContent = `${seconds}초 후 다음으로 이동할 수 있습니다`;
        } else {
            clearInterval(timer);
            timerText.style.display = 'none';
            nextText.style.display = 'inline';
            nextBtn.disabled = false;
        }
    }, 1000);
}

function initializeCanvas() {
    canvas = document.getElementById('clockCanvas');
    if (!canvas) return;
    
    ctx = canvas.getContext('2d');
    ctx.lineCap = 'round';
    ctx.lineWidth = 3;
    ctx.strokeStyle = '#000';
    
    // Mouse events
    canvas.addEventListener('mousedown', startDrawing);
    canvas.addEventListener('mousemove', draw);
    canvas.addEventListener('mouseup', stopDrawing);
    canvas.addEventListener('mouseout', stopDrawing);
    
    // Touch events
    canvas.addEventListener('touchstart', handleTouchStart);
    canvas.addEventListener('touchmove', handleTouchMove);
    canvas.addEventListener('touchend', stopDrawing);
}

function startDrawing(e) {
    isDrawing = true;
    const pos = getCanvasPosition(e);
    ctx.beginPath();
    ctx.moveTo(pos.x, pos.y);
}

function draw(e) {
    if (!isDrawing) return;
    const pos = getCanvasPosition(e);
    ctx.lineTo(pos.x, pos.y);
    ctx.stroke();
}

function stopDrawing() {
    isDrawing = false;
}

function handleTouchStart(e) {
    e.preventDefault();
    const touch = e.touches[0];
    const mouseEvent = new MouseEvent('mousedown', {
        clientX: touch.clientX,
        clientY: touch.clientY
    });
    canvas.dispatchEvent(mouseEvent);
}

function handleTouchMove(e) {
    e.preventDefault();
    const touch = e.touches[0];
    const mouseEvent = new MouseEvent('mousemove', {
        clientX: touch.clientX,
        clientY: touch.clientY
    });
    canvas.dispatchEvent(mouseEvent);
}

function getCanvasPosition(e) {
    const rect = canvas.getBoundingClientRect();
    return {
        x: e.clientX - rect.left,
        y: e.clientY - rect.top
    };
}

function resetClock() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
}

function nextSection(current) {
    // Q2로 넘어갈 때 선택지 생성
    if (current === 1) {
        generateWordOptions('section2');
    }
    
    // Q4로 넘어갈 때 선택지 생성
    if (current === 3) {
        generateWordOptions('section4');
    }
    
    if (current === 2) {
        // 단어 선택 검증
        const checked = document.querySelectorAll('input[name="word1"]:checked');
        if (checked.length !== 3) {
            alert('세 개의 단어를 선택해 주세요.');
            return;
        }
    }
    
    if (current < totalSections) {
        document.getElementById('section' + current).classList.remove('active');
        currentSection = current + 1;
        document.getElementById('section' + currentSection).classList.add('active');
        updateProgress();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function prevSection(current) {
    if (current > 1) {
        document.getElementById('section' + current).classList.remove('active');
        currentSection = current - 1;
        document.getElementById('section' + currentSection).classList.add('active');
        updateProgress();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

function updateProgress() {
    const progress = (currentSection / totalSections) * 100;
    document.getElementById('progressBar').style.width = progress + '%';
}

function checkWordLimit(groupName) {
    const checkboxes = document.querySelectorAll(`input[name="${groupName}"]`);
    const checked = document.querySelectorAll(`input[name="${groupName}"]:checked`);
    
    if (checked.length >= 3) {
        checkboxes.forEach(cb => {
            if (!cb.checked) {
                cb.disabled = true;
            }
        });
    } else {
        checkboxes.forEach(cb => {
            cb.disabled = false;
        });
    }
}

function submitSurvey() {
    // Validation
    const checked = document.querySelectorAll('input[name="word2"]:checked');
    if (checked.length !== 3) {
        alert('세 개의 단어를 선택해 주세요.');
        return;
    }
    
    console.log('=== 설문 데이터 수집 시작 ===');
    
    // 시계 그림 분석 (클라이언트 측 예비 분석)
    const analyzer = new ClockDrawingAnalyzer(canvas);
    const clockScore = analyzer.getClockScore();
    
    console.log('클라이언트 예상 점수:', clockScore + '/2');
    console.log('(실제 점수는 서버에서 OpenCV로 결정됨)');
    
    // 설문 데이터 수집
    const surveyData = collectSurveyData(analyzer);
    
    // 서버로 전송
    saveSurveyToServer(surveyData);
}

/**
 * 설문 데이터 수집
 */
function collectSurveyData(analyzer) {
    // Q1: 정답 단어 (서버 검증용)
    const correctWordsStr = correctWords.join(',');
    
    // Q2: 첫 번째 선택한 단어
    const word1Checked = document.querySelectorAll('input[name="word1"]:checked');
    const word1 = Array.from(word1Checked).map(cb => cb.value).join(',');
    
    // Q3: 시계 그림 (Base64)
    const clockImage = analyzer.getImageData();
    
    // Q4: 회상한 단어
    const word2Checked = document.querySelectorAll('input[name="word2"]:checked');
    const word2 = Array.from(word2Checked).map(cb => cb.value).join(',');
    
    console.log('수집된 데이터:');
    console.log('- 정답 단어:', correctWordsStr);
    console.log('- 시계 시간:', clockTime);
    console.log('- Q2 선택 단어:', word1);
    console.log('- Q3 시계 이미지 크기:', clockImage.length);
    console.log('- Q4 회상 단어:', word2);
    
    return {
        correctWords: correctWordsStr,
        clockTime: clockTime,
        word1: word1,
        clockImage: clockImage,
        word2: word2
    };
}

/**
 * 서버로 설문 데이터 전송
 */
function saveSurveyToServer(surveyData) {
    console.log('\n서버로 데이터 전송 중...');
    
    // Context path 가져오기
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    
    fetch(contextPath + '/login/saveSurvey', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
            correctWords: surveyData.correctWords,
            clockTime: surveyData.clockTime,
            word1: surveyData.word1,
            clockImage: surveyData.clockImage,
            word2: surveyData.word2
        })
    })
    .then(response => response.json())
    .then(data => {
        console.log('서버 응답:', data);
        
        if (data.success) {
            console.log('✓ 설문 저장 성공');
            console.log('최종 점수:', data.score + '/' + data.maxScore);
            console.log('시계 점수:', data.clockScore + '/2');
            console.log('평가:', data.message);
            
            // 세션에 최종 점수 저장
            sessionStorage.setItem('finalScore', data.score);
            sessionStorage.setItem('finalClockScore', data.clockScore);
            sessionStorage.setItem('finalMessage', data.message);
            
            // 완료 화면으로 이동
            showCompletionScreen();
        } else {
            console.error('✗ 설문 저장 실패:', data.message);
            alert('설문 저장에 실패했습니다: ' + data.message);
        }
    })
    .catch(error => {
        console.error('✗ 서버 통신 오류:', error);
        alert('서버와의 통신에 실패했습니다. 다시 시도해주세요.');
    });
}

/**
 * 완료 화면 표시
 */
function showCompletionScreen() {
    document.getElementById('section' + currentSection).classList.remove('active');
    document.getElementById('completion').classList.add('active');
    document.getElementById('progressBar').style.width = '100%';
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function goToMemberComplete() {
    window.location.href = 'surveyComplete.jsp';
}

/**
 * 시계 그림 분석기 클래스
 */
class ClockDrawingAnalyzer {
    
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        this.centerX = this.width / 2;
        this.centerY = this.height / 2;
    }
    
    getClockScore() {
        const imageData = this.ctx.getImageData(0, 0, this.width, this.height);
        
        const complexity = this.calculateComplexity(imageData);
        console.log('복잡도:', complexity.toFixed(2) + '%');
        
        if (complexity < 2.0) {
            console.log('→ 너무 적게 그려짐');
            return 0;
        }
        
        const hasCircle = this.detectCirclePattern(imageData);
        console.log('원 탐지:', hasCircle ? '있음' : '없음');
        
        const hasLines = this.detectLinesFromCenter(imageData);
        console.log('선 탐지:', hasLines ? '있음' : '없음');
        
        if (hasCircle && hasLines) {
            console.log('→ 예상: 2점');
            return 2;
        } else if (hasCircle || hasLines) {
            console.log('→ 예상: 1점');
            return 1;
        } else {
            console.log('→ 예상: 0점');
            return 0;
        }
    }
    
    detectCirclePattern(imageData) {
        const data = imageData.data;
        let circlePixels = 0;
        const expectedRadius = Math.min(this.width, this.height) / 2.5;
        
        for (let angle = 0; angle < 360; angle += 10) {
            const rad = (angle * Math.PI) / 180;
            const x = Math.round(this.centerX + expectedRadius * Math.cos(rad));
            const y = Math.round(this.centerY + expectedRadius * Math.sin(rad));
            
            if (this.isPixelDrawn(data, x, y)) {
                circlePixels++;
            }
        }
        
        return circlePixels >= 18;
    }
    
    detectLinesFromCenter(imageData) {
        const data = imageData.data;
        let linesFound = 0;
        
        for (let angle = 0; angle < 360; angle += 30) {
            const rad = (angle * Math.PI) / 180;
            let hasLine = false;
            
            for (let r = 10; r < Math.min(this.width, this.height) / 3; r += 5) {
                const x = Math.round(this.centerX + r * Math.cos(rad));
                const y = Math.round(this.centerY + r * Math.sin(rad));
                
                if (this.isPixelDrawn(data, x, y)) {
                    hasLine = true;
                    break;
                }
            }
            
            if (hasLine) {
                linesFound++;
            }
        }
        
        return linesFound >= 2;
    }
    
    calculateComplexity(imageData) {
        const data = imageData.data;
        let drawnPixels = 0;
        
        for (let i = 0; i < data.length; i += 4) {
            const alpha = data[i + 3];
            const red = data[i];
            
            if (alpha > 0 && red < 250) {
                drawnPixels++;
            }
        }
        
        return (drawnPixels / (this.width * this.height)) * 100;
    }
    
    isPixelDrawn(data, x, y) {
        if (x < 0 || x >= this.width || y < 0 || y >= this.height) {
            return false;
        }
        
        const index = (y * this.width + x) * 4;
        const alpha = data[index + 3];
        const red = data[index];
        
        return alpha > 0 && red < 250;
    }
    
    getImageData() {
        return this.canvas.toDataURL('image/png');
    }
}
// Survey State
let currentSection = 1;
const totalSections = 4;
let timerInterval = null;

// Clock Drawing Variables
let canvas, ctx;
let isDrawing = false;
let clockInitialized = false;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    updateProgress();
    startTimer();
});

// Timer for first page (3 seconds)
function startTimer() {
    let timeLeft = 3;
    const nextBtn = document.getElementById('nextBtn1');
    const timerText = document.getElementById('timerText');
    const nextText = document.getElementById('nextText');
    
    timerInterval = setInterval(function() {
        timeLeft--;
        
        if (timeLeft > 0) {
            timerText.textContent = timeLeft + '초 후 다음으로 이동할 수 있습니다';
        } else {
            clearInterval(timerInterval);
            nextBtn.disabled = false;
            timerText.style.display = 'none';
            nextText.style.display = 'inline';
        }
    }, 1000);
}

// Check word selection limit
function checkWordLimit(groupName) {
    const checkboxes = document.querySelectorAll('input[name="' + groupName + '"]');
    const checked = document.querySelectorAll('input[name="' + groupName + '"]:checked');
    
    if (checked.length > 3) {
        // Find the last checked checkbox and uncheck it
        const lastChecked = checked[checked.length - 1];
        lastChecked.checked = false;
        
        alert('이 이상 선택할 수 없습니다.');
    }
}

// Navigation Functions
function nextSection(sectionNum) {
    // Validation
    if (sectionNum === 2) {
        const checked = document.querySelectorAll('input[name="word1"]:checked');
        if (checked.length !== 3) {
            alert('세 개의 단어를 선택해 주세요.');
            return;
        }
    }
    
    if (sectionNum === 4) {
        const checked = document.querySelectorAll('input[name="word2"]:checked');
        if (checked.length !== 3) {
            alert('세 개의 단어를 선택해 주세요.');
            return;
        }
    }
    
    // Hide current section
    document.getElementById('section' + currentSection).classList.remove('active');
    
    // Show next section
    currentSection++;
    if (currentSection <= totalSections) {
        document.getElementById('section' + currentSection).classList.add('active');
        updateProgress();
        window.scrollTo({ top: 0, behavior: 'smooth' });
        
        // Initialize clock when reaching section 3
        if (currentSection === 3 && !clockInitialized) {
            setTimeout(initializeClock, 100);
        }
    }
}

function prevSection(sectionNum) {
    // Hide current section
    document.getElementById('section' + currentSection).classList.remove('active');
    
    // Show previous section
    currentSection--;
    document.getElementById('section' + currentSection).classList.add('active');
    updateProgress();
    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function submitSurvey() {
    // Validation
    const checked = document.querySelectorAll('input[name="word2"]:checked');
    if (checked.length !== 3) {
        alert('세 개의 단어를 선택해 주세요.');
        return;
    }
    
    // Hide current section
    document.getElementById('section' + currentSection).classList.remove('active');
    
    // Show completion
    document.getElementById('completion').classList.add('active');
    
    // Update progress to 100%
    document.getElementById('progressBar').style.width = '100%';
    window.scrollTo({ top: 0, behavior: 'smooth' });
    
    // 설문 데이터 저장
    // collectSurveyData();
}

function goToMemberComplete() {
    window.location.href = 'surveyComplete.jsp';
}

function updateProgress() {
    const progress = (currentSection / totalSections) * 100;
    document.getElementById('progressBar').style.width = progress + '%';
}

function goToLogin() {
    // Redirect to login page
    // In a real application, this would be the actual login page URL
    window.location.href = 'login.jsp';
}

// Clock Drawing Functions
function initializeClock() {
    canvas = document.getElementById('clockCanvas');
    if (!canvas) {
        console.error('Canvas element not found');
        return;
    }
    
    ctx = canvas.getContext('2d');
    
    // Set canvas actual size (for drawing)
    canvas.width = 400;
    canvas.height = 400;
    
    drawClockFace();
    
    // Mouse events
    canvas.addEventListener('mousedown', startDrawing);
    canvas.addEventListener('mousemove', draw);
    canvas.addEventListener('mouseup', stopDrawing);
    canvas.addEventListener('mouseout', stopDrawing);
    
    // Touch events for mobile
    canvas.addEventListener('touchstart', handleTouchStart, { passive: false });
    canvas.addEventListener('touchmove', handleTouchMove, { passive: false });
    canvas.addEventListener('touchend', stopDrawing);
    
    clockInitialized = true;
}

function drawClockFace() {
    if (!ctx || !canvas) return;
    
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = Math.min(centerX, centerY) - 20;
    
    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Fill white background
    ctx.fillStyle = '#FFFFFF';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    
    // Draw clock circle
    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
    ctx.strokeStyle = '#2D3748';
    ctx.lineWidth = 3;
    ctx.stroke();
    
    // Draw numbers
    ctx.font = 'bold 28px "Noto Sans KR", sans-serif';
    ctx.fillStyle = '#2D3748';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    
    for (let i = 1; i <= 12; i++) {
        const angle = (i * 30 - 90) * Math.PI / 180;
        const x = centerX + (radius - 35) * Math.cos(angle);
        const y = centerY + (radius - 35) * Math.sin(angle);
        ctx.fillText(i.toString(), x, y);
    }
    
    // Draw center dot
    ctx.beginPath();
    ctx.arc(centerX, centerY, 6, 0, 2 * Math.PI);
    ctx.fillStyle = '#FFE66D';
    ctx.fill();
}

function startDrawing(e) {
    isDrawing = true;
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const x = (e.clientX - rect.left) * scaleX;
    const y = (e.clientY - rect.top) * scaleY;
    
    ctx.beginPath();
    ctx.moveTo(x, y);
}

function draw(e) {
    if (!isDrawing) return;
    
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const x = (e.clientX - rect.left) * scaleX;
    const y = (e.clientY - rect.top) * scaleY;
    
    ctx.lineTo(x, y);
    ctx.strokeStyle = '#2D3748';
    ctx.lineWidth = 5;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
}

function stopDrawing() {
    if (isDrawing) {
        isDrawing = false;
        ctx.closePath();
    }
}

function handleTouchStart(e) {
    e.preventDefault();
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const x = (touch.clientX - rect.left) * scaleX;
    const y = (touch.clientY - rect.top) * scaleY;
    
    isDrawing = true;
    ctx.beginPath();
    ctx.moveTo(x, y);
}

function handleTouchMove(e) {
    e.preventDefault();
    if (!isDrawing) return;
    
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    const scaleX = canvas.width / rect.width;
    const scaleY = canvas.height / rect.height;
    const x = (touch.clientX - rect.left) * scaleX;
    const y = (touch.clientY - rect.top) * scaleY;
    
    ctx.lineTo(x, y);
    ctx.strokeStyle = '#2D3748';
    ctx.lineWidth = 5;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.stroke();
}

function resetClock() {
    if (confirm('시계를 다시 그리시겠습니까?')) {
        drawClockFace();
    }
}

// Data Collection (for server submission)
function collectSurveyData() {
    const surveyData = {
        question1: ['비행기', '연필', '소나무'], // The words shown
        question2: Array.from(document.querySelectorAll('input[name="word1"]:checked')).map(cb => cb.value),
        question3: canvas.toDataURL(), // Clock drawing as base64 image
        question4: Array.from(document.querySelectorAll('input[name="word2"]:checked')).map(cb => cb.value),
        timestamp: new Date().toISOString()
    };
    
    console.log('Survey Data:', surveyData);
    
    // In a real application, you would send this to the server via AJAX
    // fetch('/api/survey/submit', {
    //     method: 'POST',
    //     headers: { 'Content-Type': 'application/json' },
    //     body: JSON.stringify(surveyData)
    // });
    
    return surveyData;
}

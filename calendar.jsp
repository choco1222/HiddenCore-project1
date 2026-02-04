<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>기억해, 봄 - 나의 기록 달력</title>
<link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css" rel="stylesheet">
<style>
    :root {
        --spring-bg: linear-gradient(135deg, #fff1eb 0%, #ace0f9 100%);
        --card-bg: #fffbf5;
        --primary-color: #ff9a9e;
        --secondary-color: #fad0c4;
        --accent-color: #a18cd1;
        --today-color: #b2e0d6;
        --text-color: #5a4a42;
    }

    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
        font-family: 'Pretendard', sans-serif;
        background: var(--spring-bg);
        min-height: 100vh;
        display: flex; justify-content: center; align-items: center; padding: 20px;
    }

    .calendar-container {
        background: var(--card-bg);
        border-radius: 35px;
        padding: 30px;
        box-shadow: 0 20px 50px rgba(255, 182, 193, 0.3);
        max-width: 500px; width: 100%; border: 3px solid #fff;
    }

    .calendar-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
    .calendar-title { font-size: 1.6em; color: var(--primary-color); font-weight: 800; }

    .nav-button {
        background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
        color: white; border: none; padding: 10px 20px; border-radius: 50px;
        cursor: pointer; font-weight: bold; font-size: 14px;
    }

    .calendar-grid { display: grid; grid-template-columns: repeat(7, 1fr); gap: 10px; }
    .day-header { text-align: center; font-weight: 700; color: #8d7b75; font-size: 13px; padding-bottom: 10px; }
    .sun { color: #ff7f7f; } .sat { color: #87ceeb; }

    .calendar-day {
        aspect-ratio: 1;
        background: #fff;
        border-radius: 18px; /* 둥근 사각형 느낌 */
        display: flex;
        flex-direction: column; /* 숫자와 이모지를 세로로 배치 */
        align-items: center;
        justify-content: flex-start; /* 숫자를 위쪽으로 */
        padding-top: 8px;
        cursor: pointer;
        transition: 0.2s;
        border: 2px solid transparent;
        position: relative;
    }

    .calendar-day:hover { transform: scale(1.05); background: #fff0f5; }
    
    /* 날짜 숫자 스타일 */
    .day-number { font-size: 14px; font-weight: 600; margin-bottom: 2px; }

    /* ★ 기분 이모지 스티커 스타일 ★ */
    .mood-sticker {
        font-size: 22px;
        line-height: 1;
        animation: popIn 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275); /* 나타날 때 톡 튀어나오는 효과 */
    }

    @keyframes popIn {
        0% { transform: scale(0); }
        100% { transform: scale(1); }
    }

    .calendar-day.today { background: var(--today-color); color: white; }
    .calendar-day.selected { border-color: var(--primary-color); background: #fff0f5; }
    .calendar-day.empty { background: transparent; cursor: default; }

    .btn-home {
        width: 100%; padding: 15px; margin-top: 25px; border: none;
        background: linear-gradient(135deg, var(--primary-color) 0%, var(--secondary-color) 100%);
        color: white; border-radius: 20px; font-weight: bold; cursor: pointer;
    }
</style>
</head>
<body>

<div class="calendar-container">
    <div class="calendar-header">
        <button class="nav-button" onclick="location.href='CalendarServlet?year=${prevYear}&month=${prevMonth}'">◀</button>
        <div class="calendar-title">${year}년 ${month}월</div>
        <button class="nav-button" onclick="location.href='CalendarServlet?year=${nextYear}&month=${nextMonth}'">▶</button>
    </div>

    <div class="calendar-grid">
        <div class="day-header sun">일</div><div class="day-header">월</div><div class="day-header">화</div>
        <div class="day-header">수</div><div class="day-header">목</div><div class="day-header">금</div><div class="day-header sat">토</div>
        
        <c:if test="${firstDayOfWeek > 1}">
            <c:forEach var="i" begin="1" end="${firstDayOfWeek - 1}"><div class="calendar-day empty"></div></c:forEach>
        </c:if>
        
        <c:forEach var="day" begin="1" end="${daysInMonth}">
            <c:set var="isToday" value="${year == todayYear && month == todayMonth && day == todayDay}" />
            <div class="calendar-day ${isToday ? 'today' : ''}" id="day-${day}" onclick="selectDay(${year}, ${month}, ${day})">
                <span class="day-number">${day}</span>
                </div>
        </c:forEach>
    </div>
    

<button class="btn-home" 
        onclick="location.href='${pageContext.request.contextPath}/jsp/index.jsp'" 
        style="width: 100%; padding: 15px; margin-top: 20px; background: #ff9a9e; color: white; border: none; border-radius: 15px; cursor: pointer; font-weight: bold;">
    메인 화면으로 돌아가기
</button></div>
 
<script>
    function selectDay(y, m, d) { 
        location.href = `CalendarServlet?year=\${y}&month=\${m}&day=\${d}`; 
    }

    // [핵심] 페이지 로드 시 로컬스토리지에서 기분 가져와서 넣기
    document.addEventListener('DOMContentLoaded', function() {
        const moodData = JSON.parse(localStorage.getItem('moodData')) || [];
        const currentYear = ${year};
        const currentMonth = ${month};

        moodData.forEach(record => {
            // record.date 형식: "2026-02-04"
            const [rYear, rMonth, rDay] = record.date.split('-').map(Number);
            
            // 현재 달력의 연/월과 일치하는 데이터만 표시
            if (rYear === currentYear && rMonth === currentMonth) {
                const targetDayBox = document.getElementById(`day-\${rDay}`);
                if (targetDayBox) {
                    // 이모지 스팬 생성
                    const emojiSpan = document.createElement('span');
                    emojiSpan.className = 'mood-sticker';
                    emojiSpan.innerText = record.emoji;
                    
                    targetDayBox.appendChild(emojiSpan);
                    
                    // 기록이 있는 날은 배경색을 살짝 변경 (선택사항)
                    if (!targetDayBox.classList.contains('today')) {
                        targetDayBox.style.background = '#fff9fb';
                        targetDayBox.style.borderColor = '#ffe4e1';
                    }
                }
            }
        });
    });
</script>
</body>
</html>
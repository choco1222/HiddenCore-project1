<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="../css/css.css">
	
</head>
<body>
    <div class="app-container">
        <!-- -------------------------------메인 화면------------------------------ -->

        <div id="home" class="screen active">
            <div class="header">
                <div class="header-top">
                    <div class="user-info">
                        <div class="user-icon">☀️</div>
                        <div class="">
                            <h2>기억해, 봄</h2>
                             <p> 000 님, 안녕하세요! 😄 </p>
                        </div>
                    </div>
                   
                      <button class="version-btn">마이페이지</button>
                    
                    <!--임시 -->
                      <button class="reset-btn" onclick="resetData()">
                     🔄 데이터 초기화
                    </button>
                    <!--임시 -->

                </div>
               <div class="date-container">
        <p id="live-date" class="font-800"></p>
                            </div>
            </div>

            <div class="button-grid">
                <button class="main-btn" onclick="showScreen('food')">식사 🍚 </button>
                <button class="main-btn" onclick="showScreen('medicine')">약 복용 💊</button>
                <button class="main-btn" onclick="showScreen('outing')">양치 🪥</button>
                <button class="main-btn" onclick="showScreen('bathroom')">외출/복귀 🚪</button>
                <button class="main-btn" onclick="showScreen('record')"> 오늘 기분 😊</button>
                <button class="main-btn" onclick="showScreen('game')">게임 🎯</button>
            </div>
            <button class="guardian-btn" onclick="showScreen('emergency')">분석 보고서</button>
        </div>
        <!-- -------------------------------식사------------------------------ -->

      <div id="food" class="screen">
    <div class="sub-header">
        <button class="back-btn" onclick="showScreen('home')">◀</button>
        <h2> 식사 🍚 </h2>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>아침</h3>
        </div>
        <button id="breakfast-btn" class="check-btn" onclick="checkItem('breakfast-btn')">식사 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>점심</h3>           
        </div>
        <button id="lunch-btn" class="check-btn" onclick="checkItem('lunch-btn')">식사 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>저녁</h3>
        </div>
        <button id="dinner-btn" class="check-btn" onclick="checkItem('dinner-btn')">식사 체크</button>
    </div>
</div>

      <!-- -------------------------------약------------------------------ -->

     
<div id="medicine" class="screen">
    <div class="sub-header">
        <button class="back-btn" onclick="showScreen('home')">◀</button>
        <h2>💊 약 복용</h2>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>아침 약</h3>
          
        </div>
        <button id="medicine-morning-btn" class="check-btn" onclick="checkItem('medicine-morning-btn')">복약 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>점심 약</h3>
        </div>
        <button id="medicine-noon-btn" class="check-btn"  onclick="checkItem('medicine-noon-btn')">복약 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>저녁 약</h3>
         
        </div>
        <button id="medicine-evening-btn" class="check-btn" onclick="checkItem('medicine-evening-btn')">복약 체크</button>
    </div>
</div>


    <!-- -------------------------------양치------------------------------ -->

      <div id="outing" class="screen">
    <div class="sub-header">
        <button class="back-btn" onclick="showScreen('home')">◀</button>
        <h2>양치 🪥</h2>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>아침 양치</h3>
        </div>
        <button id="outing-morning-btn" class="check-btn" onclick="checkItem('outing-morning-btn')">양치 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>점심 양치</h3>
        </div>
        <button id="outing-noon-btn" class="check-btn" onclick="checkItem('outing-noon-btn')">양치 체크</button>
    </div>

    <div class="check-card">
        <div class="check-card-header">
            <h3>양치</h3>
        </div>
        <button id="outing-evening-btn" class="check-btn" onclick="checkItem('outing-evening-btn')">양치 체크</button>
    </div>
</div>

     <!-- -------------------------------외출/복귀------------------------------ -->
         
<div id="bathroom" class="screen">
    <div class="sub-header">
        <button class="back-btn" onclick="showScreen('home')">◀</button>
        <h2>🚶 외출/복귀</h2>
    </div>

    <div id="status-card" class="status-card">
        <div class="icon" id="status-icon">🏠</div>
        <h3>현재 상태</h3>
        <p id="status-text">집</p>
        <p id="outing-time" style="font-size: 16px; color: #6b7280; margin-top: 10px;"></p>
    </div>

    <button id="outing-toggle-btn" class="action-btn" onclick="toggleOuting()">외출하기</button>
</div>



         <!-- -------------------------------오늘 기분------------------------------ -->
        <div id= "record" class = "screen">
            <div class = "sub-header">
           

            <button class="back-btn" onclick="showScreen('home')">◀</button>
                   <h2> 오늘 기분 😊</h2>
                   </div>
        <div class="record">
        <h3 class="record-title">오늘의 기분은 어떠세요?</h3>
        <div class="mood-grid">
            <button class="mood-btn" onclick="checkMood('기쁨', '😊')">
                <span class="mood-emoji">😊</span>
                <span class="mood-text">기쁨</span>
            </button>
            <button class="mood-btn" onclick="checkMood('평범', '😐')">
                <span class="mood-emoji">😐</span>
                <span class="mood-text">평범</span>
            </button>
            <button class="mood-btn" onclick="checkMood('슬픔', '😢')">
                <span class="mood-emoji">😢</span>
                <span class="mood-text">슬픔</span>
            </button>
            <button class="mood-btn" onclick="checkMood('화남', '😡')">
                <span class="mood-emoji">😡</span>
                <span class="mood-text">화남</span>
            </button>
            <button class="mood-btn" onclick="checkMood('피곤', '😴')">
                <span class="mood-emoji">😴</span>
                <span class="mood-text">피곤</span>
            </button>
            <button class="mood-btn" onclick="checkMood('불안', '😨')">
                <span class="mood-emoji">😨</span>
                <span class="mood-text">불안</span>
            </button>
        </div>
    </div>

</div>



         <!-- -------------------------------게임------------------------------ -->

        <div id="game" class="screen">
            <div class="sub-header">
                <button class="back-btn" onclick="showScreen('home')">◀</button>
                <h2>게임 🎮</h2>
            </div>
        </div>
      <!-- -------------------------------보호자 연결------------------------------ -->


      <div id="emergency" class="screen">
       
        </div>
    </div>
</div>

<script src="../js/jsjs.js"></script>

</body>
</html>
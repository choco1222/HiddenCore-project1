<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>같은 카드 찾기</title>
  <link rel="stylesheet" href="../assets/css/active.css" />
  <link rel="stylesheet" href="../assets/css/card.css" />
  <style>
    /* game_main.jsp 기준: body·프레임 동일 (card.css가 body padding/background 덮어쓰는 것 취소) */
    body.card-page {
      padding: 0 !important;
      margin: 0 !important;
      background: #FFDF7C !important;
      display: flex !important;
      justify-content: center !important;
      align-items: center !important;
      min-height: 100vh !important;
      font-family: 'Dunggeunmo', sans-serif !important;
    }
    body.card-page .app-frame {
      width: 100% !important;
      max-width: 440px !important;
      height: 100vh !important;
      max-height: 956px !important;
      min-height: 560px !important;
      background: #FFFBEF !important;
      position: relative !important;
      overflow: hidden !important;
    }
    @media (min-width: 441px) {
      body.card-page .app-frame {
        height: 956px !important;
        border-radius: 28px !important;
        box-shadow: 0 12px 40px rgba(0,0,0,0.12) !important;
      }
    }
    /* card.css의 .back-btn position:fixed 제거 → 프레임 안에 표시 (game_main.jsp와 동일) */
    .app-frame .food-screen .back-btn,
    .app-frame .food-header .back-btn {
      position: static !important;
      top: auto !important;
      left: auto !important;
      z-index: auto !important;
      background: none !important;
      padding: 0 !important;
      border-radius: 0 !important;
      box-shadow: none !important;
    }
    .app-frame .food-screen .back-btn a,
    .app-frame .food-header .back-btn a {
      background: none !important;
      padding: 0 !important;
      border-radius: 0 !important;
      box-shadow: none !important;
      font-size: 26px !important;
      color: #574444 !important;
    }
    .food-screen .back-btn { text-decoration: none; }
    /* game_main.jsp와 동일: 폰트(Dunggeunmo) + 제목·안내문 크기 (card.css 덮어쓰기) */
    .app-frame .food-screen,
    .app-frame .food-screen .food-header,
    .app-frame .food-screen .food-title,
    .app-frame .food-screen .food-instruction {
      font-family: 'Dunggeunmo', sans-serif;
    }
    .app-frame .food-screen .food-title {
      font-size: 55px;
      font-weight: 700;
      color: #574444;
      line-height: 1.2;
    }
    .app-frame .food-screen .food-instruction {
      font-size: 30px;
      color: #574444;
      line-height: 1.5;
      margin-top: 14px;
      padding: 0 24px 28px;
    }
    /* game_main.jsp 버튼 기준: 크기·위치 동일, 난이도 버튼 가운데 정렬·오른쪽 잘림 방지, 조금 왼쪽으로 */
    .app-frame .food-screen .game-btns-wrap {
      display: flex !important;
      flex-direction: column !important;
      align-items: center !important;
      width: 100% !important;
      box-sizing: border-box !important;
      transform: translateX(-6px) !important;
    }
    .app-frame .food-screen .game-btns {
      margin-top: 95px !important;
      padding: 0 24px 120px !important;
      display: flex !important;
      flex-direction: column !important;
      gap: 20px !important;
      position: relative !important;
      z-index: 1 !important;
      align-items: center !important;
      width: 100% !important;
      max-width: 100% !important;
      box-sizing: border-box !important;
    }
    .app-frame .food-screen .game-btns .card.card-bg {
      aspect-ratio: auto !important;
      width: 100% !important;
      max-width: 320px !important;
      height: 170px !important;
      min-height: 170px !important;
      margin: 0 auto !important;
      box-sizing: border-box !important;
      border-radius: 30px !important;
      background-color: transparent !important;
      background-size: contain !important;
      background-repeat: no-repeat !important;
      background-position: center !important;
      border: none !important;
      outline: none !important;
      box-shadow: none !important;
      cursor: pointer !important;
      display: block !important;
      position: relative !important;
    }
    .app-frame .food-screen .game-btns .card-bg-text {
      position: absolute !important;
      top: 50% !important;
      left: 50% !important;
      transform: translate(-50%, -50%) !important;
      font-size: 28px !important;
      font-weight: 700 !important;
      color: #574444 !important;
      line-height: 1.3 !important;
      pointer-events: none !important;
      display: flex !important;
      flex-direction: column !important;
      gap: 4px !important;
      align-items: center !important;
      text-align: center !important;
    }
    .app-frame .food-screen .game-btns .card-bg-line1,
    .app-frame .food-screen .game-btns .card-bg-line2 { display: block !important; }
    .app-frame .food-screen .game-btns .card-bg-line2 { white-space: nowrap !important; }
    /* 게임 플레이 영역: 프레임보다 조금 작게 (좌우 여백), 상 난이도 등 실행 창 왼쪽으로 */
    #gameScreen { position: relative; z-index: 1; padding: 24px; padding-bottom: 120px; margin-left: 8px; margin-right: 8px; box-sizing: border-box; transform: translateX(-14px); }
    #gameScreen.hidden { display: none !important; }
    #difficultyScreen.hidden { display: none !important; }
  </style>
</head>
<body class="card-page">

<div class="app-frame">

  <!-- 배경 벡터 (game_main.jsp와 동일) -->
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg1">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg2">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

  <!-- game_main.jsp와 동일 구조: food-header + food-instruction + game-btns (텍스트만 교체) -->
  <div class="food-screen">
    <div class="food-header">
      <a href="<%= ctx %>/game/game_main.jsp" class="back-btn" aria-label="뒤로">◀</a>
      <h2 class="food-title">같은 카드 찾기</h2>
    </div>
    <p class="food-instruction">같은 카드를 찾아주세요.</p>

    <div id="difficultyScreen" class="game-btns-wrap">
    <div class="game-btns">
      <button type="button" class="card card-bg" onclick="startGame('easy')" style="background-image: url('<%= ctx %>/assets/images/game/하.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">하(쉬움)</span>
          <span class="card-bg-line2">3X4(12장) 20초</span>
        </span>
      </button>
      <button type="button" class="card card-bg" onclick="startGame('medium')" style="background-image: url('<%= ctx %>/assets/images/game/중.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">중(보통)</span>
          <span class="card-bg-line2">4X4(16장) 30초</span>
        </span>
      </button>
      <button type="button" class="card card-bg" onclick="startGame('hard')" style="background-image: url('<%= ctx %>/assets/images/game/상.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">상(어려움)</span>
          <span class="card-bg-line2">4X5(20장) 40초</span>
        </span>
      </button>
    </div>
    </div>

  <!-- 게임 플레이 화면 (난이도 선택 후 표시) -->
  <div id="gameScreen" class="hidden">
    <div class="game-header">
      <div class="time" id="timeDisplay">시간: 0초</div>
    </div>
    <div id="grid" class="grid"></div>
    <div id="gameoverScreen" class="hidden gameover">
      <h2 id="resultText"></h2>
      <p id="finalScore"></p>
      <div class="gameover-buttons">
        <button class="btn btn-primary" onclick="restartGame()">다시하기</button>
        <button class="btn btn-secondary-small" onclick="resetGame()">메뉴로 돌아가기</button>
      </div>
    </div>
    <button id="quitBtn" class="btn btn-secondary" onclick="resetGame()">처음으로</button>
  </div>

  </div>
  <!-- /food-screen -->

  <!-- 하단 풀 (game_main.jsp와 동일) -->
  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">

</div>

<script>
  const CTX = "<%= ctx %>";
</script>
<script>
  var cards = [{value0: '', flipped0: false, matched0: false},
       {value1: '', flipped1: false, matched1: false},
       {value2: '', flipped2: false, matched2: false},
       {value3: '', flipped3: false, matched3: false},
       {value4: '', flipped4: false, matched4: false},
       {value5: '', flipped5: false, matched5: false},
       {value6: '', flipped6: false, matched6: false},
       {value7: '', flipped7: false, matched7: false},
       {value8: '', flipped8: false, matched8: false},
       {value9: '', flipped9: false, matched9: false},
       {value10: '', flipped10: false, matched10: false},
       {value11: '', flipped11: false, matched11: false},
       {value12: '', flipped12: false, matched12: false},
       {value13: '', flipped13: false, matched13: false},
       {value14: '', flipped14: false, matched14: false},
       {value15: '', flipped15: false, matched15: false},
       {value16: '', flipped16: false, matched16: false},
       {value17: '', flipped17: false, matched17: false},
       {value18: '', flipped18: false, matched18: false},
       {value19: '', flipped19: false, matched19: false},];

   var firstCard = -1;
   var secondCard = -1;
   var score = 0;
   var timeLeft = 0;
   var timer = null;
   var canClick = false;
   var totalCards = 0;
   var currentLevel = '';
   var pointPerMatch = 10;

   function startGame(level) {
       currentLevel = level;
       resetAllCards();

       document.getElementById('difficultyScreen').classList.add('hidden');
       document.getElementById('gameScreen').classList.remove('hidden');

       if (level === 'easy') {
           totalCards = 12;
           timeLeft = 20;
           pointPerMatch = 16;
           setupEasyCards();
       } else if (level === 'medium') {
           totalCards = 16;
           timeLeft = 30;
           pointPerMatch = 12;
           setupMediumCards();
       } else if (level === 'hard') {
           totalCards = 20;
           timeLeft = 40;
           pointPerMatch = 10;
           setupHardCards();
       }

       score = 0;
       firstCard = -1;
       secondCard = -1;
       canClick = false;

       document.getElementById('gameoverScreen').classList.add('hidden');
       document.getElementById('quitBtn').classList.remove('hidden');

       showCards();
       startPreview();
   }

   function resetAllCards() {
       flipped0 = false; flipped1 = false; flipped2 = false; flipped3 = false; flipped4 = false;
       flipped5 = false; flipped6 = false; flipped7 = false; flipped8 = false; flipped9 = false;
       flipped10 = false; flipped11 = false; flipped12 = false; flipped13 = false; flipped14 = false;
       flipped15 = false; flipped16 = false; flipped17 = false; flipped18 = false; flipped19 = false;

       matched0 = false; matched1 = false; matched2 = false; matched3 = false; matched4 = false;
       matched5 = false; matched6 = false; matched7 = false; matched8 = false; matched9 = false;
       matched10 = false; matched11 = false; matched12 = false; matched13 = false; matched14 = false;
       matched15 = false; matched16 = false; matched17 = false; matched18 = false; matched19 = false;
   }

   function setupEasyCards() {
       var emojis = ['🎮', '🌼', '🌈', '🌳', '🌞', '🌏'];
       var shuffled = shuffleArray([emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5],  emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5]]);
       card0 = shuffled[0]; card1 = shuffled[1]; card2 = shuffled[2]; card3 = shuffled[3]; card4 = shuffled[4];
       card5 = shuffled[5]; card6 = shuffled[6]; card7 = shuffled[7]; card8 = shuffled[8]; card9 = shuffled[9]; card10 = shuffled[10];card11 = shuffled[11];
   }

   function setupMediumCards() {
       var emojis = ['🎮', '🌼', '🌈', '🌳', '🌞', '🎬', '🌏', '🎹'];
       var shuffled = shuffleArray([emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5], emojis[6], emojis[7], emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5], emojis[6], emojis[7]]);
       card0 = shuffled[0]; card1 = shuffled[1]; card2 = shuffled[2]; card3 = shuffled[3]; card4 = shuffled[4];
       card5 = shuffled[5]; card6 = shuffled[6]; card7 = shuffled[7]; card8 = shuffled[8]; card9 = shuffled[9];
       card10 = shuffled[10]; card11 = shuffled[11]; card12 = shuffled[12]; card13 = shuffled[13]; card14 = shuffled[14]; card15 = shuffled[15];
   }

   function setupHardCards() {
       var emojis = ['🎮', '🌼', '🌈', '🌳', '🌞', '🎬', '🌏', '🎹', '🎺', '🎻'];
       var shuffled = shuffleArray([emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5], emojis[6], emojis[7], emojis[8], emojis[9], emojis[0], emojis[1], emojis[2], emojis[3], emojis[4], emojis[5], emojis[6], emojis[7], emojis[8], emojis[9]]);
       card0 = shuffled[0]; card1 = shuffled[1]; card2 = shuffled[2]; card3 = shuffled[3]; card4 = shuffled[4];
       card5 = shuffled[5]; card6 = shuffled[6]; card7 = shuffled[7]; card8 = shuffled[8]; card9 = shuffled[9];
       card10 = shuffled[10]; card11 = shuffled[11]; card12 = shuffled[12]; card13 = shuffled[13]; card14 = shuffled[14];
       card15 = shuffled[15]; card16 = shuffled[16]; card17 = shuffled[17]; card18 = shuffled[18]; card19 = shuffled[19];
   }

   function shuffleArray(arr) {
       for (var i = arr.length - 1; i > 0; i--) {
           var j = Math.floor(Math.random() * (i + 1));
           var temp = arr[i];
           arr[i] = arr[j];
           arr[j] = temp;
       }
       return arr;
   }

   function showCards() {
       var grid = document.getElementById('grid');
       grid.className = 'grid ' + currentLevel;
       grid.innerHTML = '';

       for (var i = 0; i < totalCards; i++) {
           var btn = document.createElement('button');
           btn.className = 'card flipped';
           btn.id = 'c' + i;
           btn.textContent = getCardValue(i);
           btn.setAttribute('data-id', i);
           btn.onclick = function() {
               cardClick(parseInt(this.getAttribute('data-id')));
           };
           grid.appendChild(btn);
       }
   }

   function getCardValue(index) {
       if (index === 0) return card0;
       if (index === 1) return card1;
       if (index === 2) return card2;
       if (index === 3) return card3;
       if (index === 4) return card4;
       if (index === 5) return card5;
       if (index === 6) return card6;
       if (index === 7) return card7;
       if (index === 8) return card8;
       if (index === 9) return card9;
       if (index === 10) return card10;
       if (index === 11) return card11;
       if (index === 12) return card12;
       if (index === 13) return card13;
       if (index === 14) return card14;
       if (index === 15) return card15;
       if (index === 16) return card16;
       if (index === 17) return card17;
       if (index === 18) return card18;
       if (index === 19) return card19;
       return '';
   }

   function startPreview() {
       updateDisplay('미리보기: 5초', score);
       var preview = 5;
       var previewTimer = setInterval(function() {
           preview = preview - 1;
           updateDisplay('미리보기: ' + preview + '초', score);
           if (preview === 0) {
               clearInterval(previewTimer);
               hideAllCards();
               canClick = true;
               updateDisplay('시간: ' + timeLeft + '초', score);
               startTimer();
           }
       }, 1000);
   }

   function hideAllCards() {
       for (var i = 0; i < totalCards; i++) {
           var c = document.getElementById('c' + i);
           c.classList.remove('flipped');
           c.textContent = '?';
       }
   }

   function startTimer() {
       timer = setInterval(function() {
           timeLeft = timeLeft - 1;
           updateDisplay('시간: ' + timeLeft + '초', score);
           if (timeLeft === 0) {
               endGame(false);
           }
       }, 1000);
   }

   function cardClick(id) {
       if (canClick === false) return;
       if (isFlipped(id) === true) return;
       if (isMatched(id) === true) return;
       if (firstCard !== -1 && secondCard !== -1) return;

       setFlipped(id, true);
       var elem = document.getElementById('c' + id);
       elem.classList.add('flipped');
       elem.textContent = getCardValue(id);

       if (firstCard === -1) {
           firstCard = id;
       } else if (secondCard === -1) {
           secondCard = id;
           canClick = false;
           checkMatch();
       }
   }

   function checkMatch() {
       var val1 = getCardValue(firstCard);
       var val2 = getCardValue(secondCard);

       if (val1 === val2) {
           setTimeout(function() {
               setMatched(firstCard, true);
               setMatched(secondCard, true);
               document.getElementById('c' + firstCard).classList.add('matched');
               document.getElementById('c' + secondCard).classList.add('matched');
               score = score + pointPerMatch;
               updateDisplay('시간: ' + timeLeft + '초', score);
               firstCard = -1;
               secondCard = -1;
               canClick = true;
               if (allMatched() === true) {
                   endGame(true);
               }
           }, 300);
       } else {
           setTimeout(function() {
               setFlipped(firstCard, false);
               setFlipped(secondCard, false);
               document.getElementById('c' + firstCard).classList.remove('flipped');
               document.getElementById('c' + secondCard).classList.remove('flipped');
               document.getElementById('c' + firstCard).textContent = '?';
               document.getElementById('c' + secondCard).textContent = '?';
               firstCard = -1;
               secondCard = -1;
               canClick = true;
           }, 600);
       }
   }

   function isFlipped(id) {
       if (id === 0) return flipped0;
       if (id === 1) return flipped1;
       if (id === 2) return flipped2;
       if (id === 3) return flipped3;
       if (id === 4) return flipped4;
       if (id === 5) return flipped5;
       if (id === 6) return flipped6;
       if (id === 7) return flipped7;
       if (id === 8) return flipped8;
       if (id === 9) return flipped9;
       if (id === 10) return flipped10;
       if (id === 11) return flipped11;
       if (id === 12) return flipped12;
       if (id === 13) return flipped13;
       if (id === 14) return flipped14;
       if (id === 15) return flipped15;
       if (id === 16) return flipped16;
       if (id === 17) return flipped17;
       if (id === 18) return flipped18;
       if (id === 19) return flipped19;
       return false;
   }

   function setFlipped(id, val) {
       if (id === 0) flipped0 = val;
       if (id === 1) flipped1 = val;
       if (id === 2) flipped2 = val;
       if (id === 3) flipped3 = val;
       if (id === 4) flipped4 = val;
       if (id === 5) flipped5 = val;
       if (id === 6) flipped6 = val;
       if (id === 7) flipped7 = val;
       if (id === 8) flipped8 = val;
       if (id === 9) flipped9 = val;
       if (id === 10) flipped10 = val;
       if (id === 11) flipped11 = val;
       if (id === 12) flipped12 = val;
       if (id === 13) flipped13 = val;
       if (id === 14) flipped14 = val;
       if (id === 15) flipped15 = val;
       if (id === 16) flipped16 = val;
       if (id === 17) flipped17 = val;
       if (id === 18) flipped18 = val;
       if (id === 19) flipped19 = val;
   }

   function isMatched(id) {
       if (id === 0) return matched0;
       if (id === 1) return matched1;
       if (id === 2) return matched2;
       if (id === 3) return matched3;
       if (id === 4) return matched4;
       if (id === 5) return matched5;
       if (id === 6) return matched6;
       if (id === 7) return matched7;
       if (id === 8) return matched8;
       if (id === 9) return matched9;
       if (id === 10) return matched10;
       if (id === 11) return matched11;
       if (id === 12) return matched12;
       if (id === 13) return matched13;
       if (id === 14) return matched14;
       if (id === 15) return matched15;
       if (id === 16) return matched16;
       if (id === 17) return matched17;
       if (id === 18) return matched18;
       if (id === 19) return matched19;
       return false;
   }

   function setMatched(id, val) {
       if (id === 0) matched0 = val;
       if (id === 1) matched1 = val;
       if (id === 2) matched2 = val;
       if (id === 3) matched3 = val;
       if (id === 4) matched4 = val;
       if (id === 5) matched5 = val;
       if (id === 6) matched6 = val;
       if (id === 7) matched7 = val;
       if (id === 8) matched8 = val;
       if (id === 9) matched9 = val;
       if (id === 10) matched10 = val;
       if (id === 11) matched11 = val;
       if (id === 12) matched12 = val;
       if (id === 13) matched13 = val;
       if (id === 14) matched14 = val;
       if (id === 15) matched15 = val;
       if (id === 16) matched16 = val;
       if (id === 17) matched17 = val;
       if (id === 18) matched18 = val;
       if (id === 19) matched19 = val;
   }

   function allMatched() {
       var count = 0;
       if (matched0 === true) count = count + 1;
       if (matched1 === true) count = count + 1;
       if (matched2 === true) count = count + 1;
       if (matched3 === true) count = count + 1;
       if (matched4 === true) count = count + 1;
       if (matched5 === true) count = count + 1;
       if (matched6 === true) count = count + 1;
       if (matched7 === true) count = count + 1;
       if (matched8 === true) count = count + 1;
       if (matched9 === true) count = count + 1;
       if (matched10 === true) count = count + 1;
       if (matched11 === true) count = count + 1;
       if (matched12 === true) count = count + 1;
       if (matched13 === true) count = count + 1;
       if (matched14 === true) count = count + 1;
       if (matched15 === true) count = count + 1;
       if (matched16 === true) count = count + 1;
       if (matched17 === true) count = count + 1;
       if (matched18 === true) count = count + 1;
       if (matched19 === true) count = count + 1;
       if (count === totalCards) return true;
       return false;
   }

   function updateDisplay(timeText, scoreValue) {
       document.getElementById('timeDisplay').textContent = timeText;
   }

   function endGame(success) {
       clearInterval(timer);
       canClick = false;
       revealAllCards();

       document.getElementById('quitBtn').classList.add('hidden');
       document.getElementById('gameoverScreen').classList.remove('hidden');

       if (success === true) {
           if (currentLevel === 'medium' || currentLevel === 'easy') {
               score = score + 4;
           }
           document.getElementById('resultText').textContent = '🎉 성공!';
       } else {
           document.getElementById('resultText').textContent = '⏰ 시간 종료';
       }
       document.getElementById('finalScore').textContent = '최종 점수: ' + score + '점 / 100점';
       saveGameResult(currentLevel, score);
   }

   function saveGameResult(level, score) {
       const playTime = "약 " + (level === 'easy' ? 20 - timeLeft : level === 'medium' ? 30 - timeLeft : 40 - timeLeft) + "초";
       const params = new URLSearchParams();
       params.append('game_type', 'CARD_GAME');
       params.append('game_level', level);
       params.append('play_time', playTime);
       params.append('score', score);
       fetch(CTX + '/GameLogSaveServlet.do', {
           method: 'POST',
           headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
           body: params.toString()
       })
       .then(response => response.text())
       .then(data => {
           if (data === "ok") console.log("DB 저장 성공!");
           else console.error("DB 저장 실패:", data);
       })
       .catch(error => console.error('Error:', error));
   }

   function resetGame() {
       if (timer !== null) clearInterval(timer);
       document.getElementById('difficultyScreen').classList.remove('hidden');
       document.getElementById('gameScreen').classList.add('hidden');
   }

   function restartGame() {
       if (timer !== null) clearInterval(timer);
       startGame(currentLevel);
   }

   function revealAllCards() {
       for (var i = 0; i < totalCards; i++) {
           if (isMatched(i) === false) {
               setFlipped(i, true);
               var card = document.getElementById('c' + i);
               card.classList.add('flipped');
               card.textContent = getCardValue(i);
           }
       }
   }
</script>
</body>
</html>

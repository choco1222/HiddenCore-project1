<%@ page language="java" contentType="text/html; charset=UTF-8"
   pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>색깔 맞추기</title>
<link rel="stylesheet" href="../assets/css/active.css" />
<link rel="stylesheet" href="../assets/css/color.css" />
<style>
  /* card.jsp와 동일: body·프레임·헤더·버튼 디자인 */
  body.color-page { padding: 0 !important; margin: 0 !important; background: #FFDF7C !important; display: flex !important; justify-content: center !important; align-items: center !important; min-height: 100vh !important; font-family: 'Dunggeunmo', sans-serif !important; }
  body.color-page .app-frame { width: 100% !important; max-width: 440px !important; height: 100vh !important; max-height: 956px !important; min-height: 560px !important; background: #FFFBEF !important; position: relative !important; overflow: hidden !important; }
  @media (min-width: 441px) { body.color-page .app-frame { height: 956px !important; border-radius: 28px !important; box-shadow: 0 12px 40px rgba(0,0,0,0.12) !important; } }
  .app-frame .food-screen .back-btn, .app-frame .food-header .back-btn { position: static !important; top: auto !important; left: auto !important; z-index: auto !important; background: none !important; padding: 0 !important; border-radius: 0 !important; box-shadow: none !important; text-decoration: none !important; }
  .app-frame .food-screen .back-btn a, .app-frame .food-header .back-btn a { background: none !important; padding: 0 !important; border-radius: 0 !important; box-shadow: none !important; font-size: 26px !important; color: #574444 !important; }
  .app-frame .food-screen .food-title { font-size: 55px !important; font-weight: 700 !important; color: #574444 !important; line-height: 1.2 !important; font-family: 'Dunggeunmo', sans-serif !important; }
  .app-frame .food-screen .food-instruction { font-size: 30px !important; color: #574444 !important; line-height: 1.5 !important; margin-top: 14px !important; padding: 0 24px 28px !important; font-family: 'Dunggeunmo', sans-serif !important; }
  .app-frame .food-screen .game-btns { margin-top: 95px !important; padding: 0 24px 120px !important; display: flex !important; flex-direction: column !important; gap: 20px !important; position: relative !important; z-index: 1 !important; align-items: center !important; }
  .app-frame .food-screen .game-btns .card.card-bg { aspect-ratio: auto !important; width: 100% !important; max-width: 374px !important; height: 170px !important; min-height: 170px !important; margin: 0 auto !important; border-radius: 30px !important; background-color: transparent !important; background-size: contain !important; background-repeat: no-repeat !important; background-position: center !important; border: none !important; outline: none !important; box-shadow: none !important; cursor: pointer !important; display: block !important; position: relative !important; }
  .app-frame .food-screen .game-btns .card-bg-text { position: absolute !important; top: 50% !important; left: 50% !important; transform: translate(-50%, -50%) !important; font-size: 28px !important; font-weight: 700 !important; color: #574444 !important; line-height: 1.3 !important; pointer-events: none !important; display: flex !important; flex-direction: column !important; gap: 4px !important; align-items: center !important; text-align: center !important; }
  .app-frame .food-screen .game-btns .card-bg-line1, .app-frame .food-screen .game-btns .card-bg-line2 { display: block !important; }
  .app-frame .food-screen .game-btns .card-bg-line2 { white-space: nowrap !important; }
  #startScreen.hidden { display: none !important; }
  /* 게임 플레이 시 실행창: 프레임보다 조금 작게 (좌우 여백) */
  #gameScreen { padding-top: 0 !important; padding-left: 12px !important; padding-right: 12px !important; margin-top: -140px !important; margin-left: 8px !important; margin-right: 8px !important; transform: scale(0.88); transform-origin: top center; box-sizing: border-box !important; }
  /* 난이도 중: 색깔 선택 버튼만 위로 */
  #gameScreen.difficulty-medium #answerButtons { margin-top: -50px !important; }
  /* 난이도 상: 색깔 선택 버튼 축소 + 위로 */
  #gameScreen.difficulty-hard #answerButtons { margin-top: -70px !important; transform: scale(0.78); transform-origin: top center; }
  #gameScreen.difficulty-hard .answer-btn { padding: 12px !important; }
</style>
</head>
<body class="color-page">

<div class="app-frame">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg1">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg2">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

  <!-- card.jsp와 동일 구조: food-screen 안에 헤더 + 안내문 + 난이도 버튼(하/중/상 PNG) -->
  <div class="food-screen">
    <div class="food-header">
      <a href="<%= ctx %>/game/game_main.jsp" class="back-btn" aria-label="뒤로">◀</a>
      <h2 class="food-title">색깔 맞추기</h2>
    </div>
    <p class="food-instruction">글자의 실제 색깔을 맞춰주세요.</p>

    <div id="startScreen">
      <div class="game-btns">
        <button type="button" class="card card-bg" onclick="game.selectDifficulty('easy')" style="background-image: url('<%= ctx %>/assets/images/game/하.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">하(쉬움)</span>
            <span class="card-bg-line2">7초 / 10문제 / 3색</span>
          </span>
        </button>
        <button type="button" class="card card-bg" onclick="game.selectDifficulty('medium')" style="background-image: url('<%= ctx %>/assets/images/game/중.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">중(보통)</span>
            <span class="card-bg-line2">7초 / 10문제 / 6색</span>
          </span>
        </button>
        <button type="button" class="card card-bg" onclick="game.selectDifficulty('hard')" style="background-image: url('<%= ctx %>/assets/images/game/상.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">상(어려움)</span>
            <span class="card-bg-line2">7초 / 15문제 / 9색</span>
          </span>
        </button>
      </div>
    </div>
  </div>

  <!-- 게임 화면 -->
  <div id="gameScreen" class="game-screen hidden">

         <!-- 🔙 난이도 선택으로 돌아가기 -->
         

         <div class="score-board">
            <div class="score-item">
               라운드: <span class="score-value" id="currentRound">1</span> / <span
                  id="totalRounds">10</span>
            </div>
            <div class="score-item">
               시간: <span class="score-value" id="timer">5</span>초
            </div>
            <div class="score-item">
               점수: <span class="score-value" id="currentScore">0</span> / 100
            </div>
            <div class="gameover-buttons">
               <button class="reset-btn" onclick="resetGame()">처음으로</button>
            </div>
         </div>

         <div class="timer-bar-container">
            <div id="timerBar" class="timer-bar"
               style="width: 100%; background: #10b981;"></div>
         </div>

         <div class="question-card">
            <div class="question-title">이 글자의 색깔은?</div>
            <div id="colorWord" class="color-word"></div>
            <div id="feedback" class="feedback"></div>
         </div>

         <div id="answerButtons" class="answer-grid"></div>
      </div>

      <!-- 종료 화면 -->
      <div id="endScreen" class="end-screen hidden">
         <h1>게임 종료!</h1>
         <div class="final-score" id="finalScore">0</div>
         <div style="font-size: 1.3em; color: #666; margin-bottom: 20px;">
            / 100점</div>
         <div class="final-message" id="finalMessage"></div>
         <div
            style="display: flex; gap: 15px; justify-content: center; margin-top: 30px;">
            <button class="btn" onclick="game.returnToStart()">난이도 선택</button>
            <button class="btn" onclick="game.restartSameDifficulty()"
               style="background: linear-gradient(135deg, #10b981 0%, #059669 100%);">같은
               난이도로 재시작</button>
         </div>
      </div>

  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">
</div>

   <script>
      const CTX = "<%=request.getContextPath()%>"
   </script>
   
   <script>
        // 게임 객체로 관리하여 변수 스코프 문제 방지
        const game = {
            // 기본 색깔 (하 난이도)
            basicColors: [
                { name: '빨강', color: '#EF4444' },
                { name: '파랑', color: '#3B82F6' },
                { name: '초록', color: '#10B981' }
            ],

            // 중 난이도 추가 색깔
            mediumColors: [
               { name: '노랑', color: '#F59E0B' },
                { name: '보라', color: '#A855F7' },
                { name: '주황', color: '#F97316' }
            ],

            hardColors: [
               { name: '분홍', color: '#EC4899' },
                { name: '하늘', color: '#06B6D4' },
                { name: '갈색', color: '#92400E' }
            ],

            difficulties: {
                easy: { time: 7, rounds: 10, name: '하', colorSet: 'basic' },
                medium: { time: 7, rounds: 10, name: '중', colorSet: 'medium' },
                hard: { time: 7, rounds: 15, name: '상', colorSet: 'hard' }
            },

            colors: [], // 현재 난이도에 맞는 색깔 배열

            score: 0,
            round: 1,
            totalRounds: 10,
            currentWord: null,
            currentColor: null,
            answersDisabled: false,
            difficulty: 'medium',
            timeLimit: 3,
            timeRemaining: 3,
            timerInterval: null,

            // 난이도별 기본 점수 계산
            calculateScore: function() {
                let baseScore = 0;
                let finalScore = 0;
                
                if (this.difficulty === 'easy') {
                    // 하: 10문제 * 10점 = 100점
                    finalScore = this.score * 10;
                } else if (this.difficulty === 'medium') {
                    // 중: 10문제 * 10점 = 100점
                    finalScore = this.score * 10;
                } else if (this.difficulty === 'hard') {
                    // 상: 15문제 * 6점 = 90점 (만점시 +10 보너스 = 100점)
                    baseScore = Math.floor((this.score / this.totalRounds) * 90);
                    if (this.score === this.totalRounds) {
                        finalScore = 100; // 만점 보너스
                    } else {
                        finalScore = baseScore;
                    }
                }
                
                return finalScore;
            },

            selectDifficulty: function(level) {
                this.difficulty = level;
                this.startGame();
            },

            startGame: function() {
                this.score = 0;
                this.round = 1;
                this.answersDisabled = false;
                
                const difficultySettings = this.difficulties[this.difficulty];
                this.timeLimit = difficultySettings.time;
                this.totalRounds = difficultySettings.rounds;
                
                // 난이도에 따라 색깔 세트 설정
                if (this.difficulty === 'easy') {
               this.colors = [...this.basicColors];
            } else if (this.difficulty === 'medium') {
             this.colors = [...this.basicColors, ...this.mediumColors];
            } else if (this.difficulty === 'hard') {
             // 상 난이도: 9색 모두 사용
             this.colors = [...this.basicColors, ...this.mediumColors, ...this.hardColors];
            }
                
                console.log('난이도:', this.difficulty, '색깔 개수:', this.colors.length);
                
                document.getElementById('startScreen').classList.add('hidden');
                document.getElementById('endScreen').classList.add('hidden');
                var gs = document.getElementById('gameScreen');
                gs.classList.remove('hidden', 'difficulty-easy', 'difficulty-medium', 'difficulty-hard');
                gs.classList.add('difficulty-' + this.difficulty);
                this.updateScore();
                this.generateQuestion();
            },

            startTimer: function() {
                if (this.timerInterval) {
                    clearInterval(this.timerInterval);
                }
                
                this.timeRemaining = this.timeLimit;
                this.updateTimerDisplay();
                
                this.timerInterval = setInterval(() => {
                    this.timeRemaining -= 0.1;
                    
                    if (this.timeRemaining <= 0) {
                        clearInterval(this.timerInterval);
                        this.timeRemaining = 0;
                        this.handleTimeout();
                    }
                    
                    this.updateTimerDisplay();
                }, 100);
            },

            updateTimerDisplay: function() {
                const timerElement = document.getElementById('timer');
                const timerBar = document.getElementById('timerBar');
                
                timerElement.textContent = Math.ceil(this.timeRemaining);
                
                const percentage = (this.timeRemaining / this.timeLimit) * 100;
                timerBar.style.width = percentage + '%';
                
                if (percentage < 30) {
                    timerBar.style.background = '#ef4444';
                } else if (percentage < 60) {
                    timerBar.style.background = '#f59e0b';
                } else {
                    timerBar.style.background = '#10b981';
                }
            },

            handleTimeout: function() {
                if (this.answersDisabled) return;
                this.answersDisabled = true;
                
                const feedbackElement = document.getElementById('feedback');
                const correctAnswerName = this.currentColor.name;
                feedbackElement.textContent = '시간 초과! 정답은 ' + correctAnswerName + '입니다.';
                feedbackElement.className = 'feedback incorrect';
                
                // 버튼 비활성화
                const buttons = document.querySelectorAll('.answer-btn');
                buttons.forEach(btn => btn.disabled = true);
                
                setTimeout(() => {
                    if (this.round < this.totalRounds) {
                        this.round++;
                        this.generateQuestion();
                        this.updateScore();
                    } else {
                        this.endGame();
                    }
                }, 1500);
            },

            generateQuestion: function() {
                const wordIndex = Math.floor(Math.random() * this.colors.length);
                const colorIndex = Math.floor(Math.random() * this.colors.length);
                
                this.currentWord = this.colors[wordIndex];
                this.currentColor = this.colors[colorIndex];
                
                console.log('문제 생성:', '단어=' + this.currentWord.name, '색깔=' + this.currentColor.name);
                
                const colorWordElement = document.getElementById('colorWord');
                colorWordElement.textContent = this.currentWord.name;
                colorWordElement.style.color = this.currentColor.color;
                
                document.getElementById('feedback').textContent = '';
                document.getElementById('feedback').className = 'feedback';
                
                this.createAnswerButtons();
                this.answersDisabled = false;
                this.startTimer();
            },

            createAnswerButtons: function() {
                const container = document.getElementById('answerButtons');
                container.innerHTML = '';
                
                this.colors.forEach(color => {
                    const btn = document.createElement('button');
                    btn.className = 'answer-btn';
                    btn.style.borderColor = color.color;
                    btn.onclick = () => this.handleAnswer(color);
                    
                    const circle = document.createElement('div');
                    circle.className = 'color-circle';
                    circle.style.backgroundColor = color.color;
                    
                    const name = document.createElement('div');
                    name.className = 'color-name';
                    name.textContent = color.name;
                    
                    btn.appendChild(circle);
                    btn.appendChild(name);
                    container.appendChild(btn);
                });
            },

            handleAnswer: function(selectedColor) {
                if (this.answersDisabled) return;
                this.answersDisabled = true;
                
                clearInterval(this.timerInterval);
                
                console.log('선택한 색:', selectedColor.name, '정답:', this.currentColor.name);
                
                const feedbackElement = document.getElementById('feedback');
                const correctAnswerName = this.currentColor.name;
                
                // 버튼 비활성화
                const buttons = document.querySelectorAll('.answer-btn');
                buttons.forEach(btn => btn.disabled = true);
                
                if (selectedColor.name === this.currentColor.name) {
                    this.score++;
                    feedbackElement.textContent = '정답입니다! 🎉';
                    feedbackElement.className = 'feedback correct';
                } else {
                    feedbackElement.textContent = '틀렸습니다! 정답은 ' + correctAnswerName + '입니다.';
                    feedbackElement.className = 'feedback incorrect';
                }
                
                this.updateScore();
                
                setTimeout(() => {
                    if (this.round < this.totalRounds) {
                        this.round++;
                        this.generateQuestion();
                        this.updateScore();
                    } else {
                        this.endGame();
                    }
                }, 1500);
            },

            updateScore: function () {
                document.getElementById('currentRound').textContent = this.round;
                document.getElementById('currentScore').textContent = this.calculateScore();
                document.getElementById('totalRounds').textContent = this.totalRounds;
            },

            endGame: async function () {
                clearInterval(this.timerInterval);

                document.getElementById('gameScreen').classList.add('hidden');
                document.getElementById('endScreen').classList.remove('hidden');

                const finalScore = this.calculateScore();
                document.getElementById('finalScore').textContent = finalScore;

                const messageElement = document.getElementById('finalMessage');

                if (this.score === this.totalRounds) {
                    messageElement.textContent = '완벽합니다! 🏆';
                } else {
                    const percentage = (this.score / this.totalRounds) * 100;
                    if (percentage >= 80) messageElement.textContent = '대단해요! 👏';
                    else if (percentage >= 60) messageElement.textContent = '잘하셨어요! 😊';
                    else messageElement.textContent = '다시 도전해보세요! 💪';
                }

                // playTime 예시(원하시면 실제 플레이 시간 측정으로 바꿔드릴게요)
                const playTime = "약 " + (this.totalRounds * this.timeLimit) + "초";

                // ✅ DB 저장 호출 (서블릿으로 전송)
                await this.saveGameResult(this.difficulty, finalScore, playTime);
            },

            saveGameResult: async function (level, score, playTime) {
                const params = new URLSearchParams();
                params.append("game_type", "COLOR_GAME"); // 게임 종류 구분용
                params.append("game_level", level);
                params.append("play_time", playTime);
                params.append("score", String(score));

                const res = await fetch(CTX + "/GameLogSaveServlet.do", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
                    body: params.toString()
                });

                const text = await res.text();
                console.log("save result:", text); // ok / fail / bad_request
            },

            returnToStart: function () {
                if (this.timerInterval) clearInterval(this.timerInterval);
                document.getElementById('endScreen').classList.add('hidden');
                var gs = document.getElementById('gameScreen');
                gs.classList.add('hidden');
                gs.classList.remove('difficulty-easy', 'difficulty-medium', 'difficulty-hard');
                document.getElementById('startScreen').classList.remove('hidden');
            },

            restartSameDifficulty: function () {
                // 같은 난이도로 다시 시작
                if (this.timerInterval) clearInterval(this.timerInterval);
                this.startGame();
            },

            backToDifficulty: function() {
                // 타이머 정리
                if (this.timerInterval) clearInterval(this.timerInterval);
                
                // 게임 상태 초기화
                this.score = 0;
                this.round = 1;
                this.answersDisabled = false;
                
                // 화면 전환
                document.getElementById('gameScreen').classList.add('hidden');
                document.getElementById('endScreen').classList.add('hidden');
                document.getElementById('startScreen').classList.remove('hidden');
            }
            
        };
            function resetGame() {
                // 타이머 정리
                if (game.timerInterval !== null) {
                    clearInterval(game.timerInterval);
                }
                
                // 게임 상태 초기화
                game.score = 0;
                game.round = 1;
                game.answersDisabled = false;
                
                // 화면 전환
                var gs = document.getElementById('gameScreen');
                gs.classList.add('hidden');
                gs.classList.remove('difficulty-easy', 'difficulty-medium', 'difficulty-hard');
                document.getElementById('endScreen').classList.add('hidden');
                document.getElementById('startScreen').classList.remove('hidden');
            }
    </script>
</body>
</html>

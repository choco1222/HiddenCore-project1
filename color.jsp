<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>색깔 맞추기 게임</title>
<link rel="stylesheet" href="../css/color.css" />
</head>
<body>
	<div class="container">
		<!-- 시작 화면 -->
		<div id="startScreen" class="start-screen">
			<h1>🎨 색깔 맞추기 게임</h1>
			<div class="instructions">
				화면에 보이는 <strong>글자의 실제 색깔</strong>을 맞춰주세요!<br> <small>(글자의
					의미가 아닙니다)</small>
			</div>
			<div style="margin-top: 40px;">
				<h2>난이도 선택</h2>
				<div
					style="display: flex; gap: 15px; justify-content: center; flex-wrap: wrap;">
					<button class="difficulty-btn easy"
						onclick="game.selectDifficulty('easy')">
						<div class="difficulty-name">하</div>
						<div class="difficulty-desc">7초 / 10문제 / 3색</div>
					</button>
					<button class="difficulty-btn medium"
						onclick="game.selectDifficulty('medium')">
						<div class="difficulty-name">중</div>
						<div class="difficulty-desc">7초 / 10문제 / 6색</div>
					</button>
					<button class="difficulty-btn hard"
						onclick="game.selectDifficulty('hard')">
						<div class="difficulty-name">상</div>
						<div class="difficulty-desc">7초 / 15문제 / 9색</div>
					</button>
				</div>
			</div>
		</div>

		<!-- 게임 화면 -->
		<div id="gameScreen" class="game-screen hidden">
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
                { name: '초록', color: '#10B981' },
                
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

            // 상 난이도는 중 난이도와 같은 9색 사용

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
                document.getElementById('gameScreen').classList.remove('hidden');
                
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
                  messageElement.textContent = (this.difficulty === 'hard')
                    ? '완벽합니다! 🏆 '
                    : '완벽합니다! 🏆';
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
            	  // 타이머 정리
            	  if (this.timerInterval) clearInterval(this.timerInterval);

            	  // 화면 전환
            	  document.getElementById('endScreen').classList.add('hidden');
            	  document.getElementById('gameScreen').classList.add('hidden');
            	  document.getElementById('startScreen').classList.remove('hidden');
            	},

            	restartSameDifficulty: function () {
            	  // 같은 난이도로 다시 시작
            	  if (this.timerInterval) clearInterval(this.timerInterval);
            	  this.startGame();
            	}
            };
            </script>
</body>
</html>

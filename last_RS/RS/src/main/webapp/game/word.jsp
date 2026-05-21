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
<title>낱말 단어 찾기</title>
<link rel="stylesheet" href="../assets/css/active.css" />
<link rel="stylesheet" href="../assets/css/word.css" />
<style>
  /* card.jsp와 동일: body·프레임·헤더·버튼 디자인 */
  body.word-page { padding: 0 !important; margin: 0 !important; background: #FFDF7C !important; display: flex !important; justify-content: center !important; align-items: center !important; min-height: 100vh !important; font-family: 'Dunggeunmo', sans-serif !important; }
  body.word-page .app-frame { width: 100% !important; max-width: 440px !important; height: 100vh !important; max-height: 956px !important; min-height: 560px !important; background: #FFFBEF !important; position: relative !important; overflow: hidden !important; }
  @media (min-width: 441px) { body.word-page .app-frame { height: 956px !important; border-radius: 28px !important; box-shadow: 0 12px 40px rgba(0,0,0,0.12) !important; } }
  .app-frame .food-screen .back-btn, .app-frame .food-header .back-btn { position: static !important; top: auto !important; left: auto !important; z-index: auto !important; background: none !important; padding: 0 !important; border-radius: 0 !important; box-shadow: none !important; text-decoration: none !important; }
  .app-frame .food-screen .back-btn a, .app-frame .food-header .back-btn a { background: none !important; padding: 0 !important; border-radius: 0 !important; box-shadow: none !important; font-size: 26px !important; color: #574444 !important; }
  .app-frame .food-screen .food-title { font-size: 55px !important; font-weight: 700 !important; color: #574444 !important; line-height: 1.2 !important; font-family: 'Dunggeunmo', sans-serif !important; }
  .app-frame .food-screen .food-instruction { font-size: 30px !important; color: #574444 !important; line-height: 1.5 !important; margin-top: 14px !important; padding: 0 24px 28px !important; font-family: 'Dunggeunmo', sans-serif !important; }
  .app-frame .food-screen .game-btns { margin-top: 95px !important; padding: 0 24px 120px !important; display: flex !important; flex-direction: column !important; gap: 20px !important; position: relative !important; z-index: 1 !important; align-items: center !important; }
  .app-frame .food-screen .game-btns .card.card-bg { aspect-ratio: auto !important; width: 100% !important; max-width: 374px !important; height: 170px !important; min-height: 170px !important; margin: 0 auto !important; border-radius: 30px !important; background-color: transparent !important; background-size: contain !important; background-repeat: no-repeat !important; background-position: center !important; border: none !important; outline: none !important; box-shadow: none !important; cursor: pointer !important; display: block !important; position: relative !important; }
  .app-frame .food-screen .game-btns .card-bg-text { position: absolute !important; top: 50% !important; left: 50% !important; transform: translate(-50%, -50%) !important; font-size: 28px !important; font-weight: 700 !important; color: #574444 !important; line-height: 1.3 !important; pointer-events: none !important; display: flex !important; flex-direction: column !important; gap: 4px !important; align-items: center !important; text-align: center !important; }
  .app-frame .food-screen .game-btns .card-bg-line1, .app-frame .food-screen .game-btns .card-bg-line2 { display: block !important; }
  .app-frame .food-screen .game-btns .card-bg-line2 { white-space: nowrap !important; }
  /* 게임 플레이 시 실행창: 하·중·상 공통으로 프레임보다 조금 작게 (좌우 여백) */
  #gameScreen { padding-top: 0 !important; padding-bottom: 80px !important; padding-left: 12px !important; padding-right: 12px !important; margin-top: -140px !important; width: calc(100% - 16px) !important; max-width: calc(100% - 16px) !important; margin-left: auto !important; margin-right: auto !important; transform: scale(0.88); transform-origin: top center; overflow-y: auto !important; overflow-x: hidden !important; max-height: 82vh !important; position: relative !important; z-index: 1 !important; box-sizing: border-box !important; }
  .app-frame > .grass { z-index: 0 !important; }
  /* 숨은 낱말 찾기 제목: 더 줄여서 한 줄로 */
  #gameScreen .game-header h1 { font-size: 0.85em !important; white-space: nowrap !important; }
  /* 찾을 단어 리스트: 옆이 아니라 밑에, 가로 배치 */
  #gameScreen .game-content { display: grid !important; grid-template-columns: 1fr !important; gap: 16px !important; }
  #gameScreen .word-list { order: 2; }
  #gameScreen .word-items { flex-direction: row !important; flex-wrap: wrap !important; gap: 8px !important; justify-content: center !important; }
  /* 난이도 중·상: 실행창 하단도 프레임보다 작게 (밑에 여백), 내용은 왼쪽으로 조금 이동 */
  #gameScreen.difficulty-medium,
  #gameScreen.difficulty-hard { margin-bottom: 24px !important; max-height: calc(82vh - 39px) !important; }
  #gameScreen.difficulty-medium .game-content,
  #gameScreen.difficulty-hard .game-content { transform: translateX(-18px) !important; }
  /* 난이도 상만: 찾을 단어 한 줄에 3개씩, 총 3줄 */
  #gameScreen.difficulty-hard .word-items { display: grid !important; grid-template-columns: repeat(3, 1fr) !important; flex-direction: unset !important; gap: 8px !important; justify-content: unset !important; }
  /* 다시하기·처음으로 버튼 크기 축소 */
  #gameScreen .header-buttons .replay-btn,
  #gameScreen .header-buttons .reset-btn { padding: 6px 14px !important; font-size: 0.85em !important; }
</style>
</head>
<body class="word-page">

<div class="app-frame">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg1">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg2">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

  <!-- card.jsp와 동일 구조: food-screen 안에 헤더 + 안내문 + 난이도 버튼(하/중/상 PNG) -->
  <div class="food-screen">
    <div class="food-header">
      <a href="<%= ctx %>/game/game_main.jsp" class="back-btn" aria-label="뒤로">◀</a>
      <h2 class="food-title">낱말 단어 찾기</h2>
    </div>
    <p class="food-instruction">첫 글자와 마지막 글자를 클릭해서 단어를 완성하세요!</p>

    <div id="difficultyScreen">
      <div class="game-btns">
        <button type="button" class="card card-bg" onclick="startGame('easy')" style="background-image: url('<%= ctx %>/assets/images/game/하.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">하(쉬움)</span>
            <span class="card-bg-line2">7x7 / 5단어 / 25초</span>
          </span>
        </button>
        <button type="button" class="card card-bg" onclick="startGame('medium')" style="background-image: url('<%= ctx %>/assets/images/game/중.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">중(보통)</span>
            <span class="card-bg-line2">8x8 / 7단어 / 35초</span>
          </span>
        </button>
        <button type="button" class="card card-bg" onclick="startGame('hard')" style="background-image: url('<%= ctx %>/assets/images/game/상.png');">
          <span class="card-bg-text">
            <span class="card-bg-line1">상(어려움)</span>
            <span class="card-bg-line2">8x8 / 9단어 / 50초</span>
          </span>
        </button>
      </div>
    </div>
  </div>

  <!-- 게임 화면 -->
  <div class="game-screen" id="gameScreen">
			<div class="game-header">
				<h1>숨은 낱말 찾기</h1>
				<div class="header-buttons">
					<button class="replay-btn" onclick="replayGame()">🔄 다시하기</button>
					<button class="reset-btn" onclick="location.href='<%= ctx %>/game/word.jsp'">처음으로</button>
				</div>
			</div>

			<div class="game-stats">
				<div class="stat-box">
					<div class="stat-label">남은 시간</div>
					<div class="stat-value timer" id="timer">0</div>
				</div>
				<div class="stat-box">
					<div class="stat-label">점수</div>
					<div class="stat-value" id="score">0</div>
				</div>
			</div>

			<div class="game-content">
				<div>
					<div class="grid-container" id="gridContainer"></div>
					<div class="instruction-text">💡 첫 글자와 마지막 글자를 차례로 클릭하세요</div>
				</div>
				<div class="word-list">
					<h2>찾을 단어</h2>
					<div class="word-items" id="wordList"></div>
					<div id="completionMessage"></div>
				</div>
			</div>
		</div>

  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">
</div>

	<script>
	  const CTX = "<%= ctx %>"
	</script>

	<script>
        // 게임 상태
        let difficulty = null;
        let grid = [];
        let words = [];
        let wordListDisplay = [];
        let foundWords = [];
        let selectedCells = [];
        let firstCell = null;  // 첫 번째 클릭한 셀
        let timeLeft = 0;
        let timerInterval = null;
        let score = 0;
        let gameOver = false;

        // 난이도별 설정
        const difficultySettings = {
            easy: { 
                size: 7, 
                wordCount: 5, 
                words: ['두리안', '청포도', '수박', '블루베리', '딸기'],
                wordListChosungCount: 0,
                timeLimit: 25,
                baseScore: 100
            },
            medium: { 
                size: 8, 
                wordCount: 7, 
                words: ['가족여행', '나들이', '귀향길', '배우자', '가시버시', '가정', '장인어른'],
                wordListChosungCount: 0,
                timeLimit: 35,
                baseScore: 100
            },
            hard: { 
                size: 8, 
                wordCount: 9, 
                words: ['케이크', '생일파티', '결혼식', '주인공', '선물', '청첩장', '축하연', '주최자', '축하하다'],
                wordListChosungCount: 5,
                timeLimit: 50,
                baseScore: 100
            }
        };

        // 한글 초성 추출
        function getChosung(char) {
            const chosungList = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
            const code = char.charCodeAt(0) - 44032;
            if (code < 0 || code > 11171) return char;
            return chosungList[Math.floor(code / 588)];
        }

        // 단어를 초성으로 변환
        function wordToChosung(word) {
            return word.split('').map(char => getChosung(char)).join('');
        }
        
        // 단어 중 한 글자만 초성으로 변환 (보기 목록 전용)
        function wordToPartialChosung(word) {
            const index = Math.floor(Math.random() * word.length);
            return word
                .split('')
                .map((char, i) => i === index ? getChosung(char) : char)
                .join('');
        }

        // 타이머 시작
        function startTimer() {
            const settings = difficultySettings[difficulty];
            timeLeft = settings.timeLimit;
            updateTimerDisplay();
            
            timerInterval = setInterval(() => {
                timeLeft--;
                updateTimerDisplay();
                
                if (timeLeft <= 0) {
                    endGame(false);
                }
            }, 1000);
        }

        // 타이머 표시 업데이트
        function updateTimerDisplay() {
            const timerElement = document.getElementById('timer');
            timerElement.textContent = timeLeft + '초';
            
            const settings = difficultySettings[difficulty];
            const halfTime = settings.timeLimit / 2;
            const quarterTime = settings.timeLimit / 4;
            
            timerElement.classList.remove('warning', 'danger');
            if (timeLeft <= quarterTime) {
                timerElement.classList.add('danger');
            } else if (timeLeft <= halfTime) {
                timerElement.classList.add('warning');
            }
        }

        // 점수 계산
        function calculateScore() {
            const settings = difficultySettings[difficulty];
            const wordsFound = foundWords.length;
            const totalWords = words.length;
            
            // 모든 단어를 찾았을 경우
            if (wordsFound === totalWords) {
                // 시간 내에 완료한 경우 100점
                if (timeLeft > 0) {
                    return 100;
                }
                // 시간 초과 후 완료한 경우도 100점
                return 100;
            }
            
            // 일부만 찾은 경우
            const basePoints = Math.floor((wordsFound / totalWords) * settings.baseScore);
            return basePoints;
        }

        // 점수 업데이트
        function updateScore() {
            score = calculateScore();
            document.getElementById('score').textContent = score + '점';
        }
        
     // ✅ 서버 전송용 함수 (word 게임 결과 저장)
        function saveGameResult(level, score) {
          // 난이도별 제한시간에서 timeLeft를 빼서 플레이 시간 계산
          const limit = difficultySettings[level].timeLimit;
          const usedSeconds = Math.max(0, limit - timeLeft);
          const playTime = "약 " + usedSeconds + "초";

          const params = new URLSearchParams();
          params.append("game_id", "WORD_001");       // 게임 구분 id (원하는 값으로)
          params.append("game_type", "WORD_GAME");        // DAO의 getGameResultsByType과 맞추려면 'word' 추천
          params.append("game_level", level);        // easy/medium/hard
          params.append("play_time", playTime);
          params.append("score", String(score));

          fetch(CTX + "/GameLogSaveServlet.do", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
            body: params.toString()
          })
          .then(res => res.text())
          .then(txt => {
            console.log("save result:", txt);
            // 필요하면 여기서 완료 메시지/알림 처리 가능
          })
          .catch(err => console.error("save error:", err));
        }


        // 게임 종료
        function endGame(completed) {
            gameOver = true;
            clearInterval(timerInterval);
            
            // 모든 단어를 찾은 경우 남은 시간과 상관없이 100점
            if (completed) {
                score = 100;
            } else {
                score = calculateScore();
            }
            
            document.getElementById('score').textContent = score + '점';
            
         // ✅ DB 저장 (게임 종료 시점에 저장)
            saveGameResult(difficulty, score);

        }

        // 그리드 생성
        function createGrid(size, wordList) {
            const newGrid = Array(size).fill(null).map(() => 
                Array(size).fill(null).map(() => ({ letter: '', isWord: false, wordIndex: -1 }))
            );
            
            const directions = [
                [0, 1],   // 가로
                [1, 0],   // 세로
                [1, 1],   // 대각선 ↘
                [-1, 1],  // 대각선 ↗
            ];

            const placedWords = [];

            // 각 단어를 그리드에 배치
            wordList.forEach((word, wordIndex) => {
                let placed = false;
                let attempts = 0;
                
                while (!placed && attempts < 100) {
                    const direction = directions[Math.floor(Math.random() * directions.length)];
                    const row = Math.floor(Math.random() * size);
                    const col = Math.floor(Math.random() * size);
                    
                    if (canPlaceWord(newGrid, word, row, col, direction, size)) {
                        placeWord(newGrid, word, row, col, direction, wordIndex);
                        placedWords.push(word);
                        placed = true;
                    }
                    attempts++;
                }
            });

            // 빈 칸을 랜덤 한글로 채우기
            const hangul = '가나다라마바사아자차카타파하거너더러머버서어저처커터퍼허고노도로모보소오조초코토포호';
            for (let i = 0; i < size; i++) {
                for (let j = 0; j < size; j++) {
                    if (!newGrid[i][j].letter) {
                        newGrid[i][j].letter = hangul[Math.floor(Math.random() * hangul.length)];
                    }
                }
            }

            return { grid: newGrid, words: placedWords };
        }

        function canPlaceWord(grid, word, row, col, direction, size) {
            const [dx, dy] = direction;
            
            for (let i = 0; i < word.length; i++) {
                const newRow = row + (dx * i);
                const newCol = col + (dy * i);
                
                if (newRow < 0 || newRow >= size || newCol < 0 || newCol >= size) {
                    return false;
                }
                
                if (grid[newRow][newCol].letter && grid[newRow][newCol].letter !== word[i]) {
                    return false;
                }
            }
            
            return true;
        }

        function placeWord(grid, word, row, col, direction, wordIndex) {
            const [dx, dy] = direction;
            
            for (let i = 0; i < word.length; i++) {
                const newRow = row + (dx * i);
                const newCol = col + (dy * i);
                
                grid[newRow][newCol] = {
                    letter: word[i],
                    fullLetter: word[i],
                    isWord: true,
                    wordIndex: wordIndex
                };
            }
        }

        // 게임 시작
        function startGame(level) {
            difficulty = level;
            const settings = difficultySettings[level];
            const { grid: newGrid, words: placedWords } = createGrid(settings.size, settings.words);
            grid = newGrid;
            words = placedWords;
            
            // 보기 단어 목록 생성
            const numChosungWords = settings.wordListChosungCount;
            const chosungWordIndices = [];
            
            if (numChosungWords > 0) {
                const availableIndices = placedWords.map((_, idx) => idx);
                for (let i = 0; i < numChosungWords && i < availableIndices.length; i++) {
                    const randomIndex = Math.floor(Math.random() * availableIndices.length);
                    chosungWordIndices.push(availableIndices[randomIndex]);
                    availableIndices.splice(randomIndex, 1);
                }
            }
            
            wordListDisplay = placedWords.map((word, idx) => ({
                original: word,
                display: chosungWordIndices.includes(idx) ? wordToPartialChosung(word) : word,
                isChosung: chosungWordIndices.includes(idx)
            }));
            
            foundWords = [];
            selectedCells = [];
            firstCell = null;
            score = 0;
            gameOver = false;
            
            renderGame();
            startTimer();
        }

        // 게임 렌더링
        function renderGame() {
            document.getElementById('difficultyScreen').style.display = 'none';
            var gs = document.getElementById('gameScreen');
            gs.classList.add('active');
            gs.classList.remove('difficulty-easy', 'difficulty-medium', 'difficulty-hard');
            gs.classList.add('difficulty-' + difficulty);
            
            // 그리드 렌더링
            const gridContainer = document.getElementById('gridContainer');
            gridContainer.innerHTML = '';
            
            grid.forEach((row, rowIndex) => {
                const rowDiv = document.createElement('div');
                rowDiv.className = 'grid-row';
                
                row.forEach((cell, colIndex) => {
                    const cellDiv = document.createElement('div');
                    cellDiv.className = 'grid-cell';
                    cellDiv.textContent = cell.letter;
                    cellDiv.dataset.row = rowIndex;
                    cellDiv.dataset.col = colIndex;
                    
                    // 클릭 이벤트만 사용
                    cellDiv.addEventListener('click', handleCellClick);
                    
                    rowDiv.appendChild(cellDiv);
                });
                
                gridContainer.appendChild(rowDiv);
            });
            
            // 단어 목록 렌더링
            renderWordList();
            updateScore();
        }

        // 단어 목록 렌더링
        function renderWordList() {
            const wordList = document.getElementById('wordList');
            wordList.innerHTML = '';
            
            wordListDisplay.forEach(wordInfo => {
                const wordDiv = document.createElement('div');
                wordDiv.className = 'word-item';
                if (foundWords.includes(wordInfo.original)) {
                    wordDiv.classList.add('found');
                } else if (wordInfo.isChosung) {
                    wordDiv.classList.add('chosung');
                }
                wordDiv.textContent = wordInfo.display;
                wordList.appendChild(wordDiv);
            });
        }

        // 셀 클릭 처리 (첫 글자와 마지막 글자만)
        function handleCellClick(e) {
            if (gameOver) return;
            
            const row = parseInt(e.target.dataset.row);
            const col = parseInt(e.target.dataset.col);
            
            // 첫 번째 클릭
            if (firstCell === null) {
                firstCell = { row, col };
                selectedCells = [{ row, col }];
                updateCellStyles();
            } 
            // 두 번째 클릭
            else {
                const secondCell = { row, col };
                
                // 같은 셀을 클릭한 경우 선택 취소
                if (firstCell.row === row && firstCell.col === col) {
                    firstCell = null;
                    selectedCells = [];
                    updateCellStyles();
                    return;
                }
                
                // 두 점 사이의 경로 계산
                const path = calculatePath(firstCell, secondCell);
                
                if (path) {
                    selectedCells = path;
                    updateCellStyles();
                    checkWord();
                } else {
                    // 일직선이 아니면 선택 초기화
                    firstCell = null;
                    selectedCells = [];
                    updateCellStyles();
                }
            }
        }

        // 두 점 사이의 경로 계산 (가로, 세로, 대각선만)
        function calculatePath(start, end) {
            const rowDiff = end.row - start.row;
            const colDiff = end.col - start.col;
            
            // 방향 벡터 계산
            const dx = rowDiff === 0 ? 0 : Math.sign(rowDiff);
            const dy = colDiff === 0 ? 0 : Math.sign(colDiff);
            
            // 일직선이 아닌 경우
            if (dx !== 0 && dy !== 0) {
                // 대각선이 아닌 경우 (기울기가 1:1이 아님)
                if (Math.abs(rowDiff) !== Math.abs(colDiff)) {
                    return null;
                }
            }
            
            // 경로 생성
            const path = [];
            let currentRow = start.row;
            let currentCol = start.col;
            
            while (currentRow !== end.row || currentCol !== end.col) {
                path.push({ row: currentRow, col: currentCol });
                currentRow += dx;
                currentCol += dy;
            }
            path.push({ row: end.row, col: end.col });
            
            return path;
        }

        // 셀 스타일 업데이트
        function updateCellStyles() {
            document.querySelectorAll('.grid-cell').forEach(cell => {
                cell.classList.remove('selected', 'found', 'first-selected');
                
                const row = parseInt(cell.dataset.row);
                const col = parseInt(cell.dataset.col);
                
                if (selectedCells.some(c => c.row === row && c.col === col)) {
                    cell.classList.add('selected');
                    // 첫 번째 셀 표시
                    if (firstCell && firstCell.row === row && firstCell.col === col && selectedCells.length === 1) {
                        cell.classList.add('first-selected');
                    }
                } else if (isFoundCell(row, col)) {
                    cell.classList.add('found');
                }
            });
        }

        function isFoundCell(row, col) {
            const cell = grid[row][col];
            if (!cell.isWord) return false;
            const wordIndex = cell.wordIndex;
            return foundWords.includes(words[wordIndex]);
        }

        // 단어 체크
        function checkWord() {
            if (selectedCells.length < 2 || gameOver) {
                firstCell = null;
                selectedCells = [];
                updateCellStyles();
                return;
            }

            const selectedWord = selectedCells.map(cell => {
                const gridCell = grid[cell.row][cell.col];
                return gridCell.fullLetter || gridCell.letter;
            }).join('');
            
            if (words.includes(selectedWord) && !foundWords.includes(selectedWord)) {
                foundWords.push(selectedWord);
                renderWordList();
                updateScore();
                
                // 모든 단어를 찾았는지 확인
                if (foundWords.length === words.length) {
                    endGame(true);
                }
            }
            
            // 선택 초기화
            firstCell = null;
            selectedCells = [];
            updateCellStyles();
        }

        // 게임 리셋
        function resetGame() {
            clearInterval(timerInterval);
            difficulty = null;
            grid = [];
            words = [];
            wordListDisplay = [];
            foundWords = [];
            selectedCells = [];
            firstCell = null;
            score = 0;
            gameOver = false;
            
            document.getElementById('difficultyScreen').style.display = 'flex';
            var gs = document.getElementById('gameScreen');
            gs.classList.remove('active', 'difficulty-easy', 'difficulty-medium', 'difficulty-hard');
        }

        // 같은 난이도로 다시하기
        function replayGame() {
            const currentDifficulty = difficulty;
            clearInterval(timerInterval);
            foundWords = [];
            selectedCells = [];
            firstCell = null;
            score = 0;
            gameOver = false;
            
            // 완료 메시지 초기화
            document.getElementById('completionMessage').innerHTML = '';
            
            // 같은 난이도로 새 게임 시작
            startGame(currentDifficulty);
        }
    </script>
</body>
</html>

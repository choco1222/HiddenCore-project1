<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>카드 뒤집기 게임</title>
    <link rel="stylesheet" href="../../../assets/css/card.css">
</head>
<body>
    <div class="container">
        <div id="menuScreen" class="menu">
            <h1>🎮 카드 뒤집기</h1>
            <p>난이도를 선택하세요</p>
            <button class="difficulty-btn easy" onclick="startGame('easy')">
                <div>하 (쉬움)</div>
                <div class="difficulty-info">3x4 (12장) • 20초</div>
            </button>
            <button class="difficulty-btn medium" onclick="startGame('medium')">
                <div>중 (보통)</div>
                <div class="difficulty-info">4x4 (15장) • 30초</div>
            </button>
            <button class="difficulty-btn hard" onclick="startGame('hard')">
                <div>상 (어려움)</div>
                <div class="difficulty-info">4x5 (20장) • 40초</div>
            </button>
        </div>

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
            <button id="quitBtn" class="btn btn-secondary" onclick="resetGame()">포기하기</button>
        </div>
    </div>

    <script>
    
    <%
    // 테스트용 세션 설정
    session.setAttribute("user_id", "test_user");
    %>
    
        var card0 = '', card1 = '', card2 = '', card3 = '', card4 = '';
        var card5 = '', card6 = '', card7 = '', card8 = '', card9 = '';
        var card10 = '', card11 = '', card12 = '', card13 = '', card14 = '';
        var card15 = '', card16 = '', card17 = '', card18 = '', card19 = '';
        var card20 = '', card21 = '', card22 = '', card23 = '', card24 = '';

        var flipped0 = false, flipped1 = false, flipped2 = false, flipped3 = false, flipped4 = false;
        var flipped5 = false, flipped6 = false, flipped7 = false, flipped8 = false, flipped9 = false;
        var flipped10 = false, flipped11 = false, flipped12 = false, flipped13 = false, flipped14 = false;
        var flipped15 = false, flipped16 = false, flipped17 = false, flipped18 = false, flipped19 = false;
        var flipped20 = false, flipped21 = false, flipped22 = false, flipped23 = false, flipped24 = false;

        var matched0 = false, matched1 = false, matched2 = false, matched3 = false, matched4 = false;
        var matched5 = false, matched6 = false, matched7 = false, matched8 = false, matched9 = false;
        var matched10 = false, matched11 = false, matched12 = false, matched13 = false, matched14 = false;
        var matched15 = false, matched16 = false, matched17 = false, matched18 = false, matched19 = false;
        var matched20 = false, matched21 = false, matched22 = false, matched23 = false, matched24 = false;

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

            document.getElementById('menuScreen').classList.add('hidden');
            document.getElementById('gameScreen').classList.remove('hidden');
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
            flipped20 = false; flipped21 = false; flipped22 = false; flipped23 = false; flipped24 = false;

            matched0 = false; matched1 = false; matched2 = false; matched3 = false; matched4 = false;
            matched5 = false; matched6 = false; matched7 = false; matched8 = false; matched9 = false;
            matched10 = false; matched11 = false; matched12 = false; matched13 = false; matched14 = false;
            matched15 = false; matched16 = false; matched17 = false; matched18 = false; matched19 = false;
            matched20 = false; matched21 = false; matched22 = false; matched23 = false; matched24 = false;
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
            if (index === 20) return card20;
            if (index === 21) return card21;
            if (index === 22) return card22;
            if (index === 23) return card23;
            if (index === 24) return card24;
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
            if (id === 20) return flipped20;
            if (id === 21) return flipped21;
            if (id === 22) return flipped22;
            if (id === 23) return flipped23;
            if (id === 24) return flipped24;
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
            if (id === 20) flipped20 = val;
            if (id === 21) flipped21 = val;
            if (id === 22) flipped22 = val;
            if (id === 23) flipped23 = val;
            if (id === 24) flipped24 = val;
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
            if (id === 20) return matched20;
            if (id === 21) return matched21;
            if (id === 22) return matched22;
            if (id === 23) return matched23;
            if (id === 24) return matched24;
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
            if (id === 20) matched20 = val;
            if (id === 21) matched21 = val;
            if (id === 22) matched22 = val;
            if (id === 23) matched23 = val;
            if (id === 24) matched24 = val;
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
            if (matched20 === true) count = count + 1;
            if (matched21 === true) count = count + 1;
            if (matched22 === true) count = count + 1;
            if (matched23 === true) count = count + 1;
            if (matched24 === true) count = count + 1;
            
            if (count === totalCards) {
                return true;
            }
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
                if (currentLevel === 'medium'|| currentLevel === 'easy') {
                    score = score + 4;
                }
                document.getElementById('resultText').textContent = '🎉 성공!';
            } else {
                document.getElementById('resultText').textContent = '⏰ 시간 종료';
            }
            
            document.getElementById('finalScore').textContent = '최종 점수: ' + score + '점 / 100점';
        }

        function resetGame() {
            if (timer !== null) {
                clearInterval(timer);
            }
            document.getElementById('menuScreen').classList.remove('hidden');
            document.getElementById('gameScreen').classList.add('hidden');
        }

        function restartGame() {
            if (timer !== null) {
                clearInterval(timer);
            }
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
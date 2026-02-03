<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인지 기능 설문조사</title>
    <link rel="stylesheet" href="./css/style.css">
</head>
<body>
    <div class="container">
        <!-- Progress Bar -->
        <div class="progress-container">
            <div class="progress-bar" id="progressBar"></div>
        </div>

        <!-- Survey Content -->
        <div class="survey-wrapper">
            <!-- Question 1: 단어 외우기 -->
            <section class="survey-section active" id="section1">
                <div class="question-area">
                    <h1 class="question-title">다음 세 가지 단어를 기억해 주세요</h1>
                    <p class="question-description">아래 단어들을 잘 기억해 주세요. 잠시 후 다시 물어보겠습니다.</p>
                </div>
                
                <div class="answer-area">
                    <div class="word-display-single">
                        <div class="word-list">
                            <span class="word-item">비행기</span>
                            <span class="word-item">연필</span>
                            <span class="word-item">소나무</span>
                        </div>
                    </div>
                </div>

                <div class="button-container">
                    <button class="btn btn-primary" id="nextBtn1" onclick="nextSection(1)" disabled>
                        <span id="timerText">3초 후 다음으로 이동할 수 있습니다</span>
                        <span id="nextText" style="display:none;">다음</span>
                    </button>
                </div>
            </section>

            <!-- Question 2: 단어 선택하기 (첫 번째) -->
            <section class="survey-section" id="section2">
                <div class="question-area">
                    <h1 class="question-title">방금 본 단어 3개를 선택해 주세요</h1>
                    <p class="question-description">앞에서 보신 세 가지 단어를 아래에서 찾아 선택해 주세요.</p>
                </div>
                
                <div class="answer-area">
                    <div class="word-selection">
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="비행기" onchange="checkWordLimit('word1')">
                            <span class="word-label">비행기</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="자동차" onchange="checkWordLimit('word1')">
                            <span class="word-label">자동차</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="연필" onchange="checkWordLimit('word1')">
                            <span class="word-label">연필</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="지우개" onchange="checkWordLimit('word1')">
                            <span class="word-label">지우개</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="소나무" onchange="checkWordLimit('word1')">
                            <span class="word-label">소나무</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="장미" onchange="checkWordLimit('word1')">
                            <span class="word-label">장미</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="기차" onchange="checkWordLimit('word1')">
                            <span class="word-label">기차</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="공책" onchange="checkWordLimit('word1')">
                            <span class="word-label">공책</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="은행나무" onchange="checkWordLimit('word1')">
                            <span class="word-label">은행나무</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word1" value="백합" onchange="checkWordLimit('word1')">
                            <span class="word-label">백합</span>
                        </label>
                    </div>
                </div>

                <div class="button-container">
                    <button class="btn btn-secondary" onclick="prevSection(2)">이전</button>
                    <button class="btn btn-primary" onclick="nextSection(2)">다음</button>
                </div>
            </section>

            <!-- Question 3: 시계 그리기 -->
            <section class="survey-section" id="section3">
                <div class="question-area">
                    <h1 class="question-title">11시 10분을 나타내는 시계를 그려주세요</h1>
                    <p class="question-description">아래 시계판에 시침과 분침을 그려주세요.</p>
                </div>
                
                <div class="answer-area">
                    <div class="clock-container">
                        <canvas id="clockCanvas" width="400" height="400"></canvas>
                        <button class="btn-reset" onclick="resetClock()">다시 그리기</button>
                    </div>
                </div>

                <div class="button-container">
                    <button class="btn btn-secondary" onclick="prevSection(3)">이전</button>
                    <button class="btn btn-primary" onclick="nextSection(3)">다음</button>
                </div>
            </section>

            <!-- Question 4: 단어 선택하기 (두 번째) -->
            <section class="survey-section" id="section4">
                <div class="question-area">
                    <h1 class="question-title">처음에 기억했던 단어 3개를 다시 선택해 주세요</h1>
                    <p class="question-description">맨 처음 보셨던 세 가지 단어를 아래에서 찾아 선택해 주세요.</p>
                </div>
                
                <div class="answer-area">
                    <div class="word-selection">
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="비행기" onchange="checkWordLimit('word2')">
                            <span class="word-label">비행기</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="기차" onchange="checkWordLimit('word2')">
                            <span class="word-label">기차</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="연필" onchange="checkWordLimit('word2')">
                            <span class="word-label">연필</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="공책" onchange="checkWordLimit('word2')">
                            <span class="word-label">공책</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="소나무" onchange="checkWordLimit('word2')">
                            <span class="word-label">소나무</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="은행나무" onchange="checkWordLimit('word2')">
                            <span class="word-label">은행나무</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="버스" onchange="checkWordLimit('word2')">
                            <span class="word-label">버스</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="볼펜" onchange="checkWordLimit('word2')">
                            <span class="word-label">볼펜</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="단풍나무" onchange="checkWordLimit('word2')">
                            <span class="word-label">단풍나무</span>
                        </label>
                        <label class="word-option">
                            <input type="checkbox" name="word2" value="국화" onchange="checkWordLimit('word2')">
                            <span class="word-label">국화</span>
                        </label>
                    </div>
                </div>

                <div class="button-container">
                    <button class="btn btn-secondary" onclick="prevSection(4)">이전</button>
                    <button class="btn btn-primary" onclick="submitSurvey()">제출하기</button>
                </div>
            </section>

            <!-- Completion Page -->
            <section class="survey-section" id="completion">
                <div class="completion-message">
                    <div class="success-icon">✓</div>
                    <h1 class="completion-title">설문이 완료되었습니다</h1>
                    <p class="completion-description">응답해 주셔서 감사합니다.</p>
                </div>
                
                <div class="button-container">
                    <button class="btn btn-primary btn-large" onclick="goToMemberComplete()">다음</button>
                </div>
            </section>
        </div>
    </div>

    <script src="./js/survey-script.js"></script>
</body>
</html>

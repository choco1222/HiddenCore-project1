<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>인지 기능 설문조사</title>
    <link rel="stylesheet" href="../assets/css/style.css">
    <style>
        /* survey: 프레임 비율 유지·반응형, 내부 절대 짤리지 않게 */
        .page-survey { overflow-x: hidden; }
        .page-survey .app-frame {
            box-sizing: border-box;
            width: 100%;
            max-width: min(440px, 100vw);
            min-width: 0;
            overflow-x: hidden;
            overflow-y: auto;
        }
        .page-survey .app-frame .container {
            max-width: 100%;
            width: 100%;
            min-width: 0;
            box-sizing: border-box;
            padding: clamp(0.5rem, 4%, 1.5rem);
        }
        .page-survey .survey-wrapper {
            max-width: 100%;
            min-width: 0;
            padding: clamp(0.75rem, 4%, 2.5rem);
            min-height: 0;
            box-sizing: border-box;
            overflow-x: hidden;
        }
        .page-survey .question-area,
        .page-survey .answer-area,
        .page-survey .word-display-single,
        .page-survey .word-list,
        .page-survey .word-selection,
        .page-survey .clock-container { max-width: 100%; min-width: 0; box-sizing: border-box; }
        .page-survey .question-title {
            font-size: clamp(1rem, 4.2vw, 1.75rem);
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        .page-survey .question-description {
            font-size: clamp(0.8rem, 2.5vw, 1.1rem);
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        .page-survey .question-area { margin-bottom: clamp(0.75rem, 2.5vw, 2rem); padding-bottom: clamp(0.75rem, 1.5vw, 1.5rem); }
        .page-survey .answer-area { margin-bottom: clamp(0.75rem, 2.5vw, 2rem); }
        .page-survey .word-list { padding: clamp(0.75rem, 4%, 2rem); }
        .page-survey .word-item { font-size: clamp(1.1rem, 3.5vw, 2rem); overflow-wrap: break-word; }
        .page-survey .word-card { max-width: 100%; box-sizing: border-box; min-width: 0; }
        .page-survey .word-selection { grid-template-columns: repeat(auto-fit, minmax(72px, 1fr)); }
        .page-survey .word-label { font-size: clamp(0.9rem, 2.5vw, 1.25rem); padding: clamp(0.6rem, 2vw, 1rem) clamp(0.75rem, 2.5vw, 1.25rem); }
        .page-survey .clock-container { margin: clamp(0.5rem, 1.5vw, 1.5rem) auto; }
        .page-survey #clockCanvas { max-width: 100%; max-height: min(48vh, 340px); display: block; margin: 0 auto; }
        .page-survey .progress-container { max-width: 100%; margin-bottom: clamp(0.5rem, 2vw, 2rem); }
        .page-survey .button-container { margin-top: clamp(0.75rem, 2.5vw, 2rem); flex-wrap: wrap; gap: 0.5rem; }
        .page-survey .btn { min-width: 0; padding: clamp(0.6rem, 1.5vw, 1rem) clamp(1rem, 3vw, 2rem); font-size: clamp(0.85rem, 2.2vw, 1.1rem); }
    </style>
</head>
<body class="page-survey">
    <div class="app-frame app-frame-center">
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
                <!-- 정답 단어 표시 -->
                <div class="answer-area">
                    <div class="word-display-single">
                        <div class="word-list"></div> 
                    </div>
                </div>

                <div class="button-container">
                    <button class="btn btn-primary" id="nextBtn1" onclick="nextSection(1)" disabled>
                        <span id="timerText">3초 후 다음으로 이동할 수 있습니다</span>
                        <span id="nextText" style="display:none;">다음</span>
                    </button>
                </div>
            </section>

            <!-- Question 1: 단어 선택하기 -->
            <section class="survey-section" id="section2">
                <div class="question-area">
                    <h1 class="question-title">방금 본 단어 3개를 선택해 주세요</h1>
                    <p class="question-description">앞에서 보신 세 가지 단어를 아래에서 찾아 선택해 주세요.</p>
                </div>
                <!-- 선택 단어 표시 -->
                <div class="answer-area">
                    <div class="word-selection"></div>
                </div>

                <div class="button-container">
                    <button class="btn btn-secondary" onclick="prevSection(2)">이전</button>
                    <button class="btn btn-primary" onclick="nextSection(2)">다음</button>
                </div>
            </section>

            <!-- Question 3: 시계 그리기 -->
            <section class="survey-section" id="section3">
                <div class="question-area">
                    <h1 class="question-title">시계를 그려주세요</h1>
                    <p class="question-description">아래에 시계와 시침, 분침을 그려주세요.</p>
                </div>
                
                <div class="answer-area">
                    <div class="clock-container">
                        <canvas id="clockCanvas" width="500" height="500"></canvas>
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
                <!-- 선택 단어 표시 -->
                <div class="answer-area">
                    <div class="word-selection"></div>
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
    </div>

    <script src="../assets/js/survey-script.js"></script>
</body>
</html>

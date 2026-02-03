<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>하루 일과 기록</title>
    <link rel="stylesheet" href="./css/style.css">
    <link rel="stylesheet" href="./css/routineInput.css">
</head>
<body>
    <div class="container">
        <div class="survey-wrapper">
            <div class="question-area">
                <h1 class="question-title">간단한<br>하루 일과를 기록해주세요</h1>
                <p class="question-description">더 정확한 관리 서비스를 위해 검사를 시행해주세요.</p>
            </div>

            <form class="routine-form" id="routineForm" onsubmit="handleRoutineSubmit(event)">
                <div class="answer-area">
                    <!-- 식사 시간 입력 섹션 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">1. 식사 시간을 알려주세요!</h3>
                        
                        <!-- 아침 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="breakfastCheck" onchange="toggleMeal('breakfast')">
                                <span class="routine-label">아침</span>
                            </label>
                            <input type="time" id="breakfastTime" class="time-input" disabled>
                        </div>

                        <!-- 점심 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="lunchCheck" onchange="toggleMeal('lunch')">
                                <span class="routine-label">점심</span>
                            </label>
                            <input type="time" id="lunchTime" class="time-input" disabled>
                        </div>

                        <!-- 저녁 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="dinnerCheck" onchange="toggleMeal('dinner')">
                                <span class="routine-label">저녁</span>
                            </label>
                            <input type="time" id="dinnerTime" class="time-input" disabled>
                        </div>
                    </div>

                    <!-- 복약 시간 입력 섹션 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">2. 복약 시간을 알려주세요!</h3>
                        
                        <div class="medication-controls">
                            <button type="button" class="btn-none" id="noMedicationBtn" onclick="toggleNoMedication()">
                                없음
                            </button>
                        </div>

                        <!-- 아침 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="medicationBreakfastCheck" onchange="toggleMedication('breakfast')">
                                <span class="routine-label">아침</span>
                            </label>
                            <input type="time" id="medicationBreakfastTime" class="time-input" disabled>
                        </div>

                        <!-- 점심 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="medicationLunchCheck" onchange="toggleMedication('lunch')">
                                <span class="routine-label">점심</span>
                            </label>
                            <input type="time" id="medicationLunchTime" class="time-input" disabled>
                        </div>

                        <!-- 저녁 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="medicationDinnerCheck" onchange="toggleMedication('dinner')">
                                <span class="routine-label">저녁</span>
                            </label>
                            <input type="time" id="medicationDinnerTime" class="time-input" disabled>
                        </div>

                        <!-- 그외 -->
                        <div class="routine-item">
                            <label class="routine-checkbox">
                                <input type="checkbox" id="medicationOtherCheck" onchange="toggleMedication('other')">
                                <span class="routine-label">그외</span>
                            </label>
                            <input type="time" id="medicationOtherTime" class="time-input" disabled>
                        </div>
                    </div>
                </div>

                <div class="button-container">
                    <button type="submit" class="btn btn-primary btn-large">제출하기</button>
                </div>
            </form>
        </div>
    </div>

    <script src="./js/routine-script.js"></script>
</body>
</html>

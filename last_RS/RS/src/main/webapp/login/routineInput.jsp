<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>하루 일과 기록</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>
    <div class="app-frame">
    <div class="container">
        <div class="survey-wrapper">
            <!-- 제목 영역 -->
            <div class="question-area">
                <h1 class="question-title">간단한<br>하루 일과를 기록해주세요.</h1>
                <p class="question-description">더 정확한 관리 서비스를 위해 검사를 시행해주세요.</p>
            </div>

            <!-- 폼 영역 -->
            <form class="routine-form" id="routineForm" action="${pageContext.request.contextPath}/patient/careRoutine" method="post">
                <div class="answer-area">
                    
                    <!-- 1. 기상 시간 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">1. 기상 시간을 알려주세요!</h3>
                        
                        <div class="routine-item-single">
                            <input type="time" id="wakeTime" class="time-input-large" required>
                        </div>
                    </div>

                    <!-- 2. 수면 시간 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">2. 수면 시간을 알려주세요!</h3>
                        
                        <div class="routine-item-single">
                            <input type="time" id="sleepTime" class="time-input-large" required>
                        </div>
                    </div>
                    
                    <!-- 3. 식사 시간 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">3. 식사 시간을 알려주세요!</h3>
                        
                        <!-- 아침 -->
                        <div class="routine-item">
                            <div class="routine-checkbox-group">
                                <input type="checkbox" id="breakfast" value="breakfast" onchange="toggleMeal('breakfast')">
                                <label for="breakfast" class="routine-label">아침</label>
                            </div>
                            <input type="time" id="breakfastTime" class="time-input" disabled>
                        </div>

                        <!-- 점심 -->
                        <div class="routine-item">
                            <div class="routine-checkbox-group">
                                <input type="checkbox" id="lunch" value="lunch" onchange="toggleMeal('lunch')">
                                <label for="lunch" class="routine-label">점심</label>
                            </div>
                            <input type="time" id="lunchTime" class="time-input" disabled>
                        </div>

                        <!-- 저녁 -->
                        <div class="routine-item">
                            <div class="routine-checkbox-group">
                                <input type="checkbox" id="dinner" value="dinner" onchange="toggleMeal('dinner')">
                                <label for="dinner" class="routine-label">저녁</label>
                            </div>
                            <input type="time" id="dinnerTime" class="time-input" disabled>
                        </div>
                    </div>

                    <!-- 4. 복약 시간 -->
                    <div class="routine-section">
                        <h3 class="routine-section-title">4. 복약 시간을 알려주세요!</h3>
                        
                        <div id="medicationList">
                            <!-- 기상 후 -->
                            <div class="medication-item" data-index="0">
                                <div class="medication-row">
                                    <div class="medication-checkbox">
                                        <input type="checkbox" id="med0" onchange="toggleMedication(0)">
                                        <label for="med0" class="routine-label">기상 후</label>
                                    </div>
                                    <div class="time-display" id="wakeTimeDisplay">기상 시간을 먼저 입력해주세요</div>
                                </div>
                            </div>

                            <!-- 식후 -->
                            <div class="medication-item" data-index="1">
                                <div class="medication-row">
                                    <div class="medication-time-group">
                                        <div class="medication-checkbox">
                                            <input type="checkbox" id="med1" onchange="toggleMedication(1)" disabled>
                                            <label for="med1" class="routine-label medication-disabled-label">식후</label>
                                            <span class="hint-text">(식사 시간을 먼저 입력해주세요)</span>
                                        </div>
                                        <div class="meal-checkbox-group" id="mealCheckboxGroup">
                                            <label class="meal-checkbox">
                                                <input type="checkbox" id="medBreakfast" value="breakfast" disabled>
                                                <span class="meal-label">아침</span>
                                                <span class="meal-time" id="medBreakfastTime">-</span>
                                            </label>
                                            <label class="meal-checkbox">
                                                <input type="checkbox" id="medLunch" value="lunch" disabled>
                                                <span class="meal-label">점심</span>
                                                <span class="meal-time" id="medLunchTime">-</span>
                                            </label>
                                            <label class="meal-checkbox">
                                                <input type="checkbox" id="medDinner" value="dinner" disabled>
                                                <span class="meal-label">저녁</span>
                                                <span class="meal-time" id="medDinnerTime">-</span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- 취침 전 -->
                            <div class="medication-item" data-index="2">
                                <div class="medication-row">
                                    <div class="medication-checkbox">
                                        <input type="checkbox" id="med2" onchange="toggleMedication(2)">
                                        <label for="med2" class="routine-label">취침 전</label>
                                    </div>
                                    <div class="time-display" id="sleepTimeDisplay">수면 시간을 먼저 입력해주세요</div>
                                </div>
                            </div>

                            <!-- 그 외 -->
                            <div class="medication-item" data-index="3">
                                <div class="medication-row">
                                    <div class="medication-checkbox">
                                        <input type="checkbox" id="med3" onchange="toggleMedication(3)">
                                        <label for="med3" class="routine-label">그 외</label>
                                    </div>
                                    <input type="time" id="medTime3" class="time-input" disabled>
                                    <button type="button" class="btn-icon-only btn-delete" onclick="removeMedication(3)" style="display:none;">
                                        <span>×</span>
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- 추가 버튼 -->
                        <button type="button" class="btn-add-medication" onclick="addMedication()">
                            <span class="add-icon">+</span>
                            <span>복약 시간 추가</span>
                        </button>
                    </div>

                </div>

                <!-- 제출 버튼 -->
                <div class="button-container">
                    <button type="submit" class="btn btn-primary btn-large">제출하기</button>
                </div>
            </form>
        </div>
    </div>
    </div>

    <script src="../assets/js/routine-script.js"></script>
</body>
</html>

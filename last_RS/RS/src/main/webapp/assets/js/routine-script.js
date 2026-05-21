// 복약 카운터
let medicationCount = 4; // 기본 4개

/**
 * 페이지 로드 시 초기화
 */
document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('routineForm');
    if (form) {
        form.addEventListener('submit', handleRoutineSubmit);
    }
    
    // 기상 시간 입력 이벤트
    const wakeTimeInput = document.getElementById('wakeTime');
    if (wakeTimeInput) {
        wakeTimeInput.addEventListener('change', updateWakeTimeDisplay);
    }
    
    // 수면 시간 입력 이벤트
    const sleepTimeInput = document.getElementById('sleepTime');
    if (sleepTimeInput) {
        sleepTimeInput.addEventListener('change', updateSleepTimeDisplay);
    }
});

/**
 * 기상 시간 표시 업데이트
 */
function updateWakeTimeDisplay() {
    const wakeTime = document.getElementById('wakeTime').value;
    const display = document.getElementById('wakeTimeDisplay');
    
    if (wakeTime) {
        display.textContent = wakeTime;
        display.classList.add('time-display-active');
    } else {
        display.textContent = '기상 시간을 먼저 입력해주세요';
        display.classList.remove('time-display-active');
    }
}

/**
 * 수면 시간 표시 업데이트
 */
function updateSleepTimeDisplay() {
    const sleepTime = document.getElementById('sleepTime').value;
    const display = document.getElementById('sleepTimeDisplay');
    
    if (sleepTime) {
        display.textContent = sleepTime;
        display.classList.add('time-display-active');
    } else {
        display.textContent = '수면 시간을 먼저 입력해주세요';
        display.classList.remove('time-display-active');
    }
}

/**
 * 식사 시간 체크박스 토글
 */
function toggleMeal(mealType) {
    const checkbox = document.getElementById(mealType);
    const timeInput = document.getElementById(mealType + 'Time');
    
    if (checkbox.checked) {
        // 체크하면 시간 입력 활성화
        timeInput.disabled = false;
        timeInput.focus();
        
        // 시간 입력 시 복약-식후 업데이트
        timeInput.addEventListener('change', updateMealMedication);
    } else {
        // 체크 해제하면 비활성화
        timeInput.disabled = true;
        timeInput.value = '';
        
        // 복약-식후에서 해당 식사 비활성화
        updateMealMedication();
    }
}

/**
 * 복약-식후 옵션 업데이트
 */
function updateMealMedication() {
    const breakfast = document.getElementById('breakfast');
    const lunch = document.getElementById('lunch');
    const dinner = document.getElementById('dinner');
    
    const breakfastTime = document.getElementById('breakfastTime').value;
    const lunchTime = document.getElementById('lunchTime').value;
    const dinnerTime = document.getElementById('dinnerTime').value;
    
    // 식후 복약 메인 체크박스
    const med1 = document.getElementById('med1');
    const med1Label = document.querySelector('label[for="med1"]');
    const hintText = document.querySelector('.hint-text');
    
    // 하나라도 식사 시간이 입력되면 활성화
    const hasMealTime = (breakfast.checked && breakfastTime) || 
                        (lunch.checked && lunchTime) || 
                        (dinner.checked && dinnerTime);
    
    if (hasMealTime) {
        med1.disabled = false;
        med1Label.classList.remove('medication-disabled-label');
        if (hintText) hintText.style.display = 'none';
    } else {
        med1.disabled = true;
        med1.checked = false;
        med1Label.classList.add('medication-disabled-label');
        if (hintText) hintText.style.display = 'inline';
    }
    
    // 각 식사별 체크박스 및 시간 표시
    updateMealCheckbox('breakfast', breakfast.checked && breakfastTime, breakfastTime);
    updateMealCheckbox('lunch', lunch.checked && lunchTime, lunchTime);
    updateMealCheckbox('dinner', dinner.checked && dinnerTime, dinnerTime);
}

/**
 * 개별 식사 체크박스 업데이트
 */
function updateMealCheckbox(mealType, isAvailable, time) {
    const checkbox = document.getElementById('med' + mealType.charAt(0).toUpperCase() + mealType.slice(1));
    const timeDisplay = document.getElementById('med' + mealType.charAt(0).toUpperCase() + mealType.slice(1) + 'Time');
    
    if (isAvailable) {
        checkbox.disabled = false;
        timeDisplay.textContent = time;
        timeDisplay.classList.add('meal-time-active');
    } else {
        checkbox.disabled = true;
        checkbox.checked = false;
        timeDisplay.textContent = '-';
        timeDisplay.classList.remove('meal-time-active');
    }
}

/**
 * 복약 시간 체크박스 토글
 */
function toggleMedication(index) {
    const checkbox = document.getElementById('med' + index);
    
    if (index === 0) {
        // 기상 후 - 체크만 토글
        console.log('기상 후:', checkbox.checked);
    } else if (index === 1) {
        // 식후 - 체크만 토글 (하위 체크박스는 별도)
        console.log('식후:', checkbox.checked);
    } else if (index === 2) {
        // 취침 전 - 체크만 토글
        console.log('취침 전:', checkbox.checked);
    } else {
        // 그 외 - 시간 입력 활성화
        const timeInput = document.getElementById('medTime' + index);
        const deleteBtn = document.querySelector(`[data-index="${index}"] .btn-delete`);
        
        if (checkbox.checked) {
            if (timeInput) {
                timeInput.disabled = false;
                timeInput.focus();
            }
            if (index >= 4 && deleteBtn) {
                deleteBtn.style.display = 'flex';
            }
        } else {
            if (timeInput) {
                timeInput.disabled = true;
                timeInput.value = '';
            }
            if (deleteBtn) {
                deleteBtn.style.display = 'none';
            }
        }
    }
}

/**
 * 복약 시간 추가
 */
function addMedication() {
    const medicationList = document.getElementById('medicationList');
    const newIndex = medicationCount++;
    
    const newItem = document.createElement('div');
    newItem.className = 'medication-item';
    newItem.setAttribute('data-index', newIndex);
    newItem.style.opacity = '0';
    newItem.style.transform = 'translateY(-10px)';
    
    newItem.innerHTML = `
        <div class="medication-row">
            <div class="medication-checkbox">
                <input type="checkbox" id="med${newIndex}" onchange="toggleMedication(${newIndex})">
                <label for="med${newIndex}" class="routine-label">그 외</label>
            </div>
            <input type="time" id="medTime${newIndex}" class="time-input" disabled>
            <button type="button" class="btn-icon-only btn-delete" onclick="removeMedication(${newIndex})">
                <span>×</span>
            </button>
        </div>
    `;
    
    medicationList.appendChild(newItem);
    
    // 애니메이션
    setTimeout(() => {
        newItem.style.opacity = '1';
        newItem.style.transform = 'translateY(0)';
    }, 10);
}

/**
 * 복약 시간 삭제
 */
function removeMedication(index) {
    const item = document.querySelector(`[data-index="${index}"]`);
    if (item) {
        item.style.opacity = '0';
        item.style.transform = 'translateY(-10px)';
        
        setTimeout(() => {
            item.remove();
        }, 300);
    }
}

/**
 * 폼 제출 처리
 */
function handleRoutineSubmit(event) {
    event.preventDefault();
    
    console.log('=== 일과 데이터 수집 시작 ===');
    
    // 1. 기상 시간
    const wakeTime = document.getElementById('wakeTime').value;
    if (!wakeTime) {
        alert('기상 시간을 입력해주세요.');
        return;
    }
    
    // 기상 후 복약 여부 확인
    const wakeHasDrug = document.getElementById('med0').checked;
    console.log('기상 시간:', wakeTime, '복약:', wakeHasDrug);
    
    // 2. 수면 시간
    const sleepTime = document.getElementById('sleepTime').value;
    if (!sleepTime) {
        alert('수면 시간을 입력해주세요.');
        return;
    }
    
    // 취침 전 복약 여부 확인
    const sleepHasDrug = document.getElementById('med2').checked;
    console.log('수면 시간:', sleepTime, '복약:', sleepHasDrug);
    
    // 3. 식사 시간 (여러 개 가능)
    const meals = [];
    ['breakfast', 'lunch', 'dinner'].forEach(mealType => {
        const checkbox = document.getElementById(mealType);
        const timeInput = document.getElementById(mealType + 'Time');
        
        if (checkbox.checked) {
            if (!timeInput.value) {
                alert(`${getMealName(mealType)} 시간을 입력해주세요.`);
                throw new Error('Missing meal time');
            }
            
            // 해당 식사에 복약이 있는지 확인
            const mealName = mealType.charAt(0).toUpperCase() + mealType.slice(1);
            const medCheckbox = document.getElementById('med' + mealName);
            const hasDrug = medCheckbox && medCheckbox.checked && !medCheckbox.disabled;
            
            meals.push({
                type: mealType,
                time: timeInput.value,
                hasDrug: hasDrug  // 복약 여부 추가
            });
        }
    });
    
    console.log('식사 시간:', meals);
    
    // 4. 복약 시간
    const medications = [];
    
    // 기상 후
    if (document.getElementById('med0').checked) {
        medications.push({
            type: 'after_waking',
            time: wakeTime
        });
    }
    
    // 식후
    if (document.getElementById('med1').checked) {
        const selectedMeals = [];
        ['Breakfast', 'Lunch', 'Dinner'].forEach(meal => {
            const checkbox = document.getElementById('med' + meal);
            if (checkbox && checkbox.checked && !checkbox.disabled) {
                selectedMeals.push(meal.toLowerCase());
            }
        });
        
        if (selectedMeals.length > 0) {
            medications.push({
                type: 'after_meal',
                meals: selectedMeals
            });
        }
    }
    
    // 취침 전
    if (document.getElementById('med2').checked) {
        medications.push({
            type: 'before_sleep',
            time: sleepTime
        });
    }
    
    // 그 외
    document.querySelectorAll('.medication-item').forEach((item) => {
        const index = item.getAttribute('data-index');
        if (parseInt(index) >= 3) {
            const checkbox = document.getElementById('med' + index);
            const timeInput = document.getElementById('medTime' + index);
            
            if (checkbox && checkbox.checked) {
                if (!timeInput || !timeInput.value) {
                    alert('복약 시간을 입력해주세요.');
                    throw new Error('Missing medication time');
                }
                
                medications.push({
                    type: 'other',
                    time: timeInput.value
                });
            }
        }
    });
    
    console.log('복약 시간:', medications);
    
    // 데이터 수집 완료
    const routineData = {
        wakeTime: wakeTime,
        wakeHasDrug: wakeHasDrug,      // 기상 후 복약
        sleepTime: sleepTime,
        sleepHasDrug: sleepHasDrug,    // 취침 전 복약
        meals: meals,
        medications: medications
    };
    
    console.log('수집된 데이터:', routineData);
    console.log('=== 수집 완료 ===');
    
    // 서버로 전송
    submitRoutineToServer(routineData);
}

/**
 * 식사명 한글 변환
 */
function getMealName(mealType) {
    const names = {
        breakfast: '아침',
        lunch: '점심',
        dinner: '저녁'
    };
    return names[mealType] || mealType;
}

/**
 * 서버로 데이터 전송
 */
function submitRoutineToServer(routineData) {
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    
    fetch(contextPath + '/patient/saveRoutine', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(routineData)
    })
    .then(response => response.json())
    .then(data => {
        console.log('서버 응답:', data);
        
        if (data.success) {
            console.log('✓ 일과 저장 성공');
            alert('일과가 저장되었습니다.');
            
            // 다음 페이지로 이동
            window.location.href = contextPath + '/active/main.jsp';
        } else {
            console.error('✗ 저장 실패:', data.message);
            alert('저장에 실패했습니다: ' + data.message);
        }
    })
    .catch(error => {
        console.error('✗ 통신 오류:', error);
        alert('서버와의 통신에 실패했습니다.');
    });
}
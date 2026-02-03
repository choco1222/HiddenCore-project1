// Meal toggle
function toggleMeal(mealType) {
    const checkbox = document.getElementById(mealType + 'Check');
    const timeInput = document.getElementById(mealType + 'Time');
    
    if (checkbox.checked) {
        timeInput.disabled = false;
        timeInput.required = true;
    } else {
        timeInput.disabled = true;
        timeInput.required = false;
        timeInput.value = '';
    }
}

// Medication toggle
let noMedication = false;

function toggleMedication(medicationType) {
    const checkbox = document.getElementById('medication' + capitalize(medicationType) + 'Check');
    const timeInput = document.getElementById('medication' + capitalize(medicationType) + 'Time');
    
    if (checkbox.checked) {
        timeInput.disabled = false;
        noMedication = false;
        document.getElementById('noMedicationBtn').classList.remove('active');
    } else {
        timeInput.disabled = true;
        timeInput.value = '';
    }
}

function toggleNoMedication() {
    noMedication = !noMedication;
    const btn = document.getElementById('noMedicationBtn');
    
    if (noMedication) {
        btn.classList.add('active');
        // 모든 복약 체크박스와 시간 초기화
        ['breakfast', 'lunch', 'dinner', 'other'].forEach(function(type) {
            const checkbox = document.getElementById('medication' + capitalize(type) + 'Check');
            const timeInput = document.getElementById('medication' + capitalize(type) + 'Time');
            checkbox.checked = false;
            timeInput.disabled = true;
            timeInput.value = '';
        });
    } else {
        btn.classList.remove('active');
    }
}

// Capitalize first letter
function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
}

// Form submit
function handleRoutineSubmit(event) {
    event.preventDefault();
    
    // 적어도 하나의 식사는 입력해야 함
    const breakfastCheck = document.getElementById('breakfastCheck').checked;
    const lunchCheck = document.getElementById('lunchCheck').checked;
    const dinnerCheck = document.getElementById('dinnerCheck').checked;
    
    if (!breakfastCheck && !lunchCheck && !dinnerCheck) {
        alert('적어도 하나의 식사 시간을 입력해주세요.');
        return;
    }
    
    // 선택된 식사의 시간이 입력되었는지 확인
    if (breakfastCheck && !document.getElementById('breakfastTime').value) {
        alert('아침 식사 시간을 입력해주세요.');
        return;
    }
    if (lunchCheck && !document.getElementById('lunchTime').value) {
        alert('점심 식사 시간을 입력해주세요.');
        return;
    }
    if (dinnerCheck && !document.getElementById('dinnerTime').value) {
        alert('저녁 식사 시간을 입력해주세요.');
        return;
    }
    
    // 데이터 수집
    const routineData = {
        meals: {
            breakfast: breakfastCheck ? document.getElementById('breakfastTime').value : null,
            lunch: lunchCheck ? document.getElementById('lunchTime').value : null,
            dinner: dinnerCheck ? document.getElementById('dinnerTime').value : null
        },
        medication: noMedication ? null : {
            breakfast: document.getElementById('medicationBreakfastCheck').checked ? 
                document.getElementById('medicationBreakfastTime').value : null,
            lunch: document.getElementById('medicationLunchCheck').checked ? 
                document.getElementById('medicationLunchTime').value : null,
            dinner: document.getElementById('medicationDinnerCheck').checked ? 
                document.getElementById('medicationDinnerTime').value : null,
            other: document.getElementById('medicationOtherCheck').checked ? 
                document.getElementById('medicationOtherTime').value : null
        }
    };
    
    console.log('Routine Data:', routineData);
    
    // 백엔드로 전송
    sessionStorage.setItem('routineCompleted', 'true');
    
    alert('하루 일과가 등록되었습니다!');
    window.location.href = '/KTW/jsp/index.jsp';
}

// Get Korean meal name
function getKoreanMealName(type) {
    const names = {
        'breakfast': '아침',
        'lunch': '점심',
        'dinner': '저녁',
        'other': '그외'
    };
    return names[type] || type;
}

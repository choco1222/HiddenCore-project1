/**
 * [이게 뭔지] 월간 보고서 전용 로직. [뭘 썼는지] LOCAL_DATA(activeLog, gameLog), Chart.js.
 * [어디서] monthly.jsp에서 script로 삽입된 activeLogsJsonData, gameLogsJsonData → LOCAL_DATA. [어디로] displayMonthlyReport로 DOM에 렌더, 차트는 canvas에 그림.
 */
// Chart.js는 다른 차트(루틴 이행률, 게임)에서만 사용, 기분 차트는 Canvas 직접 그리기

// [이게 뭔지] 로컬 날짜를 yyyy-MM-dd 문자열로. toISOString()은 UTC라 서버 event_time과 어긋나므로 로컬 기준 사용.
function toLocalDateStr(d) {
    const y = d.getFullYear();
    const m = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return y + '-' + m + '-' + day;
}

// [이게 뭔지] played_at 값에서 날짜 부분만 반환. 서버는 "2026-02-04T10:00:00" 형식으로 보냄.
function getPlayedAtDate(playedAt) {
    if (!playedAt) return '';
    const s = String(playedAt);
    return s.indexOf('T') >= 0 ? s.split('T')[0] : s.substring(0, 10);
}

// [이게 뭔지] 선택한 날짜 기준 "전날부터 역으로 30일" 구간의 월간 리포트 데이터 계산. [어디서] LOCAL_DATA.activeLog, LOCAL_DATA.gameLog (서버에서 JSP로 넣은 JSON). [어디로] 반환 객체 → displayMonthlyReport(data).
function calculateMonthlyReportLocal(selectedDateInput) {
    // 선택한 날짜의 전날을 종료일로 설정 (시간 23:59:59.999)
    const selectedDate = new Date(selectedDateInput);
    const endDate = new Date(selectedDate);
    endDate.setDate(selectedDate.getDate() - 1);
    endDate.setHours(23, 59, 59, 999);
    // 시작일 = 종료일로부터 역으로 29일 전 → 기간 정확히 30일 (루틴 약점 총 누락 최대 90 = 30×3)
    const startDate = new Date(endDate.getTime() - 29 * 24 * 60 * 60 * 1000);
    startDate.setHours(0, 0, 0, 0);
    const startDateStr = toLocalDateStr(startDate);
    const endDateStr = toLocalDateStr(endDate);
    // 7일씩 주차로 나누기 (최대 4주차). [어디로] weeks 배열 → 주차별 통계 계산에 사용. 로컬 날짜 문자열로 해야 event_time과 매칭됨.
    const weeks = [];
    let currentDate = new Date(startDate);
    let weekNum = 1;
    
    // 4주차까지만 계산 (비교 계산용)
    while (currentDate <= endDate && weekNum <= 4) {
        const weekDates = [];
        const weekStart = new Date(currentDate);
        
        for (let i = 0; i < 7; i++) {
            const checkDate = new Date(weekStart);
            checkDate.setDate(weekStart.getDate() + i);
            
            if (checkDate > endDate) break; // 종료일을 넘어가면 중단
            
            weekDates.push(toLocalDateStr(checkDate));
        }
        
        if (weekDates.length > 0) {
            weeks.push({weekNum: weekNum, dates: weekDates});
            // 다음 주차는 7일 후부터
            currentDate.setDate(currentDate.getDate() + 7);
            weekNum++;
        } else {
            break; // 더 이상 날짜가 없으면 중단
        }
    }
    
    // [이게 뭔지] 주차별 루틴 통계 및 활동별 약점(누락/중복/취약 시간대). [어디로] routineWeaknessArray, weeklyStats, routineTrend 등.
    const weeklyStats = [];
    const routineWeakness = {
        '식사': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()},
        '복약': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()},
        '양치': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()}
    };
    // LOCAL_DATA는 monthly.jsp에서 activeLogsJsonData, gameLogsJsonData 파싱해 채움
    if (!LOCAL_DATA || !LOCAL_DATA.activeLog || !LOCAL_DATA.gameLog) {
        console.error('LOCAL_DATA가 제대로 초기화되지 않았습니다:', LOCAL_DATA);
        throw new Error('데이터가 로드되지 않았습니다. 페이지를 새로고침하세요.');
    }
    
    weeks.forEach((week, weekIndex) => {
        const weekRecords = LOCAL_DATA.activeLog.filter(r => 
            r && week.dates.includes(r.event_time) && r.event_type !== '외출복귀'
        );
        
        const activityStats = {
            '식사': {total: 0, duplicates: 0, omissions: 0, completed: 0},
            '복약': {total: 0, duplicates: 0, omissions: 0, completed: 0},
            '양치': {total: 0, duplicates: 0, omissions: 0, completed: 0}
        };
        
        const dailyCompletion = {};
        week.dates.forEach(date => {
            dailyCompletion[date] = {
                '식사': {아침: false, 점심: false, 저녁: false},
                '복약': {아침: false, 점심: false, 저녁: false},
                '양치': {아침: false, 점심: false, 저녁: false}
            };
        });
        
        weekRecords.forEach(record => {
            // routineType(아침/점심/저녁)이나 event_type이 없으면 스킵
            if (!record.routineType || !record.event_type) {
                console.warn('routineType 또는 event_type이 없는 레코드:', record);
                return;
            }
            
            const activity = activityStats[record.event_type];
            if (activity) {
                activity.total++;
                if (record.isDuplicate) {
                    activity.duplicates++;
                    routineWeakness[record.event_type].totalDuplicates++;
                } else {
                    dailyCompletion[record.event_time][record.event_type][record.routineType] = true;
                }
            }
        });
        
        // 누락 계산 (각 주차는 해당 주차의 일수 × 3시간대 기준)
        const expectedPerWeek = week.dates.length * 3;
        week.dates.forEach(date => {
            Object.entries(dailyCompletion[date]).forEach(([activityName, timeSlots]) => {
                Object.entries(timeSlots).forEach(([timeSlot, completed]) => {
                    if (!completed) {
                        activityStats[activityName].omissions++;
                        routineWeakness[activityName].totalOmissions++;
                        routineWeakness[activityName].weakTimeSlots.add(timeSlot);
                    } else {
                        activityStats[activityName].completed++;
                    }
                });
            });
        });
        
        // 주차별 평균 이행률 계산 (각 주차는 해당 주차의 일수 × 3시간대 기준)
        let totalCompletionRate = 0;
        Object.entries(activityStats).forEach(([activityName, stats]) => {
            const completionRate = expectedPerWeek > 0 ? (stats.completed / expectedPerWeek) * 100 : 0;
            routineWeakness[activityName].completionRates.push(completionRate);
            totalCompletionRate += completionRate;
        });
        
        weeklyStats.push({
            weekNum: weekIndex + 1,
            avgCompletionRate: totalCompletionRate / 3,
            activityStats: activityStats
        });
    });
    
    // [이게 뭔지] 루틴 약점(총 중복/총 누락)을 주차가 아닌 전체 기간 기준으로 재집계. 4주만 쓰면 말일이 빠져 합계가 적게 나옴.
    const allDatesInRange = [];
    for (let d = new Date(startDate.getTime()); d.getTime() <= endDate.getTime(); d.setDate(d.getDate() + 1)) {
        allDatesInRange.push(toLocalDateStr(new Date(d.getTime())));
    }
    const dateSet = new Set(allDatesInRange);
    // 총 중복: 기간 내 모든 레코드 중 isDuplicate true인 것
    ['식사', '복약', '양치'].forEach(act => {
        routineWeakness[act].totalDuplicates = 0;
        routineWeakness[act].totalOmissions = 0;
        routineWeakness[act].weakTimeSlots = new Set();
    });
    const completedSlots = {}; // { 'date': { '식사': { 아침: true, ... }, ... } }
    allDatesInRange.forEach(date => {
        completedSlots[date] = { '식사': { 아침: false, 점심: false, 저녁: false }, '복약': { 아침: false, 점심: false, 저녁: false }, '양치': { 아침: false, 점심: false, 저녁: false } };
    });
    LOCAL_DATA.activeLog.forEach(r => {
        if (!r || !dateSet.has(r.event_time) || r.event_type === '외출복귀') return;
        if (!r.event_type || !r.routineType) return;
        const act = r.event_type;
        if (act !== '식사' && act !== '복약' && act !== '양치') return;
        if (r.isDuplicate) {
            routineWeakness[act].totalDuplicates++;
        } else {
            if (completedSlots[r.event_time] && completedSlots[r.event_time][act]) {
                completedSlots[r.event_time][act][r.routineType] = true;
            }
        }
    });
    allDatesInRange.forEach(date => {
        ['식사', '복약', '양치'].forEach(act => {
            ['아침', '점심', '저녁'].forEach(slot => {
                if (!completedSlots[date][act][slot]) {
                    routineWeakness[act].totalOmissions++;
                    routineWeakness[act].weakTimeSlots.add(slot);
                }
            });
        });
    });
    
    // 루틴 약점 정리
    const routineWeaknessArray = Object.entries(routineWeakness).map(([activity, data]) => ({
        activity,
        totalOmissions: data.totalOmissions,
        totalDuplicates: data.totalDuplicates,
        avgCompletionRate: data.completionRates.length > 0 
            ? data.completionRates.reduce((a, b) => a + b, 0) / data.completionRates.length 
            : 0,
        weakTimeSlots: Array.from(data.weakTimeSlots)
    }));

    // [이게 뭔지] 한 달 기분 비율. 기간 내 activeLog에서 mood 6종(기쁨/평범/슬픔/화남/피곤/불안) 집계. [어디로] moodCounts → 원형 차트.
    const moodCounts = { '기쁨': 0, '평범': 0, '슬픔': 0, '화남': 0, '피곤': 0, '불안': 0 };
    (LOCAL_DATA.activeLog || []).forEach(r => {
        if (!r || !dateSet.has(r.event_time) || !r.mood) return;
        const m = String(r.mood).trim();
        if (moodCounts.hasOwnProperty(m)) moodCounts[m]++;
    });
    
    // 루틴 상태 변화 계산
    let completionScore = 0, duplicateScore = 0, omissionScore = 0;
    
    const weeklyDuplicates = weeklyStats.map(w => {
        return Object.values(w.activityStats).reduce((sum, stats) => sum + stats.duplicates, 0);
    });
    const weeklyOmissions = weeklyStats.map(w => {
        return Object.values(w.activityStats).reduce((sum, stats) => sum + stats.omissions, 0);
    });
    
    // 계산 과정 상세 저장
    const calculationDetails = [];
    
    for (let i = 0; i < weeklyStats.length - 1; i++) {
        let compChange = 0, dupChange = 0, omiChange = 0;
        
        if (weeklyStats[i] && weeklyStats[i + 1]) {
            const current = weeklyStats[i].avgCompletionRate;
            const next = weeklyStats[i + 1].avgCompletionRate;
            if (next > current) {
                completionScore += 1;
                compChange = 1;
            } else if (next < current) {
                completionScore -= 1;
                compChange = -1;
            }
        }
        
        if (weeklyDuplicates[i] !== undefined && weeklyDuplicates[i + 1] !== undefined) {
            const dupCurrent = weeklyDuplicates[i];
            const dupNext = weeklyDuplicates[i + 1];
            if (dupNext > dupCurrent) {
                duplicateScore -= 1;
                dupChange = -1;
            } else if (dupNext < dupCurrent) {
                duplicateScore += 1;
                dupChange = 1;
            }
        }
        
        if (weeklyOmissions[i] !== undefined && weeklyOmissions[i + 1] !== undefined) {
            const omiCurrent = weeklyOmissions[i];
            const omiNext = weeklyOmissions[i + 1];
            if (omiNext > omiCurrent) {
                omissionScore -= 1;
                omiChange = -1;
            } else if (omiNext < omiCurrent) {
                omissionScore += 1;
                omiChange = 1;
            }
        }
        
        calculationDetails.push({
            fromWeek: i + 1,
            toWeek: i + 2,
            completionRate: weeklyStats[i]?.avgCompletionRate || 0,
            nextCompletionRate: weeklyStats[i + 1]?.avgCompletionRate || 0,
            duplicates: weeklyDuplicates[i] || 0,
            nextDuplicates: weeklyDuplicates[i + 1] || 0,
            omissions: weeklyOmissions[i] || 0,
            nextOmissions: weeklyOmissions[i + 1] || 0,
            compChange,
            dupChange,
            omiChange,
            totalChange: compChange + dupChange + omiChange
        });
    }
    
    const totalScore = completionScore + duplicateScore + omissionScore;
    
    let routineTrend = {
        status: '유지', icon: '➡️', color: '#d1ecf1', borderColor: '#17a2b8', textColor: '#0c5460',
        description: '한 달 동안 루틴 이행률이 안정적으로 유지되었습니다.',
        completionScore,
        duplicateScore,
        omissionScore,
        totalScore,
        calculationDetails
    };
    
    if (totalScore > 0) {
        routineTrend = {
            status: '완화', icon: '📈', color: '#d4edda', borderColor: '#28a745', textColor: '#155724',
            description: '한 달 동안 루틴 이행률이 개선되었습니다.',
            completionScore,
            duplicateScore,
            omissionScore,
            totalScore,
            calculationDetails
        };
    } else if (totalScore < 0) {
        routineTrend = {
            status: '악화', icon: '📉', color: '#f8d7da', borderColor: '#dc3545', textColor: '#721c24',
            description: '한 달 동안 루틴 이행률이 감소했습니다.',
            completionScore,
            duplicateScore,
            omissionScore,
            totalScore,
            calculationDetails
        };
    }
    
    // 게임 주차별 평균 계산 (4주차까지만)
    // 게임 3종 고정 + 실제 데이터에서 나온 타입 병합 (WORD_GAME 등 누락 방지)
    const KNOWN_GAME_TYPES = ['CARD_GAME', 'COLOR_GAME', 'WORD_GAME'];
    const allGameRecords = LOCAL_DATA.gameLog || [];
    const fromData = [...new Set(allGameRecords.map(r => (r.game_type && String(r.game_type).trim()) || ''))].filter(t => t);
    const gameTypes = [...new Set([...KNOWN_GAME_TYPES, ...fromData])];
    
    const gameWeeklyAverages = {};
    gameTypes.forEach(gameType => {
        gameWeeklyAverages[gameType] = [];
    });
    
    function normGameType(v) { return v ? String(v).trim() : ''; }
    
    weeks.forEach(week => {
        gameTypes.forEach(gameType => {
            const weekGameRecords = LOCAL_DATA.gameLog.filter(r => 
                week.dates.includes(getPlayedAtDate(r.played_at)) && normGameType(r.game_type) === gameType
            );
            if (weekGameRecords.length > 0) {
                const avg = weekGameRecords.reduce((sum, r) => sum + r.score, 0) / weekGameRecords.length;
                gameWeeklyAverages[gameType].push(avg);
            } else {
                gameWeeklyAverages[gameType].push(0);
            }
        });
    });
    
    // 게임 상태 변화 계산 (전체 게임 평균 기준)
    // 각 주차별로 모든 게임의 평균 점수 계산
    const weeklyGameAverages = [];
    const maxWeeks = Math.max(...Object.values(gameWeeklyAverages).map(arr => arr.length));
    
    for (let i = 0; i < maxWeeks; i++) {
        let totalScore = 0;
        let gameCount = 0;
        
        gameTypes.forEach(gameType => {
            if (gameWeeklyAverages[gameType] && gameWeeklyAverages[gameType][i]) {
                totalScore += gameWeeklyAverages[gameType][i];
                gameCount++;
            }
        });
        
        const avgScore = gameCount > 0 ? totalScore / gameCount : 0;
        weeklyGameAverages.push(avgScore);
    }
    
    // 주차 간 비교 점수 계산
    let gameTotalScore = 0;
    const gameCalculationDetails = [];
    
    for (let i = 0; i < weeklyGameAverages.length - 1; i++) {
        const current = weeklyGameAverages[i];
        const next = weeklyGameAverages[i + 1];
        let change = 0;
        
        if (next > current) {
            change = 1;
            gameTotalScore += 1;
        } else if (next < current) {
            change = -1;
            gameTotalScore -= 1;
        }
        
        gameCalculationDetails.push({
            fromWeek: i + 1,
            toWeek: i + 2,
            currentAvg: current,
            nextAvg: next,
            change
        });
    }
    
    // 게임 상태 판정
    let gameTrend = {
        status: '유지', icon: '➡️', color: '#d1ecf1', borderColor: '#17a2b8', textColor: '#0c5460',
        description: '한 달 동안 게임 점수가 안정적으로 유지되었습니다.',
        totalScore: gameTotalScore,
        calculationDetails: gameCalculationDetails,
        weeklyAverages: weeklyGameAverages
    };
    
    if (gameTotalScore > 0) {
        gameTrend = {
            status: '완화', icon: '📈', color: '#d4edda', borderColor: '#28a745', textColor: '#155724',
            description: '한 달 동안 게임 점수가 향상되었습니다.',
            totalScore: gameTotalScore,
            calculationDetails: gameCalculationDetails,
            weeklyAverages: weeklyGameAverages
        };
    } else if (gameTotalScore < 0) {
        gameTrend = {
            status: '악화', icon: '📉', color: '#f8d7da', borderColor: '#dc3545', textColor: '#721c24',
            description: '한 달 동안 게임 점수가 감소했습니다.',
            totalScore: gameTotalScore,
            calculationDetails: gameCalculationDetails,
            weeklyAverages: weeklyGameAverages
        };
    }
    
    // 최종 종합 평가 (새로운 채점 기준)
    // 루틴 상태 변화 보고서 점수
    let routineStatusScore = 0;
    if (routineTrend.status === '완화') {
        routineStatusScore = 2;
    } else if (routineTrend.status === '유지') {
        routineStatusScore = 1;
    } else if (routineTrend.status === '악화') {
        routineStatusScore = -2;
    }
    
    // 게임 상태 변화 보고서 점수
    let gameStatusScore = 0;
    if (gameTrend.status === '완화') {
        gameStatusScore = 1;
    } else if (gameTrend.status === '유지') {
        gameStatusScore = 0;
    } else if (gameTrend.status === '악화') {
        gameStatusScore = -1;
    }
    
    // 총점 계산
    const finalTotalScore = routineStatusScore + gameStatusScore;
    
    // 최종 상태 판정
    let finalAssessment = {
        status: '유지', icon: '➡️',
        description: '이번 달 동안 전반적인 상태가 안정적으로 유지되었습니다.',
        routineStatusScore,
        gameStatusScore,
        totalScore: finalTotalScore
    };
    
    if (finalTotalScore > 1) {
        finalAssessment = {
            status: '완화', icon: '📈',
            description: '이번 달 동안 루틴 이행과 인지 기능이 개선되어 경도인지장애 증상이 완화되는 경향을 보입니다.',
            routineStatusScore,
            gameStatusScore,
            totalScore: finalTotalScore
        };
    } else if (finalTotalScore < 0) {
        finalAssessment = {
            status: '악화', icon: '📉',
            description: '이번 달 동안 루틴 이행과 인지 기능이 감소하여 경도인지장애 증상이 악화되는 경향을 보입니다.',
            routineStatusScore,
            gameStatusScore,
            totalScore: finalTotalScore
        };
    }
    
    // 기간 레이블 생성 (유동적)
    const startMonth = startDate.getMonth() + 1;
    const startDay = startDate.getDate();
    const endMonth = endDate.getMonth() + 1;
    const endDay = endDate.getDate();
    const year = startDate.getFullYear();
    
    let periodLabel = '';
    if (startMonth === endMonth) {
        periodLabel = `${year}년 ${startMonth}월 ${startDay}일 ~ ${endDay}일`;
    } else {
        periodLabel = `${year}년 ${startMonth}월 ${startDay}일 ~ ${endMonth}월 ${endDay}일`;
    }
    
    return {
        monthLabel: periodLabel,
        startDate: startDateStr,
        endDate: endDateStr, // 선택한 날짜의 전날
        moodCounts: moodCounts,
        routineWeakness: routineWeaknessArray,
        weeklyStats: weeklyStats.map(w => ({weekNum: w.weekNum, avgCompletionRate: w.avgCompletionRate})),
        routineTrend,
        gameWeeklyAverages,
        gameTrend,
        finalAssessment
    };
}

// [이게 뭔지] 월간 리포트 HTML 생성 후 화면에 표시. [뭘 썼는지] data = calculateMonthlyReportLocal 반환값. [어디로] monthlyReportContent innerHTML, 차트는 renderMonthlyWeeklyTrendChart/renderMonthlyGameChart로 canvas에 그림.
function displayMonthlyReport(data) {
    const contentDiv = document.getElementById('monthlyReportContent');
    
    if (!data || !data.monthLabel) {
        contentDiv.innerHTML = '<p style="color: red;">데이터를 불러올 수 없습니다.</p>';
        return;
    }
    
    let html = `
        <div class="score-display">
            <h2>${data.startDate} <br/> ~ <br/>${data.endDate}<br/>월간 분석 보고서</h2>
            
        </div>
    `;
    
    html += `
        <div class="chart-container" style="margin-top: 30px; padding: 20px; background: #fff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.08), 0 8px 24px rgba(0,0,0,0.06);">
            <h3 style="color: #8B6914; margin-bottom: 15px;">😊 한 달 기분 비율</h3>
            <div class="mood-chart-3d-perspective">
                <div class="mood-chart-3d-wrapper">
                <canvas id="moodChart"></canvas>
            </div>
            </div>
            <div id="moodChartLegend" class="mood-chart-legend"></div>
        </div>
        <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📊 루틴 약점 분석</h3>
            <table class="report-table routine-weakness-table">
                <thead>
                    <tr><th>활동</th><th>총<br>누락</th><th>총<br>중복</th><th>평균<br>이행률</th><th>약점<br>시간대</th></tr>
                </thead>
                <tbody>
    `;
    
    data.routineWeakness.forEach(item => {
        html += `
            <tr>
                <td>${item.activity}</td>
                <td>${item.totalOmissions}회</td>
                <td>${item.totalDuplicates}회</td>
                <td>${item.avgCompletionRate.toFixed(1)}%</td>
                <td>${item.weakTimeSlots.join(', ') || '없음'}</td>
            </tr>
        `;
    });
    
    html += '</tbody></table></div>';
    
    html += `
        <div class="chart-container" style="margin-top: 30px;">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📈 주차별 루틴 이행률 변화</h3>
            <canvas id="weeklyTrendChart"></canvas>
        </div>
    `;
    
    html += `
        <div style="margin-top: 30px; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📋 루틴 상태 변화 보고서</h3>
            <div style="padding: 15px; background: ${data.routineTrend.color}; border-left: 4px solid ${data.routineTrend.borderColor}; border-radius: 6px; margin-bottom: 20px;">
                <h4 style="margin: 0 0 10px 0; color: ${data.routineTrend.textColor};">
                    ${data.routineTrend.icon} ${data.routineTrend.status}
                </h4>
                <p style="margin: 0; color: ${data.routineTrend.textColor};">
                    ${data.routineTrend.description}
                </p>
            </div>
            
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-top: 20px;">
                <h4 onclick="toggleRoutineCalcDetails()" style="margin: 0 0 15px 0; color: #8B6914; font-size: 1.1rem; cursor: pointer; user-select: none; display: flex; align-items: center; justify-content: space-between;">
                    <span>📊 점수 계산 기준 및 과정</span>
                    <span id="routine-calc-toggle" style="font-size: 0.9rem; color: #666;">▼</span>
                </h4>
                <div id="routine-calc-details" style="display: none;">
                
                <div style="margin-bottom: 15px; padding: 12px; background: white; border-radius: 6px; border-left: 3px solid #FFE294;">
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>1. 이행률 점수 (completionScore)</strong></p>
                    <p style="margin: 0; font-size: 0.9rem; color: #666;">
                        다음 주차가 더 높으면: +1점, 더 낮으면: -1점, 같으면: 0점
                    </p>
                </div>
                
                <div style="margin-bottom: 15px; padding: 12px; background: white; border-radius: 6px; border-left: 3px solid #FFE294;">
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>2. 중복 횟수 점수 (duplicateScore)</strong></p>
                    <p style="margin: 0; font-size: 0.9rem; color: #666;">
                        다음 주차가 더 높으면: -1점 (중복 증가는 불리), 더 낮으면: +1점 (중복 감소는 유리), 같으면: 0점
                    </p>
                </div>
                
                <div style="margin-bottom: 15px; padding: 12px; background: white; border-radius: 6px; border-left: 3px solid #FFE294;">
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>3. 누락 횟수 점수 (omissionScore)</strong></p>
                    <p style="margin: 0; font-size: 0.9rem; color: #666;">
                        다음 주차가 더 높으면: -1점 (누락 증가는 불리), 더 낮으면: +1점 (누락 감소는 유리), 같으면: 0점
                    </p>
                </div>
                
                <div style="margin-bottom: 20px; padding: 12px; background: white; border-radius: 6px; border-left: 3px solid #28a745;">
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>4. 총점 계산</strong></p>
                    <p style="margin: 0; font-size: 0.9rem; color: #666;">
                        총점 = 이행률 점수 + 중복 점수 + 누락 점수
                    </p>
                </div>
                
                <div style="background: white; padding: 15px; border-radius: 6px; border: 1px solid #dee2e6;">
                    <p style="margin: 0 0 12px 0; font-size: 0.95rem;"><strong>📈 주차별 비교 결과</strong></p>
    `;
    
    if (data.routineTrend.calculationDetails && data.routineTrend.calculationDetails.length > 0) {
        data.routineTrend.calculationDetails.forEach((detail, idx) => {
            const compSign = detail.compChange > 0 ? '+' : (detail.compChange < 0 ? '-' : '0');
            const dupSign = detail.dupChange > 0 ? '+' : (detail.dupChange < 0 ? '-' : '0');
            const omiSign = detail.omiChange > 0 ? '+' : (detail.omiChange < 0 ? '-' : '0');
            const totalSign = detail.totalChange > 0 ? '+' : (detail.totalChange < 0 ? '' : '');
            
            html += `
                <div style="margin-bottom: ${idx < data.routineTrend.calculationDetails.length - 1 ? '12px' : '0'}; padding: 12px; background: #f8f9fa; border-radius: 4px;">
                    <p style="margin: 0 0 8px 0; font-size: 0.9rem; font-weight: bold; color: #495057;">
                        ${detail.fromWeek}주차 → ${detail.toWeek}주차:
                    </p>
                    <div style="padding-left: 10px; font-size: 0.85rem; color: #666;">
                        <p style="margin: 3px 0;">
                            이행률: ${detail.completionRate.toFixed(1)}% → ${detail.nextCompletionRate.toFixed(1)}% 
                            <span style="color: ${detail.compChange > 0 ? '#28a745' : detail.compChange < 0 ? '#dc3545' : '#6c757d'}; font-weight: bold;">
                                (${compSign}${Math.abs(detail.compChange)}점)
                            </span>
                        </p>
                        <p style="margin: 3px 0;">
                            중복: ${detail.duplicates}회 → ${detail.nextDuplicates}회 
                            <span style="color: ${detail.dupChange > 0 ? '#28a745' : detail.dupChange < 0 ? '#dc3545' : '#6c757d'}; font-weight: bold;">
                                (${dupSign}${Math.abs(detail.dupChange)}점)
                            </span>
                        </p>
                        <p style="margin: 3px 0;">
                            누락: ${detail.omissions}회 → ${detail.nextOmissions}회 
                            <span style="color: ${detail.omiChange > 0 ? '#28a745' : detail.omiChange < 0 ? '#dc3545' : '#6c757d'}; font-weight: bold;">
                                (${omiSign}${Math.abs(detail.omiChange)}점)
                            </span>
                        </p>
                        <p style="margin: 8px 0 0 0; padding-top: 8px; border-top: 1px solid #dee2e6; font-weight: bold; color: #495057;">
                            합계: ${totalSign}${detail.totalChange}점
                        </p>
                    </div>
                </div>
            `;
        });
    }
    
    html += `
                    <div style="margin-top: 15px; padding: 12px; background: ${data.routineTrend.color}; border-radius: 4px; border-left: 4px solid ${data.routineTrend.borderColor};">
                        <p style="margin: 0 0 5px 0; font-size: 0.95rem; font-weight: bold; color: ${data.routineTrend.textColor};">
                            최종 총점 계산:
                        </p>
                        <p style="margin: 0; font-size: 0.9rem; color: ${data.routineTrend.textColor};">
                            이행률 점수: ${data.routineTrend.completionScore > 0 ? '+' : ''}${data.routineTrend.completionScore}점<br>
                            중복 점수: ${data.routineTrend.duplicateScore > 0 ? '+' : ''}${data.routineTrend.duplicateScore}점<br>
                            누락 점수: ${data.routineTrend.omissionScore > 0 ? '+' : ''}${data.routineTrend.omissionScore}점<br>
                            <strong style="font-size: 1.05rem;">총점: ${data.routineTrend.totalScore > 0 ? '+' : ''}${data.routineTrend.totalScore}점</strong>
                        </p>
                        <p style="margin: 8px 0 0 0; padding-top: 8px; border-top: 1px solid rgba(0,0,0,0.1); font-size: 0.85rem; color: ${data.routineTrend.textColor};">
                            총점 ${data.routineTrend.totalScore > 0 ? '> 0' : data.routineTrend.totalScore < 0 ? '< 0' : '= 0'} → 
                            <strong>${data.routineTrend.status}</strong>
                        </p>
                    </div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    html += `
        <div class="chart-container" style="margin-top: 30px;">
            <h3 style="color: #8B6914; margin-bottom: 15px;">🎮 게임별 주차별 평균 점수</h3>
            <canvas id="gameWeeklyChart"></canvas>
        </div>
    `;
    
    html += `
        <div style="margin-top: 30px; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📋 게임 상태 변화 보고서</h3>
            <div style="padding: 15px; background: ${data.gameTrend.color}; border-left: 4px solid ${data.gameTrend.borderColor}; border-radius: 6px; margin-bottom: 20px;">
                <h4 style="margin: 0 0 10px 0; color: ${data.gameTrend.textColor};">
                    ${data.gameTrend.icon} ${data.gameTrend.status}
                </h4>
                <p style="margin: 0; color: ${data.gameTrend.textColor};">
                    ${data.gameTrend.description}
                </p>
            </div>
            
            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-top: 20px;">
                <h4 onclick="toggleGameCalcDetails()" style="margin: 0 0 15px 0; color: #8B6914; font-size: 1.1rem; cursor: pointer; user-select: none; display: flex; align-items: center; justify-content: space-between;">
                    <span>📊 점수 계산 기준</span>
                    <span id="game-calc-toggle" style="font-size: 0.9rem; color: #666;">▼</span>
                </h4>
                <div id="game-calc-details" style="display: none;">
                
                <div style="margin-bottom: 20px; padding: 12px; background: white; border-radius: 6px; border-left: 3px solid #FFE294;">
                    <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>게임 평균 점수 점수</strong></p>
                    <p style="margin: 0; font-size: 0.9rem; color: #666;">
                        다음 주차의 게임 평균 점수가 더 높으면: +1점, 더 낮으면: -1점, 같으면: 0점<br>
                        (각 주차별 게임1, 게임2, 게임3의 평균 점수를 비교)
                    </p>
                </div>
                
                <div style="background: white; padding: 15px; border-radius: 6px; border: 1px solid #dee2e6;">
                    <p style="margin: 0 0 12px 0; font-size: 0.95rem;"><strong>📈 주차별 비교 결과</strong></p>
    `;
    
    if (data.gameTrend.calculationDetails && data.gameTrend.calculationDetails.length > 0) {
        data.gameTrend.calculationDetails.forEach((detail, idx) => {
            const changeSign = detail.change > 0 ? '+' : (detail.change < 0 ? '-' : '0');
            
            html += `
                <div style="margin-bottom: ${idx < data.gameTrend.calculationDetails.length - 1 ? '12px' : '0'}; padding: 12px; background: #f8f9fa; border-radius: 4px;">
                    <p style="margin: 0 0 8px 0; font-size: 0.9rem; font-weight: bold; color: #495057;">
                        ${detail.fromWeek}주차 → ${detail.toWeek}주차:
                    </p>
                    <div style="padding-left: 10px; font-size: 0.85rem; color: #666;">
                        <p style="margin: 3px 0;">
                            게임 평균 점수: ${detail.currentAvg.toFixed(1)}점 → ${detail.nextAvg.toFixed(1)}점 
                            <span style="color: ${detail.change > 0 ? '#28a745' : detail.change < 0 ? '#dc3545' : '#6c757d'}; font-weight: bold;">
                                (${changeSign}${Math.abs(detail.change)}점)
                            </span>
                        </p>
                    </div>
                </div>
            `;
        });
    }
    
    html += `
                    <div style="margin-top: 15px; padding: 12px; background: ${data.gameTrend.color}; border-radius: 4px; border-left: 4px solid ${data.gameTrend.borderColor};">
                        <p style="margin: 0 0 5px 0; font-size: 0.95rem; font-weight: bold; color: ${data.gameTrend.textColor};">
                            최종 총점 계산:
                        </p>
                        <p style="margin: 0; font-size: 0.9rem; color: ${data.gameTrend.textColor};">
                            <strong style="font-size: 1.05rem;">총점: ${data.gameTrend.totalScore > 0 ? '+' : ''}${data.gameTrend.totalScore}점</strong>
                        </p>
                        <p style="margin: 8px 0 0 0; padding-top: 8px; border-top: 1px solid rgba(0,0,0,0.1); font-size: 0.85rem; color: ${data.gameTrend.textColor};">
                            총점 ${data.gameTrend.totalScore > 0 ? '> 0' : data.gameTrend.totalScore < 0 ? '< 0' : '= 0'} → 
                            <strong>${data.gameTrend.status}</strong>
                        </p>
                    </div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    html += `
        <div style="margin-top: 30px; padding: 25px; background: linear-gradient(135deg, #FFE294 0%, #FFF0C7 100%); border-radius: 8px; color: #8B6914;">
            <h3 style="margin: 0 0 20px 0; font-size: 1.5rem; text-align: center;">🏥 경도인지장애 종합 평가</h3>
            <div style="padding: 20px; background: rgba(255, 255, 255, 0.15); border-radius: 8px; backdrop-filter: blur(10px);">
                <div style="text-align: center; margin-bottom: 15px;">
                    <div style="font-size: 2.5rem; margin-bottom: 10px;">${data.finalAssessment.icon}</div>
                    <h4 style="margin: 0 0 10px 0; font-size: 1.3rem;">${data.finalAssessment.status}</h4>
                    <p style="margin: 0; font-size: 1.1rem; opacity: 0.95;">${data.finalAssessment.description}</p>
                </div>
                <div style="margin-top: 20px; padding-top: 20px; border-top: 1px solid rgba(255, 255, 255, 0.3);">
                    <div style="background: rgba(255, 255, 255, 0.1); padding: 15px; border-radius: 6px; margin-bottom: 15px;">
                        <h4 style="margin: 0 0 15px 0; font-size: 1.1rem;">📊 채점 기준 및 계산 과정</h4>
                        
                        <div style="margin-bottom: 12px; padding: 10px; background: rgba(255, 255, 255, 0.05); border-radius: 4px;">
                            <p style="margin: 0 0 5px 0; font-size: 0.95rem;"><strong>1. 루틴 상태 변화 보고서 점수</strong></p>
                            <p style="margin: 0; font-size: 0.9rem; opacity: 0.95;">
                                루틴 상태 변화 보고서 상태: <strong>${data.routineTrend.status}</strong>
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.85rem; opacity: 0.85;">
                                완화: +2점, 유지: +1점, 악화: -2점
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.95; font-weight: bold;">
                                → 루틴 상태 점수: ${data.finalAssessment.routineStatusScore > 0 ? '+' : ''}${data.finalAssessment.routineStatusScore}점
                            </p>
                        </div>
                        
                        <div style="margin-bottom: 12px; padding: 10px; background: rgba(255, 255, 255, 0.05); border-radius: 4px;">
                            <p style="margin: 0 0 5px 0; font-size: 0.95rem;"><strong>2. 게임 상태 변화 보고서 점수</strong></p>
                            <p style="margin: 0; font-size: 0.9rem; opacity: 0.95;">
                                게임 상태 변화 보고서 상태: <strong>${data.gameTrend.status}</strong>
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.85rem; opacity: 0.85;">
                                완화: +1점, 유지: 0점, 악화: -1점
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.95; font-weight: bold;">
                                → 게임 상태 점수: ${data.finalAssessment.gameStatusScore > 0 ? '+' : ''}${data.finalAssessment.gameStatusScore}점
                            </p>
                        </div>
                        
                        <div style="padding: 10px; background: rgba(255, 255, 255, 0.1); border-radius: 4px; border-left: 3px solid rgba(255, 255, 255, 0.5);">
                            <p style="margin: 0 0 5px 0; font-size: 0.95rem;"><strong>3. 종합 점수 계산 및 판정</strong></p>
                            <p style="margin: 0; font-size: 0.9rem; opacity: 0.95;">
                                루틴 상태 점수 + 게임 상태 점수 = 종합 점수
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.95;">
                                (${data.finalAssessment.routineStatusScore > 0 ? '+' : ''}${data.finalAssessment.routineStatusScore}) + (${data.finalAssessment.gameStatusScore > 0 ? '+' : ''}${data.finalAssessment.gameStatusScore}) = 
                                <strong style="font-size: 1.05rem;">${data.finalAssessment.totalScore > 0 ? '+' : ''}${data.finalAssessment.totalScore}점</strong>
                            </p>
                            <p style="margin: 8px 0 0 0; padding-top: 8px; border-top: 1px solid rgba(255, 255, 255, 0.2); font-size: 0.85rem; opacity: 0.85;">
                                판정 기준: 0 이상 1 이하 → 유지, 1보다 크면 → 완화, 0보다 작으면 → 악화
                            </p>
                            <p style="margin: 5px 0 0 0; font-size: 0.9rem; opacity: 0.95; font-weight: bold;">
                                최종 판정: <strong style="font-size: 1.05rem;">${data.finalAssessment.status}</strong>
                            </p>
                        </div>
                    </div>
                    
                    <div style="background: rgba(255, 255, 255, 0.1); padding: 12px; border-radius: 6px;">
                        <p style="margin: 0 0 8px 0; font-size: 0.95rem;"><strong>📋 최종 점수 요약</strong></p>
                        <p style="margin: 3px 0;"><strong>루틴 상태 점수:</strong> ${data.finalAssessment.routineStatusScore > 0 ? '+' : ''}${data.finalAssessment.routineStatusScore}점 (${data.routineTrend.status})</p>
                        <p style="margin: 3px 0;"><strong>게임 상태 점수:</strong> ${data.finalAssessment.gameStatusScore > 0 ? '+' : ''}${data.finalAssessment.gameStatusScore}점 (${data.gameTrend.status})</p>
                        <p style="margin: 8px 0 0 0; padding-top: 8px; border-top: 1px solid rgba(255, 255, 255, 0.2);">
                            <strong style="font-size: 1.05rem;">종합 점수: ${data.finalAssessment.totalScore > 0 ? '+' : ''}${data.finalAssessment.totalScore}점 → ${data.finalAssessment.status}</strong>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    contentDiv.innerHTML = html;
    
    // 차트 렌더링 (데이터가 있을 때만)
    renderMonthlyMoodChart(data.moodCounts || {});
    if (data.weeklyStats && data.weeklyStats.length > 0) {
        renderMonthlyWeeklyTrendChart(data.weeklyStats);
    }
    if (data.gameWeeklyAverages && Object.keys(data.gameWeeklyAverages).length > 0) {
        renderMonthlyGameChart(data.gameWeeklyAverages);
    }
}

// [이게 뭔지] Canvas 직접 그려서 Figma 디자인 구현: 3D 도넛(값 클수록 높이 증가), 꺾은선 라벨, 평평한 범례.
function renderMonthlyMoodChart(moodCounts) {
    const canvas = document.getElementById('moodChart');
    if (!canvas) return;
    
    // 기존 Chart.js 인스턴스가 있으면 파괴
    if (typeof Chart !== 'undefined' && Chart.getChart) {
        const existingChart = Chart.getChart(canvas);
        if (existingChart) {
            existingChart.destroy();
        }
    }
    
    const labels = ['기쁨', '불안', '슬픔', '평범', '화남', '피곤'];
    const counts = labels.map(l => moodCounts[l] || 0);
    const total = counts.reduce((a, b) => a + b, 0);
    if (total === 0) {
        const container = canvas.parentElement;
        if (container) {
            const msg = document.createElement('p');
            msg.style.cssText = 'text-align: center; color: #888; margin: 20px 0; font-size: 0.95rem;';
            msg.textContent = '해당 기간 기분 기록이 없습니다.';
            canvas.style.display = 'none';
            container.appendChild(msg);
        }
        return;
    }
    const colors = ['#FFE89A', '#7EC8D8', '#BBA5D0', '#9CD98E', '#F89898', '#FFBB78'];
    const ctx = canvas.getContext('2d');
    const dpr = window.devicePixelRatio || 1;
    const width = 480;
    const height = 360;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    canvas.style.width = width + 'px';
    canvas.style.height = height + 'px';
    ctx.scale(dpr, dpr);
    ctx.clearRect(0, 0, width, height);
    
    const centerX = width / 2;
    const baseY = height / 2 + 20; // 가장 낮은 슬라이스의 baseline
    const outerRadiusX = 85;
    const outerRadiusY = 55;
    const innerRadiusX = 42;
    const innerRadiusY = 27;
    const maxValue = Math.max(...counts);
    const minHeight = 5;
    const maxHeight = 35;
    
    let currentAngle = -Math.PI / 2;
    const slices = [];
    counts.forEach((value, i) => {
        const percent = total > 0 ? value / total : 0;
        const sweepAngle = percent * Math.PI * 2;
        const height = value > 0 ? minHeight + (value / maxValue) * (maxHeight - minHeight) : minHeight;
        slices.push({
            label: labels[i],
            value: value,
            color: colors[i],
            startAngle: currentAngle,
            endAngle: currentAngle + sweepAngle,
            height: height
        });
        currentAngle += sweepAngle;
    });
    
    // 높이 순으로 정렬 (낮은 것부터 그려서 높은 것이 위에 오도록)
    const sortedSlices = [...slices].sort((a, b) => a.height - b.height);
    
    // 그림자
    ctx.save();
    ctx.fillStyle = 'rgba(0, 0, 0, 0.12)';
    ctx.beginPath();
    ctx.ellipse(centerX, baseY + 8, outerRadiusX + 3, outerRadiusY + 3, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
    
    // 각 슬라이스를 높이 순으로 그림 (낮은 것부터)
    sortedSlices.forEach(slice => {
        if (slice.value === 0) return;
        
        const topY = baseY - slice.height; // 값이 클수록 위로 올라감
        
        // 시작각도 radial 측면 (좌측면)
        ctx.fillStyle = shadeColor(slice.color, -0.35);
        ctx.beginPath();
        ctx.moveTo(
            centerX + Math.cos(slice.startAngle) * outerRadiusX,
            topY + Math.sin(slice.startAngle) * outerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.startAngle) * innerRadiusX,
            topY + Math.sin(slice.startAngle) * innerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.startAngle) * innerRadiusX,
            baseY + Math.sin(slice.startAngle) * innerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.startAngle) * outerRadiusX,
            baseY + Math.sin(slice.startAngle) * outerRadiusY
        );
        ctx.closePath();
        ctx.fill();
        
        // 끝각도 radial 측면 (우측면)
        ctx.fillStyle = shadeColor(slice.color, -0.35);
        ctx.beginPath();
        ctx.moveTo(
            centerX + Math.cos(slice.endAngle) * outerRadiusX,
            topY + Math.sin(slice.endAngle) * outerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.endAngle) * outerRadiusX,
            baseY + Math.sin(slice.endAngle) * outerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.endAngle) * innerRadiusX,
            baseY + Math.sin(slice.endAngle) * innerRadiusY
        );
        ctx.lineTo(
            centerX + Math.cos(slice.endAngle) * innerRadiusX,
            topY + Math.sin(slice.endAngle) * innerRadiusY
        );
        ctx.closePath();
        ctx.fill();
        
        // 외부 호 측면
        ctx.fillStyle = shadeColor(slice.color, -0.25);
        ctx.beginPath();
        let a = slice.startAngle;
        ctx.moveTo(
            centerX + Math.cos(a) * outerRadiusX,
            topY + Math.sin(a) * outerRadiusY
        );
        while (a < slice.endAngle) {
            a += 0.01;
            if (a > slice.endAngle) a = slice.endAngle;
            ctx.lineTo(
                centerX + Math.cos(a) * outerRadiusX,
                topY + Math.sin(a) * outerRadiusY
            );
        }
        a = slice.endAngle;
        ctx.lineTo(
            centerX + Math.cos(a) * outerRadiusX,
            baseY + Math.sin(a) * outerRadiusY
        );
        while (a > slice.startAngle) {
            a -= 0.01;
            if (a < slice.startAngle) a = slice.startAngle;
            ctx.lineTo(
                centerX + Math.cos(a) * outerRadiusX,
                baseY + Math.sin(a) * outerRadiusY
            );
        }
        ctx.closePath();
        ctx.fill();
        
        // 내부 호 측면
        ctx.fillStyle = shadeColor(slice.color, -0.4);
        ctx.beginPath();
        a = slice.startAngle;
        ctx.moveTo(
            centerX + Math.cos(a) * innerRadiusX,
            topY + Math.sin(a) * innerRadiusY
        );
        while (a < slice.endAngle) {
            a += 0.01;
            if (a > slice.endAngle) a = slice.endAngle;
            ctx.lineTo(
                centerX + Math.cos(a) * innerRadiusX,
                topY + Math.sin(a) * innerRadiusY
            );
        }
        a = slice.endAngle;
        ctx.lineTo(
            centerX + Math.cos(a) * innerRadiusX,
            baseY + Math.sin(a) * innerRadiusY
        );
        while (a > slice.startAngle) {
            a -= 0.01;
            if (a < slice.startAngle) a = slice.startAngle;
            ctx.lineTo(
                centerX + Math.cos(a) * innerRadiusX,
                baseY + Math.sin(a) * innerRadiusY
            );
        }
        ctx.closePath();
        ctx.fill();
        
        // 상단 면 (원색, 테두리 없음)
        ctx.fillStyle = slice.color;
        ctx.beginPath();
        ctx.ellipse(centerX, topY, outerRadiusX, outerRadiusY, 0, slice.startAngle, slice.endAngle);
        ctx.ellipse(centerX, topY, innerRadiusX, innerRadiusY, 0, slice.endAngle, slice.startAngle, true);
        ctx.closePath();
        ctx.fill();
    });
    
    // 꺾은선 라벨 (기쁨 10, 불안 10 등) - 각 슬라이스의 높이에 맞춰
    slices.forEach(slice => {
        if (slice.value === 0) return;
        const midAngle = (slice.startAngle + slice.endAngle) / 2;
        const topY = baseY - slice.height; // 각 슬라이스의 상단 Y 좌표
        const x1 = centerX + Math.cos(midAngle) * (outerRadiusX - 3);
        const y1 = topY + Math.sin(midAngle) * (outerRadiusY - 3);
        const labelDist = 38;
        const x2 = centerX + Math.cos(midAngle) * (outerRadiusX + labelDist);
        const y2 = topY + Math.sin(midAngle) * (outerRadiusY + labelDist * 0.65);
        const horizLen = 28;
        const x3 = x2 + (Math.cos(midAngle) > 0 ? horizLen : -horizLen);
        const y3 = y2;
        
        ctx.strokeStyle = '#888';
        ctx.lineWidth = 1.5;
        ctx.beginPath();
        ctx.moveTo(x1, y1);
        ctx.lineTo(x2, y2);
        ctx.lineTo(x3, y3);
        ctx.stroke();
        
        const text = slice.label + ' ' + slice.value;
        ctx.fillStyle = '#333';
        ctx.font = 'bold 13px sans-serif';
        ctx.textAlign = Math.cos(midAngle) > 0 ? 'left' : 'right';
        ctx.textBaseline = 'middle';
        ctx.fillText(text, x3 + (Math.cos(midAngle) > 0 ? 5 : -5), y3 - 2);
    });
    
    // 범례: 기쁨 불안 슬픔 평범 화남 피곤 텍스트 옆에 동그라미에 Feel 이미지 (순서대로)
    const legendContainer = document.getElementById('moodChartLegend');
    if (legendContainer) {
        const baseUrl = (window.CTX || window.contextPath || '') + '/assets/images/calender/';
        const iconFiles = ['Feel=happy.png', 'Feel=Lonely.png', 'Feel=sad.png', 'Feel=calm.png', 'Feel=Angry.png', 'Embarrassed 1.png'];
        let legendHTML = '<div class="mood-chart-legend-items">';
        labels.forEach((label, i) => {
            const imgSrc = baseUrl + (iconFiles[i] || '').replace(/ /g, '%20');
            legendHTML += `
                <div class="mood-chart-legend-item">
                    <span class="mood-chart-legend-icon"><img src="${imgSrc}" alt="${label}"></span>
                    <span>${label}</span>
                </div>
            `;
        });
        legendHTML += '</div>';
        legendContainer.innerHTML = legendHTML;
    }
}

// 색상 명암 조절 (3D 측면용)
function shadeColor(color, percent) {
    const f = parseInt(color.slice(1), 16);
    const t = percent < 0 ? 0 : 255;
    const p = percent < 0 ? percent * -1 : percent;
    const R = f >> 16;
    const G = (f >> 8) & 0x00FF;
    const B = f & 0x0000FF;
    return '#' + (0x1000000 +
        (Math.round((t - R) * p) + R) * 0x10000 +
        (Math.round((t - G) * p) + G) * 0x100 +
        (Math.round((t - B) * p) + B)
    ).toString(16).slice(1);
}

// [이게 뭔지] 주차별 루틴 이행률 라인 차트. [뭘 썼는지] Chart.js. [어디서] weeklyStats (주차번호, avgCompletionRate). [어디로] id="weeklyTrendChart" canvas에 그림.
function renderMonthlyWeeklyTrendChart(weeklyStats) {
    const ctx = document.getElementById('weeklyTrendChart');
    if (!ctx || !weeklyStats || weeklyStats.length === 0) return;
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: weeklyStats.map(w => `${w.weekNum}주차`),
            datasets: [{
                label: '평균 이행률',
                data: weeklyStats.map(w => w.avgCompletionRate || 0),
                borderColor: '#667eea',
                backgroundColor: 'rgba(102, 126, 234, 0.1)',
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true,
                    max: 100,
                    title: {display: true, text: '이행률 (%)'}
                }
            }
        }
    });
}

// [이게 뭔지] 게임별 주차별 평균 점수 라인 차트. [뭘 썼는지] Chart.js. [어디서] gameWeeklyAverages { 게임타입: [주차별평균배열] }. [어디로] id="gameWeeklyChart" canvas에 그림.
function renderMonthlyGameChart(gameWeeklyAverages) {
    const ctx = document.getElementById('gameWeeklyChart');
    if (!ctx || !gameWeeklyAverages) return;
    
    // 실제 게임 타입 추출
    const gameTypes = Object.keys(gameWeeklyAverages);
    
    // 게임이 없으면 차트를 그리지 않음
    if (gameTypes.length === 0) {
        console.log('게임 데이터가 없어 차트를 건너뜁니다.');
        return;
    }
    
    // 최대 주차 계산 (최대 4주차)
    const maxWeeks = Math.min(
        Math.max(...Object.values(gameWeeklyAverages).map(arr => arr.length)),
        4
    );
    const labels = Array.from({length: maxWeeks}, (_, i) => `${i + 1}주차`);
    
    // 색상 팔레트
    const colors = [
        { border: '#667eea', bg: 'rgba(102, 126, 234, 0.1)' },
        { border: '#f093fb', bg: 'rgba(240, 147, 251, 0.1)' },
        { border: '#4facfe', bg: 'rgba(79, 172, 254, 0.1)' },
        { border: '#ff6b6b', bg: 'rgba(255, 107, 107, 0.1)' },
        { border: '#4ecdc4', bg: 'rgba(78, 205, 196, 0.1)' }
    ];
    
    // 동적으로 데이터셋 생성 (주차 수에 맞춰 길이 맞춤, 없으면 0)
    const datasets = gameTypes.map((gameType, index) => {
        const color = colors[index % colors.length];
        const arr = gameWeeklyAverages[gameType] || [];
        const data = Array.from({ length: maxWeeks }, (_, i) => arr[i] ?? 0);
        return {
            label: gameType,
            data: data,
            borderColor: color.border,
            backgroundColor: color.bg,
            tension: 0.4
        };
    });
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: datasets
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true,
                    max: 100,
                    title: {display: true, text: '평균 점수'}
                }
            }
        }
    });
}

// 루틴 점수 계산 기준 토글
function toggleRoutineCalcDetails() {
    const details = document.getElementById('routine-calc-details');
    const toggle = document.getElementById('routine-calc-toggle');
    if (details && toggle) {
        if (details.style.display === 'none') {
            details.style.display = 'block';
            toggle.textContent = '▲';
        } else {
            details.style.display = 'none';
            toggle.textContent = '▼';
        }
    }
}

// 게임 점수 계산 기준 토글
function toggleGameCalcDetails() {
    const details = document.getElementById('game-calc-details');
    const toggle = document.getElementById('game-calc-toggle');
    if (details && toggle) {
        if (details.style.display === 'none') {
            details.style.display = 'block';
            toggle.textContent = '▲';
        } else {
            details.style.display = 'none';
            toggle.textContent = '▼';
        }
    }
}
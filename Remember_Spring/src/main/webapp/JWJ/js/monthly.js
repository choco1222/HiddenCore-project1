// 월간 보고서 전용 로직

// 로컬 데이터로 월간 리포트 계산 (선택한 날짜의 전날부터 역으로 한 달 기간)
function calculateMonthlyReportLocal(selectedDateInput) {
    // 선택한 날짜의 전날을 종료일로 설정
    const selectedDate = new Date(selectedDateInput);
    const endDate = new Date(selectedDate);
    endDate.setDate(selectedDate.getDate() - 1); // 전날
    endDate.setHours(23, 59, 59, 999);
    
    // 종료일로부터 역으로 30일 전을 시작일로 설정
    const startDate = new Date(endDate);
    startDate.setDate(endDate.getDate() - 30); // 30일 전
    startDate.setHours(0, 0, 0, 0);
    
    const startDateStr = startDate.toISOString().split('T')[0];
    const endDateStr = endDate.toISOString().split('T')[0];
    
    // 7일씩 주차로 나누기 (시작일부터 종료일까지, 각 주차는 7일씩)
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
            
            weekDates.push(checkDate.toISOString().split('T')[0]);
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
    
    // 주차별 통계 계산
    const weeklyStats = [];
    const routineWeakness = {
        '식사': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()},
        '복약': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()},
        '양치': {totalOmissions: 0, totalDuplicates: 0, completionRates: [], weakTimeSlots: new Set()}
    };
    
    weeks.forEach((week, weekIndex) => {
        const weekRecords = LOCAL_DATA.activeLog.filter(r => 
            week.dates.includes(r.event_time) && r.event_type !== '외출복귀'
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
            const activity = activityStats[record.event_type];
            if (activity) {
                activity.total++;
                if (record.isDuplicate) {
                    activity.duplicates++;
                    routineWeakness[record.event_type].totalDuplicates++;
                } else {
                    dailyCompletion[record.event_time][record.event_type][record.timeSlot] = true;
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
    const gameWeeklyAverages = {
        '게임1': [], '게임2': [], '게임3': []
    };
    
    weeks.forEach(week => {
        ['게임1', '게임2', '게임3'].forEach(gameType => {
            const weekGameRecords = LOCAL_DATA.gameLog.filter(r => 
                week.dates.includes(r.played_at) && r.game_type === gameType
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
    // 각 주차별로 게임1, 게임2, 게임3의 평균 점수 계산
    const weeklyGameAverages = [];
    for (let i = 0; i < Math.max(gameWeeklyAverages['게임1'].length, gameWeeklyAverages['게임2'].length, gameWeeklyAverages['게임3'].length); i++) {
        const game1Score = gameWeeklyAverages['게임1'][i] || 0;
        const game2Score = gameWeeklyAverages['게임2'][i] || 0;
        const game3Score = gameWeeklyAverages['게임3'][i] || 0;
        const avgScore = (game1Score + game2Score + game3Score) / 3;
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
        routineWeakness: routineWeaknessArray,
        weeklyStats: weeklyStats.map(w => ({weekNum: w.weekNum, avgCompletionRate: w.avgCompletionRate})),
        routineTrend,
        gameWeeklyAverages,
        gameTrend,
        finalAssessment
    };
}

// 월간 리포트 화면 표시
function displayMonthlyReport(data) {
    const contentDiv = document.getElementById('monthlyReportContent');
    
    if (!data || !data.monthLabel) {
        contentDiv.innerHTML = '<p style="color: red;">데이터를 불러올 수 없습니다.</p>';
        return;
    }
    
    let html = `
        <div class="score-display">
            <h2>${data.monthLabel} 월간 분석 보고서</h2>
            <div class="completion-rate">${data.startDate} ~ ${data.endDate}</div>
        </div>
    `;
    
    html += `
        <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📊 루틴 약점 분석</h3>
            <table class="report-table">
                <thead>
                    <tr><th>활동</th><th>총 누락</th><th>총 중복</th><th>평균 이행률</th><th>약점 시간대</th></tr>
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
                <h4 style="margin: 0 0 15px 0; color: #8B6914; font-size: 1.1rem;">📊 점수 계산 기준 및 과정</h4>
                
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
                <h4 style="margin: 0 0 15px 0; color: #8B6914; font-size: 1.1rem;">📊 점수 계산 기준</h4>
                
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
    if (data.weeklyStats && data.weeklyStats.length > 0) {
        renderMonthlyWeeklyTrendChart(data.weeklyStats);
    }
    if (data.gameWeeklyAverages && Object.keys(data.gameWeeklyAverages).length > 0) {
        renderMonthlyGameChart(data.gameWeeklyAverages);
    }
}

// 월간 주차별 추이 차트
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

// 월간 게임 차트
function renderMonthlyGameChart(gameWeeklyAverages) {
    const ctx = document.getElementById('gameWeeklyChart');
    if (!ctx || !gameWeeklyAverages) return;
    
    // 4주차까지만 레이블 생성 (계산은 4주차까지만, 최대 4개)
    const maxWeeks = Math.min(
        Math.max(
            gameWeeklyAverages['게임1']?.length || 0,
            gameWeeklyAverages['게임2']?.length || 0,
            gameWeeklyAverages['게임3']?.length || 0
        ),
        4
    );
    const labels = Array.from({length: maxWeeks}, (_, i) => `${i + 1}주차`);
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '게임1',
                    data: gameWeeklyAverages['게임1'] || [],
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4
                },
                {
                    label: '게임2',
                    data: gameWeeklyAverages['게임2'] || [],
                    borderColor: '#f093fb',
                    backgroundColor: 'rgba(240, 147, 251, 0.1)',
                    tension: 0.4
                },
                {
                    label: '게임3',
                    data: gameWeeklyAverages['게임3'] || [],
                    borderColor: '#4facfe',
                    backgroundColor: 'rgba(79, 172, 254, 0.1)',
                    tension: 0.4
                }
            ]
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

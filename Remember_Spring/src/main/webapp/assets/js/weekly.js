// 주간 보고서 전용 로직

// 로컬 데이터로 주간 리포트 계산
function calculateWeeklyReportLocal(selectedDate) {
    // 선택한 날짜로부터 역으로 7일간 (선택한 날짜 포함)
    const selected = new Date(selectedDate);
    const end = new Date(selected);
    end.setHours(23, 59, 59, 999);
    
    const start = new Date(selected);
    start.setDate(selected.getDate() - 6); // 선택한 날짜 포함하여 7일간
    start.setHours(0, 0, 0, 0);
    
    const dates = [];
    const currentDate = new Date(start);
    while (currentDate <= end) {
        dates.push(currentDate.toISOString().split('T')[0]);
        currentDate.setDate(currentDate.getDate() + 1);
    }
    
    const startDate = dates[0];
    const endDate = dates[dates.length - 1];
    
    const weekRecords = LOCAL_DATA.activeLog.filter(r => 
        dates.includes(r.event_time) && r.event_type !== '외출복귀'
    );
    const outingRecords = LOCAL_DATA.activeLog.filter(r => 
        dates.includes(r.event_time) && r.event_type === '외출복귀'
    );
    const weekGameRecords = LOCAL_DATA.gameLog.filter(r => dates.includes(r.played_at));
    
    const activityStats = {
        '식사': {아침: {total: 0, duplicates: 0, omissions: 0}, 점심: {total: 0, duplicates: 0, omissions: 0}, 저녁: {total: 0, duplicates: 0, omissions: 0}},
        '복약': {아침: {total: 0, duplicates: 0, omissions: 0}, 점심: {total: 0, duplicates: 0, omissions: 0}, 저녁: {total: 0, duplicates: 0, omissions: 0}},
        '양치': {아침: {total: 0, duplicates: 0, omissions: 0}, 점심: {total: 0, duplicates: 0, omissions: 0}, 저녁: {total: 0, duplicates: 0, omissions: 0}}
    };
    
    const dailyCompletion = {};
    dates.forEach(date => {
        dailyCompletion[date] = {
            '식사_아침': false, '식사_점심': false, '식사_저녁': false,
            '복약_아침': false, '복약_점심': false, '복약_저녁': false,
            '양치_아침': false, '양치_점심': false, '양치_저녁': false
        };
    });
    
    weekRecords.forEach(record => {
        const stats = activityStats[record.event_type]?.[record.timeSlot];
        if (stats) {
            stats.total++;
            if (record.isDuplicate) {
                stats.duplicates++;
            } else {
                dailyCompletion[record.event_time][record.event_type + '_' + record.timeSlot] = true;
            }
        }
    });
    
    dates.forEach(date => {
        Object.keys(dailyCompletion[date]).forEach(key => {
            if (!dailyCompletion[date][key]) {
                const [activity, timeSlot] = key.split('_');
                activityStats[activity][timeSlot].omissions++;
            }
        });
    });
    
    function determineStatus(stats) {
        if (stats.duplicates > 0 && stats.omissions > 0) return '취약';
        if (stats.duplicates > 0) return '중복';
        if (stats.omissions > 0) return '취약';
        if (stats.total === 7) return '완벽';
        return '안정';
    }
    
    const detailedAnalysis = [];
    Object.entries(activityStats).forEach(([activity, timeSlots]) => {
        const 아침 = {...timeSlots.아침, status: determineStatus(timeSlots.아침)};
        const 점심 = {...timeSlots.점심, status: determineStatus(timeSlots.점심)};
        const 저녁 = {...timeSlots.저녁, status: determineStatus(timeSlots.저녁)};
        
        const summaryParts = [];
        if (아침.status === '완벽' && 점심.status === '완벽' && 저녁.status === '완벽') {
            summaryParts.push('모든 시간대 완벽');
        } else {
            if (아침.status === '취약') summaryParts.push('아침 취약');
            if (아침.status === '중복') summaryParts.push('아침 중복 주의');
            if (점심.status === '취약') summaryParts.push('점심 취약');
            if (점심.status === '중복') summaryParts.push('점심 중복 주의');
            if (저녁.status === '취약') summaryParts.push('저녁 취약');
            if (저녁.status === '중복') summaryParts.push('저녁 중복 주의');
        }
        
        detailedAnalysis.push({
            activity,
            아침, 점심, 저녁,
            summary: summaryParts.length > 0 ? summaryParts.join(', ') : '안정적'
        });
    });
    
    const activityDailyCounts = {};
    ['식사', '복약', '양치'].forEach(activity => {
        activityDailyCounts[activity] = dates.map(date => ({
            date,
            count: weekRecords.filter(r => r.event_time === date && r.event_type === activity).length
        }));
    });
    
    const gameDailyAverages = {};
    ['게임1', '게임2', '게임3'].forEach(gameType => {
        gameDailyAverages[gameType] = dates.map(date => {
            const scores = weekGameRecords.filter(r => r.played_at === date && r.game_type === gameType).map(r => r.score);
            return {
                date,
                averageScore: scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0
            };
        });
    });
    
    return {
        startDate: startDate,
        endDate: endDate,
        outingCount: outingRecords.length,
        detailedRoutineAnalysis: detailedAnalysis,
        activityDailyCounts,
        gameDailyAverages
    };
}

// 주간 리포트 화면 표시
function displayWeeklyReport(data) {
    const contentDiv = document.getElementById('weeklyReportContent');
    
    let html = '';
    
    if (data.outingCount >= 2 && data.outingCount <= 3) {
        html += `
            <div style="margin-bottom: 20px; padding: 15px; background: linear-gradient(135deg, #FFE294 0%, #FFF0C7 100%); border-radius: 8px; text-align: center; color: #8B6914;">
                <h3 style="margin: 0; font-size: 1.2rem;">🌟 일주일 동안 ${data.outingCount}번 외출하셨네요! 활기찬 한 주였어요! 🌟</h3>
            </div>
        `;
    }
    
    const formatDate = (dateStr) => {
        const [year, month, day] = dateStr.split('-');
        return `${year}/${parseInt(month)}/${parseInt(day)}`;
    };
    
    html += `
        <div class="chart-container">
            <h3 style="color: #8B6914; margin-bottom: 15px;">📈 ${formatDate(data.startDate)}~${formatDate(data.endDate)}</h3>
            <canvas id="activityChart"></canvas>
        </div>
        <h3 style="margin-top: 20px; margin-bottom: 15px; color: #8B6914;">📊 활동별 상세 분석</h3>
        <table class="analysis-table">
            <thead>
                <tr><th>활동</th><th>아침</th><th>점심</th><th>저녁</th><th>요약</th></tr>
            </thead>
            <tbody>
    `;
    
    data.detailedRoutineAnalysis.forEach(activity => {
        html += `<tr><td class="activity-name">${activity.activity}</td>`;
        
        [activity.아침, activity.점심, activity.저녁].forEach(timeData => {
            const statusClass = 'status-' + (timeData.status === '완벽' ? 'perfect' : 
                                             timeData.status === '안정' ? 'stable' : 
                                             timeData.status === '중복' ? 'duplicate' : 'weak');
            html += `
                <td class="time-slot-cell ${statusClass}">
                    <div class="time-slot-value">${timeData.total}회</div>
                    <div class="time-slot-status">${timeData.status}</div>
            `;
            if (timeData.duplicates > 0) {
                html += `<div class="time-slot-duplicate">중복 ${timeData.duplicates}회</div>`;
            }
            if (timeData.omissions > 0) {
                html += `<div class="time-slot-duplicate">누락 ${timeData.omissions}회</div>`;
            }
            html += `</td>`;
        });
        
        html += `<td class="summary-cell">${activity.summary}</td></tr>`;
    });
    
    html += '</tbody></table>';
    html += `
        <div class="chart-container">
            <h3 style="color: #8B6914; margin-bottom: 15px;">🎮 주간 게임 평균 점수 추이</h3>
            <canvas id="gameChart"></canvas>
        </div>
    `;
    
    contentDiv.innerHTML = html;
    
    renderWeeklyActivityChart(data.activityDailyCounts);
    renderWeeklyGameChart(data.gameDailyAverages);
}

// 주간 활동 차트
function renderWeeklyActivityChart(activityDailyCounts) {
    const ctx = document.getElementById('activityChart');
    if (!ctx) return;
    
    const labels = activityDailyCounts['식사'].map((item, index) => `${index + 1}일차`);
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '식사',
                    data: activityDailyCounts['식사'].map(item => item.count),
                    borderColor: '#28a745',
                    backgroundColor: 'rgba(40, 167, 69, 0.1)',
                    tension: 0.4
                },
                {
                    label: '복약',
                    data: activityDailyCounts['복약'].map(item => item.count),
                    borderColor: '#dc3545',
                    backgroundColor: 'rgba(220, 53, 69, 0.1)',
                    tension: 0.4
                },
                {
                    label: '양치',
                    data: activityDailyCounts['양치'].map(item => item.count),
                    borderColor: '#17a2b8',
                    backgroundColor: 'rgba(23, 162, 184, 0.1)',
                    tension: 0.4
                }
            ]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true,
                    title: {display: true, text: '기록 횟수 (회)'},
                    ticks: {stepSize: 1}
                }
            }
        }
    });
}

// 주간 게임 차트
function renderWeeklyGameChart(gameDailyAverages) {
    const ctx = document.getElementById('gameChart');
    if (!ctx) return;
    
    const labels = gameDailyAverages['게임1'].map((item, index) => `${index + 1}일차`);
    
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [
                {
                    label: '게임1',
                    data: gameDailyAverages['게임1'].map(item => item.averageScore),
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    tension: 0.4
                },
                {
                    label: '게임2',
                    data: gameDailyAverages['게임2'].map(item => item.averageScore),
                    borderColor: '#f093fb',
                    backgroundColor: 'rgba(240, 147, 251, 0.1)',
                    tension: 0.4
                },
                {
                    label: '게임3',
                    data: gameDailyAverages['게임3'].map(item => item.averageScore),
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
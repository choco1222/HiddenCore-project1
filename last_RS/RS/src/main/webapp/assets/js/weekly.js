/**
 * [이게 뭔지] 주간 보고서 전용 로직. [뭘 썼는지] LOCAL_DATA(activeLog, gameLog), Chart.js.
 * [어디서] weekly.jsp의 weeklyActiveLogsJsonData, weeklyGameLogsJsonData → LOCAL_DATA. [어디로] displayWeeklyReport로 DOM 렌더, 차트는 canvas에 그림.
 */

// [이게 뭔지] 로컬 날짜 yyyy-MM-dd. 서버 event_time과 맞추기 위해 toISOString(UTC) 대신 사용.
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

// [이게 뭔지] 선택한 날짜 포함 역으로 7일 구간의 주간 리포트 데이터 계산. [어디서] LOCAL_DATA.activeLog, LOCAL_DATA.gameLog. [어디로] 반환 객체 → displayWeeklyReport(data).
function calculateWeeklyReportLocal(selectedDate) {
    const selected = new Date(selectedDate);
    const end = new Date(selected);
    end.setHours(23, 59, 59, 999);
    const start = new Date(selected);
    start.setDate(selected.getDate() - 6); // 선택일 포함 7일
    start.setHours(0, 0, 0, 0);
    const dates = [];
    const currentDate = new Date(start);
    while (currentDate <= end) {
        dates.push(toLocalDateStr(new Date(currentDate.getTime())));
        currentDate.setDate(currentDate.getDate() + 1);
    }
    const startDate = dates[0];
    const endDate = dates[dates.length - 1];
    if (!LOCAL_DATA || !LOCAL_DATA.activeLog) {
        console.error('LOCAL_DATA가 제대로 초기화되지 않았습니다:', LOCAL_DATA);
        throw new Error('데이터가 로드되지 않았습니다. 페이지를 새로고침하세요.');
    }
    var gameLogList = Array.isArray(LOCAL_DATA.gameLog) ? LOCAL_DATA.gameLog : [];
    
    const weekRecords = LOCAL_DATA.activeLog.filter(r => 
        r && dates.includes(r.event_time) && r.event_type !== '외출복귀'
    );
    const outingRecords = LOCAL_DATA.activeLog.filter(r => 
        r && dates.includes(r.event_time) && r.event_type === '외출복귀'
    );
    const weekGameRecords = gameLogList.filter(r => r && (dates.includes(getPlayedAtDate(r.played_at)) || dates.includes(r.played_at)));
    
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
        // routineType(아침/점심/저녁)이나 event_type이 없으면 스킵
        if (!record.routineType || !record.event_type) {
            console.warn('routineType 또는 event_type이 없는 레코드:', record);
            return;
        }
        
        const stats = activityStats[record.event_type]?.[record.routineType];
        if (stats) {
            stats.total++;
            if (record.isDuplicate) {
                stats.duplicates++;
            } else {
                dailyCompletion[record.event_time][record.event_type + '_' + record.routineType] = true;
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
    // 실제 데이터에서 게임 타입 추출
    const gameTypes = [...new Set(weekGameRecords.map(r => r.game_type))].filter(t => t);
    
    gameTypes.forEach(gameType => {
        gameDailyAverages[gameType] = dates.map(date => {
            const scores = weekGameRecords.filter(r => getPlayedAtDate(r.played_at) === date && r.game_type === gameType).map(r => r.score);
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

// [이게 뭔지] 주간 리포트 HTML 생성 후 화면에 표시. [뭘 썼는지] data = calculateWeeklyReportLocal 반환값. [어디로] weeklyReportContent innerHTML, renderWeeklyActivityChart/renderWeeklyGameChart로 차트 그림.
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

// [이게 뭔지] report subject1.png 디자인: 카드형 요약/차트/활동별 상세(프로그레스 바)/게임 차트. [어디로] weeklyReportContent (주간 전용 페이지).
function displayWeeklyReportSubject1(data) {
    const contentDiv = document.getElementById('weeklyReportContent');
    if (!contentDiv) return;

    const formatDate = (dateStr) => {
        const [year, month, day] = dateStr.split('-').map(Number);
        return year + '/' + month + '/' + day;
    };

    let html = '';

    // 1. 요약 카드 (외출 메시지)
    const outingMsg = data.outingCount >= 1
        ? '일주일 동안 ' + data.outingCount + '번 외출하셨네요! 활기찬 한 주였어요!'
        : '이번 주도 꾸준히 기록해 보아요!';
    html += '<div class="weekly-summary-card">' + outingMsg + '</div>';

    // 2. 금주 활동 분석 차트
    html += '<div class="weekly-card">';
    html += '<h3>금주 활동 분석 차트</h3>';
    html += '<div class="date-range">' + formatDate(data.startDate) + ' - ' + formatDate(data.endDate) + '</div>';
    html += '<canvas id="activityChart" style="max-height: 220px;"></canvas>';
    html += '</div>';

    // 3. 활동별 상세 분석 (목업: 활동별 상세 분석 식사.png) - 식사/복약/양치 각각 mr-activity-card
    data.detailedRoutineAnalysis.forEach(function(act) {
        html += '<div class="mr-activity-card">';
        html += '<div class="mr-activity-title">' + act.activity + '</div>';
        var weakList = [];
        ['아침', '점심', '저녁'].forEach(function(timeLabel) {
            const slot = act[timeLabel];
            if (!slot) return;
            if (slot.status === '취약') weakList.push(timeLabel);
            const total = slot.total || 0, dup = slot.duplicates || 0, miss = slot.omissions || 0;
            const done = Math.max(0, total - dup);
            var wTotal = 0, wMiss = 0;  // wTotal = 총 클릭(노랑) 구간 %, 그 안에 중복(녹색) 비율
            var sum = done + dup + miss;
            if (sum > 0) {
                var scale = sum > 7 ? 7 / sum : 1;
                var pDone = (done * scale / 7) * 100, pDup = (dup * scale / 7) * 100, pMiss = (miss * scale / 7) * 100;
                var totalPct = pDone + pDup + pMiss;
                if (totalPct > 0) { pDone = pDone / totalPct * 100; pDup = pDup / totalPct * 100; pMiss = pMiss / totalPct * 100; }
                wTotal = pDone + pDup;
                wMiss = pMiss;
            } else {
                wMiss = 100;
            }
            var dupInTotal = (done + dup) > 0 ? (dup / (done + dup) * 100) : 0;  // 노랑 구간 안에서 중복(녹색)이 차지하는 비율
            wTotal = Number(wTotal.toFixed(1)); wMiss = Number(wMiss.toFixed(1)); dupInTotal = Number(dupInTotal.toFixed(1));
            html += '<div class="mr-time-row">';
            html += '<div class="mr-time-label">' + timeLabel + '</div>';
            html += '<div class="mr-bar-wrap">';
            html += '<div class="mr-bar-layer-miss"></div>';
            if (Number(wTotal) > 0) {
                html += '<div class="mr-bar-layer-total" style="width:' + wTotal + '%">';
                html += '<span class="mr-seg-total">';
                if (Number(dupInTotal) > 0) html += '<span class="mr-seg-dup-inner" style="width:' + dupInTotal + '%"></span>';
                html += '</span></div>';
            }
            html += '</div>';
            html += '<div class="mr-metrics">';
            html += '<span><span class="mr-icon mr-icon-clicks"></span>총 클릭 횟수: ' + total + '회</span>';
            html += '<span><span class="mr-icon mr-icon-dup"></span>중복: ' + dup + '회</span>';
            html += '<span><span class="mr-icon mr-icon-miss"></span>누락: ' + miss + '회</span>';
            html += '</div>';
            html += '</div>';
        });
        if (weakList.length) html += '<div class="mr-weak"><span class="mr-weak-label">취약</span> <span class="mr-weak-list">' + weakList.join(', ') + '</span></div>';
        html += '</div>';
    });

    // 4. 주간 게임 평균 점수
    html += '<div class="weekly-card">';
    html += '<h3>주간 게임 평균 점수</h3>';
    html += '<div class="date-range">주간 게임 평균 점수 추이</div>';
    html += '<canvas id="gameChart" style="max-height: 220px;"></canvas>';
    html += '</div>';

    contentDiv.innerHTML = html;
}

// [이게 뭔지] 주간 활동(식사/복약/양치) 일별 횟수 라인 차트. [뭘 썼는지] Chart.js. [어디서] activityDailyCounts { 식사/복약/양치: [{ date, count }] }. [어디로] id="activityChart" canvas.
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

// [이게 뭔지] 게임별 일별 평균 점수 라인 차트. [뭘 썼는지] Chart.js. [어디서] gameDailyAverages { 게임타입: [{ date, averageScore }] }. [어디로] id="gameChart" canvas.
function renderWeeklyGameChart(gameDailyAverages) {
    const ctx = document.getElementById('gameChart');
    const container = ctx ? ctx.parentElement : null;
    if (!ctx) return;
    
    // 실제 게임 타입 추출 (null/undefined 방어)
    const gameDaily = gameDailyAverages && typeof gameDailyAverages === 'object' ? gameDailyAverages : {};
    const gameTypes = Object.keys(gameDaily).filter(function(k) { return gameDaily[k] && Array.isArray(gameDaily[k]); });
    
    // 게임이 없으면 "데이터 없음" 표시 후 리턴
    if (gameTypes.length === 0) {
        if (container) {
            const msg = document.createElement('p');
            msg.style.cssText = 'padding: 24px; color: #666; text-align: center; margin: 0;';
            msg.textContent = '해당 기간 게임 기록이 없습니다.';
            ctx.style.display = 'none';
            container.appendChild(msg);
        }
        return;
    }
    
    // 첫 번째 게임의 일수로 라벨 생성
    const firstGameData = gameDaily[gameTypes[0]];
    const labels = firstGameData.map((item, index) => `${index + 1}일차`);
    
    // 색상 팔레트
    const colors = [
        { border: '#667eea', bg: 'rgba(102, 126, 234, 0.1)' },
        { border: '#f093fb', bg: 'rgba(240, 147, 251, 0.1)' },
        { border: '#4facfe', bg: 'rgba(79, 172, 254, 0.1)' },
        { border: '#ff6b6b', bg: 'rgba(255, 107, 107, 0.1)' },
        { border: '#4ecdc4', bg: 'rgba(78, 205, 196, 0.1)' }
    ];
    
    // 동적으로 데이터셋 생성
    const datasets = gameTypes.map((gameType, index) => {
        const color = colors[index % colors.length];
        return {
            label: gameType,
            data: gameDaily[gameType].map(item => item.averageScore),
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
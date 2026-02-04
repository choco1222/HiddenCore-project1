/* =========================
   alarmScheduler.js (stable)
   - OS Notification로 알림 표시
   - 폴링 없이: 루틴 1회 로드 -> 스케줄 생성 -> 식사는 30분 뒤 DB 1회 체크 -> 재알림
   - JSP/Servlet 환경에서 contextPath(프로젝트명) 포함 fetch 오류 방지
========================= */

const Alarm = (() => {
  // ====== 외부 설정(초기값) ======
  const CONFIG = {
    ctx: "",                // 예: "/memory_spring" (JSP에서 init로 주입)
    retryMinutes: 30,       // 재확인(식사) 기준
    debug: true,            // 콘솔 로그
    skipPastEvents: true,   // 이미 지난 이벤트는 예약 안 함
    midnightRebuild: true   // 자정 넘으면 재생성
  };

  // ====== 내부 상수 ======
  const LS_SENT_PREFIX = "alarm_sent:";
  const LS_RETRY_PREFIX = "alarm_retry_sent:";

  // ====== 로그 ======
  function log(...args) {
    if (CONFIG.debug) console.log("[Alarm]", ...args);
  }

  // ====== 날짜/시간 유틸 ======
  function pad2(n) { return String(n).padStart(2, "0"); }

  function todayStrLocal() {
    // ✅ local 기준 YYYY-MM-DD (toISOString는 UTC라 날짜가 틀어질 수 있음)
    const d = new Date();
    return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
  }

  function parseHHMM(hhmm) {
    // "08:00"만 허용
    if (typeof hhmm !== "string") return null;
    const m = hhmm.match(/^(\d{1,2}):(\d{2})$/);
    if (!m) return null;
    const hh = Number(m[1]);
    const mm = Number(m[2]);
    if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;
    return { hh, mm };
  }

  function dateAtToday(hhmm) {
    const t = parseHHMM(hhmm);
    if (!t) return null;
    const now = new Date();
    return new Date(now.getFullYear(), now.getMonth(), now.getDate(), t.hh, t.mm, 0, 0);
  }

  function addMinutes(dateObj, min) {
    const d = new Date(dateObj.getTime());
    d.setMinutes(d.getMinutes() + min);
    return d;
  }

  function hhmmOf(dateObj) {
    return `${pad2(dateObj.getHours())}:${pad2(dateObj.getMinutes())}`;
  }

  // ====== localStorage 중복 방지 ======
  function makeKey(userId, date, eventType, hhmm) {
    return `${userId}|${date}|${eventType}|${hhmm}`;
  }

  function wasSent(key) {
    return localStorage.getItem(LS_SENT_PREFIX + key) === "1";
  }
  function markSent(key) {
    localStorage.setItem(LS_SENT_PREFIX + key, "1");
  }
  function wasRetrySent(key) {
    return localStorage.getItem(LS_RETRY_PREFIX + key) === "1";
  }
  function markRetrySent(key) {
    localStorage.setItem(LS_RETRY_PREFIX + key, "1");
  }

  // (선택) 오늘 아닌 키 정리 — localStorage 폭주 방지
  function cleanupOldKeys(keepDate) {
    try {
      const removeKeys = [];
      for (let i = 0; i < localStorage.length; i++) {
        const k = localStorage.key(i);
        if (!k) continue;
        if (k.startsWith(LS_SENT_PREFIX) || k.startsWith(LS_RETRY_PREFIX)) {
          const raw = k.replace(LS_SENT_PREFIX, "").replace(LS_RETRY_PREFIX, "");
          // raw = user|date|type|hhmm
          const parts = raw.split("|");
          if (parts.length >= 2) {
            const date = parts[1];
            if (date !== keepDate) removeKeys.push(k);
          }
        }
      }
      removeKeys.forEach(k => localStorage.removeItem(k));
      if (removeKeys.length) log("cleanup removed", removeKeys.length);
    } catch (e) {
      // 실패해도 기능엔 영향 없게 조용히
      log("cleanupOldKeys skipped", e);
    }
  }

	
	async function ensureNotificationPermission() {
    if (!("Notification" in window)) {
      alert("이 브라우저는 Notification API를 지원하지 않습니다.");
      return false;
    }
    if (Notification.permission === "granted") return true;
    if (Notification.permission === "denied") {
      alert("알림 권한이 차단되어 있습니다. 브라우저 설정에서 허용해주세요.");
      return false;
    }
    
    const p = await Notification.requestPermission();
    return p === "granted";
  }

  function osNotify(title, body) {
    try {
      if (Notification.permission !== "granted") return;
      new Notification(title, { body });
    } catch (e) {
      log("osNotify error", e);
    }
  }


  function api(pathWithQuery) {

    return `${CONFIG.ctx}${pathWithQuery}`;
  }

  async function fetchJson(url) {
    const res = await fetch(url, { method: "GET" });
    const text = await res.text(); // JSON 아닐 때도 있어서 먼저 text로 받음
    if (!res.ok) {
      // 서버가 HTML 에러페이지를 줄 수도 있어서 text 같이 로깅
      throw new Error(`HTTP ${res.status} ${res.statusText} :: ${text.slice(0, 200)}`);
    }
    try {
      return JSON.parse(text);
    } catch (e) {
      throw new Error(`JSON parse error :: ${text.slice(0, 200)}`);
    }
  }

  // ====== routine 파싱 ======
  function findRoutineTime(routines, type) {
    if (!Array.isArray(routines)) return null;
    const row = routines.find(x => x && x.routine_type === type);
    return row ? row.routine_time : null;
  }

  function parseOffsetMin(val) {
    // routine_time이 "30" 같은 문자열일 때
    const n = parseInt(val, 10);
    return Number.isFinite(n) ? n : 0;
  }

  // ====== 스케줄 생성 ======
  function buildTodayEvents(userId, routines) {
    const date = todayStrLocal();
    cleanupOldKeys(date);

    // 기준 시각들
    const breakfast = findRoutineTime(routines, "Meal_breakfast");
    const lunch     = findRoutineTime(routines, "Meal_lunch");
    const dinner    = findRoutineTime(routines, "Meal_dinner");
    const goodMorning = findRoutineTime(routines, "Good_Morning");
    const goodNight   = findRoutineTime(routines, "Good_Night");

    // 오프셋(분)
    const beforePillMin  = parseOffsetMin(findRoutineTime(routines, "Before_pill"));
    const afterPillMin   = parseOffsetMin(findRoutineTime(routines, "After_pill"));
    const morningPillMin = parseOffsetMin(findRoutineTime(routines, "Morning_pill"));
    const nightPillMin   = parseOffsetMin(findRoutineTime(routines, "Night_pill"));

    const events = [];

    function pushEvent(ev) {
      // fireDate 없으면 스킵
      if (!ev.fireDate || !(ev.fireDate instanceof Date) || isNaN(ev.fireDate.getTime())) return;

      // 과거 이벤트 스킵(오늘 남은 것만)
      if (CONFIG.skipPastEvents) {
        const now = new Date();
        if (ev.fireDate.getTime() <= now.getTime()) return;
      }

      ev.hhmm = ev.hhmm || hhmmOf(ev.fireDate);
      ev.key = makeKey(userId, date, ev.event_type, ev.hhmm);
      events.push(ev);
    }

    // 1) 식사 정시 알림 + 재확인
    const meals = [
      { type: "Meal_breakfast", time: breakfast, label: "아침" },
      { type: "Meal_lunch",     time: lunch,     label: "점심" },
      { type: "Meal_dinner",    time: dinner,    label: "저녁" }
    ];

    meals.forEach(m => {
      const base = dateAtToday(m.time);
      if (!base) return;

      pushEvent({
        kind: "meal",
        event_type: m.type,
        fireDate: base,
        retry: true,
        message: `${m.label} 식사 기록해주세요`
      });

      // 2) 식전/식후 약 (식사 기준 파생)
      // ⚠️ 계산 결과가 전날로 떨어질 수 있음(예: 00:10 - 30분)
      // 시연/운영 기준으로는 "오늘 내"만 예약하므로, 전날이면 스킵됨(위 skipPastEvents가 막아줌)
      if (beforePillMin > 0) {
        const t = addMinutes(base, -beforePillMin);
        pushEvent({
          kind: "pill",
          event_type: `Pill_before_${m.type}`,
          fireDate: t,
          retry: false,
          message: `${m.label} 식전약 시간입니다`
        });
      }

      if (afterPillMin > 0) {
        const t = addMinutes(base, +afterPillMin);
        pushEvent({
          kind: "pill",
          event_type: `Pill_after_${m.type}`,
          fireDate: t,
          retry: false,
          message: `${m.label} 식후약 시간입니다`
        });
      }
    });

    // 3) 기상/취침 인사 + 기상/취침 약
    const gm = dateAtToday(goodMorning);
    if (gm) {
      pushEvent({
        kind: "greet",
        event_type: "Good_Morning",
        fireDate: gm,
        retry: false,
        message: "좋은 아침입니다 😊"
      });

      if (morningPillMin > 0) {
        const t = addMinutes(gm, +morningPillMin);
        pushEvent({
          kind: "pill",
          event_type: "Pill_morning",
          fireDate: t,
          retry: false,
          message: "기상 관련 약 복용 시간입니다"
        });
      }
    }

    const gn = dateAtToday(goodNight);
    if (gn) {
      pushEvent({
        kind: "greet",
        event_type: "Good_Night",
        fireDate: gn,
        retry: false,
        message: "안녕히 주무세요 🌙"
      });

      if (nightPillMin > 0) {
        const t = addMinutes(gn, -nightPillMin);
        pushEvent({
          kind: "pill",
          event_type: "Pill_night",
          fireDate: t,
          retry: false,
          message: "취침 전 약 복용 시간입니다"
        });
      }
    }

    // 시간순 정렬
    events.sort((a, b) => a.fireDate - b.fireDate);

    log("events built", events);
    return events;
  }

  // ====== 스케줄 실행 ======
  function scheduleAtDate(dateObj, cb) {
    const delay = dateObj.getTime() - Date.now();
    if (delay <= 0) return;
    setTimeout(cb, delay);
  }

  function runSchedule(userId, events) {
    const date = todayStrLocal();
    const retryDelayMs = CONFIG.retryMinutes * 60 * 1000;

    events.forEach(ev => {
      scheduleAtDate(ev.fireDate, async () => {
        // 1) 중복 알림 방지
        if (wasSent(ev.key)) {
          log("skip sent", ev.key);
          return;
        }
        markSent(ev.key);

        // 2) 알림 발송
        osNotify("알림", `${ev.message || ev.event_type} (${ev.hhmm})`);
        log("notify", ev.event_type, ev.hhmm);

        // 3) 식사면 재확인
        if (ev.kind === "meal" && ev.retry) {
          setTimeout(async () => {
            if (wasRetrySent(ev.key)) {
              log("skip retry sent", ev.key);
              return;
            }

            // ✅ 컨텍스트 경로 포함해서 호출 (404 방지)
            const url = api(`/api/active/exists?user_id=${encodeURIComponent(userId)}&event_type=${encodeURIComponent(ev.event_type)}&date=${encodeURIComponent(date)}`);

            try {
              const r = await fetchJson(url);

              // {"exists":true/false} 형태 기대
              if (r && r.exists === false) {
                markRetrySent(ev.key);
                osNotify("재알림", `${ev.event_type} 기록이 아직 없어요!`);
                log("retry notify", ev.event_type);
              } else {
                log("retry check ok", ev.event_type, r);
              }
            } catch (e) {
              // 서버/네트워크 문제여도 앱이 죽지 않게
              log("retry check failed", e.message);
            }
          }, retryDelayMs);
        }
      });
    });
  }

  // ====== 자정 재생성 ======
  function scheduleMidnightRebuild(userId, onPreviewEvents) {
    if (!CONFIG.midnightRebuild) return;

    const now = new Date();
    const next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 5, 0); // 00:00:05
    const delay = next.getTime() - now.getTime();

    setTimeout(() => {
      start(userId, onPreviewEvents);
    }, delay);

    log("midnight rebuild scheduled in ms", delay);
  }

  // ====== 외부 함수 ======
  function init(opts = {}) {
    // JSP에서 contextPath 주입용
    if (typeof opts.ctx === "string") CONFIG.ctx = opts.ctx;
    if (typeof opts.retryMinutes === "number") CONFIG.retryMinutes = opts.retryMinutes;
    if (typeof opts.debug === "boolean") CONFIG.debug = opts.debug;
    if (typeof opts.skipPastEvents === "boolean") CONFIG.skipPastEvents = opts.skipPastEvents;
    if (typeof opts.midnightRebuild === "boolean") CONFIG.midnightRebuild = opts.midnightRebuild;

    log("init", CONFIG);
  }

  async function start(userId, onPreviewEvents) {
    const ok = await ensureNotificationPermission();
    if (!ok) return;

    // routine 1회 조회 (✅ ctx 포함)
    const routineUrl = api(`/api/routine?user_id=${encodeURIComponent(userId)}`);

    let routines;
    try {
      routines = await fetchJson(routineUrl);
    } catch (e) {
      log("routine fetch failed", e.message);
      alert("루틴 조회 실패: 콘솔 로그 확인");
      return;
    }

    const events = buildTodayEvents(userId, routines);

    if (typeof onPreviewEvents === "function") {
      try { onPreviewEvents(events); } catch (e) { log("preview callback error", e); }
    }

    runSchedule(userId, events);
    scheduleMidnightRebuild(userId, onPreviewEvents);
  }

  return { init, start };
})();

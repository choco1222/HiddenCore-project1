/* =========================
   alarmScheduler.js (stable+fixed v2)
   - OS Notification + 화면 Toast
   - 폴링 없음
	 1) 루틴 1회 로드 -> 스케줄 생성
	 2) 식사: 루틴 시간 알림 -> 30분 뒤 DB exists 체크 -> 없으면 재알림
	 3) 식후약: "식사 체크된 시간(event_time)" + 30분에 약 알림
			  -> 약 알림 후 30분 뒤 DB exists 체크 -> 없으면 재알림
   - JSP/Servlet 환경에서 contextPath 포함 fetch
   - ✅ event_type 정리:
	 Meal_breakfast / Meal_lunch / Meal_dinner
	 Med_morning / Med_lunch / Med_dinner
	 Awake / Sleep / Mood / Game 등
========================= */

const Alarm = (() => {
	// ====== 외부 설정(초기값) ======
	const CONFIG = {
		ctx: "",                  // 예: "/Remember_Spring"
		retryMinutes: 30,
		afterMealPillMinutes: 30,
		pillRetryMinutes: 30,
		debug: true,
		skipPastEvents: true,
		midnightRebuild: true
	};

	// ====== 내부 상수 ======
	const LS_SENT_PREFIX = "alarm_sent:";
	const LS_RETRY_PREFIX = "alarm_retry_sent:";

	// start() 중복 호출 방지용 토큰
	let runToken = 0;

	// ====== 로그 ======
	function log(...args) { if (CONFIG.debug) console.log("[Alarm]", ...args); }
	function warn(...args) { if (CONFIG.debug) console.warn("[Alarm]", ...args); }
	function err(...args) { console.error("[Alarm]", ...args); }

	// ====== fetch 유틸 (컨텍스트 경로 포함 + JSON 안전 파싱) ======
	function api(pathWithQuery) {
		return `${CONFIG.ctx}${pathWithQuery}`;
	}

	async function fetchJson(url) {
		const res = await fetch(url, { method: "GET" });
		const text = await res.text();

		if (!res.ok) {
			throw new Error(`HTTP ${res.status} ${res.statusText} :: ${text.slice(0, 200)}`);
		}
		try {
			return JSON.parse(text);
		} catch (e) {
			throw new Error(`JSON parse error :: ${text.slice(0, 200)}`);
		}
	}

	// ====== 날짜/시간 유틸 ======
	function pad2(n) { return String(n).padStart(2, "0"); }

	function todayStrLocal() {
		const d = new Date();
		return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`;
	}

	function parseHHMM(hhmm) {
		if (typeof hhmm !== "string") return null;
		const m = hhmm.match(/^(\d{1,2}):(\d{2})(?::(\d{2}))?$/); // "08:00" or "08:00:00"
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

	// 서버에서 "YYYY-MM-DD HH:mm:ss" 받는 용도 (/api/active/today)
	function parseMysqlDateTime(s) {
		if (!s || typeof s !== "string") return null;
		const m = s.match(/^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})(?::(\d{2}))?$/);
		if (!m) return null;
		const y = +m[1], mo = +m[2] - 1, d = +m[3], hh = +m[4], mm = +m[5], ss = +(m[6] || 0);
		return new Date(y, mo, d, hh, mm, ss, 0);
	}

	// ====== localStorage 중복 방지 ======
	function makeKey(userId, date, eventType, hhmm) {
		return `${userId}|${date}|${eventType}|${hhmm}`;
	}
	function wasSent(key) { return localStorage.getItem(LS_SENT_PREFIX + key) === "1"; }
	function markSent(key) { localStorage.setItem(LS_SENT_PREFIX + key, "1"); }
	function wasRetrySent(key) { return localStorage.getItem(LS_RETRY_PREFIX + key) === "1"; }
	function markRetrySent(key) { localStorage.setItem(LS_RETRY_PREFIX + key, "1"); }

	function cleanupOldKeys(keepDate) {
		try {
			const removeKeys = [];
			for (let i = 0; i < localStorage.length; i++) {
				const k = localStorage.key(i);
				if (!k) continue;
				if (k.startsWith(LS_SENT_PREFIX) || k.startsWith(LS_RETRY_PREFIX)) {
					const raw = k.replace(LS_SENT_PREFIX, "").replace(LS_RETRY_PREFIX, "");
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
			warn("cleanupOldKeys skipped", e);
		}
	}

	// ====== Notification/Toast ======
	function showToast(text) {
		const el = document.createElement("div");
		el.textContent = text;
		el.style.position = "fixed";
		el.style.right = "20px";
		el.style.bottom = "20px";
		el.style.padding = "12px 14px";
		el.style.borderRadius = "10px";
		el.style.background = "rgba(30,30,30,0.92)";
		el.style.color = "#fff";
		el.style.zIndex = 999999;
		el.style.maxWidth = "340px";
		el.style.boxShadow = "0 8px 24px rgba(0,0,0,0.25)";
		el.style.fontSize = "14px";
		document.body.appendChild(el);
		setTimeout(() => el.remove(), 2500);
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
		// 주의: 이 호출은 사용자 클릭 이벤트 안에서 실행되는 게 가장 안전함
		const p = await Notification.requestPermission();
		return p === "granted";
	}

	function osNotify(title, body) {
		// 1) 토스트는 무조건
		showToast(`${title} - ${body}`);

		// 2) OS Notification
		try {
			if (!("Notification" in window)) return;
			if (Notification.permission !== "granted") return;

			const n = new Notification(title, { body, requireInteraction: true });
			n.onshow = () => log("[osNotify] onshow ✅", title);
			n.onerror = (e) => err("[osNotify] onerror ❌", e);

			setTimeout(() => n.close(), 15000);
		} catch (e) {
			err("[osNotify] exception ❌", e);
		}
	}

	/*
	  // ====== 디버그 ======
	  function debugTestNotify() {
		osNotify("테스트", "OS 알림/토스트 체크");
		log("debugTestNotify fired");
	  }
	*/
	/*  function debugScheduleSoon() {
		const evs = [
		  { title: "테스트(10초)", body: "스케줄 알림 1", at: new Date(Date.now() + 10 * 1000) },
		  { title: "테스트(30초)", body: "스케줄 알림 2", at: new Date(Date.now() + 30 * 1000) },
		  { title: "테스트(60초)", body: "스케줄 알림 3", at: new Date(Date.now() + 60 * 1000) },
		];
	
		evs.forEach(e => {
		  const delay = e.at.getTime() - Date.now();
		  setTimeout(() => {
			osNotify(e.title, e.body);
			log("debugScheduleSoon fired", e.title);
		  }, Math.max(0, delay));
		});
	
		log("debugScheduleSoon scheduled", evs.map(x => x.at.toString()));
	  }*/

	// ====== routine 파싱 ======
	function findRoutineRow(routines, type) {
		if (!Array.isArray(routines)) return null;
		return routines.find(x => x && x.routine_type === type) || null;
	}

	// ====== 스케줄 생성 ======
	function buildTodayEvents(userId, routines) {
		const date = todayStrLocal();
		cleanupOldKeys(date);

		const events = [];

		function pushEvent(ev) {
			if (!ev.fireDate || isNaN(ev.fireDate.getTime())) {
				warn("pushEvent skipped: invalid fireDate", ev);
				return;
			}

			if (CONFIG.skipPastEvents) {
				const now = new Date();
				if (ev.fireDate.getTime() <= now.getTime()) {
					warn("pushEvent skipped: past event", ev.event_type, ev.fireDate.toString());
					return;
				}
			}

			ev.hhmm = ev.hhmm || hhmmOf(ev.fireDate);
			ev.key = makeKey(userId, date, ev.event_type, ev.hhmm);
			events.push(ev);
		}

		const breakfastRow = findRoutineRow(routines, "Meal_breakfast");
		const lunchRow = findRoutineRow(routines, "Meal_lunch");
		const dinnerRow = findRoutineRow(routines, "Meal_dinner");
		const awakeRow = findRoutineRow(routines, "Awake");
		const sleepRow = findRoutineRow(routines, "Sleep");

		const meals = [
			{ row: breakfastRow, label: "아침", type: "Meal_breakfast" },
			{ row: lunchRow, label: "점심", type: "Meal_lunch" },
			{ row: dinnerRow, label: "저녁", type: "Meal_dinner" }
		];

		// ✅ 식사 알림(재확인 포함)
		meals.forEach(m => {
			if (!m.row) return;

			const base = dateAtToday(m.row.routine_time);
			if (!base) {
				warn("meal time parse failed:", m.type, m.row.routine_time);
				return;
			}

			pushEvent({
				kind: "meal",
				event_type: m.type,
				fireDate: base,
				retry: true,
				message: `${m.label} 식사 기록해주세요`
			});

			// ⚠️ 기존 코드의 "정시 약(Drug)" 알림은 제거
			// is_drug=true는 scheduleAfterMealPills에서 "식후약"으로 처리
		});

		// ✅ 기상/취침 인사 + 취침 1시간 전(게임/기분)
		if (awakeRow) {
			const aw = dateAtToday(awakeRow.routine_time);
			if (!aw) warn("awake time parse failed:", awakeRow.routine_time);
			else {
				pushEvent({
					kind: "greet",
					event_type: "Awake",
					fireDate: aw,
					retry: false,
					message: "좋은 아침입니다 😊"
				});
			}
		}

		if (sleepRow) {
			const sl = dateAtToday(sleepRow.routine_time);
			if (!sl) warn("sleep time parse failed:", sleepRow.routine_time);
			else {
				pushEvent({
					kind: "greet",
					event_type: "Sleep",
					fireDate: sl,
					retry: false,
					message: "안녕히 주무세요 🌙"
				});

				pushEvent({
					kind: "daily",
					event_type: "Game",
					fireDate: addMinutes(sl, -60),
					retry: false,
					message: "취침 1시간 전입니다. 게임 플레이하세요 🎮"
				});

				pushEvent({
					kind: "daily",
					event_type: "Mood",
					fireDate: addMinutes(sl, -60),
					retry: false,
					message: "취침 1시간 전입니다. 오늘 기분 기록해주세요 😊"
				});
			}
		}

		events.sort((a, b) => a.fireDate - b.fireDate);
		log("events built", events.map(e => ({
			type: e.event_type, hhmm: e.hhmm, fire: e.fireDate.toString(), key: e.key
		})));
		return events;
	}

	// ====== 스케줄 실행 ======
	function scheduleAtDate(dateObj, cb) {
		const delay = dateObj.getTime() - Date.now();
		log("scheduleAtDate delay(ms)=", delay, "at=", dateObj.toString());
		if (delay <= 0) return;
		setTimeout(cb, delay);
	}

	function runSchedule(userId, events, token) {
		const date = todayStrLocal();
		const retryDelayMs = CONFIG.retryMinutes * 60 * 1000;

		events.forEach(ev => {
			scheduleAtDate(ev.fireDate, async () => {
				// ✅ 이전 start()에서 잡힌 타이머면 무시
				if (token !== runToken) return;

				if (wasSent(ev.key)) {
					log("skip sent", ev.key);
					return;
				}
				markSent(ev.key);

				osNotify("알림", `${ev.message || ev.event_type} (${ev.hhmm})`);
				log("notify", ev.event_type, ev.hhmm);

				// ✅ 식사 재확인
				if (ev.kind === "meal" && ev.retry) {
					setTimeout(async () => {
						if (token !== runToken) return;

						if (wasRetrySent(ev.key)) {
							log("skip retry sent", ev.key);
							return;
						}

						const url = `${ctx}/api/routine?user_id=${encodeURIComponent(userId)}&userId=${encodeURIComponent(userId)}`;
						try {
							const r = await fetchJson(url);
							if (r && r.exists === false) {
								markRetrySent(ev.key);
								osNotify("재알림", `${ev.event_type} 기록이 아직 없어요!`);
								log("meal retry notify", ev.event_type);
							} else {
								log("meal retry check ok", ev.event_type, r);
							}
						} catch (e) {
							warn("meal retry check failed", e.message);
						}
					}, retryDelayMs);
				}
			});
		});
	}

	// ✅ 식후약: “식사 기록 시간 + 30분” 알림 + 재확인
	async function scheduleAfterMealPills(userId, routines, token) {
		const date = todayStrLocal();

		const mealDefs = [
			{ mealType: "Meal_breakfast", pillType: "Med_morning", label: "아침" },
			{ mealType: "Meal_lunch", pillType: "Med_lunch", label: "점심" },
			{ mealType: "Meal_dinner", pillType: "Med_dinner", label: "저녁" }
		];

		for (const m of mealDefs) {
			if (token !== runToken) return;

			const row = findRoutineRow(routines, m.mealType);
			if (!row || row.is_drug !== true) continue;

			const url = api(`/api/active/today?userId=${encodeURIComponent(userId)}&event_type=${encodeURIComponent(m.mealType)}&date=${encodeURIComponent(date)}`);

			let r;
			try {
				r = await fetchJson(url);
			} catch (e) {
				warn("afterMeal mealTime fetch failed", m.mealType, e.message);
				continue;
			}

			if (!r || r.exists !== true || !r.time) continue;

			const mealLoggedAt = parseMysqlDateTime(r.time);
			if (!mealLoggedAt) {
				warn("afterMeal parseMysqlDateTime failed", r.time);
				continue;
			}

			const pillAt = addMinutes(mealLoggedAt, CONFIG.afterMealPillMinutes);
			if (CONFIG.skipPastEvents && pillAt.getTime() <= Date.now()) {
				warn("afterMeal pillAt already past", m.mealType, pillAt.toString());
				continue;
			}

			const hhmm = hhmmOf(pillAt);
			const pillKey = makeKey(userId, date, m.pillType, hhmm);

			scheduleAtDate(pillAt, () => {
				if (token !== runToken) return;

				if (wasSent(pillKey)) return;
				markSent(pillKey);

				osNotify("복약 알림", `${m.label} 식사 후 ${CONFIG.afterMealPillMinutes}분 지났어요. 약 복용하세요 💊 (${hhmm})`);
				log("afterMeal pill notify", m.pillType, hhmm);

				setTimeout(async () => {
					if (token !== runToken) return;

					const retryKey = pillKey + "|pillRetry";
					if (wasRetrySent(retryKey)) return;

					const existsUrl = api(`/api/active/exists?userId=${encodeURIComponent(userId)}&event_type=${encodeURIComponent(m.pillType)}&date=${encodeURIComponent(date)}`);

					try {
						const ex = await fetchJson(existsUrl);
						if (ex && ex.exists === false) {
							markRetrySent(retryKey);
							osNotify("복약 재알림", `${m.label} 복약 기록이 아직 없어요! 복용 체크해주세요 💊`);
							log("afterMeal pill retry notify", m.pillType);
						} else {
							log("afterMeal pill retry check ok", m.pillType, ex);
						}
					} catch (e) {
						warn("afterMeal pill retry check failed", e.message);
					}
				}, CONFIG.pillRetryMinutes * 60 * 1000);
			});
		}
	}

	function scheduleMidnightRebuild(userId, onPreviewEvents) {
		if (!CONFIG.midnightRebuild) return;

		const now = new Date();
		const next = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 5, 0);
		const delay = next.getTime() - now.getTime();

		setTimeout(() => start(userId, onPreviewEvents), delay);
		log("midnight rebuild scheduled in ms", delay);
	}

	// ====== 외부 함수 ======
	function init(opts = {}) {
		if (typeof opts.ctx === "string") CONFIG.ctx = opts.ctx;
		if (typeof opts.retryMinutes === "number") CONFIG.retryMinutes = opts.retryMinutes;
		if (typeof opts.afterMealPillMinutes === "number") CONFIG.afterMealPillMinutes = opts.afterMealPillMinutes;
		if (typeof opts.pillRetryMinutes === "number") CONFIG.pillRetryMinutes = opts.pillRetryMinutes;
		if (typeof opts.debug === "boolean") CONFIG.debug = opts.debug;
		if (typeof opts.skipPastEvents === "boolean") CONFIG.skipPastEvents = opts.skipPastEvents;
		if (typeof opts.midnightRebuild === "boolean") CONFIG.midnightRebuild = opts.midnightRebuild;

		log("init", CONFIG);
	}

	async function start(userId, onPreviewEvents) {
		// ✅ 새 실행 토큰 발급(이전 타이머 무효화)
		runToken++;
		const token = runToken;

		const ok = await ensureNotificationPermission();
		if (!ok) return;

		if (!CONFIG.ctx) {
			warn("CONFIG.ctx is empty! 반드시 init({ctx: '<contextPath>'}) 해줘야 함");
		}

		const routineUrl = api(`/api/routine?userId=${encodeURIComponent(userId)}`);

		let routines;
		try {
			routines = await fetchJson(routineUrl);
		} catch (e) {
			err("routine fetch failed", e.message);
			alert("루틴 조회 실패: 콘솔 로그 확인");
			return;
		}

		log("routines loaded", routines);

		const events = buildTodayEvents(userId, routines);

		if (typeof onPreviewEvents === "function") {
			try { onPreviewEvents(events); } catch (e) { warn("preview callback error", e); }
		}

		runSchedule(userId, events, token);
		scheduleAfterMealPills(userId, routines, token);
		scheduleMidnightRebuild(userId, onPreviewEvents);
	}

	return { init, start };
})();

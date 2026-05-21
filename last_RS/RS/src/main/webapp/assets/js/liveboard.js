/* =========================
   liveboard.js (v3, fixed)
   - load live board summary from servlet: /api/liveboard/daily
   - works standalone on guard.jsp (no showScreen needed)
   - optional hook showScreen('live') if exists
========================= */

(function () {
  // ====== config ======
  const getCtx = () => (window.CTX || document.body.getAttribute("data-ctx") || "");
  const getUserId = () => window.userId; // guard.jsp에서 linkedPatientId를 window.userId로 주입하는 전제

  // ====== helpers ======
  function $(id) { return document.getElementById(id); }

  function asStr(v, def = "") {
    if (v === undefined || v === null) return def;
    return String(v);
  }

  function asCount(v) {
    const s = asStr(v, "").trim();
    if (!s || s === "null" || s === "-") return "0";
    const n = Number(s);
    if (!Number.isFinite(n)) return "0";
    return String(n);
  }

  function asTime(v) {
    let s = asStr(v, "").trim();
    if (!s || s === "null" || s === "-") return "--:--";
    const m = s.match(/\b(\d{2}):(\d{2})(?::\d{2})?\b/);
    if (m) return `${m[1]}:${m[2]}`;
    return s;
  }

  function prettyMood(v) {
    let s = asStr(v, "").trim();
    if (!s || s === "-" || s === "null") return "-";
    if (s.startsWith("Mood_")) s = s.slice("Mood_".length);
    return s;
  }

  function getMealObj(d, key) {
    const obj = (d && d.meal && d.meal[key]) ? d.meal[key] : null;
    return {
      count: asCount(obj && obj.count),
      lastTime: asTime(obj && obj.lastTime)
    };
  }

  function setText(id, text) {
    const el = $(id);
    if (el) el.textContent = text;
  }

  // ====== main ======
  async function loadLiveBoardDaily() {
    const ctx = getCtx();
    const uid = getUserId();

    console.log("[liveboard] ctx=", ctx, "userId=", uid);

    if (uid === undefined || uid === null || uid === "" || uid === "null") {
      console.warn("[liveboard] userId missing");
      return;
    }

    // ✅ 실시간 조회: 캐시 방지용 타임스탬프 추가
    const url = `${ctx}/api/liveboard/daily?user_id=${encodeURIComponent(uid)}&_t=${Date.now()}`;

    try {
      const res = await fetch(url, { cache: "no-store", credentials: "same-origin" });
      const txt = await res.text();
      if (!res.ok) throw new Error(`HTTP ${res.status} ${txt}`);

      const d = JSON.parse(txt);
      console.log("[liveboard] data:", d);

      // 날짜
      setText("live-date", asStr(d && d.date, "-"));

      // 식사
      const bf = getMealObj(d, "Meal_breakfast");
      const lu = getMealObj(d, "Meal_lunch");
      const di = getMealObj(d, "Meal_dinner");

      setText("live-breakfast", bf.count);
      setText("live-lunch", lu.count);
      setText("live-dinner", di.count);

      setText("live-breakfast-time", bf.lastTime);
      setText("live-lunch-time", lu.lastTime);
      setText("live-dinner-time", di.lastTime);

      // 복약
      const drugRow = $("live-drug-row");
      const enabled =
        (d && d.drug && typeof d.drug.enabled === "boolean")
          ? d.drug.enabled
          : true;

      if (drugRow) {
        drugRow.style.display = (enabled === false) ? "none" : "";
      }
      setText("live-drug", asCount(d && d.drug && d.drug.count));
      setText("live-drug-time", asTime(d && d.drug && d.drug.lastTime));

      // 기분
      setText("live-mood", prettyMood(d && d.mood && d.mood.value));

      // 게임
      const playCount = (d && d.game)
        ? (d.game.playCount ?? d.game.play_count ?? d.game.count)
        : null;
      setText("live-game", asStr(playCount, "0"));

    } catch (e) {
      console.error("[liveboard] load failed:", e);

      // 실패 시 기본값
      setText("live-date", "-");
      setText("live-breakfast", "0");
      setText("live-lunch", "0");
      setText("live-dinner", "0");
      setText("live-breakfast-time", "--:--");
      setText("live-lunch-time", "--:--");
      setText("live-dinner-time", "--:--");
      setText("live-mood", "-");
      setText("live-game", "0");
      const drugRow = $("live-drug-row");
      if (drugRow) drugRow.style.display = "";
      setText("live-drug", "0");
      setText("live-drug-time", "--:--");
    }
  }

  // ====== expose ======
  window.LiveBoard = window.LiveBoard || {};
  window.LiveBoard.loadDaily = loadLiveBoardDaily;

  // ====== optional hook showScreen ======
  function hookShowScreen() {
    const original = window.showScreen;
    if (typeof original !== "function") return;
    if (original.__liveboardHooked) return;

    function wrapped(id) {
      original(id);
      if (id === "live" || id === "home") loadLiveBoardDaily();
    }
    wrapped.__liveboardHooked = true;
    original.__liveboardHooked = true;
    window.showScreen = wrapped;
  }

  // ====== auto run ======
  document.addEventListener("DOMContentLoaded", function () {
    hookShowScreen();
    loadLiveBoardDaily();
  });
})();

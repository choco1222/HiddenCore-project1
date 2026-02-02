/* =============================
   Global
============================= */
const CTX = window.CTX || "";

/* =============================
   Date / storage utils
============================= */
const getToday = () => new Date().toISOString().split('T')[0];

const storage = {
	set: (key, val) => localStorage.setItem(key, JSON.stringify(val)),
	get: (key) => JSON.parse(localStorage.getItem(key) || "[]")
};

/* =============================
   Server
============================= */
function sendToServer(type, time) {
	fetch(CTX + "/saveLog", {
		method: "POST",
		headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
		body: `type=${encodeURIComponent(type)}&time=${encodeURIComponent(time)}`
	})
		.then(res => {
			if (!res.ok) throw new Error("HTTP " + res.status);
			console.log("✅ 서버 저장 완료:", type, time);
		})
		.catch(err => console.error("❌ 서버 전송 실패:", err));
}

/* =============================
   Normalize event type
============================= */
function normalizeEventType(buttonId) {
	if (buttonId === "breakfast-btn" || buttonId === "lunch-btn" || buttonId === "dinner-btn") return "식사";
	if (buttonId.startsWith("medicine-")) return "약복용";
	if (buttonId.startsWith("outing-")) return "양치";
	return "기타";
}

/* =============================
   UI actions
============================= */
function checkItem(buttonId) {
	const today = getToday();
	const checkedItems = storage.get("checkedItems");

	const now = new Date();
	const timeString = now.toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit", hour12: true });

	// 로컬 저장(원하면 유지)
	checkedItems.push({ date: today, id: buttonId, time: timeString });
	storage.set("checkedItems", checkedItems);

	// 서버 저장
	const eventType = normalizeEventType(buttonId);
	sendToServer(eventType, timeString);

	const btn = document.getElementById(buttonId);
	if (btn) btn.classList.add("checked");

	alert(`[${timeString}] 기록이 완료되었습니다.`);
}

function toggleOuting() {
	const statusCard = document.getElementById("status-card");
	const statusText = document.getElementById("status-text");
	const statusIcon = document.getElementById("status-icon");
	const outingBtn = document.getElementById("outing-toggle-btn");
	const outingTime = document.getElementById("outing-time");

	const now = new Date();
	const timeString = now.toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit", hour12: true });

	if (!statusCard.classList.contains("out")) {
		statusCard.classList.add("out");
		statusText.innerText = "외출 중";
		statusIcon.innerText = "🚶";
		outingBtn.innerText = "집에 도착";
		outingBtn.classList.add("return");
		outingTime.innerText = `출발 시간: ${timeString}`;
		sendToServer("외출 시작", timeString);
	} else {
		statusCard.classList.remove("out");
		statusText.innerText = "집";
		statusIcon.innerText = "🏠";
		outingBtn.innerText = "외출하기";
		outingBtn.classList.remove("return");
		outingTime.innerText = `귀가 시간: ${timeString}`;
		sendToServer("귀가 완료", timeString);
	}
}

function checkMood(moodName, emoji) {
	const today = getToday();
	let moodData = JSON.parse(localStorage.getItem("moodData") || "[]");

	const alreadyDone = moodData.find(item => item.date === today);
	if (alreadyDone) {
		alert(`이미 오늘 기분을 [${alreadyDone.mood} ${alreadyDone.emoji}]라고 기록하셨습니다!`);
		return;
	}

	const now = new Date();
	const time = now.toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit", hour12: true });

	moodData.push({ date: today, mood: moodName, emoji: emoji, time: time });
	localStorage.setItem("moodData", JSON.stringify(moodData));

	sendToServer(`기분:${moodName}`, time);
	alert(`[${time}] 오늘의 기분(${moodName})이 잘 기록되었습니다!`);
}

function resetData() {
	if (confirm("오늘의 기록을 모두 삭제하고 초기화할까요?")) {
		localStorage.removeItem("checkedItems");
		localStorage.removeItem("moodData");
		location.reload();
	}
}

/* =============================
   Date text
============================= */
function updateDate() {
	const now = new Date();
	const dateString = now.toLocaleDateString("ko-KR", {
		year: "numeric", month: "long", day: "numeric", weekday: "long"
	});
	const el = document.getElementById("live-date");
	if (el) el.innerText = dateString;
}
updateDate();

/* =============================
   Screen switch
============================= */
function showScreen(screenId) {
	document.querySelectorAll(".screen").forEach(s => s.classList.remove("active"));
	const target = document.getElementById(screenId);
	if (target) target.classList.add("active");

	if (screenId === "emergency") renderTodayReport();
}


/* =============================
   Report (현재 네 서블릿 버전: items/total 기준)
============================= */
function renderTodayReport() {
  fetch(CTX + "/api/report/today", { cache: "no-store" })
    .then(function (r) {
      if (!r.ok) throw new Error("HTTP " + r.status);
      return r.json();
    })
    .then(function (data) {
      var dateStr = new Date().toLocaleDateString("ko-KR", {
        month: "long",
        day: "numeric",
        weekday: "long"
      });

      var dateEl = document.getElementById("report-date");
      var totalEl = document.getElementById("report-total");
      var listEl = document.getElementById("report-list");
      var moodEl = document.getElementById("report-mood");

      if (dateEl) dateEl.textContent = dateStr;
      if (!listEl) return;

      var map = data.counts || {};
      var order = ["식사", "약복용", "양치", "외출 시작", "귀가 완료", "게임"];

      if (totalEl) totalEl.textContent = (data.total != null ? data.total : 0);

      listEl.innerHTML = "";
      order.forEach(function (type) {
        var cnt = map[type] || 0;
        var card = document.createElement("div");
        card.className = "check-card";
        card.innerHTML =
          "<h3>" + type + "</h3>" +
          "<p style='margin-top:6px;'>" + cnt + "회</p>";
        listEl.appendChild(card);
      });

      if (moodEl) {
        moodEl.textContent = data.mood
          ? "오늘의 기분: " + data.mood
          : "오늘의 기분: 기록 없음";
      }

      console.log("report counts=", data.counts);
    })
    .catch(function (err) {
      console.error(err);
      var listEl = document.getElementById("report-list");
      if (listEl) listEl.innerHTML =
        "<div class='check-card'><p>요약을 불러오지 못했어요.</p></div>";
    });
}



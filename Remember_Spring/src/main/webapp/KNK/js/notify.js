// ===== State =====
var shownKeys = JSON.parse(localStorage.getItem("shownNotifKeys") || "{}");
var lastSeenMs = localStorage.getItem("lastSeenNotifMs") || "0";

function getContextPath() {
	var path = window.location.pathname;
	var idx = path.indexOf("/", 1);
	return idx > 0 ? path.substring(0, idx) : "";
}

function showBadge(count) {
	var badge = document.getElementById("badge");
	if (!badge) return;

	if (count > 0) {
		badge.style.display = "inline-block";
		badge.textContent = String(count);
	} else {
		badge.style.display = "none";
	}
}

function canUseOsNotification() {
	var enabled = localStorage.getItem("notifEnabled") === "1";
	var perm = ("Notification" in window) ? Notification.permission : "no-api";
	console.log("[osCheck] enabled=", enabled, "perm=", perm);
	return enabled && ("Notification" in window) && perm === "granted";
}

function fireOsNotification(title, body) {
	if (!canUseOsNotification()) return false;
	try {
		new Notification(title, { body: body });
		console.log("[osNotify] fired:", title);
		return true;
	} catch (e) {
		console.log("[osNotify] failed", e);
		return false;
	}
}

function pollNotifications() {
	try {
		var ctx = getContextPath();
		var url = ctx + "/api/notifications?sinceId=" + encodeURIComponent(lastSeenMs);

		console.log("[poll] url=", url, "lastSeenId=", lastSeenId);

		fetch(url, { cache: "no-store" })
			.then(function(res) {
				console.log("[poll] status=", res.status);
				if (!res.ok) throw new Error("HTTP " + res.status);
				return res.json();
			})
			.then(function(data) {
				console.log("[poll] data=", data);

				showBadge(data.unreadCount || 0);

				var items = data.items || [];
				console.log("[poll] items.length=", items.length);

				for (var i = 0; i < items.length; i++) {
					var it = items[i];

					// id 기준으로 "새 알림"만 처리
					var itId = Number(it.id || 0);
					if (itId <= Number(lastSeenId || 0)) {
						console.log("[skip] old item by id", itId);
						continue;
					}

					// key 기준 중복 방지
					if (it.key && shownKeys[it.key]) {
						console.log("[skip] already shown key=", it.key);
						continue;
					}

					if (it.key) {
						shownKeys[it.key] = 1;
						localStorage.setItem("shownNotifKeys", JSON.stringify(shownKeys));
					}

					// ✅ OS 알림만
					fireOsNotification(it.title || "알림", it.body || "새 알림이 있어요");
				}

				// lastSeenId 갱신
				if (items.length > 0) {
					var newest = items[items.length - 1];
					lastSeenMs = String(newest.id);
					localStorage.setItem("lastSeenNotifMs", lastSeenMs);
					console.log("[poll] updated lastSeenMs=", lastSeenMs);
				}
			})
			.catch(function(e) {
				console.log("[poll] error", e);
			});

	} catch (e) {
		console.log("[poll] outer error", e);
	}
}

window.addEventListener("load", function() {
	console.log("[notify.js] loaded ✅");
	showBadge(0);
	pollNotifications();
	setInterval(pollNotifications, 30000);
});

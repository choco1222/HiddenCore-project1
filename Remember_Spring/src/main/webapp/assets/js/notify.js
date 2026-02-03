
// ===== Auto-enable notification =====
(function autoEnableNotification() {
  if (!("Notification" in window)) return;

  // 이미 ON이면 아무것도 안 함
  if (localStorage.getItem("notifEnabled") === "1") return;

  // 권한이 이미 허용된 경우 → 자동 ON
  if (Notification.permission === "granted") {
    localStorage.setItem("notifEnabled", "1");
    console.log("[notify] auto-enabled (permission granted)");
  }
})();

// ===== State =====
var shownKeys = JSON.parse(localStorage.getItem("shownNotifKeys") || "{}");
var lastSeenMs = Number(localStorage.getItem("lastSeenNotifMs") || "0");

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
    var url = ctx + "/api/notifications?sinceMs=" + encodeURIComponent(String(lastSeenMs));

    console.log("[poll] url=", url, "lastSeenMs=", lastSeenMs);

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
          var itId = Number(it.id || 0);

          // 시간(ms) 기준: 이미 본 알림 스킵
          if (itId <= lastSeenMs) continue;

          // key 기준 중복 스킵
          if (it.key && shownKeys[it.key]) continue;

          if (it.key) {
            shownKeys[it.key] = 1;
            localStorage.setItem("shownNotifKeys", JSON.stringify(shownKeys));
          }

          fireOsNotification(it.title || "알림", it.body || "새 알림이 있어요");

          // lastSeenMs 갱신
          if (itId > lastSeenMs) lastSeenMs = itId;
        }

        localStorage.setItem("lastSeenNotifMs", String(lastSeenMs));
        console.log("[poll] updated lastSeenMs=", lastSeenMs);
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
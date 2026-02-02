<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>   

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Notification</title>
</head>
<body>
<script defer src="<%=request.getContextPath()%>/js/notify.js"></script>

<button onclick="enableNotify()">알림 켜기</button>
<span id="badge" style="display:none;background:red;color:#fff;border-radius:999px;padding:2px 8px;"></span>

<script>
function enableNotify() {
  Notification.requestPermission().then(p => {
    if (p === "granted") {
      localStorage.setItem("notifEnabled", "1"); // ⭐ 여기 핵심
      new Notification("알림이 활성화되었습니다");
    } else {
      localStorage.removeItem("notifEnabled");
      alert("알림 권한이 거부되어 OS 알림을 띄울 수 없어요.");
    }
  });
}
</script>

</body>
</html>
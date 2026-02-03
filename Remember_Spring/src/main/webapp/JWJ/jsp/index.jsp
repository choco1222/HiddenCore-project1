<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>루틴 분석 보고서</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
</head>
<body>
    <!-- 메인 메뉴 -->
    <div class="container">
        <header>
            <h1>루틴 분석 보고서</h1>
        </header>
        <main style="padding: 60px 30px; text-align: center;">
            <div style="display: flex; flex-direction: column; gap: 30px; max-width: 400px; margin: 0 auto;">
                <a href="${pageContext.request.contextPath}/daily" class="nav-btn" style="padding: 25px; font-size: 1.3rem; text-decoration: none; display: block;">
                    📊 일간 보고서 보기
                </a>
                <a href="${pageContext.request.contextPath}/weekly" class="nav-btn" style="padding: 25px; font-size: 1.3rem; text-decoration: none; display: block;">
                    📈 주간 보고서 보기
                </a>
                <a href="${pageContext.request.contextPath}/monthly" class="nav-btn" style="padding: 25px; font-size: 1.3rem; text-decoration: none; display: block;">
                    📅 월간 보고서 보기
                </a>
            </div>
        </main>
    </div>
</body>
</html>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>게임</title>
  <link rel="stylesheet" href="../assets/css/active.css" />
  <link rel="stylesheet" href="<%= ctx %>/assets/css/game_main.css" />
  <style>
    /* card.jsp 버튼과 동일: 크기·레이아웃·텍스트 중앙 (PNG·텍스트만 game_main용) */
    .food-screen .back-btn { text-decoration: none; }
    .app-frame .food-screen .game-btns {
      margin-top: 60px !important;
      padding: 0 24px 120px !important;
      display: flex !important;
      flex-direction: column !important;
      gap: 20px !important;
      position: relative !important;
      z-index: 1 !important;
      align-items: center !important;
    }
    .app-frame .food-screen .game-btns .card.card-bg {
      aspect-ratio: auto !important;
      width: 100% !important;
      max-width: 374px !important;
      height: 170px !important;
      min-height: 170px !important;
      margin: 0 auto !important;
      border-radius: 30px !important;
      background-color: transparent !important;
      background-size: contain !important;
      background-repeat: no-repeat !important;
      background-position: center !important;
      border: none !important;
      outline: none !important;
      box-shadow: none !important;
      cursor: pointer !important;
      display: block !important;
      position: relative !important;
      text-decoration: none !important;
    }
    .app-frame .food-screen .game-btns .card-bg-text {
      position: absolute !important;
      top: 50% !important;
      left: 50% !important;
      transform: translate(-50%, -50%) !important;
      font-size: 28px !important;
      font-weight: 700 !important;
      color: #574444 !important;
      line-height: 1.3 !important;
      pointer-events: none !important;
      display: flex !important;
      flex-direction: column !important;
      gap: 4px !important;
      align-items: center !important;
      text-align: center !important;
    }
    .app-frame .food-screen .game-btns .card-bg-line1 { display: block !important; }
  </style>
</head>
<body>

<div class="app-frame">

  <!-- 배경 벡터 (main.jsp와 동일) -->
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg1">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg2">
  <img src="<%= ctx %>/assets/images/main01/Vector.png" alt="" class="bg bg-outing-game">
  <img src="<%= ctx %>/assets/images/main01/Vector1.png" alt="" class="bg bg-meal">

  <!-- 게임 화면 (식사 화면과 동일 프레임 구조) -->
  <div class="food-screen">
    <div class="food-header">
      <a href="<%= ctx %>/active/main.jsp" class="back-btn" aria-label="뒤로">◀</a>
      <h2 class="food-title">게임</h2>
    </div>
    <p class="food-instruction">재밌는 게임과 함께<br>기억훈련 해요!</p>

    <div class="game-btns">
      <a href="<%= ctx %>/game/card.jsp" class="card card-bg" style="background-image: url('<%= ctx %>/assets/images/game/같은%20카드%20찾기1.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">같은 카드 찾기</span>
        </span>
      </a>
      <a href="<%= ctx %>/game/color.jsp" class="card card-bg" style="background-image: url('<%= ctx %>/assets/images/game/색깔%20맞추기.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">색깔 맞추기</span>
        </span>
      </a>
      <a href="<%= ctx %>/game/word.jsp" class="card card-bg" style="background-image: url('<%= ctx %>/assets/images/game/낱말%20단어%20찾기.png');">
        <span class="card-bg-text">
          <span class="card-bg-line1">낱말 단어 찾기</span>
        </span>
      </a>
    </div>
  </div>

  <!-- 하단 풀 (main.jsp와 동일) -->
  <img src="<%= ctx %>/assets/images/main01/풀.png" alt="" class="grass">

</div>

</body>
</html>

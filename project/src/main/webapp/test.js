fetch("/GameLogSave.do", {
  method: "POST",
  headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  },
  body: new URLSearchParams({
    game_type: "word",
    game_level: "easy",
    play_time: "02:15",
    score: 120
  })
})
.then(res => res.text())
.then(data => console.log(data));
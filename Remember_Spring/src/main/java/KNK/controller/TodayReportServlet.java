package KNK.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import KNK.connect.ConDB;

@WebServlet("/api/report/today")
public class TodayReportServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    req.setCharacterEncoding("UTF-8");
    resp.setContentType("application/json; charset=UTF-8");

    HttpSession session = req.getSession(false);
    String userId = (session == null) ? null : (String) session.getAttribute("user_id");
    if (userId == null || userId.isEmpty()) userId = "U001"; // 테스트용

    // ✅ 고정 항목(0회도 보여주기 위한 기본 세트) - 순서 유지하려고 LinkedHashMap
    Map<String, Integer> counts = new LinkedHashMap<>();
    counts.put("식사", 0);
    counts.put("약복용", 0);
    counts.put("양치", 0);
    counts.put("외출 시작", 0);
    counts.put("귀가 완료", 0);
    counts.put("게임", 0);

    // ✅ 오늘 카운트(기분/테스트 제외) - "한번 클릭=한줄 INSERT" 기준 => COUNT(*)
    String sqlCounts =
      "SELECT event_type, COUNT(*) AS cnt " +
      "FROM activelog " +
      "WHERE user_id = ? " +
      "  AND DATE(event_time) = CURDATE() " +
      "  AND event_type <> '테스트' " +
      "  AND event_type NOT LIKE '기분:%' " +
      "GROUP BY event_type";

    // ✅ 오늘 기분(마지막 1개)
    String sqlMood =
      "SELECT event_type " +
      "FROM activelog " +
      "WHERE user_id = ? " +
      "  AND DATE(event_time) = CURDATE() " +
      "  AND event_type LIKE '기분:%' " +
      "ORDER BY event_time DESC " +
      "LIMIT 1";

    String mood = null;
    int total = 0;

    try (Connection con = ConDB.getConnection()) {

      // 1) counts 채우기
      try (PreparedStatement ps = con.prepareStatement(sqlCounts)) {
        ps.setString(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            String type = rs.getString("event_type");
            int cnt = rs.getInt("cnt");

            // 고정 항목만 반영(혹시 다른 값 들어오면 무시)
            if (counts.containsKey(type)) {
              counts.put(type, cnt);
              total += cnt;
            }
          }
        }
      }

      // 2) mood 가져오기
      try (PreparedStatement ps = con.prepareStatement(sqlMood)) {
        ps.setString(1, userId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            String raw = rs.getString("event_type"); // "기분:기쁨"
            if (raw != null && raw.startsWith("기분:")) {
              mood = raw.substring("기분:".length()); // "기쁨"
            }
          }
        }
      }

    } catch (Exception e) {
      e.printStackTrace();
      resp.setStatus(500);
      resp.getWriter().write("{\"total\":0,\"counts\":{},\"mood\":null}");
      return;
    }

    // ✅ JSON 출력 (라이브러리 없이)
    StringBuilder sb = new StringBuilder();
    sb.append("{");
    sb.append("\"total\":").append(total).append(",");
    sb.append("\"mood\":").append(mood == null ? "null" : ("\"" + esc(mood) + "\"")).append(",");
    sb.append("\"counts\":{");

    boolean first = true;
    for (Map.Entry<String, Integer> e : counts.entrySet()) {
      if (!first) sb.append(",");
      first = false;
      sb.append("\"").append(esc(e.getKey())).append("\":").append(e.getValue());
    }

    sb.append("}}");
    resp.getWriter().write(sb.toString());
  }

  private String esc(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\").replace("\"", "\\\"");
  }
}

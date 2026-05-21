package notify;

import java.io.IOException;

import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/api/liveboard/daily")
public class LiveboardDailyServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
    	
    	System.out.println("✅ LiveboardDailyServlet HIT");
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json; charset=UTF-8");

        int userId = resolveTargetUserId(req);

        Map<String, Map<String, String>> activity = LiveboardDailyDAO.getTodayActivity(userId);
        boolean hasDrug = LiveboardDailyDAO.hasDrugRoutine(userId);
        Map<String, String> mood = LiveboardDailyDAO.getTodayMood(userId);
        int gameCount = LiveboardDailyDAO.getTodayGameCount(userId);

        // ✅ null-safe 기본값
        Map<String, String> bf = safe(activity.get("Meal_breakfast"));
        Map<String, String> lu = safe(activity.get("Meal_lunch"));
        Map<String, String> dn = safe(activity.get("Meal_dinner"));
        Map<String, String> dr = safe(activity.get("Drug"));
        Map<String, String> md = safeMood(mood);

        PrintWriter out = resp.getWriter();

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"date\":\"").append(LocalDate.now()).append("\",");

        // meal
        sb.append("\"meal\":{");
        sb.append("\"Meal_breakfast\":").append(toJson(bf)).append(",");
        sb.append("\"Meal_lunch\":").append(toJson(lu)).append(",");
        sb.append("\"Meal_dinner\":").append(toJson(dn));
        sb.append("},");

        // drug
        sb.append("\"drug\":{");
        sb.append("\"enabled\":").append(hasDrug).append(",");
        sb.append("\"count\":\"").append(escape(dr.get("count"))).append("\",");
        sb.append("\"lastTime\":\"").append(escape(dr.get("lastTime"))).append("\"");
        sb.append("},");

        // mood
        sb.append("\"mood\":{");
        sb.append("\"value\":\"").append(escape(md.get("value"))).append("\",");
        sb.append("\"time\":\"").append(escape(md.get("time"))).append("\"");
        sb.append("},");

        // game
        sb.append("\"game\":{");
        sb.append("\"playCount\":").append(gameCount);
        sb.append("}");

        sb.append("}");

        out.print(sb.toString());
        out.flush();
        
    }

    private int resolveTargetUserId(HttpServletRequest req) {

        HttpSession session = req.getSession(false);
        if (session == null) return 0;

        // 1️⃣ 보호자인 경우 → linkedPatientId 사용
        String role = (String) session.getAttribute("userRole");

        if ("보호자".equals(role)) {
            Integer linked = (Integer) session.getAttribute("linkedPatientId");
            if (linked != null) {
                System.out.println("👨‍⚕️ 보호자 로그인 → 환자 activelog 조회: " + linked);
                return linked;
            }
        }

        // 2️⃣ 환자 로그인 → 본인 userId
        Integer myId = (Integer) session.getAttribute("userId");
        if (myId != null) {
            System.out.println("🧑 환자 로그인 → 본인 activelog 조회: " + myId);
            return myId;
        }

        // 3️⃣ 혹시 쿼리로 넘어온 경우 fallback
        String q = req.getParameter("user_id");
        if (q != null && q.matches("\\d+")) {
            System.out.println("📡 파라미터 user_id 사용: " + q);
            return Integer.parseInt(q);
        }
        System.out.println("===== LIVEBOARD DEBUG =====");
        System.out.println("session userId = " + session.getAttribute("userId"));
        System.out.println("session role = " + session.getAttribute("userRole"));
        System.out.println("session linked = " + session.getAttribute("linkedPatientId"));
        System.out.println("===========================");

        return 0;
    }



    // ✅ activity 기본값
    private Map<String, String> safe(Map<String, String> m) {
        if (m == null) return Map.of("count", "0", "lastTime", "");
        String c = (m.get("count") == null) ? "0" : m.get("count");
        String t = (m.get("lastTime") == null) ? "" : m.get("lastTime");
        return Map.of("count", c, "lastTime", t);
    }

    // ✅ mood 기본값
    private Map<String, String> safeMood(Map<String, String> m) {
        if (m == null) return Map.of("value", "", "time", "");
        String v = (m.get("value") == null) ? "" : m.get("value");
        String t = (m.get("time") == null) ? "" : m.get("time");
        return Map.of("value", v, "time", t);
    }

    private String toJson(Map<String, String> m) {
        return "{"
            + "\"count\":\"" + escape(m.get("count")) + "\","
            + "\"lastTime\":\"" + escape(m.get("lastTime")) + "\""
            + "}";
    }

    // ✅ JSON 문자열 안전 처리
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}

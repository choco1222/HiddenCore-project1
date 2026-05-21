package login;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

/**
 * 루틴 저장 서블릿
 * routineInput.jsp에서 전송된 데이터를 routine 테이블에 저장
 */
@WebServlet("/patient/saveRoutine")
public class RoutineInputServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            return;
        }
        
        try {
            // JSON 데이터 읽기
            BufferedReader reader = request.getReader();
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
            
            String jsonData = sb.toString();
            System.out.println("=== 루틴 데이터 수신 ===");
            System.out.println(jsonData);
            
            // JSON 파싱
            Gson gson = new Gson();
            JsonObject json = gson.fromJson(jsonData, JsonObject.class);
            
            List<RoutineDTO> routines = new ArrayList<>();
            
            // 1. 기상 시간
            String wakeTime = json.get("wakeTime").getAsString();
            boolean wakeHasDrug = json.has("wakeHasDrug") && json.get("wakeHasDrug").getAsBoolean();
            routines.add(new RoutineDTO(userId, "Awake", Time.valueOf(wakeTime + ":00"), wakeHasDrug));
            System.out.println("기상: " + wakeTime + (wakeHasDrug ? " (복약 있음)" : ""));
            
            // 2. 수면 시간
            String sleepTime = json.get("sleepTime").getAsString();
            boolean sleepHasDrug = json.has("sleepHasDrug") && json.get("sleepHasDrug").getAsBoolean();
            routines.add(new RoutineDTO(userId, "Sleep", Time.valueOf(sleepTime + ":00"), sleepHasDrug));
            System.out.println("수면: " + sleepTime + (sleepHasDrug ? " (복약 있음)" : ""));
            
            // 3. 식사 시간
            JsonArray meals = json.getAsJsonArray("meals");
            if (meals != null) {
                for (int i = 0; i < meals.size(); i++) {
                    JsonObject meal = meals.get(i).getAsJsonObject();
                    String mealType = meal.get("type").getAsString();  // "breakfast", "lunch", "dinner"
                    String mealTime = meal.get("time").getAsString();
                    
                    // JavaScript에서 보낸 hasDrug 값 사용
                    boolean hasDrug = meal.has("hasDrug") && meal.get("hasDrug").getAsBoolean();
                    
                    String routineType = "Meal_" + mealType;  // "Meal_breakfast", "Meal_lunch", "Meal_dinner"
                    routines.add(new RoutineDTO(userId, routineType, Time.valueOf(mealTime + ":00"), hasDrug));
                    System.out.println("식사: " + mealType + " " + mealTime + (hasDrug ? " (복약 있음)" : ""));
                }
            }
            
            // 4. 복약 시간 (독립 복약만)
            JsonArray medications = json.getAsJsonArray("medications");
            if (medications != null) {
                for (int i = 0; i < medications.size(); i++) {
                    JsonObject med = medications.get(i).getAsJsonObject();
                    String medType = med.get("type").getAsString();
                    
                    // "after_meal", "after_waking", "before_sleep"은 제외 (이미 처리됨)
                    if (!"after_meal".equals(medType) && 
                        !"after_waking".equals(medType) && 
                        !"before_sleep".equals(medType)) {
                        // "other" 복약 - 독립 시간
                        String medTime = med.get("time").getAsString();
                        routines.add(new RoutineDTO(userId, "Drug", Time.valueOf(medTime + ":00"), false));
                        System.out.println("복약: " + medTime + " (other)");
                    }
                }
            }
            
            // DB 저장
            RoutineDAO dao = new RoutineDAO();
            boolean saved = dao.saveRoutines(userId, routines);
            
            if (saved) {
                System.out.println("✓ 루틴 저장 완료");
                response.getWriter().write("{\"success\": true, \"message\": \"루틴이 저장되었습니다.\"}");
            } else {
                System.err.println("✗ 루틴 저장 실패");
                response.getWriter().write("{\"success\": false, \"message\": \"저장에 실패했습니다.\"}");
            }
            
        } catch (Exception e) {
            System.err.println("✗ 오류 발생:");
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"오류 발생: " + 
                e.getMessage() + "\"}");
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
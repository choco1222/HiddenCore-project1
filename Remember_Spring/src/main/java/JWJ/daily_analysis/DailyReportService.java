package JWJ.daily_analysis;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Service 클래스 - 비즈니스 로직 처리
 * 일간 리포트 데이터를 계산하고 가공하는 역할
 */
public class DailyReportService {
    
    /**
     * 일간 리포트 데이터를 Map 형태로 반환
     * @param date 조회할 날짜
     * @param userId 사용자 ID
     * @param activeLogs 활동 로그 리스트
     * @param gameLogs 게임 로그 리스트
     * @param routineList 루틴 설정 정보 리스트 (DB 테이블 구조 그대로)
     * @return 리포트 데이터 Map
     */
    public static Map<String, Object> getDailyReportMap(String date, String userId, 
                                                         List<DailyReportDTO.activelog> activeLogs, 
                                                         List<DailyReportDTO.game_log> gameLogs,
                                                         List<DailyReportDTO.routine> routineList) {
        List<DailyReportDTO.activelog> dayRecords = activeLogs.stream()
            .filter(r -> r.event_time != null && r.event_time.equals(date) && r.event_type != null && !r.event_type.equals("외출복귀"))
            .collect(Collectors.toList());
        
        List<DailyReportDTO.activelog> outingRecords = activeLogs.stream()
            .filter(r -> r.event_time != null && r.event_time.equals(date) && r.event_type != null && r.event_type.equals("외출복귀"))
            .collect(Collectors.toList());
        
        List<DailyReportDTO.game_log> gameRecords = gameLogs.stream()
            .filter(r -> r.played_at != null && r.played_at.equals(date))
            .collect(Collectors.toList());
        
        // DB의 routine 리스트를 시간대별로 변환
        List<String> mealTimes = new ArrayList<>();
        List<String> medicineTimes = new ArrayList<>();
        List<String> brushTimes = new ArrayList<>();
        
        for (DailyReportDTO.routine routine : routineList) {
            String timeSlot = convertTimeToSlot(routine.routine_time); // HH:MM -> 아침/점심/저녁
            
            if ("밥".equals(routine.routine_type)) {
                if (!mealTimes.contains(timeSlot)) {
                    mealTimes.add(timeSlot);
                }
            } else if ("약".equals(routine.routine_type)) {
                if (!medicineTimes.contains(timeSlot)) {
                    medicineTimes.add(timeSlot);
                }
            } else if ("양치".equals(routine.routine_type)) {
                if (!brushTimes.contains(timeSlot)) {
                    brushTimes.add(timeSlot);
                }
            }
        }
        
        // 루틴 설정에 따라 활동 초기화 (루틴에 없는 시간대는 null로 설정)
        Map<String, Map<String, Object>> activities = new HashMap<>();
        
        // 식사 루틴 설정
        Map<String, Object> mealActivity = new HashMap<>();
        mealActivity.put("morning", mealTimes.contains("아침") ? 0 : null);
        mealActivity.put("lunch", mealTimes.contains("점심") ? 0 : null);
        mealActivity.put("dinner", mealTimes.contains("저녁") ? 0 : null);
        mealActivity.put("morningCompleted", mealTimes.contains("아침") ? false : null);
        mealActivity.put("lunchCompleted", mealTimes.contains("점심") ? false : null);
        mealActivity.put("dinnerCompleted", mealTimes.contains("저녁") ? false : null);
        activities.put("식사", mealActivity);
        
        // 복약 루틴 설정 (복약이 없으면 모든 시간대가 null)
        Map<String, Object> medicineActivity = new HashMap<>();
        if (medicineTimes.isEmpty()) {
            medicineActivity.put("morning", null);
            medicineActivity.put("lunch", null);
            medicineActivity.put("dinner", null);
            medicineActivity.put("morningCompleted", null);
            medicineActivity.put("lunchCompleted", null);
            medicineActivity.put("dinnerCompleted", null);
        } else {
            medicineActivity.put("morning", medicineTimes.contains("아침") ? 0 : null);
            medicineActivity.put("lunch", medicineTimes.contains("점심") ? 0 : null);
            medicineActivity.put("dinner", medicineTimes.contains("저녁") ? 0 : null);
            medicineActivity.put("morningCompleted", medicineTimes.contains("아침") ? false : null);
            medicineActivity.put("lunchCompleted", medicineTimes.contains("점심") ? false : null);
            medicineActivity.put("dinnerCompleted", medicineTimes.contains("저녁") ? false : null);
        }
        activities.put("복약", medicineActivity);
        
        // 양치 루틴 설정
        Map<String, Object> brushActivity = new HashMap<>();
        brushActivity.put("morning", brushTimes.contains("아침") ? 0 : null);
        brushActivity.put("lunch", brushTimes.contains("점심") ? 0 : null);
        brushActivity.put("dinner", brushTimes.contains("저녁") ? 0 : null);
        brushActivity.put("morningCompleted", brushTimes.contains("아침") ? false : null);
        brushActivity.put("lunchCompleted", brushTimes.contains("점심") ? false : null);
        brushActivity.put("dinnerCompleted", brushTimes.contains("저녁") ? false : null);
        activities.put("양치", brushActivity);
        
        for (DailyReportDTO.activelog record : dayRecords) {
            if (!record.isDuplicate && activities.containsKey(record.event_type) && record.timeSlot != null) {
                Map<String, Object> activity = activities.get(record.event_type);
                if ("아침".equals(record.timeSlot) && activity.get("morning") != null) {
                    activity.put("morning", ((Integer)activity.get("morning")) + 1);
                    activity.put("morningCompleted", true);
                } else if ("점심".equals(record.timeSlot) && activity.get("lunch") != null) {
                    activity.put("lunch", ((Integer)activity.get("lunch")) + 1);
                    activity.put("lunchCompleted", true);
                } else if ("저녁".equals(record.timeSlot) && activity.get("dinner") != null) {
                    activity.put("dinner", ((Integer)activity.get("dinner")) + 1);
                    activity.put("dinnerCompleted", true);
                }
            }
        }
        
        // 루틴에 해당하는 총 슬롯 수와 완료된 슬롯 수 계산
        int totalRoutineSlots = 0;
        int completedSlots = 0;
        for (Map<String, Object> activity : activities.values()) {
            if (activity.get("morningCompleted") != null) {
                totalRoutineSlots++;
                if (Boolean.TRUE.equals(activity.get("morningCompleted"))) completedSlots++;
            }
            if (activity.get("lunchCompleted") != null) {
                totalRoutineSlots++;
                if (Boolean.TRUE.equals(activity.get("lunchCompleted"))) completedSlots++;
            }
            if (activity.get("dinnerCompleted") != null) {
                totalRoutineSlots++;
                if (Boolean.TRUE.equals(activity.get("dinnerCompleted"))) completedSlots++;
            }
        }
        int completionRate = totalRoutineSlots > 0 ? Math.round((completedSlots * 100) / totalRoutineSlots) : 0;
        
        String score = "노력해요";
        if (completionRate >= 90) score = "최고에요";
        else if (completionRate >= 70) score = "잘했어요";
        
        // 루틴에 해당하는 항목 중 완료하지 않은 것만 추가
        List<String> missedActivities = new ArrayList<>();
        for (Map.Entry<String, Map<String, Object>> entry : activities.entrySet()) {
            String name = entry.getKey();
            Map<String, Object> activity = entry.getValue();
            if (activity.get("morningCompleted") != null && !Boolean.TRUE.equals(activity.get("morningCompleted"))) {
                missedActivities.add(name + " - 아침");
            }
            if (activity.get("lunchCompleted") != null && !Boolean.TRUE.equals(activity.get("lunchCompleted"))) {
                missedActivities.add(name + " - 점심");
            }
            if (activity.get("dinnerCompleted") != null && !Boolean.TRUE.equals(activity.get("dinnerCompleted"))) {
                missedActivities.add(name + " - 저녁");
            }
        }
        
        Map<String, Double> gameAverages = new HashMap<>();
        for (String gameType : Arrays.asList("게임1", "게임2", "게임3")) {
            List<Integer> scores = gameRecords.stream()
                .filter(r -> r.game_type != null && r.game_type.equals(gameType))
                .map(r -> r.score)
                .collect(Collectors.toList());
            if (scores.size() > 0) {
                double avg = scores.stream().mapToInt(Integer::intValue).average().orElse(0);
                gameAverages.put(gameType, (double)Math.round(avg));
            }
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("date", date);
        result.put("completionRate", completionRate);
        result.put("score", score);
        result.put("hasOuting", outingRecords.size() > 0);
        result.put("missedActivities", missedActivities);
        result.put("activities", activities);
        result.put("gameAverages", gameAverages);
        
        return result;
    }
    
    /**
     * 시간(HH:MM)을 시간대(아침/점심/저녁)로 변환
     * @param timeStr 시간 문자열 (HH:MM 형식, 예: "08:30")
     * @return 시간대 문자열 ("아침", "점심", "저녁")
     */
    private static String convertTimeToSlot(String timeStr) {
        if (timeStr == null || timeStr.length() != 5) {
            return "저녁"; // 기본값
        }
        
        try {
            String[] parts = timeStr.split(":");
            int hour = Integer.parseInt(parts[0]);
            
            // 시간대 구분
            // 아침: 06:00 ~ 10:59
            // 점심: 11:00 ~ 15:59
            // 저녁: 16:00 ~ 23:59 또는 00:00 ~ 05:59
            if (hour >= 6 && hour < 11) {
                return "아침";
            } else if (hour >= 11 && hour < 16) {
                return "점심";
            } else {
                return "저녁";
            }
        } catch (Exception e) {
            return "저녁"; // 기본값
        }
    }
}

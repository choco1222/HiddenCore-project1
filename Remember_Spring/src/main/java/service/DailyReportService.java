package service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import dao.DailyReportDAO;

/**
 * Service - DailyAnalysis + timeSlot만 사용. 나머지는 DB에서 직접 불러와 쓴다.
 */
public class DailyReportService {

	/**
	 * 일간 리포트 데이터를 Map 형태로 반환 activeLogs(timeSlot)만 사용. 루틴/게임은 기본값(전체 시간대, 게임 없음).
	 */
	public static Map<String, Object> getDailyReportMap(String date, String userId,
			List<DailyReportDAO.ActivelogRow> activeLogs) {
		List<DailyReportDAO.ActivelogRow> dayRecords = activeLogs.stream().filter(r -> r.event_time != null
				&& r.event_time.equals(date) && r.event_type != null && !r.event_type.equals("외출복귀"))
				.collect(Collectors.toList());

		List<DailyReportDAO.ActivelogRow> outingRecords = activeLogs.stream().filter(r -> r.event_time != null
				&& r.event_time.equals(date) && r.event_type != null && r.event_type.equals("외출복귀"))
				.collect(Collectors.toList());

		// 기본 루틴: 아침/점심/저녁 모두 (routine 테이블 없이 timeSlot만 activelog에서 사용)
		List<String> mealTimes = List.of("아침", "점심", "저녁");
		List<String> medicineTimes = List.of("아침", "점심", "저녁");
		List<String> brushTimes = List.of("아침", "점심", "저녁");

		Map<String, Map<String, Object>> activities = new HashMap<>();

		Map<String, Object> mealActivity = new HashMap<>();
		mealActivity.put("morning", 0);
		mealActivity.put("lunch", 0);
		mealActivity.put("dinner", 0);
		mealActivity.put("morningCompleted", false);
		mealActivity.put("lunchCompleted", false);
		mealActivity.put("dinnerCompleted", false);
		activities.put("식사", mealActivity);

		Map<String, Object> medicineActivity = new HashMap<>();
		medicineActivity.put("morning", 0);
		medicineActivity.put("lunch", 0);
		medicineActivity.put("dinner", 0);
		medicineActivity.put("morningCompleted", false);
		medicineActivity.put("lunchCompleted", false);
		medicineActivity.put("dinnerCompleted", false);
		activities.put("복약", medicineActivity);

		Map<String, Object> brushActivity = new HashMap<>();
		brushActivity.put("morning", 0);
		brushActivity.put("lunch", 0);
		brushActivity.put("dinner", 0);
		brushActivity.put("morningCompleted", false);
		brushActivity.put("lunchCompleted", false);
		brushActivity.put("dinnerCompleted", false);
		activities.put("양치", brushActivity);

		for (DailyReportDAO.ActivelogRow record : dayRecords) {
			if (!record.isDuplicate && activities.containsKey(record.event_type) && record.timeSlot != null) {
				Map<String, Object> activity = activities.get(record.event_type);
				if ("아침".equals(record.timeSlot) && activity.get("morning") != null) {
					activity.put("morning", ((Integer) activity.get("morning")) + 1);
					activity.put("morningCompleted", true);
				} else if ("점심".equals(record.timeSlot) && activity.get("lunch") != null) {
					activity.put("lunch", ((Integer) activity.get("lunch")) + 1);
					activity.put("lunchCompleted", true);
				} else if ("저녁".equals(record.timeSlot) && activity.get("dinner") != null) {
					activity.put("dinner", ((Integer) activity.get("dinner")) + 1);
					activity.put("dinnerCompleted", true);
				}
			}
		}

		int totalRoutineSlots = 9;
		int completedSlots = 0;
		for (Map<String, Object> activity : activities.values()) {
			if (Boolean.TRUE.equals(activity.get("morningCompleted")))
				completedSlots++;
			if (Boolean.TRUE.equals(activity.get("lunchCompleted")))
				completedSlots++;
			if (Boolean.TRUE.equals(activity.get("dinnerCompleted")))
				completedSlots++;
		}
		int completionRate = totalRoutineSlots > 0 ? Math.round((completedSlots * 100) / totalRoutineSlots) : 0;

		String score = "노력해요";
		if (completionRate >= 90)
			score = "최고에요";
		else if (completionRate >= 70)
			score = "잘했어요";

		List<String> missedActivities = new ArrayList<>();
		for (Map.Entry<String, Map<String, Object>> entry : activities.entrySet()) {
			String name = entry.getKey();
			Map<String, Object> activity = entry.getValue();
			if (!Boolean.TRUE.equals(activity.get("morningCompleted")))
				missedActivities.add(name + " - 아침");
			if (!Boolean.TRUE.equals(activity.get("lunchCompleted")))
				missedActivities.add(name + " - 점심");
			if (!Boolean.TRUE.equals(activity.get("dinnerCompleted")))
				missedActivities.add(name + " - 저녁");
		}

		// 게임 데이터 없음 -> daily_score = active_score, game_score_avg = 0
		int gameScoreAvg = 0;
		int activeScore = completionRate;
		int dailyScore = activeScore;
		Map<String, Double> gameAverages = new HashMap<>();

		Map<String, Object> result = new HashMap<>();
		result.put("date", date);
		result.put("completionRate", completionRate);
		result.put("score", score);
		result.put("hasOuting", outingRecords.size() > 0);
		result.put("missedActivities", missedActivities);
		result.put("activities", activities);
		result.put("gameAverages", gameAverages);
		result.put("daily_score", dailyScore);
		result.put("active_score", activeScore);
		result.put("game_score_avg", gameScoreAvg);
		result.put("status_level", score);

		return result;
	}
}

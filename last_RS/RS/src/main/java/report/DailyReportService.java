package report;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * [이게 뭔지] Service - 일간 리포트 비즈니스 로직. ActivelogRow.routineType 사용. 테이블 DTO 없음.
 * [어디서] DailyReportDAO.ActivelogRow, GameLogRow 리스트를 서블릿에서 받음. [어디로] Map 형태로 서블릿에 반환 → JSON → JSP.
 */
public class DailyReportService {

	/**
	 * [이게 뭔지] 일간 리포트 데이터 Map 생성. activeLogs(routineType)와 gameLogs로 해당 날짜 루틴/게임 통계 계산.
	 * [어디서] date, userId, activeLogs, gameLogs 인자. [어디로] Map → JsonUtil.mapToJson → JSP reportDataJson.
	 */
	public static Map<String, Object> getDailyReportMap(String date, String userId,
			List<DailyReportDAO.ActivelogRow> activeLogs, List<DailyReportDAO.GameLogRow> gameLogs) {
		// [이게 뭔지] 해당 날짜의 일반 활동만 (외출복귀 제외). [뭘 썼는지] stream filter. [어디서] activeLogs.
		List<DailyReportDAO.ActivelogRow> dayRecords = activeLogs.stream()
			.filter(r -> r.event_time != null && r.event_time.equals(date) && r.event_type != null && !r.event_type.equals("외출복귀"))
			.collect(Collectors.toList());

		// [이게 뭔지] 해당 날짜의 외출복귀만. [어디로] result의 hasOuting 계산.
		List<DailyReportDAO.ActivelogRow> outingRecords = activeLogs.stream()
			.filter(r -> r.event_time != null && r.event_time.equals(date) && r.event_type != null && r.event_type.equals("외출복귀"))
			.collect(Collectors.toList());

		// [이게 뭔지] 기본 루틴 시간대(아침/점심/저녁). routineType은 DAO에서 routine JOIN으로 채움.
		List<String> mealTimes = List.of("아침", "점심", "저녁");
		List<String> medicineTimes = List.of("아침", "점심", "저녁");
		List<String> brushTimes = List.of("아침", "점심", "저녁");

		Map<String, Map<String, Object>> activities = new HashMap<>();

		// [이게 뭔지] 식사/복약/양치별 아침·점심·저녁 횟수 및 완료 여부. [어디로] result.activities, 화면 테이블용.
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

		// [이게 뭔지] dayRecords를 순회하며 activities 갱신. routineType(아침/점심/저녁)별로 해당 슬롯 +1, Completed true.
		for (DailyReportDAO.ActivelogRow record : dayRecords) {
			if (!record.isDuplicate && activities.containsKey(record.event_type) && record.routineType != null) {
				Map<String, Object> activity = activities.get(record.event_type);
				if ("아침".equals(record.routineType) && activity.get("morning") != null) {
					activity.put("morning", ((Integer) activity.get("morning")) + 1);
					activity.put("morningCompleted", true);
				} else if ("점심".equals(record.routineType) && activity.get("lunch") != null) {
					activity.put("lunch", ((Integer) activity.get("lunch")) + 1);
					activity.put("lunchCompleted", true);
				} else if ("저녁".equals(record.routineType) && activity.get("dinner") != null) {
					activity.put("dinner", ((Integer) activity.get("dinner")) + 1);
					activity.put("dinnerCompleted", true);
				}
			}
		}

		// [이게 뭔지] 완료율 계산. 9개 슬롯(식사·복약·양치 각 아침/점심/저녁) 중 완료 개수. [어디로] result.completionRate, score 판정.
		int totalRoutineSlots = 9;
		int completedSlots = 0;
		for (Map<String, Object> activity : activities.values()) {
			if (Boolean.TRUE.equals(activity.get("morningCompleted"))) completedSlots++;
			if (Boolean.TRUE.equals(activity.get("lunchCompleted"))) completedSlots++;
			if (Boolean.TRUE.equals(activity.get("dinnerCompleted"))) completedSlots++;
		}
		int completionRate = totalRoutineSlots > 0 ? Math.round((completedSlots * 100) / totalRoutineSlots) : 0;

		// [이게 뭔지] 완료율에 따른 문구. [어디로] result.score, status_level.
		String score = "노력해요";
		if (completionRate >= 90) score = "최고에요";
		else if (completionRate >= 70) score = "잘했어요";

		// [이게 뭔지] 놓친 루틴 목록 (예: "식사 - 아침"). [어디로] result.missedActivities → JSP 리스트 표시.
		List<String> missedActivities = new ArrayList<>();
		for (Map.Entry<String, Map<String, Object>> entry : activities.entrySet()) {
			String name = entry.getKey();
			Map<String, Object> activity = entry.getValue();
			if (!Boolean.TRUE.equals(activity.get("morningCompleted"))) missedActivities.add(name + " - 아침");
			if (!Boolean.TRUE.equals(activity.get("lunchCompleted"))) missedActivities.add(name + " - 점심");
			if (!Boolean.TRUE.equals(activity.get("dinnerCompleted"))) missedActivities.add(name + " - 저녁");
		}

		// [이게 뭔지] 해당 날짜 게임 로그만 필터. [어디서] gameLogs. [어디로] 게임 타입별 평균 계산. (GameLogRow.playedAt = LocalDateTime, GameDTO와 동일)
		List<DailyReportDAO.GameLogRow> dayGameRecords = gameLogs.stream()
			.filter(r -> r.playedAt != null && r.playedAt.toLocalDate().toString().equals(date))
			.collect(Collectors.toList());

		Map<String, Double> gameAverages = new HashMap<>();
		Map<String, List<Integer>> gameScoresByType = new HashMap<>();

		// [이게 뭔지] 게임 타입별 점수 수집. [뭘 썼는지] score 사용, total_score는 만점. [어디로] gameAverages 계산용.
		for (DailyReportDAO.GameLogRow gameRecord : dayGameRecords) {
			String gameType = gameRecord.game_type;
			if (gameType != null) {
				gameScoresByType.putIfAbsent(gameType, new ArrayList<>());
				gameScoresByType.get(gameType).add(gameRecord.score);
			}
		}

		for (Map.Entry<String, List<Integer>> entry : gameScoresByType.entrySet()) {
			String gameType = entry.getKey();
			List<Integer> scores = entry.getValue();
			if (!scores.isEmpty()) {
				double average = scores.stream().mapToInt(Integer::intValue).average().orElse(0.0);
				gameAverages.put(gameType, Math.round(average * 10.0) / 10.0); // 소수점 1자리
			}
		}

		// [이게 뭔지] 전체 게임 평균(정수). [어디로] result.game_score_avg, daily_score 계산.
		int gameScoreAvg = 0;
		if (!gameAverages.isEmpty()) {
			double totalAvg = gameAverages.values().stream().mapToDouble(Double::doubleValue).average().orElse(0.0);
			gameScoreAvg = (int) Math.round(totalAvg);
		}

		// [이게 뭔지] daily_score = (active_score + game_score_avg) / 2. 게임 없으면 active_score만. [어디로] result.
		int activeScore = completionRate;
		int dailyScore = gameScoreAvg > 0 ? (activeScore + gameScoreAvg) / 2 : activeScore;

		// [이게 뭔지] 최종 반환 Map. [어디로] JsonUtil.mapToJson → request.reportDataJson → daily.jsp.
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

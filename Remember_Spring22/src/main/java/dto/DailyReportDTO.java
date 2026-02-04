package dto;

/**
 * DTO (Data Transfer Object) - 데이터 전송 객체 우리 테이블: DailyAnalysis 만 사용.
 * TimeSlotRecord: timeSlot만 따로 쓸 때 사용 (이 안에는 timeSlot만 있음).
 */
public class DailyReportDTO {

	/**
	 * timeSlot만 따로 쓰기 위한 레코드. 이 안에는 timeSlot만 있으면 됨.
	 */
	public static class TimeSlotRecord {
		public String timeSlot;

		public TimeSlotRecord(String timeSlot) {
			this.timeSlot = timeSlot;
		}
	}

	/**
	 * DAILY_ANALYSIS 테이블 DTO analysis_date: 분석일, daily_score: 종합 일일 점수(0-100),
	 * active_score: 루틴(활동) 완료율(0-100), game_score_avg: 그날 게임 평균 점수, status_level:
	 * 등급(최고에요/잘했어요/노력해요), is_save_bool: 보고서 정상 유무(1=정상, 0=비정상)
	 */
	public static class DailyAnalysis {
		public String analysis_id;
		public String user_id;
		public String analysis_date; // yyyy-MM-dd
		public int daily_score;
		public int active_score;
		public int game_score_avg;
		public String status_level;
		public int is_save_bool;

		public DailyAnalysis() {
		}

		public DailyAnalysis(String analysis_id, String user_id, String analysis_date, int daily_score,
				int active_score, int game_score_avg, String status_level, int is_save_bool) {
			this.analysis_id = analysis_id;
			this.user_id = user_id;
			this.analysis_date = analysis_date;
			this.daily_score = daily_score;
			this.active_score = active_score;
			this.game_score_avg = game_score_avg;
			this.status_level = status_level;
			this.is_save_bool = is_save_bool;
		}
	}
}

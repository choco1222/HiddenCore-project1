package daily_analysis;

/**
 * DTO (Data Transfer Object) - 데이터 전송 객체
 * 데이터베이스 테이블 구조와 동일한 데이터 모델 클래스
 */
public class DailyReportDTO {
	
	/**
	 * ACTIVE_LOG 테이블 DTO
	 */
	public static class activelog {
		public String user_id;
		public String event_type;
		public String event_time;
		// 자바 코드안에서만 씀
		public String timeSlot; // 시간대별 아침 점심 저녁 카운트에 사용 (DailyReportService)
		public boolean isDuplicate; // 중복 체크 더미데이터처럼 불린값이 와야 함!!!!!
		
		public activelog(String user_id, String event_type, String event_time, String timeSlot, boolean isDuplicate) {
			this.user_id = user_id;
			this.event_type = event_type;
			this.event_time = event_time;
			this.timeSlot = timeSlot;
			this.isDuplicate = isDuplicate;
		}
	}

	/**
	 * GAME_LOG 테이블 DTO
	 */
	public static class game_log {
		public String user_id;
		public String game_type;
		public String game_level;
		public int score;
		public String played_at;

		public game_log(String user_id, String game_type, String game_level, int score, String played_at) {
			this.user_id = user_id;
			this.game_type = game_type;
			this.game_level = game_level;
			this.score = score;
			this.played_at = played_at;
		}
	}

	/**
	 * ROUTINE 테이블 DTO
	 * 실제 데이터베이스 테이블 구조와 동일
	 * 
	 * DB 구조:
	 * - user_id: 사용자 ID
	 * - routine_type: '밥', '약', '양치'
	 * - routine_time: 'HH:MM' 형식 (예: "08:30", "12:00", "19:30")
	 */
	public static class routine {
		public String user_id;
		public String routine_type;  // '밥', '약', '양치'
		public String routine_time;  // 'HH:MM' 형식

		public routine(String user_id, String routine_type, String routine_time) {
			this.user_id = user_id;
			this.routine_type = routine_type;
			this.routine_time = routine_time;
		}
	}
}

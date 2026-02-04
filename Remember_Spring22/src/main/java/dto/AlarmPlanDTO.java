package dto;

import java.time.LocalTime;

public class AlarmPlanDTO {
	private String routineType; // "아침_밥", "식전_약" ...
	private int seq; // 1=아침 2=점심 3=저녁 / 기상/취침은 1
	private LocalTime baseTime; // 기준시간 T
	private LocalTime fireTime; // 발생시간 (T or T+30)
	private String stage; // "ONTIME" or "LATE"
	private String title;
	private String body;

	public AlarmPlanDTO(String routineType, int seq, LocalTime baseTime, LocalTime fireTime, String stage, String title,
			String body) {
		this.routineType = routineType;
		this.seq = seq;
		this.baseTime = baseTime;
		this.fireTime = fireTime;
		this.stage = stage;
		this.title = title;
		this.body = body;
	}

	public String getRoutineType() {
		return routineType;
	}

	public int getSeq() {
		return seq;
	}

	public LocalTime getBaseTime() {
		return baseTime;
	}

	public LocalTime getFireTime() {
		return fireTime;
	}

	public String getStage() {
		return stage;
	}

	public String getTitle() {
		return title;
	}

	public String getBody() {
		return body;
	}
}

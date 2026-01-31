package active_log;

public class board_DTO {

	private String log_Id;
	private String user_Id;
	private String event_Type;
	private int event_Count;
	private String event_Time;

	public String getLog_Id() {
		return log_Id;
	}

	public void setLog_Id(String log_Id) {
		this.log_Id = log_Id;
	}

	public String getUser_Id() {
		return user_Id;
	}

	public void setUser_Id(String user_Id) {
		this.user_Id = user_Id;
	}

	public String getEvent_Type() {
		return event_Type;
	}

	public void setEvent_Type(String event_Type) {
		this.event_Type = event_Type;
	}

	public int getEvent_Count() {
		return event_Count;
	}

	public void setEvent_Count(int event_Count) {
		this.event_Count = event_Count;
	}

	public String getEvent_Time() {
		return event_Time;
	}

	public void setEvent_Time(String event_Time) {
		this.event_Time = event_Time;
	}

}
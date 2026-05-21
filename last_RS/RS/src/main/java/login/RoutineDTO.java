package login;

import java.sql.Time;

/**
 * Routine DTO
 * routine 테이블에 대응
 */
public class RoutineDTO {
    private int routineId;
    private int userId;
    private String routineType;  // 'meal', 'drug', 'wake', 'sleep'
    private Time routineTime;
    private boolean isDrug;     // 식후 복약: '아침', '점심', '저녁'
    
    // Constructors
    public RoutineDTO() {}
    
    public RoutineDTO(int userId, String routineType, Time routineTime, boolean isDrug) {
        this.userId = userId;
        this.routineType = routineType;
        this.routineTime = routineTime;
        this.isDrug = isDrug;
    }
    
    // Getters and Setters
    public int getRoutineId() {
        return routineId;
    }
    
    public void setRoutineId(int routineId) {
        this.routineId = routineId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getRoutineType() {
        return routineType;
    }
    
    public void setRoutineType(String routineType) {
        this.routineType = routineType;
    }
    
    public Time getRoutineTime() {
        return routineTime;
    }
    
    public void setRoutineTime(Time routineTime) {
        this.routineTime = routineTime;
    }
    
    public boolean getIsDrug() {
        return isDrug;
    }
    
    public void setIsDrug(boolean isDrug) {
        this.isDrug = isDrug;
    }
    
    // 편의 메서드
    public String getRoutineTimeString() {
        return routineTime != null ? routineTime.toString().substring(0, 5) : "";
    }
    
    @Override
    public String toString() {
        return "RoutineDTO{routineId=" + routineId + ", userId=" + userId + 
               ", routineType='" + routineType + "', routineTime=" + routineTime + 
               ", isDrug='" + isDrug + "'}";
    }
}

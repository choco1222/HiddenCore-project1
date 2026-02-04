package dto;

import java.sql.Connection;

public class DailyAnalysisDTO {

    public String analysis_id;
    public String user_id;
    public String analysis_date;   // yyyy-MM-dd
    public String status_level;    // 최고에요 / 잘했어요 / 주의 / 위험
    public int is_save_bool;        // 1 = 정상
    public Connection con;

    public DailyAnalysisDTO() {}
    
    public DailyAnalysisDTO(Connection con, String user_id) {
    	this.user_id = user_id;
    	this.con = con;
    }
    

    public DailyAnalysisDTO(String analysis_id, String user_id, String analysis_date,
                            String status_level, int is_save_bool) {
        this.analysis_id = analysis_id;
        this.user_id = user_id;
        this.analysis_date = analysis_date;
        this.status_level = status_level;
        this.is_save_bool = is_save_bool;
    }
}

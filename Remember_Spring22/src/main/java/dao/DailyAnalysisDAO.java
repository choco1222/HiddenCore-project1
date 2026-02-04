package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import dto.DailyAnalysisDTO;


public class DailyAnalysisDAO {
	
    public DailyAnalysisDTO selectToday(Connection con, String userId) throws Exception {

        String sql =
            "SELECT analysis_id, user_id, analysis_date, status_level, is_save_bool " +
            "FROM daily_analysis " +
            "WHERE user_id = ? " +
            "  AND analysis_date = CURDATE() " +
            "  AND is_save_bool = 1 " +
            "LIMIT 1";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;

                return new DailyAnalysisDTO(
                    rs.getString("analysis_id"),
                    rs.getString("user_id"),
                    rs.getDate("analysis_date").toString(),
                    rs.getString("status_level"),
                    rs.getInt("is_save_bool")
                );
            }
        }
    }
}

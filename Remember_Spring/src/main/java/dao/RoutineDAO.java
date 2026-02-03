package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

public class RoutineDAO {

	public Map<String, String> selectRoutineMap(Connection con, String userId) throws Exception {
		Map<String, String> map = new HashMap<>();

		String sql = "SELECT routine_type, routine_time FROM routine WHERE user_id = ?";
		try (PreparedStatement ps = con.prepareStatement(sql)) {
			ps.setString(1, userId);

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					String type = rs.getString("routine_type");
					String time = rs.getString("routine_time");
					if (type != null && time != null) {
						map.put(type.trim(), time.trim());
					}
				}
			}
		}
		return map;
	}
}
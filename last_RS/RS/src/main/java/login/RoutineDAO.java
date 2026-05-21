package login;

import java.sql.*;

import java.util.ArrayList;
import java.util.List;

import connect.ConDB;

/**
 * Routine DAO
 */
public class RoutineDAO {
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	/**
	 * 루틴 일괄 저장 (기존 삭제 후 새로 등록)
	 */
	public boolean saveRoutines(int userId, List<RoutineDTO> routines) {

		try (Connection con = ConDB.getCon();){
			con.setAutoCommit(false);

			// 1. 기존 루틴 삭제
			String deleteSql = "DELETE FROM routine WHERE user_id = ?";
			pstmt = con.prepareStatement(deleteSql);
			pstmt.setInt(1, userId);
			pstmt.executeUpdate();
			pstmt.close();

			System.out.println("✓ 기존 루틴 삭제");

			// 2. 새 루틴 저장
			String insertSql = "INSERT INTO routine (user_id, routine_type, routine_time, is_drug) "
					+ "VALUES (?, ?, ?, ?)";
			pstmt = con.prepareStatement(insertSql);

			for (RoutineDTO routine : routines) {
				pstmt.setInt(1, userId);
				pstmt.setString(2, routine.getRoutineType());
				pstmt.setTime(3, routine.getRoutineTime());
				pstmt.setBoolean(4, routine.getIsDrug());
				pstmt.addBatch();
			}

			int[] results = pstmt.executeBatch();
			System.out.println("☑️ 새 루틴 저장: " + results.length + "개");

			con.commit();
			return true;

		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
	}

	/**
	 * 사용자의 모든 루틴 조회 일치
	 */
	
	public List<RoutineDTO> getRoutines(int userId) {
		List<RoutineDTO> list = new ArrayList<>();

		try (Connection con = ConDB.getCon();){
			String sql = "SELECT * FROM routine WHERE user_id = ? ORDER BY routine_time";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				RoutineDTO dto = new RoutineDTO();
				dto.setRoutineId(rs.getInt("routine_id"));
				dto.setUserId(rs.getInt("user_id"));
				dto.setRoutineType(rs.getString("routine_type"));
				dto.setRoutineTime(rs.getTime("routine_time"));
				dto.setIsDrug(rs.getBoolean("is_Drug"));
				list.add(dto);
			}
	
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}

		return list;
	}

	/**
	 * 타입별 루틴 조회
	 */
	public List<RoutineDTO> getRoutinesByType(int userId, String routineType) {
		List<RoutineDTO> list = new ArrayList<>();
		
		try (Connection con = ConDB.getCon();){
			String sql = "SELECT * FROM routine WHERE user_id = ? AND routine_type = ? " + "ORDER BY routine_time";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			pstmt.setString(2, routineType);
			rs = pstmt.executeQuery();
			
			while (rs.next()) {
				RoutineDTO dto = new RoutineDTO();
				dto.setRoutineId(rs.getInt("routine_id"));
				dto.setUserId(rs.getInt("user_id"));
				dto.setRoutineType(rs.getString("routine_type"));
				dto.setRoutineTime(rs.getTime("routine_time"));
				dto.setIsDrug(rs.getBoolean("is_Drug"));
				list.add(dto);
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}

		return list;
	}

	/**
	 * 사용자의 루틴 등록 여부 확인
	 */
	public boolean hasRoutine(int userId) {
		try (Connection con = ConDB.getCon();){
			System.out.print(userId);
			String sql = "SELECT COUNT(*) FROM routine WHERE user_id = ?";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			if (rs.next()) 
				return rs.getInt(1) > 0;
			else 
				return false;		

		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try {
				if (rs != null)
					rs.close();
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
	}

	/**
	 * 기상 시간 조회
	 */
	public RoutineDTO getWakeTime(int userId) {
		List<RoutineDTO> list = getRoutinesByType(userId, "wake");
		return list.isEmpty() ? null : list.get(0);
	}

	/**
	 * 수면 시간 조회
	 */
	public RoutineDTO getSleepTime(int userId) {
		List<RoutineDTO> list = getRoutinesByType(userId, "sleep");
		return list.isEmpty() ? null : list.get(0);
	}

	/**
	 * 식사 시간 조회
	 */
	public List<RoutineDTO> getMealTimes(int userId) {
		return getRoutinesByType(userId, "meal");
	}

	/**
	 * 복약 시간 조회
	 */
	public List<RoutineDTO> getDrugTimes(int userId) {
		return getRoutinesByType(userId, "drug");
	}

	/**
	 * 루틴 삭제
	 */
	public boolean deleteRoutine(int routineId, int userId) {
		try (Connection con = ConDB.getCon();){
			String sql = "DELETE FROM routine WHERE routine_id = ? AND user_id = ?";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, routineId);
			pstmt.setInt(2, userId);

			return pstmt.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
			return false;
		} finally {
			try {
				if (pstmt != null)
					pstmt.close();
			} catch (Exception e) {
			}
		}
	}
}

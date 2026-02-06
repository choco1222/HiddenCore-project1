package project;

import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import project.GameDTO;

public class GameDAO {

	// DB 연결 정보 (실제 사용 시 수정 필요)
	private static final String DB_URL = "jdbc:mysql://localhost:3306/memory_spring?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
	private static final String DB_USER = "root";
	private static final String DB_PASSWORD = "12345";

	// DB 연결
	private Connection getConnection() throws SQLException {
		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
			return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
		} catch (ClassNotFoundException e) {
			throw new SQLException("MySQL 드라이버를 찾을 수 없습니다.", e);
		}
	}

	/**
	 * 게임 결과를 DB에 저장
	 * 
	 * @param dto 게임 결과 정보
	 * @return 저장 성공 여부
	 */
	public boolean insertGameLog(GameDTO dto) {
		String sql = "INSERT INTO game_log (game_id, user_id, game_type, game_level, play_time, score, played_at) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setString(1, dto.getGame_id());
			pstmt.setInt(2, dto.getUser_id());
			pstmt.setString(3, dto.getGame_type());
			pstmt.setString(4, dto.getGame_level());
			pstmt.setString(5, dto.getPlay_time());
			pstmt.setInt(6, dto.getScore());
			pstmt.setTimestamp(7, Timestamp.valueOf(dto.getPlayedAt()));

			int result = pstmt.executeUpdate();
			return result > 0;

		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	/**
	 * ✅ 특정 날짜의 특정 게임 타입에 대한 평균 점수를 계산하여 모든 해당 레코드에 업데이트
	 * 
	 * @param userId   사용자 ID
	 * @param gameType 게임 타입 (예: "CARD_GAME", "WORD_GAME")
	 * @param date     날짜
	 * @return 업데이트 성공 여부
	 */
	public boolean updateDailyAverageScore(int userId, String gameType, LocalDate date) {
		// 1단계: 해당 날짜의 해당 게임 타입의 평균 점수 계산
		String selectSql = "SELECT AVG(score) as avg_score " +
		                   "FROM game_log " +
		                   "WHERE user_id = ? AND game_type = ? AND DATE(played_at) = ?";
		
		// 2단계: 계산된 평균을 해당 레코드들에 업데이트
		String updateSql = "UPDATE game_log " +
		                   "SET avg_score = ? " +
		                   "WHERE user_id = ? AND game_type = ? AND DATE(played_at) = ?";
		
		try (Connection conn = getConnection()) {
			// 평균 계산 (반올림하여 정수로 변환)
			int avgScore = 0;
			try (PreparedStatement selectPstmt = conn.prepareStatement(selectSql)) {
				selectPstmt.setInt(1, userId);
				selectPstmt.setString(2, gameType);
				selectPstmt.setDate(3, Date.valueOf(date));
				
				ResultSet rs = selectPstmt.executeQuery();
				if (rs.next()) {
					avgScore = (int) Math.round(rs.getDouble("avg_score"));
				}
			}
			
			// 평균 업데이트
			try (PreparedStatement updatePstmt = conn.prepareStatement(updateSql)) {
				updatePstmt.setInt(1, avgScore);
				updatePstmt.setInt(2, userId);
				updatePstmt.setString(3, gameType);
				updatePstmt.setDate(4, Date.valueOf(date));
				
				int result = updatePstmt.executeUpdate();
				System.out.println(userId + "번 사용자의 " + date + " " + gameType + " 평균: " + avgScore + "점");
				return result > 0;
			}
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
	}

	/**
	 * 특정 사용자의 게임 결과 조회
	 * 
	 * @param userId 사용자 ID
	 * @param gameId 게임 ID
	 * @return 게임 결과 리스트
	 */
	public List<GameDTO> getGameResults(String userId, String gameId) {
		List<GameDTO> results = new ArrayList<>();
		String sql = "SELECT * FROM game_log WHERE user_id = ? AND game_id = ? ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setString(2, gameId);

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getInt("user_id"));
				dto.setGame_type(rs.getString("game_type"));
				dto.setGame_level(rs.getString("game_level"));
				dto.setPlay_time(rs.getString("play_time"));
				dto.setScore(rs.getInt("score"));
				dto.setPlayedAt(rs.getTimestamp("played_at").toLocalDateTime());
				results.add(dto);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return results;
	}

	/**
	 * 게임 타입별로 결과 조회 (word게임, card게임 구별)
	 * 
	 * @param userId   사용자 ID
	 * @param gameType 게임 타입 ("word" 또는 "card")
	 * @return 게임 결과 리스트
	 */
	public List<GameDTO> getGameResultsByType(String userId, String gameType) {
		List<GameDTO> results = new ArrayList<>();
		String sql = "SELECT * FROM game_log WHERE user_id = ? AND game_type = ? ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setString(2, gameType);

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getInt("user_id"));
				dto.setGame_type(rs.getString("game_type"));
				dto.setGame_level(rs.getString("game_level"));
				dto.setPlay_time(rs.getString("play_time"));
				dto.setScore(rs.getInt("score"));
				dto.setPlayedAt(rs.getTimestamp("played_at").toLocalDateTime());
				results.add(dto);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return results;
	}

	/**
	 * 하루 동안 각 게임 타입마다 점수 평균 조회 (avg_score 컬럼에서)
	 * 
	 * @param userId   사용자 ID
	 * @param date     날짜 (년-월-일)
	 * @return Map<게임타입, 평균점수>
	 */
	public Map<String, Integer> getDailyAverageScoreByType(int userId, LocalDate date) {
	    Map<String, Integer> averageScores = new HashMap<>();
	    
	    // ✅ avg_score 컬럼에서 읽어오기 (이미 계산되어 저장된 값)
	    String sql = "SELECT DISTINCT game_type, avg_score " +
	                 "FROM game_log " +
	                 "WHERE user_id = ? AND DATE(played_at) = ? " +
	                 "ORDER BY game_type";
	    
	    try (Connection conn = getConnection(); 
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        
	        pstmt.setInt(1, userId);
	        pstmt.setDate(2, Date.valueOf(date));
	        
	        ResultSet rs = pstmt.executeQuery();
	        
	        while (rs.next()) {
	            String gameType = rs.getString("game_type");
	            int avgScore = rs.getInt("avg_score");
	            averageScores.put(gameType, avgScore);
	        }
	        
	    } catch (SQLException e) {
	        e.printStackTrace();
	    }
	    
	    return averageScores;
	}

	/**
	 * 특정 날짜의 게임 결과 조회 (년/월/일)
	 * 
	 * @param userId 사용자 ID
	 * @param date   조회할 날짜
	 * @return 게임 결과 리스트
	 */
	public List<GameDTO> getGameResultsByDate(String userId, LocalDate date) {
		List<GameDTO> results = new ArrayList<>();

		String sql = "SELECT * FROM game_log " + "WHERE user_id = ? AND DATE(played_at) = ? "
				+ "ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setDate(2, Date.valueOf(date));

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getInt("user_id"));
				dto.setGame_type(rs.getString("game_type"));
				dto.setGame_level(rs.getString("game_level"));
				dto.setPlay_time(rs.getString("play_time"));
				dto.setScore(rs.getInt("score"));
				dto.setPlayedAt(rs.getTimestamp("played_at").toLocalDateTime());
				results.add(dto);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return results;
	}
	
	

	/**
	 * 특정 기간 동안의 게임 타입별, 난이도별 평균 점수 조회
	 * 
	 * @param userId    사용자 ID
	 * @param startDate 시작 날짜
	 * @param endDate   종료 날짜
	 * @return Map<게임타입_난이도, 평균점수>
	 */
	public Map<String, Double> getAverageScoreByTypeAndLevel(String userId, LocalDate startDate, LocalDate endDate) {
		Map<String, Double> averageScores = new HashMap<>();

		String sql = "SELECT game_type, game_level, AVG(score) as avg_score " + "FROM game_log "
				+ "WHERE user_id = ? AND DATE(played_at) BETWEEN ? AND ? " + "GROUP BY game_type, game_level";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setDate(2, Date.valueOf(startDate));
			pstmt.setDate(3, Date.valueOf(endDate));

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				String gameType = rs.getString("game_type");
				String level = rs.getString("game_level");
				double avgScore = rs.getDouble("avg_score");
				String key = gameType + "_" + level;
				averageScores.put(key, avgScore);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return averageScores;
	}

	/**
	 * 사용자의 전체 게임 통계 조회
	 * 
	 * @param userId 사용자 ID
	 * @return 통계 정보를 담은 Map
	 */
	public Map<String, Object> getUserGameStatistics(String userId) {
		Map<String, Object> statistics = new HashMap<>();

		String sql = "SELECT " + "COUNT(*) as total_games, " + "AVG(score) as avg_score, " + "MAX(score) as max_score, "
				+ "MIN(score) as min_score, " + "game_type, " + "game_level " + "FROM game_log "
				+ "WHERE user_id = ? " + "GROUP BY game_type, game_level";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				String key = rs.getString("game_type") + "_" + rs.getString("game_level");
				Map<String, Object> stat = new HashMap<>();
				stat.put("total_games", rs.getInt("total_games"));
				stat.put("avg_score", rs.getDouble("avg_score"));
				stat.put("max_score", rs.getInt("max_score"));
				stat.put("min_score", rs.getInt("min_score"));
				statistics.put(key, stat);
			}

		} catch (SQLException e) {
			e.printStackTrace();
		}

		return statistics;
	}

	/**
	 * DB 테이블 생성 (최초 실행 시)
	 */
	public void createTable() {
		String sql = "CREATE TABLE IF NOT EXISTS game_log (" + "id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "game_id VARCHAR(50) NOT NULL, " + "user_id INT NOT NULL, "
				+ "game_type VARCHAR(20) NOT NULL, " + "game_level VARCHAR(20) NOT NULL, " + "play_time VARCHAR(20), "
				+ "score INT NOT NULL, " 
				+ "avg_score INT DEFAULT 0, "  // ✅ avg_score 컬럼 - 정수형
				+ "played_at TIMESTAMP NOT NULL, "
				+ "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " + "INDEX idx_user_game (user_id, game_id), "
				+ "INDEX idx_user_type (user_id, game_type), " + "INDEX idx_played_at (played_at)" + ")";

		try (Connection conn = getConnection(); Statement stmt = conn.createStatement()) {

			stmt.executeUpdate(sql);
			System.out.println("테이블이 생성되었습니다.");

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}
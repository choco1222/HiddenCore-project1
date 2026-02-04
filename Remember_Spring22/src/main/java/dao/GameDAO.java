package dao;

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

import dto.GameDTO;

public class GameDAO {

	// DB 연결 정보 (실제 사용 시 수정 필요)
	private static final String DB_URL = "jdbc:mysql://localhost:3306/game_db";
	private static final String DB_USER = "root";
	private static final String DB_PASSWORD = "password";

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
		String sql = "INSERT INTO game_results (game_id, user_id, game_type, game_level, play_time, score, played_at) "
				+ "VALUES (?, ?, ?, ?, ?, ?, ?)";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, dto.getGame_id());
			pstmt.setString(2, dto.getUser_id());
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
	 * 특정 사용자의 게임 결과 조회
	 * 
	 * @param userId 사용자 ID
	 * @param gameId 게임 ID
	 * @return 게임 결과 리스트
	 */
	public List<GameDTO> getGameResults(String userId, String gameId) {
		List<GameDTO> results = new ArrayList<>();
		String sql = "SELECT * FROM game_results WHERE user_id = ? AND game_id = ? ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setString(2, gameId);

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getString("user_id"));
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
		String sql = "SELECT * FROM game_results WHERE user_id = ? AND game_type = ? ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setString(2, gameType);

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getString("user_id"));
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
	 * 하루 동안 각 게임 난이도마다 점수 평균 계산
	 * 
	 * @param userId   사용자 ID
	 * @param gameType 게임 타입
	 * @param date     날짜 (년-월-일)
	 * @return Map<난이도, 평균점수>
	 */
	public Map<String, Double> getDailyAverageScoreByLevel(String userId, String gameType, LocalDate date) {
		Map<String, Double> averageScores = new HashMap<>();

		String sql = "SELECT game_level, AVG(score) as avg_score " + "FROM game_results "
				+ "WHERE user_id = ? AND game_type = ? " + "AND DATE(played_at) = ? " + "GROUP BY game_level";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setString(2, gameType);
			pstmt.setDate(3, Date.valueOf(date));

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				String level = rs.getString("game_level");
				double avgScore = rs.getDouble("avg_score");
				averageScores.put(level, avgScore);
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

		String sql = "SELECT * FROM game_results " + "WHERE user_id = ? AND DATE(played_at) = ? "
				+ "ORDER BY played_at DESC";

		try (Connection conn = getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {

			pstmt.setString(1, userId);
			pstmt.setDate(2, Date.valueOf(date));

			ResultSet rs = pstmt.executeQuery();

			while (rs.next()) {
				GameDTO dto = new GameDTO();
				dto.setGame_id(rs.getString("game_id"));
				dto.setUser_id(rs.getString("user_id"));
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

		String sql = "SELECT game_type, game_level, AVG(score) as avg_score " + "FROM game_results "
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
				+ "MIN(score) as min_score, " + "game_type, " + "game_level " + "FROM game_results "
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
		String sql = "CREATE TABLE IF NOT EXISTS game_results (" + "id INT AUTO_INCREMENT PRIMARY KEY, "
				+ "game_id VARCHAR(50) NOT NULL, " + "user_id VARCHAR(50) NOT NULL, "
				+ "game_type VARCHAR(20) NOT NULL, " + "game_level VARCHAR(20) NOT NULL, " + "play_time VARCHAR(20), "
				+ "score INT NOT NULL, " + "played_at TIMESTAMP NOT NULL, "
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
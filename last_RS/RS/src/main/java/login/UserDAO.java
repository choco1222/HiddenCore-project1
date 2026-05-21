package login;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import connect.ConDB;
import login.SurveyResultDTO;
import login.UserDTO;
import login.PasswordUtil;

public class UserDAO {

	private PreparedStatement pstmt;
	private ResultSet rs;

	// -----------------------1. 아이디 중복 체크-----------------------
	public boolean checkDuplicateId(String loginId) {
		boolean isDuplicate = false;

		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT COUNT(*) FROM users WHERE login_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, loginId);
			rs = pstmt.executeQuery();

			if (rs.next() && rs.getInt(1) > 0) {
				isDuplicate = true;
			}
			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return isDuplicate;
	}

	// -----------------------2. 회원가입 (INSERT)-----------------------
	public boolean insertUser(UserDTO dto) {
		boolean success = false;

		try (Connection con = ConDB.getCon();) {
			// loginId와 password로 userId 생성
			int userId = dto.generateUserId();

			// 중복 userId 체크 및 재생성 (충돌 가능성 대비)
			int attempts = 0;
			while (checkDuplicateUserId(userId) && attempts < 10) {
				// 충돌 시 약간 변형하여 재생성
				dto.setLoginId(dto.getLoginId() + "_" + attempts);
				userId = dto.generateUserId();
				attempts++;
			}

			if (attempts >= 10) {
				System.err.println("Failed to generate unique userId after 10 attempts");
				return false;
			}

			// userId를 명시적으로 지정
			String sql = "INSERT INTO users (user_id, login_id, password, role, name, phone, email, created_at) "
					+ "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			pstmt.setString(2, dto.getLoginId());
			pstmt.setString(3, dto.getPassword());
			pstmt.setString(4, dto.getRole());
			pstmt.setString(5, dto.getName());
			pstmt.setString(6, dto.getPhone());
			pstmt.setString(7, dto.getEmail());

			success = (pstmt.executeUpdate() > 0);

			// 생성된 userId를 DTO에 저장
			if (success) {
				dto.setUserId(userId);
				System.out.println("저장 성공 userId: " + userId);
			} else {
				System.out.println("DB 저장 실패");
			}

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return success;
	}

	// -----------------------2-1. userId 중복 체크 + 회원 유무 확인-----------------------
	public boolean checkDuplicateUserId(int userId) {
		boolean isDuplicate = false;

		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT COUNT(*) FROM users WHERE user_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			if (rs.next() && rs.getInt(1) > 0) {
				isDuplicate = true;
			}
			rs.close();
			pstmt.close();
			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return isDuplicate;
	}

	// -----------------------3. 로그인 인증-----------------------
	public UserDTO authenticateUser(String loginId, String password) {
		UserDTO user = null;

		try (Connection con = ConDB.getCon();) {
			// loginId로 사용자 조회
			String sql = "SELECT user_id, login_id, password, role, name, phone, email, "
					+ "linked_user_id, survey_type, survey_score, survey_date " + "FROM users WHERE login_id = ?";

			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, loginId);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				// DB에 저장된 암호화된 비밀번호
				String storedPassword = rs.getString("password");

				// 비밀번호 검증
				if (PasswordUtil.verifyPassword(password, storedPassword)) {
					// 검증 성공 - UserDTO 생성
					user = new UserDTO();
					user.setUserId(rs.getInt("user_id"));
					user.setLoginId(rs.getString("login_id"));
					user.setPassword(rs.getString("password"));
					user.setRole(rs.getString("role"));
					user.setName(rs.getString("name"));
					user.setPhone(rs.getString("phone"));
					user.setEmail(rs.getString("email"));

					// NULL 가능 필드 처리
					int linkedUserId = rs.getInt("linked_user_id");
					if (!rs.wasNull()) {
						user.setLinkedUserId(linkedUserId);
					}

					user.setSurveyType(rs.getString("survey_type"));

					int surveyScore = rs.getInt("survey_score");
					if (!rs.wasNull()) {
						user.setSurveyScore(surveyScore);
					}

					user.setSurveyDate(rs.getDate("survey_date"));
				}
			}
			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return user;
	}

	// -----------------------4. 사용자 ID로 조회-----------------------
	public UserDTO getUserById(int userId) {
		UserDTO user = null;

		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT * FROM users WHERE user_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				user = new UserDTO();
				user.setUserId(rs.getInt("user_id"));
				user.setLoginId(rs.getString("login_id"));
				user.setRole(rs.getString("role"));
				user.setName(rs.getString("name"));
				user.setPhone(rs.getString("phone"));
				user.setEmail(rs.getString("email"));

				int linkedUserId = rs.getInt("linked_user_id");
				if (!rs.wasNull()) {
					user.setLinkedUserId(linkedUserId);
				}
			}

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}
		return user;
	}

	// -----------------------5. 보호자-환자 연결-----------------------
	public boolean linkPatient(int caregiverId, int patientId) {
		boolean success = false;

		try (Connection con = ConDB.getCon();) {
			String sql = "UPDATE users SET linked_user_id = ? WHERE user_id = ? AND role = '보호자'";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, patientId);
			pstmt.setInt(2, caregiverId);

			int result = pstmt.executeUpdate();
			success = (result > 0);

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return success;
	}

	// -----------------------6. 환자 회원번호로 user_id 조회-----------------------
	public Integer getPatientIdByMemberId(String memberId) {
		Integer patientId = null;

		try (Connection con = ConDB.getCon();) {
			// memberId는 user_id를 문자열로 표현한 것으로 가정
			String sql = "SELECT user_id FROM users WHERE user_id = ? AND role = '환자'";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, Integer.parseInt(memberId));
			rs = pstmt.executeQuery();

			if (rs.next()) {
				patientId = rs.getInt("user_id");
			}

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}
		return patientId;
	}

	// -----------------------7. 설문 결과 저장-----------------------
	/**
	 * 설문 결과 저장 (survey, users 모두 업데이트)
	 */
	public boolean saveSurveyResult(SurveyResultDTO survey) {
		try (Connection con = ConDB.getCon();) {
			if (con == null) {
				System.err.println("✗ DB 연결 실패");
				return false;
			}

			// 1. survey 테이블에 상세 데이터 저장
			String sql1 = "INSERT INTO survey (" + "user_id, correct_words, clock_time, word_answer_1, "
					+ "word_answer_2, clock_image, clock_score, word_score, " + "total_score, evaluation) "
					+ "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

			pstmt = con.prepareStatement(sql1);
			pstmt.setInt(1, survey.getUserId());
			pstmt.setString(2, survey.getCorrectWords());
			pstmt.setString(3, survey.getClockTime());
			pstmt.setString(4, survey.getWordAnswer1());
			pstmt.setString(5, survey.getWordAnswer2());
			pstmt.setString(6, survey.getClockImage());
			pstmt.setInt(7, survey.getClockScore());
			pstmt.setInt(8, survey.getWordScore());
			pstmt.setInt(9, survey.getTotalScore());
			pstmt.setString(10, survey.getEvaluation());

			int result = pstmt.executeUpdate();
			pstmt.close();

			System.out.println("✓ survey 테이블 저장 완료");

			// 2. users 테이블 요약 정보 업데이트
			String sql2 = "UPDATE users SET " + "survey_type = ?, " + "survey_score = ?, " + "survey_date = CURDATE() "
					+ "WHERE user_id = ?";

			pstmt = con.prepareStatement(sql2);
			pstmt.setString(1, "인지검사");
			pstmt.setInt(2, survey.getTotalScore());
			pstmt.setInt(3, survey.getUserId());

			pstmt.executeUpdate();
			System.out.println("✓ users 테이블 요약 업데이트 완료");

			return result > 0;

		} catch (Exception e) {
			System.err.println("✗ saveSurveyResult 오류:");
			e.printStackTrace();
			return false;
		} finally {
			pstmt = null;
			rs = null;
		}
	}

	/**
	 * 특정 사용자의 설문 이력 조회
	 */
	public List<SurveyResultDTO> getSurveyHistory(int userId) {
		List<SurveyResultDTO> list = new ArrayList<>();

		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT * FROM survey " + "WHERE user_id = ? " + "ORDER BY created_at DESC";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			while (rs.next()) {
				SurveyResultDTO dto = new SurveyResultDTO();
				dto.setSurveyId(rs.getInt("survey_id"));
				dto.setUserId(rs.getInt("user_id"));
				dto.setCorrectWords(rs.getString("correct_words"));
				dto.setClockTime(rs.getString("clock_time"));
				dto.setWordAnswer1(rs.getString("word_answer_1"));
				dto.setWordAnswer2(rs.getString("word_answer_2"));
				dto.setClockImage(rs.getString("clock_image"));
				dto.setClockScore(rs.getInt("clock_score"));
				dto.setWordScore(rs.getInt("word_score"));
				dto.setTotalScore(rs.getInt("total_score"));
				dto.setEvaluation(rs.getString("evaluation"));
				dto.setCreatedAt(rs.getTimestamp("created_at"));

				list.add(dto);
			}

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return list;
	}

	/**
	 * 최신 설문 결과 조회
	 */
	public SurveyResultDTO getLatestSurvey(int userId) {
		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT * FROM survey " + "WHERE user_id = ? " + "ORDER BY created_at DESC " + "LIMIT 1";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				SurveyResultDTO dto = new SurveyResultDTO();
				dto.setSurveyId(rs.getInt("survey_id"));
				dto.setUserId(rs.getInt("user_id"));
				dto.setCorrectWords(rs.getString("correct_words"));
				dto.setClockTime(rs.getString("clock_time"));
				dto.setWordAnswer1(rs.getString("word_answer_1"));
				dto.setWordAnswer2(rs.getString("word_answer_2"));
				dto.setClockImage(rs.getString("clock_image"));
				dto.setClockScore(rs.getInt("clock_score"));
				dto.setWordScore(rs.getInt("word_score"));
				dto.setTotalScore(rs.getInt("total_score"));
				dto.setEvaluation(rs.getString("evaluation"));
				dto.setCreatedAt(rs.getTimestamp("created_at"));

				return dto;
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return null;
	}

	/**
	 * 설문 점수 통계 (평균, 최고, 최저)
	 */
	public Map<String, Object> getSurveyStats(int userId) {
		Map<String, Object> stats = new HashMap<>();

		try (Connection con = ConDB.getCon();) {
			String sql = "SELECT " + "COUNT(*) as count, " + "AVG(total_score) as avg_score, "
					+ "MAX(total_score) as max_score, " + "MIN(total_score) as min_score "
					+ "FROM survey WHERE user_id = ?";

			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);
			rs = pstmt.executeQuery();

			if (rs.next()) {
				stats.put("count", rs.getInt("count"));
				stats.put("avgScore", rs.getDouble("avg_score"));
				stats.put("maxScore", rs.getInt("max_score"));
				stats.put("minScore", rs.getInt("min_score"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return stats;
	}

	// -----------------------8. 회원 정보 수정-----------------------
	public boolean updateUser(UserDTO dto) {
		boolean success = false;

		try (Connection con = ConDB.getCon();) {
			String sql = "UPDATE users SET name = ?, phone = ?, email = ? WHERE user_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setString(1, dto.getName());
			pstmt.setString(2, dto.getPhone());
			pstmt.setString(3, dto.getEmail());
			pstmt.setInt(4, dto.getUserId());

			int result = pstmt.executeUpdate();
			success = (result > 0);

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}

		return success;
	}

	// -----------------------9. 회원 탈퇴-----------------------
	public boolean deleteUser(int userId) {
		boolean success = false;

		try (Connection con = ConDB.getCon();) {
			String sql = "DELETE FROM users WHERE user_id = ?";
			pstmt = con.prepareStatement(sql);
			pstmt.setInt(1, userId);

			int result = pstmt.executeUpdate();
			success = (result > 0);

			con.close();
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			pstmt = null;
			rs = null;
		}
		return success;
	}
}


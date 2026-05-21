package login;

import java.sql.Date;
import java.security.MessageDigest;
import java.nio.charset.StandardCharsets;

public class UserDTO {

	// users 테이블 컬럼
	private int userId;
	private String loginId;
	private String password;
	private String role; // 환자/보호자
	private String name;
	private String phone;
	private String email;
	private Integer linkedUserId; // 보호자가 연결한 환자 ID
	private String surveyType;
	private Integer surveyScore;
	private Date surveyDate;
	private String fcmToken;
	private String createdAt;

	// 회원가입 시 추가 필드
	private String birthdate;
	private String gender;

	/**
	 * loginId와 password를 조합하여 고유한 숫자 userId 생성
	 */
	public int generateUserId() {
		try {
			// loginId + password를 조합
			String combined = this.loginId + this.password;

			/*SHA-256 해시 생성
			 * 4byte를 hash로 변환 ※ 음수 방지, 최소값 보장(8자리)
			 */ MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hash = digest.digest(combined.getBytes(StandardCharsets.UTF_8));

			int userId = 0;
			for (int i = 0; i < 4; i++) {
				userId = (userId << 8) | (hash[i] & 0xFF);
			}

			userId = Math.abs(userId);
			userId = userId % 1000000000; // 10억 미만
			if (userId < 10000000)
				userId += 10000000;

			this.userId = userId;
			return userId;

		} catch (Exception e) {
			e.printStackTrace();
			// 예외 시 기본값 지정
			return Math.abs((loginId + password).hashCode()) % 1000000000 + 10000000;
		}
	}

	// Getters and Setters
	public int getUserId() {
		return userId;
	}

	public void setUserId(int userId) {
		this.userId = userId;
	}

	public String getLoginId() {
		return loginId;
	}

	public void setLoginId(String loginId) {
		this.loginId = loginId;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getRole() {
		return role;
	}

	public void setRole(String role) {
		this.role = role;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public Integer getLinkedUserId() {
		return linkedUserId;
	}

	public void setLinkedUserId(Integer linkedUserId) {
		this.linkedUserId = linkedUserId;
	}

	public String getSurveyType() {
		return surveyType;
	}

	public void setSurveyType(String surveyType) {
		this.surveyType = surveyType;
	}

	public Integer getSurveyScore() {
		return surveyScore;
	}

	public void setSurveyScore(Integer surveyScore) {
		this.surveyScore = surveyScore;
	}

	public Date getSurveyDate() {
		return surveyDate;
	}

	public void setSurveyDate(Date surveyDate) {
		this.surveyDate = surveyDate;
	}

	public String getFcmToken() {
		return fcmToken;
	}

	public void setFcmToken(String fcmToken) {
		this.fcmToken = fcmToken;
	}

	public String getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(String createdAt) {
		this.createdAt = createdAt;
	}

	public String getBirthdate() {
		return birthdate;
	}

	public void setBirthdate(String birthdate) {
		this.birthdate = birthdate;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}
}


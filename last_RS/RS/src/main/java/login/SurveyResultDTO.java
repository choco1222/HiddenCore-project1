package login;

import java.sql.Timestamp;

public class SurveyResultDTO {
    // Primary Key
    private int surveyId;
    private int userId;
    
    // Question
    private String correctWords;
    private String clockTime;
    
    // Answer
    private String wordAnswer1;     // Q2
    private String wordAnswer2;     // Q4
    private String clockImage;      // Base64
    
    // Score
    private int clockScore;         // 0-2
    private int wordScore;          // 0-3
    private int totalScore;         // 0-5
    private String evaluation;      // 정상/인지 장애 위험/정밀한 평가 필요
    
    // 메타 정보
    private String surveyType;      // 유형 추가 가능
    private Timestamp createdAt;
    
    // Constructors
    public SurveyResultDTO() {}
    
    public SurveyResultDTO(int userId, String correctWords, String clockTime,
                           String wordAnswer1, String wordAnswer2, String clockImage,
                           int clockScore, int wordScore, int totalScore, String evaluation) {
        this.userId = userId;
        this.correctWords = correctWords;
        this.clockTime = clockTime;
        this.wordAnswer1 = wordAnswer1;
        this.wordAnswer2 = wordAnswer2;
        this.clockImage = clockImage;
        this.clockScore = clockScore;
        this.wordScore = wordScore;
        this.totalScore = totalScore;
        this.evaluation = evaluation;
        this.surveyType = "인지검사";
    }
    
    // Getters and Setters
    public int getSurveyId() {
        return surveyId;
    }
    
    public void setSurveyId(int surveyId) {
        this.surveyId = surveyId;
    }
    
    public int getUserId() {
        return userId;
    }
    
    public void setUserId(int userId) {
        this.userId = userId;
    }
    
    public String getCorrectWords() {
        return correctWords;
    }
    
    public void setCorrectWords(String correctWords) {
        this.correctWords = correctWords;
    }
    
    public String getClockTime() {
        return clockTime;
    }
    
    public void setClockTime(String clockTime) {
        this.clockTime = clockTime;
    }
    
    public String getWordAnswer1() {
        return wordAnswer1;
    }
    
    public void setWordAnswer1(String wordAnswer1) {
        this.wordAnswer1 = wordAnswer1;
    }
    
    public String getWordAnswer2() {
        return wordAnswer2;
    }
    
    public void setWordAnswer2(String wordAnswer2) {
        this.wordAnswer2 = wordAnswer2;
    }
    
    public String getClockImage() {
        return clockImage;
    }
    
    public void setClockImage(String clockImage) {
        this.clockImage = clockImage;
    }
    
    public int getClockScore() {
        return clockScore;
    }
    
    public void setClockScore(int clockScore) {
        this.clockScore = clockScore;
    }
    
    public int getWordScore() {
        return wordScore;
    }
    
    public void setWordScore(int wordScore) {
        this.wordScore = wordScore;
    }
    
    public int getTotalScore() {
        return totalScore;
    }
    
    public void setTotalScore(int totalScore) {
        this.totalScore = totalScore;
    }
    
    public String getEvaluation() {
        return evaluation;
    }
    
    public void setEvaluation(String evaluation) {
        this.evaluation = evaluation;
    }
    
    public String getSurveyType() {
        return surveyType;
    }
    
    public void setSurveyType(String surveyType) {
        this.surveyType = surveyType;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "SurveyResultDTO{" +
                "surveyId=" + surveyId +
                ", userId=" + userId +
                ", correctWords='" + correctWords + '\'' +
                ", clockTime='" + clockTime + '\'' +
                ", totalScore=" + totalScore +
                ", evaluation='" + evaluation + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}

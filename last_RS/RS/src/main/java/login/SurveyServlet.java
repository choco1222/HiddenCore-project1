package login;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * 설문 결과 저장 서블릿
 * 
 * OpenCV 기반 시계 채점:
 * - ClockDrawingScorer.scoreClockDrawing() 사용
 * - Hough Transform으로 정확한 채점
 */
@WebServlet("/login/saveSurvey")
public class SurveyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");
        
        if (userId == null) {
            response.getWriter().write("{\"success\": false, \"message\": \"로그인이 필요합니다.\"}");
            return;
        }
        
        try {
            // 클라이언트에서 전송된 데이터
            String correctWords = request.getParameter("correctWords"); // 정답 단어
            String clockTime = request.getParameter("clockTime"); // 시계 시간
            String word1 = request.getParameter("word1"); // Q2: 선택한 단어들 (첫 번째)
            String clockImage = request.getParameter("clockImage"); // Q3: 시계 그림 Base64
            String word2 = request.getParameter("word2"); // Q4: 회상한 단어들
            
            System.out.println("=== 설문 채점 시작 ===");
            System.out.println("userId: " + userId);
            System.out.println("정답 단어: " + correctWords);
            System.out.println("시계 시간: " + clockTime);
            
            // 시계 그림 채점 (OpenCV 사용 + 방향 검증)
            int clockScore = 0;
            if (clockImage != null && !clockImage.isEmpty()) {
                System.out.println("시계 이미지 크기: " + clockImage.length() + " bytes");
                clockScore = ClockDrawingScorer.scoreClockDrawing(clockImage, clockTime);
                System.out.println("시계 점수: " + clockScore + "/2");
            } else {
                System.out.println("시계 이미지 없음");
            }
            
            SurveyResultDTO surveyResult = new SurveyResultDTO(userId, correctWords,
            		clockTime, word1, word2, clockImage, clockScore, 0, 0, "");
            // 총점 계산 (5점 만점)
            surveyResult = calculateTotalScore(correctWords, word2, clockScore, surveyResult);
            
            System.out.println("총점: " + surveyResult.getTotalScore() + "/5 (" + surveyResult.getEvaluation() + ")");
            System.out.println("=== 채점 완료 ===\n");
            
            // DB에 저장
            UserDAO userDAO = new UserDAO();
            session.setAttribute("userId", userId);
            
            // users 테이블에 요약 정보 저장
            boolean saved = userDAO.saveSurveyResult(surveyResult);
            
            if (saved) {
                // 세션에 점수 저장
                session.setAttribute("surveyScore", surveyResult.getTotalScore());
                session.setAttribute("clockScore", surveyResult.getClockScore());
                session.setAttribute("surveyMessage", surveyResult.getEvaluation());
                
                System.out.println("설문 결과가 저장되었습니다.");
                
                response.getWriter().write("{\"success\": true, \"score\": " + surveyResult.getTotalScore() + 
                    ", \"maxScore\": 5, \"clockScore\": " + surveyResult.getClockScore() + 
                    ", \"message\": \"" + surveyResult.getEvaluation() + "\"}");
            } else {
                response.getWriter().write("{\"success\": false, \"message\": \"저장 실패\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"success\": false, \"message\": \"오류 발생: " + 
                e.getMessage() + "\"}");
        }
    }
    
    /**
     * 총점 계산 (5점 만점)
     * 
     * 1. Q2 단어 선택: 0점 (학습용)
     * 2. Q3 시계 그리기: 0-2점
     * 3. Q4 단어 회상: 각 1점 (최대 3점)
     */
    private SurveyResultDTO calculateTotalScore(String correctWords, String word2, int clockScore, SurveyResultDTO surveyResult) {
        int score = 0;
        
        // 1. Q2 단어 선택 - 점수 없음 (학습 단계)
        
        // 2. 시계 그리기 (OpenCV로 채점된 점수 사용)
        score += clockScore;
        System.out.println("- 시계 그리기: " + clockScore + "점");
        
        // 3. Q4 단어 회상 (각 1점, 최대 3점)
        if (word2 != null && !word2.isEmpty() && correctWords != null && !correctWords.isEmpty()) {
            String[] correctWordsArr = correctWords.split(",");
            String[] recalledWords = word2.split(",");
            int correct = 0;
            
            for (String recalled : recalledWords) {
                recalled = recalled.trim();
                for (String correctWord : correctWordsArr) {
                    correctWord = correctWord.trim();
                    if (recalled.equals(correctWord)) {
                        correct++;
                        break;
                    }
                }
            }
            surveyResult.setWordScore(correct);
            
            score += Math.min(correct, 3);
            surveyResult.setTotalScore(score);         
            System.out.println("- 단어 회상: " + correct + "개 정답 (" + Math.min(correct, 3) + "점)");
        }
        surveyResult.setEvaluation(getScoreMessage(Math.min(score, 5)));         
        
        return surveyResult;
    }
    
    /**
     * 점수에 따른 평가 메시지
     */
    private String getScoreMessage(int score) {
        if (score == 5) {
            return "정상";
        } else if (score == 4) {
            return "인지 장애 위험";
        } else {
            return "정밀한 평가 필요";
        }
    }
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doPost(request, response);
    }
}
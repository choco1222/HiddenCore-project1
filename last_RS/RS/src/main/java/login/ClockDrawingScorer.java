package login;

import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.io.ByteArrayInputStream;
import java.util.Base64;

import javax.imageio.ImageIO;

import org.opencv.core.*;
import org.opencv.imgproc.Imgproc;

/**
 * OpenCV 기반 시계 그림 채점 (시침/분침 방향 검증 포함)
 * 
 * 채점 기준:
 * - 2점: 원 + 시침/분침 + 대략적인 방향 일치
 * - 1점: 원 + 시침/분침 (방향 불일치)
 * - 0점: 시계를 그리지 못함
 */
public class ClockDrawingScorer {
    
    static {
        try {
            System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
            System.out.println("✓ OpenCV 로드 성공: " + Core.VERSION);
        } catch (UnsatisfiedLinkError e) {
            System.err.println("✗ OpenCV 로드 실패. 기본 방식으로 작동합니다.");
        }
    }
    
    /**
     * Base64 이미지를 분석하여 점수 반환
     * @param base64Image 시계 그림 Base64
     * @param clockTime 시계 시간 (예: "11시 10분")
     * @return 0점, 1점, 또는 2점
     */
    public static int scoreClockDrawing(String base64Image, String clockTime) {
        try {
            Core.VERSION.toString();
            return scoreWithOpenCV(base64Image, clockTime);
        } catch (Throwable e) {
            return scoreWithBasicMethod(base64Image, clockTime);
        }
    }
    
    /**
     * OpenCV 기반 채점 (Hough Transform + Direction)
     */
    private static int scoreWithOpenCV(String base64Image, String clockTime) {
        try {
            Mat src = decodeBase64ToMat(base64Image);
            if (src.empty()) return 0;
            
            int centerX = src.cols() / 2;
            int centerY = src.rows() / 2;
            
            // 그레이스케일 변환
            Mat gray = new Mat();
            if (src.channels() == 3 || src.channels() == 4) {
                Imgproc.cvtColor(src, gray, Imgproc.COLOR_BGR2GRAY);
            } else {
                gray = src.clone();
            }
            
            // 노이즈 제거
            Mat blurred = new Mat();
            Imgproc.GaussianBlur(gray, blurred, new Size(5, 5), 0);
            
            // 원 탐지
            Mat circles = new Mat();
            Imgproc.HoughCircles(
                blurred, circles, Imgproc.HOUGH_GRADIENT,
                1, 50, 100, 30, 30, src.cols() / 2
            );
            boolean hasCircle = circles.cols() > 0;
            
            // 에지 검출
            Mat edges = new Mat();
            Imgproc.Canny(blurred, edges, 50, 150);
            
            // 직선 탐지
            Mat lines = new Mat();
            Imgproc.HoughLinesP(
                edges, lines, 1, Math.PI / 180, 50, 50, 10
            );
            
            // 시침/분침 필터링
            int handsCount = countHandsFromCenter(lines, centerX, centerY);
            boolean hasHands = handsCount >= 2;
            
            // 기본 점수
            if (!hasCircle || !hasHands) {
                if (hasCircle || hasHands) return 1;
                return 0;
            }
            
            // 시침/분침 방향 검증
            if (clockTime != null && !clockTime.isEmpty()) {
                boolean directionsCorrect = verifyHandDirections(lines, centerX, centerY, clockTime);
                System.out.println("방향 검증: " + (directionsCorrect ? "대략 일치" : "불일치"));
                
                if (directionsCorrect) {
                    return 2;  // 원 + 바늘 + 방향 일치
                } else {
                    return 1;  // 원 + 바늘만 (방향 불일치)
                }
            }
            
            return 2;  // 시간 정보 없으면 2점
            
        } catch (Exception e) {
            e.printStackTrace();
            return scoreWithBasicMethod(base64Image, clockTime);
        }
    }
    
    /**
     * 중심 근처를 지나는 선 개수
     */
    private static int countHandsFromCenter(Mat lines, int centerX, int centerY) {
        int count = 0;
        int threshold = 40;
        
        for (int i = 0; i < lines.rows(); i++) {
            double[] l = lines.get(i, 0);
            int x1 = (int) l[0], y1 = (int) l[1];
            int x2 = (int) l[2], y2 = (int) l[3];
            
            double dist1 = Math.hypot(x1 - centerX, y1 - centerY);
            double dist2 = Math.hypot(x2 - centerX, y2 - centerY);
            
            if (dist1 < threshold || dist2 < threshold) count++;
        }
        
        return count;
    }
    
    /**
     * 시침/분침 방향 검증 (대략적으로 맞는지)
     */
    private static boolean verifyHandDirections(Mat lines, int centerX, int centerY, String clockTime) {
        try {
            // 시간 파싱
            int[] time = parseClockTime(clockTime);
            if (time == null) return false;
            
            int hours = time[0];
            int minutes = time[1];
            
            // 예상 각도 계산 (12시 방향을 0도, 시계방향)
            double expectedHourAngle = ((hours % 12) * 30 + minutes * 0.5) % 360;
            double expectedMinuteAngle = (minutes * 6) % 360;
            
            System.out.println("예상 각도 - 시침: " + expectedHourAngle + "°, 분침: " + expectedMinuteAngle + "°");
            
            // 중심에서 나가는 선들의 각도 추출
            double[] angles = extractHandAngles(lines, centerX, centerY);
            
            if (angles.length < 2) {
                System.out.println("충분한 선이 없음");
                return false;
            }
            
            // 예상 각도와 비교 (오차 범위 ±45도)
            boolean hourMatched = false;
            boolean minuteMatched = false;
            
            for (double angle : angles) {
                double hourDiff = angleDifference(angle, expectedHourAngle);
                double minuteDiff = angleDifference(angle, expectedMinuteAngle);
                
                if (hourDiff <= 45) hourMatched = true;
                if (minuteDiff <= 45) minuteMatched = true;
            }
            
            System.out.println("시침 일치: " + hourMatched + ", 분침 일치: " + minuteMatched);
            
            return hourMatched && minuteMatched;
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * 시계 시간 파싱 ("11시 10분" → [11, 10])
     */
    private static int[] parseClockTime(String clockTime) {
        try {
            // "11시 10분" 또는 "11시" 형태
            String cleaned = clockTime.replace("시", ":").replace("분", "").trim();
            String[] parts = cleaned.split(":");
            
            int hours = Integer.parseInt(parts[0].trim());
            int minutes = parts.length > 1 ? Integer.parseInt(parts[1].trim()) : 0;
            
            return new int[]{hours, minutes};
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 중심에서 나가는 선들의 각도 추출
     */
    private static double[] extractHandAngles(Mat lines, int centerX, int centerY) {
        java.util.ArrayList<Double> angleList = new java.util.ArrayList<>();
        int threshold = 40;
        
        for (int i = 0; i < lines.rows(); i++) {
            double[] l = lines.get(i, 0);
            int x1 = (int) l[0], y1 = (int) l[1];
            int x2 = (int) l[2], y2 = (int) l[3];
            
            double dist1 = Math.hypot(x1 - centerX, y1 - centerY);
            double dist2 = Math.hypot(x2 - centerX, y2 - centerY);
            
            // 중심 근처를 지나는 선
            if (dist1 < threshold || dist2 < threshold) {
                // 중심에서 먼 쪽 끝점 선택
                int endX = dist1 > dist2 ? x1 : x2;
                int endY = dist1 > dist2 ? y1 : y2;
                
                // 각도 계산 (12시 방향을 0도, 시계방향)
                double angle = Math.toDegrees(Math.atan2(endX - centerX, centerY - endY));
                if (angle < 0) angle += 360;
                
                angleList.add(angle);
            }
        }
        
        return angleList.stream().mapToDouble(Double::doubleValue).toArray();
    }
    
    /**
     * 두 각도의 차이 계산 (0~180도)
     */
    private static double angleDifference(double angle1, double angle2) {
        double diff = Math.abs(angle1 - angle2);
        if (diff > 180) diff = 360 - diff;
        return diff;
    }
    
    /**
     * Base64 → Mat 변환
     */
    private static Mat decodeBase64ToMat(String base64Image) {
        try {
            String data = base64Image.contains(",") ? base64Image.split(",")[1] : base64Image;
            byte[] bytes = Base64.getDecoder().decode(data);
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
            
            Mat mat = new Mat(img.getHeight(), img.getWidth(), CvType.CV_8UC3);
            byte[] imgData = ((DataBufferByte) img.getRaster().getDataBuffer()).getData();
            mat.put(0, 0, imgData);
            
            return mat;
        } catch (Exception e) {
            e.printStackTrace();
            return new Mat();
        }
    }
    
    /**
     * 기본 픽셀 분석 방식 (OpenCV 없을 때)
     */
    private static int scoreWithBasicMethod(String base64Image, String clockTime) {
        try {
            String data = base64Image.contains(",") ? base64Image.split(",")[1] : base64Image;
            byte[] bytes = Base64.getDecoder().decode(data);
            BufferedImage img = ImageIO.read(new ByteArrayInputStream(bytes));
            
            if (img == null) return 0;
            
            int cx = img.getWidth() / 2, cy = img.getHeight() / 2;
            
            double complexity = calcComplexity(img);
            if (complexity < 2.0) return 0;
            
            boolean hasCircle = detectCircle(img, cx, cy);
            boolean hasLines = detectLines(img, cx, cy);
            
            if (hasCircle && hasLines) return 2;
            if (hasCircle || hasLines) return 1;
            return 0;
            
        } catch (Exception e) {
            return 0;
        }
    }
    
    private static boolean detectCircle(BufferedImage img, int cx, int cy) {
        int r = Math.min(img.getWidth(), img.getHeight()) / 5;
        int count = 0;
        
        for (int a = 0; a < 360; a += 10) {
            double rad = Math.toRadians(a);
            int x = (int) (cx + r * Math.cos(rad));
            int y = (int) (cy + r * Math.sin(rad));
            
            if (x >= 0 && x < img.getWidth() && y >= 0 && y < img.getHeight()) {
                if (isDrawn(img, x, y)) count++;
            }
        }
        
        return count >= 18;
    }
    
    private static boolean detectLines(BufferedImage img, int cx, int cy) {
        int maxR = Math.min(img.getWidth(), img.getHeight()) / 3;
        int count = 0;
        
        for (int a = 0; a < 360; a += 30) {
            double rad = Math.toRadians(a);
            
            for (int r = 10; r < maxR; r += 5) {
                int x = (int) (cx + r * Math.cos(rad));
                int y = (int) (cy + r * Math.sin(rad));
                
                if (x >= 0 && x < img.getWidth() && y >= 0 && y < img.getHeight()) {
                    if (isDrawn(img, x, y)) {
                        count++;
                        break;
                    }
                }
            }
        }
        
        return count >= 2;
    }
    
    private static double calcComplexity(BufferedImage img) {
        int drawn = 0;
        for (int y = 0; y < img.getHeight(); y++) {
            for (int x = 0; x < img.getWidth(); x++) {
                if (isDrawn(img, x, y)) drawn++;
            }
        }
        return (drawn * 100.0) / (img.getWidth() * img.getHeight());
    }
    
    private static boolean isDrawn(BufferedImage img, int x, int y) {
        int rgb = img.getRGB(x, y);
        int a = (rgb >> 24) & 0xFF;
        int r = (rgb >> 16) & 0xFF;
        return a > 0 && r < 250;
    }
}
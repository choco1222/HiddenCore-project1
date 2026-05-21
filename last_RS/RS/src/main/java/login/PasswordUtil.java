package login;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * 비밀번호 암호화 유틸리티
 * BCrypt 라이브러리 없이 SHA-256 + Salt 사용
 */
public class PasswordUtil {
    
    private static final int SALT_LENGTH = 16;
    private static final int ITERATIONS = 10000;
    
    /**
     * 비밀번호를 해시화 (Salt 포함)
     * @param password 평문 비밀번호
     * @return "salt$hashedPassword" 형식의 문자열
     */
    public static String hashPassword(String password) {
        try {
            // 1. Salt 생성
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[SALT_LENGTH];
            random.nextBytes(salt);
            
            // 2. Password + Salt를 해시화
            String hashedPassword = hashWithSalt(password, salt);
            
            // 3. Salt와 Hash를 결합하여 반환
            String saltString = Base64.getEncoder().encodeToString(salt);
            return saltString + "$" + hashedPassword;
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 비밀번호 검증
     * @param inputPassword 입력된 평문 비밀번호
     * @param storedPassword DB에 저장된 "salt$hash" 형식 문자열
     * @return 일치 여부
     */
    public static boolean verifyPassword(String inputPassword, String storedPassword) {
        try {
            // 1. Salt와 Hash 분리
            String[] parts = storedPassword.split("\\$");
            if (parts.length != 2) {
                return false;
            }
            
            String saltString = parts[0];
            String storedHash = parts[1];
            
            // 2. Salt 디코딩
            byte[] salt = Base64.getDecoder().decode(saltString);
            
            // 3. 입력된 비밀번호를 같은 Salt로 해시화
            String inputHash = hashWithSalt(inputPassword, salt);
            
            // 4. 비교
            return storedHash.equals(inputHash);
            
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Salt를 사용하여 비밀번호 해시화
     */
    private static String hashWithSalt(String password, byte[] salt) {
        try {
            // SHA-256 해시 생성
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            
            // Salt 추가
            md.update(salt);
            
            // 여러 번 반복하여 보안 강화 (PBKDF2와 유사)
            byte[] hash = password.getBytes("UTF-8");
            for (int i = 0; i < ITERATIONS; i++) {
                md.reset();
                md.update(salt);
                hash = md.digest(hash);
            }
            
            // Base64 인코딩하여 문자열로 반환
            return Base64.getEncoder().encodeToString(hash);
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * 테스트용 메인 메서드
     */
    public static void main(String[] args) {
        String password = "test1234!";
        
        // 암호화
        String hashed = hashPassword(password);
        System.out.println("원본: " + password);
        System.out.println("암호화: " + hashed);
        System.out.println("길이: " + hashed.length());
        
        // 검증
        boolean isValid = verifyPassword(password, hashed);
        System.out.println("검증 성공: " + isValid);
        
        boolean isInvalid = verifyPassword("wrong_password", hashed);
        System.out.println("검증 실패: " + !isInvalid);
    }
}

package login;

/**
 * 비밀번호 암호화 테스트
 * 실행 방법: java KNY.PasswordUtilTest
 */
public class PasswordUtilTest {
    
    public static void main(String[] args) {
        System.out.println("=== 비밀번호 암호화 테스트 ===\n");
        
        // 테스트 1: 기본 암호화
        System.out.println("1. 기본 암호화 테스트");
        testBasicEncryption();
        
        // 테스트 2: 동일 비밀번호, 다른 해시
        System.out.println("\n2. Salt 테스트 (동일 비밀번호 → 다른 해시)");
        testSalt();
        
        // 테스트 3: 로그인 시뮬레이션
        System.out.println("\n3. 로그인 시뮬레이션");
        testLogin();
        
        // 테스트 4: 테스트 계정용 해시 생성
        System.out.println("\n4. 테스트 계정용 해시 생성");
        generateTestHashes();
        
        System.out.println("\n=== 테스트 완료 ===");
    }
    
    private static void testBasicEncryption() {
        String password = "test1234!";
        String hashed = PasswordUtil.hashPassword(password);
        
        System.out.println("원본 비밀번호: " + password);
        System.out.println("암호화된 비밀번호: " + hashed);
        System.out.println("길이: " + hashed.length() + "자");
    }
    
    private static void testSalt() {
        String password = "samePassword123";
        
        String hash1 = PasswordUtil.hashPassword(password);
        String hash2 = PasswordUtil.hashPassword(password);
        
        System.out.println("동일 비밀번호: " + password);
        System.out.println("해시1: " + hash1);
        System.out.println("해시2: " + hash2);
        System.out.println("다른가? " + (!hash1.equals(hash2) ? "✓ 다름 (Salt 동작)" : "✗ 같음 (문제)"));
    }
    
    private static void testLogin() {
        String originalPassword = "mySecurePass!";
        
        // 회원가입 시뮬레이션
        String storedHash = PasswordUtil.hashPassword(originalPassword);
        System.out.println("DB 저장: " + storedHash);
        
        // 로그인 시뮬레이션 1: 올바른 비밀번호
        boolean correctLogin = PasswordUtil.verifyPassword(originalPassword, storedHash);
        System.out.println("\n올바른 비밀번호 입력: " + (correctLogin ? "✓ 로그인 성공" : "✗ 실패"));
        
        // 로그인 시뮬레이션 2: 잘못된 비밀번호
        boolean wrongLogin = PasswordUtil.verifyPassword("wrongPassword", storedHash);
        System.out.println("잘못된 비밀번호 입력: " + (!wrongLogin ? "✓ 로그인 거부" : "✗ 통과됨 (문제)"));
    }
    
    private static void generateTestHashes() {
        System.out.println("schema.sql에 넣을 암호화된 비밀번호:");
        System.out.println();
        
        String[] testPasswords = {
            "test1234!",
            "patient123!",
            "caregiver456!"
        };
        
        for (String password : testPasswords) {
            String hashed = PasswordUtil.hashPassword(password);
            System.out.println("비밀번호: " + password);
            System.out.println("INSERT 값: '" + hashed + "'");
            System.out.println();
        }
        
        System.out.println("사용 예시:");
        System.out.println("INSERT INTO users (..., password, ...) VALUES");
        System.out.println("(..., '" + PasswordUtil.hashPassword("test1234!") + "', ...);");
    }
}

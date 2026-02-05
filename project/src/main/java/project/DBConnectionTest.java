package project;

import java.time.LocalDateTime;
import project.GameDAO;
import project.GameDTO;

public class DBConnectionTest {
    public static void main(String[] args) {

        GameDTO dto = new GameDTO();
        dto.setGame_id("TEST_GAME_001");
        dto.setUser_id(1);                 // 테스트 유저 ID
        dto.setGame_type("word");
        dto.setGame_level("easy");
        dto.setPlay_time("120");
        dto.setScore(80);
        dto.setPlayedAt(LocalDateTime.now());

        GameDAO dao = new GameDAO();
        boolean result = dao.insertGameLog(dto);

        if (result) {
            System.out.println("✅ DB 연결 및 INSERT 성공");
        } else {
            System.out.println("❌ DB 연결 실패");
        }
    }
}
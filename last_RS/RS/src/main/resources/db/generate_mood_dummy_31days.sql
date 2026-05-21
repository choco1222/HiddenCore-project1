-- ============================================================
-- 기분 더미데이터: 2026-01-14 ~ 2026-02-13 (31일)
-- activelog 테이블에 Mood_* 이벤트 삽입
-- ============================================================

USE memory_spring;

-- [선택] 프로시저 방식
DROP PROCEDURE IF EXISTS generate_mood_dummy_31days;

DELIMITER $$

CREATE PROCEDURE generate_mood_dummy_31days(IN target_user_id INT)
BEGIN
    DECLARE d INT DEFAULT 0;
    DECLARE target_date DATE;
    DECLARE log_time DATETIME;
    DECLARE mood_type VARCHAR(30);

    -- 31일치 (2026-02-13부터 역산 → 2026-01-14)
    day_loop: WHILE d < 31 DO
        -- 2026-02-13에서 d일 전
        SET target_date = DATE_SUB('2026-02-13', INTERVAL d DAY);
        
        -- 랜덤 기분 (6종류)
        SET mood_type = ELT(FLOOR(1 + RAND() * 6),
            'Mood_happy', 'Mood_neutral', 'Mood_sad', 
            'Mood_angry', 'Mood_tired', 'Mood_anxious'
        );
        
        -- 랜덤 시간 (08:00 ~ 22:00 사이)
        SET log_time = TIMESTAMP(target_date,
            SEC_TO_TIME(3600 * (8 + FLOOR(RAND() * 14)))
        );
        
        INSERT INTO activelog (
            log_id, user_id, routine_id,
            event_type, event_count, is_duplicate, event_time
        ) VALUES (
            UUID(), target_user_id, NULL,
            mood_type, 1, 0, log_time
        );
        
        SET d = d + 1;
    END WHILE day_loop;
    
    SELECT CONCAT('✅ ', d, '일치 기분 더미데이터 생성 완료 (user_id=', target_user_id, ')') AS result;

END$$

DELIMITER ;

-- ============================================================
-- 실행 예시:
-- 
-- 1. user_id = 682383016 (기본 더미 유저)
-- CALL generate_mood_dummy_31days(682383016);
-- 
-- 2. 특정 user_id (예: 123456789)
-- CALL generate_mood_dummy_31days(123456789);
-- 
-- 3. 결과 확인
-- SELECT DATE(event_time) AS date, event_type, event_time 
-- FROM activelog 
-- WHERE user_id = 682383016 AND event_type LIKE 'Mood_%'
-- ORDER BY event_time DESC
-- LIMIT 31;
-- ============================================================

-- 기본 실행 (user_id = 682383016)
CALL generate_mood_dummy_31days(682383016);

-- 생성된 데이터 확인
SELECT 
    DATE(event_time) AS 날짜,
    event_type AS 기분,
    TIME(event_time) AS 시간,
    COUNT(*) AS 건수
FROM activelog 
WHERE user_id = 682383016 
  AND event_type LIKE 'Mood_%'
  AND event_time >= '2026-01-14'
  AND event_time <= '2026-02-13 23:59:59'
GROUP BY DATE(event_time), event_type, TIME(event_time)
ORDER BY DATE(event_time) DESC;

-- ============================================================
-- 더미데이터만 수정: 30일치 activelog 생성 (기분은 하루 1회만)
-- 테이블/트리거는 변경하지 않음.
-- 기분 event_type: Mood_happy, Mood_neutral, Mood_sad, Mood_angry, Mood_tired, Mood_anxious
-- ============================================================
--
-- [방법 1] 에러 "PROCEDURE generate_dummy_logs already exists" 나면
--         아래 한 줄만 먼저 실행한 뒤, 그 다음에 CREATE PROCEDURE ~ END 블록 실행.
--
DROP PROCEDURE IF EXISTS generate_dummy_logs;

-- ============================================================
USE memory_spring;

DELIMITER $$

CREATE PROCEDURE generate_dummy_logs()
BEGIN
    DECLARE d INT DEFAULT 0;
    DECLARE base_date DATE;
    DECLARE log_time DATETIME;
    DECLARE uid INT DEFAULT 682383016;
    DECLARE event_name VARCHAR(30);
    DECLARE mood_type VARCHAR(20);

    -- 30일
    day_loop: WHILE d < 30 DO
        SET base_date = DATE_SUB(CURDATE(), INTERVAL d DAY);
        SET @day_type = FLOOR(1 + RAND() * 3);
        SET @i = 1;

        -- 식사/복약/양치/외출 등 11개 이벤트
        event_loop: WHILE @i <= 11 DO
            SET event_name = ELT(@i,
                'Meal_breakfast','Meal_lunch','Meal_dinner',
                'Med_morning','Med_lunch','Med_dinner',
                'Brush_morning','Brush_lunch','Brush_dinner',
                'Outing_start','Outing_return'
            );

            IF @day_type = 2 AND RAND() < 0.3 THEN
                SET @i = @i + 1;
                ITERATE event_loop;
            END IF;

            SET log_time = TIMESTAMP(base_date,
                SEC_TO_TIME(3600 * (6 + FLOOR(RAND()*14)))
            );

            INSERT INTO activelog (
                log_id, user_id, routine_id,
                event_type, event_count, is_duplicate, event_time
            ) VALUES (
                UUID(), uid, NULL,
                event_name, 1, 0, log_time
            );

            IF @day_type = 3 AND RAND() < 0.25 THEN
                INSERT INTO activelog (
                    log_id, user_id, routine_id,
                    event_type, event_count, is_duplicate, event_time
                ) VALUES (
                    UUID(), uid, NULL,
                    event_name, 2, 1,
                    DATE_ADD(log_time, INTERVAL 5 MINUTE)
                );
            END IF;

            SET @i = @i + 1;
        END WHILE event_loop;

        -- 기분: 하루에 한 번만 (Mood_happy, Mood_neutral, Mood_sad, Mood_angry, Mood_tired, Mood_anxious)
        SET mood_type = ELT(FLOOR(1 + RAND() * 6),
            'Mood_happy','Mood_neutral','Mood_sad','Mood_angry','Mood_tired','Mood_anxious'
        );
        SET log_time = TIMESTAMP(base_date,
            SEC_TO_TIME(3600 * (8 + FLOOR(RAND()*10)))
        );
        INSERT INTO activelog (
            log_id, user_id, routine_id,
            event_type, event_count, is_duplicate, event_time
        ) VALUES (
            UUID(), uid, NULL,
            mood_type, 1, 0, log_time
        );

        SET d = d + 1;
    END WHILE day_loop;

END$$
DELIMITER ;

-- 기존 activelog 비우고 30일치 생성
DELETE FROM activelog;
CALL generate_dummy_logs();

SELECT COUNT(*) AS activelog_count FROM activelog;
SELECT event_type, COUNT(*) AS cnt FROM activelog GROUP BY event_type ORDER BY event_type;

-- ---------------------------------------------------------------------------
-- [선택] 기분(Mood_*) 더미가 들어가려면 routine_id=NULL 이 허용되어야 합니다.
--        아래처럼 트리거를 수정한 뒤 다시 CALL generate_dummy_logs(); 실행하세요.
-- ---------------------------------------------------------------------------
/*
DROP TRIGGER IF EXISTS trg_activelog_routine_check;
DELIMITER $$
CREATE TRIGGER trg_activelog_routine_check
BEFORE INSERT ON activelog
FOR EACH ROW
BEGIN
    IF NEW.routine_id IS NULL THEN
        IF NOT (NEW.event_type = '외출복귀' OR NEW.event_type LIKE 'Brush_%' OR NEW.event_type LIKE 'Mood_%') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'routine_id는 외출복귀, Brush_%, Mood_% 일 때만 NULL 허용됩니다.';
        END IF;
    END IF;
END$$
DELIMITER ;
*/

-- ============================================================
-- 게임 더미 데이터: 30일치 game_log 생성 (activelog 더미와 동일 사용자 682383016)
-- game_type: WORD_GAME, CARD_GAME, COLOR_GAME / game_level: easy, medium, hard
-- ============================================================
--
-- [에러 "PROCEDURE generate_dummy_game_logs already exists" 나면]
-- DROP PROCEDURE IF EXISTS generate_dummy_game_logs; 먼저 실행 후 CREATE 실행.
--
DROP PROCEDURE IF EXISTS generate_dummy_game_logs;

-- ============================================================
USE memory_spring;

DELIMITER $$

CREATE PROCEDURE generate_dummy_game_logs()
BEGIN
    DECLARE d INT DEFAULT 0;
    DECLARE base_date DATE;
    DECLARE play_at DATETIME;
    DECLARE uid INT DEFAULT 682383016;
    DECLARE g_type VARCHAR(30);
    DECLARE g_level VARCHAR(10);
    DECLARE g_score INT;
    DECLARE g_play_time VARCHAR(10);
    DECLARE plays_per_day INT;
    DECLARE p INT;

    -- 30일
    day_loop: WHILE d < 30 DO
        SET base_date = DATE_SUB(CURDATE(), INTERVAL d DAY);
        SET plays_per_day = 2 + FLOOR(RAND() * 4);

        play_loop: WHILE plays_per_day > 0 DO
            SET g_type = ELT(FLOOR(1 + RAND() * 3), 'WORD_GAME', 'CARD_GAME', 'COLOR_GAME');
            SET g_level = ELT(FLOOR(1 + RAND() * 3), 'easy', 'medium', 'hard');
            SET g_score = 50 + FLOOR(RAND() * 51);
            SET g_play_time = CONCAT(LPAD(2 + FLOOR(RAND() * 8), 2, '0'), ':', LPAD(FLOOR(RAND() * 60), 2, '0'));
            SET play_at = TIMESTAMP(base_date, SEC_TO_TIME(3600 * (8 + FLOOR(RAND() * 12))));

            INSERT INTO game_log (game_id, user_id, game_type, game_level, play_time, score, played_at)
            VALUES (
                CONCAT('G', DATE_FORMAT(play_at, '%Y%m%d%H%i'), LPAD(FLOOR(RAND() * 10000), 4, '0')),
                uid,
                g_type,
                g_level,
                g_play_time,
                g_score,
                play_at
            );

            SET plays_per_day = plays_per_day - 1;
        END WHILE play_loop;

        SET d = d + 1;
    END WHILE day_loop;

END$$
DELIMITER ;

-- 기존 game_log 비우고 30일치 생성 (다른 사용자 데이터는 유지하려면 DELETE 시 WHERE user_id = 682383016 만 사용)
DELETE FROM game_log WHERE user_id = 682383016;
CALL generate_dummy_game_logs();

SELECT COUNT(*) AS game_log_count FROM game_log WHERE user_id = 682383016;
SELECT game_type, COUNT(*) AS cnt FROM game_log WHERE user_id = 682383016 GROUP BY game_type ORDER BY game_type;

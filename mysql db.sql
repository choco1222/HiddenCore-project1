-- USERS 테이블
CREATE TABLE users (
    user_id        INT primary key,
    login_id       VARCHAR(30) NOT NULL UNIQUE,
    password       VARCHAR(100) NOT NULL,
    role           VARCHAR(10) NOT NULL,
    name           VARCHAR(30) NOT NULL,
    phone          VARCHAR(20) NOT NULL,
    email          VARCHAR(50),
    linked_user_id INT,
    survey_type    VARCHAR(10),
    survey_score   INT,
    survey_date    DATE,
    fcm_token      VARCHAR(500),
    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    CHECK (role IN ('환자', '보호자'))
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

-- SURVEY 테이블
CREATE TABLE survey (
    survey_id       VARCHAR(20) PRIMARY KEY,
    user_id         INT,
    survey_type     VARCHAR(10),
    survey_question VARCHAR(200),
    extra_point     INT,
    CONSTRAINT fk_survey_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

-- ACTIVELOG 테이블
CREATE TABLE activelog (
    log_id      VARCHAR(50) PRIMARY KEY,
    user_id     INT,
    event_type  VARCHAR(20),
    event_count INT DEFAULT 1,
    event_time  DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

ALTER TABLE activelog
MODIFY log_id VARCHAR(50);


-- GAME_LOG 테이블
CREATE TABLE game_log (
    game_id    VARCHAR(20) PRIMARY KEY,
    user_id    INT,
    game_type  VARCHAR(30),
    game_level VARCHAR(10),
    score      INT,
    play_time  VARCHAR(10),
    played_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_game_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

-- DAILY_ANALYSIS 테이블
CREATE TABLE daily_analysis (
    analysis_id     VARCHAR(20) PRIMARY KEY,
    user_id         INT,
    analysis_date   DATE,
    daily_score     INT,
    active_score    INT,
    game_score_avg  INT,
    status_level    VARCHAR(10),
    is_save_bool    TINYINT(1) DEFAULT 0,
    CONSTRAINT fk_analysis_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT uq_daily UNIQUE (user_id, analysis_date)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

-- ROUTINE 테이블
CREATE TABLE routine (
    user_id      INT NOT NULL,
    routine_type VARCHAR(10) NOT NULL,
    routine_time VARCHAR(5)  NOT NULL,
    CONSTRAINT pk_routine PRIMARY KEY (user_id, routine_type, routine_time),
    CONSTRAINT ck_routine_type CHECK (routine_type IN ('밥','약','양치')),
    CONSTRAINT ck_routine_time CHECK (routine_time REGEXP '^[0-2][0-9]:[0-5][0-9]$'),
    CONSTRAINT fk_routine_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4;

-- routine_type 컬럼이 VARCHAR(10)이면 'Meal_breakfast'(14자) 등이 잘려서 저장 실패함.
-- "Data too long for column 'routine_type'" 해결용.
USE memory_spring;

ALTER TABLE routine
MODIFY COLUMN routine_type VARCHAR(30) NOT NULL;

-- CHECK 제약이 있어서 위가 실패하면, 아래처럼 제약 먼저 제거 후 실행할 수 있음:
-- ALTER TABLE routine DROP CONSTRAINT ck_routine_type;
-- ALTER TABLE routine MODIFY COLUMN routine_type VARCHAR(30) NOT NULL;

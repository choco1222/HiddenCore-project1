--------------------------------------------------------
--  파일이 생성됨 - 화요일-1월-27-2026   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table ROUTINE
--------------------------------------------------------

  CREATE TABLE "SOLDESK"."ROUTINE" 
   (	"USER_ID" VARCHAR2(20 BYTE), 
	"ROUTINE_TYPE" VARCHAR2(10 BYTE), 
	"ROUTINE_TIME" VARCHAR2(5 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Index PK_ROUTINE
--------------------------------------------------------

  CREATE UNIQUE INDEX "SOLDESK"."PK_ROUTINE" ON "SOLDESK"."ROUTINE" ("USER_ID", "ROUTINE_TYPE", "ROUTINE_TIME") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  Constraints for Table ROUTINE
--------------------------------------------------------

  ALTER TABLE "SOLDESK"."ROUTINE" MODIFY ("USER_ID" NOT NULL ENABLE);
  ALTER TABLE "SOLDESK"."ROUTINE" MODIFY ("ROUTINE_TYPE" NOT NULL ENABLE);
  ALTER TABLE "SOLDESK"."ROUTINE" MODIFY ("ROUTINE_TIME" NOT NULL ENABLE);
  ALTER TABLE "SOLDESK"."ROUTINE" ADD CONSTRAINT "CK_ROUTINE_TYPE" CHECK (routine_type IN ('밥','약','양치')) ENABLE;
  ALTER TABLE "SOLDESK"."ROUTINE" ADD CONSTRAINT "CK_ROUTINE_TIME" CHECK (REGEXP_LIKE(routine_time, '^[0-2][0-9]:[0-5][0-9]$')) ENABLE;
  ALTER TABLE "SOLDESK"."ROUTINE" ADD CONSTRAINT "PK_ROUTINE" PRIMARY KEY ("USER_ID", "ROUTINE_TYPE", "ROUTINE_TIME")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 
  TABLESPACE "USERS"  ENABLE;
--------------------------------------------------------
--  Ref Constraints for Table ROUTINE
--------------------------------------------------------

  ALTER TABLE "SOLDESK"."ROUTINE" ADD CONSTRAINT "FK_ROUTINE_USER" FOREIGN KEY ("USER_ID")
	  REFERENCES "SOLDESK"."USERS" ("USER_ID") ENABLE;

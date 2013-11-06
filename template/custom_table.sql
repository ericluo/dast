------------------------------------------------
-- 表的 DDL 语句 "T_DIY_YQXX"
------------------------------------------------
 

CREATE TABLE "T_DIY_YQXX"  (
		  "KH" VARCHAR(60) , 
		  "XYKZH" VARCHAR(60) , 
		  "YQRQ" CHAR(8) )   
		 IN "EASTSS1" ; 

 




-- 表上的索引的 DDL 语句 "T_GX_YGB"

CREATE INDEX "T_DIY_YQXX" ON "T_DIY_YQXX" 
		("KH" ASC)
		PCTFREE 10 
		 ALLOW REVERSE SCANS;

------------------------------------------------
-- 表的 DDL 语句 "T_DIY_XYKZKM"
------------------------------------------------
 

CREATE TABLE "T_KP_XYKZKM"  (
		  "XYKZH" VARCHAR(60) , 
		  "HXJYLSH" VARCHAR(60) , 
		  "MXKMBH" VARCHAR(60) , 
		  "MXKMMC" VARCHAR(60)) 
		 IN "EASTSS1" ; 

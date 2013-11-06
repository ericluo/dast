------------------------------------------------
-- ��� DDL ��� "T_DIY_YQXX"
------------------------------------------------
 

CREATE TABLE "T_DIY_YQXX"  (
		  "KH" VARCHAR(60) , 
		  "XYKZH" VARCHAR(60) , 
		  "YQRQ" CHAR(8) )   
		 IN "EASTSS1" ; 

 




-- ���ϵ������� DDL ��� "T_GX_YGB"

CREATE INDEX "T_DIY_YQXX" ON "T_DIY_YQXX" 
		("KH" ASC)
		PCTFREE 10 
		 ALLOW REVERSE SCANS;

------------------------------------------------
-- ��� DDL ��� "T_DIY_XYKZKM"
------------------------------------------------
 

CREATE TABLE "T_KP_XYKZKM"  (
		  "XYKZH" VARCHAR(60) , 
		  "HXJYLSH" VARCHAR(60) , 
		  "MXKMBH" VARCHAR(60) , 
		  "MXKMMC" VARCHAR(60)) 
		 IN "EASTSS1" ; 

数据接口文件名称错误: 

ZCZRGXB  <--> WZBCDZTRJGLXMMDD
ZZKJQKMB <--> ZZHJQKMB


# 设定银行数据库Schema
# db2 connect to EASTST
# db2 set current schema='HKYH'
# 创建银行数据库表
# db2 -tvf create_table.sql > create_table.log
# 银行数据库用户授权
# db2 -tvf grant_HKYH.sql > grant.log
# 银行数据导入
# db2 load from '*.txt' of del replace into 'schema'.'table'

cd d:/data/before_trans/hkyh/
db2 connect to EASTST
db2 set current schema='HKYH'

db2 load from B0187H242010002-GRHQCKFHZMXJL-20130523-1.txt of del replace into HKYH.T_KJ_GRHCFZMX

db2 load from B0187H242010002-GRHQCKFHZMXJL-20130523-2.txt of del insert into HKYH.T_KJ_GRHCFZMX
db2 load from B0187H242010002-GRHQCKFHZMXJL-20130523-3.txt of del insert into HKYH.T_KJ_GRHCFZMX
db2 load from B0187H242010002-GRHQCKFHZMXJL-20130523-4.txt of del insert into HKYH.T_KJ_GRHCFZMX
db2 load from B0187H242010002-GRHQCKFHZMXJL-20130523-5.txt of del insert into HKYH.T_KJ_GRHCFZMX
# vim:shiftwidth=2:softtabstop=2:
#
#
#

db2 connect to EASTST
db2 set schema="HKYH"

db2 load from d:/data/before_trans/hkyh/B0187H242010002-GRHQCKFHZMXJL-20130616.txt of del replace into "HKYH"."T_KJ_GRHCFZMX" > grhqck.log

db2 load from d:/data/before_trans/hkyh/B0187H242010002-JYLS-20130616.txt of del replace into "HKYH"."T_JL_JYLS" > jyls.log

db2 load from d:/data/before_trans/hkyh/B0187H242010002-NBFHZMXJL-20130616.txt of del replace into "HKYH"."T_KJ_NBFZMX" > nbfzmx.log

db2 load from d:/data/before_trans/hkyh/B0187H242010002-DGDQCKFHZ-20130616.txt of del replace into "HKYH"."T_KJ_DGDCFZ" > dgdcfz.log


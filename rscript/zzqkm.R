library(ggplot2)
library(scales)

# pt <- pt + theme_economist() + theme(text = element_text(family='STKaiti')) 
my.theme = theme(text=element_text(family='STKaiti', size=16),
                 axis.text.x=element_text(angle=45),
                 title=element_text(size=20))

cnames <- c("科目编码", "科目名称", "科目层级", "科目类别", 
              "借贷","借方金额", "贷方金额", "采集日期")
zzqkm <- read.csv("d:/dast/data/zzqkm_T_RMB_L31.csv", header = F, 
                 col.names = cnames, encoding='gbk')
zzqkm <- transform(zzqkm, 科目编码 = as.factor(科目编码),
                   科目名称 = as.factor(科目名称),
                   科目类别 = as.factor(科目类别),
                   借贷 = as.factor(借贷),
                   借方金额 = 借方金额 / 100000000,
                   贷方金额 = 贷方金额 / 100000000,
                   采集日期 = as.Date(as.character(采集日期), "%Y%m%d"))

# 生成单位活期存款约趋势图(3级)
dwhq.codes <- c("200101", "200102", "200103", "200107", "200108", "200109", "200111", "200199")
dwhq <- zzqkm[zzqkm$科目编码 %in% dwhq.codes,]
dwhq <- dwhq[order(dwhq$采集日期),]
dwhq <- dwhq[!duplicated(dwhq),]
pt.dwhq <- qplot(采集日期, 贷方金额, data = dwhq, geom='path')
pt.dwhq <- pt.dwhq + geom_smooth()
pt.dwhq <- pt.dwhq + my.theme
pt.dwhq <- pt.dwhq + labs(x='日期', y='存款余额(单位：亿元)', title='单位活期存款科目每日趋势图')
pt.dwhq <- pt.dwhq + scale_x_date(limits = c(start, end), labels=date_format("%Y%m%d"),
                        breaks = "months")
pt.dwhq <- pt.dwhq + facet_grid(科目名称 ~ ., scale="free_y") 
pt.dwhq


km.codes <- c("2001", "2002", "2005", "2010", "2011", "2012", "2036", "2038")
l1 <- zzqkm[which(zzqkm$科目层级 == 1),]
l1 <- l1[!duplicated(l1),]
l1.debit <- l1[l1$科目编码 %in% km.codes,]
l1.debit <- l1.debit[order(l1.debit$采集日期),]

# 生成存款余额趋势图
library(reshape2)
l1.debit.total <- melt(l1.debit[, c(5:8)], id=c("采集日期", "借贷"))
l1.debit.total <- dcast(l1.debit.total, 采集日期+借贷~variable, sum)
pt.ck <- qplot(采集日期, 贷方金额, data = l1.debit.total, geom='path')
pt.ck <- pt.ck + geom_smooth()
pt.ck <- pt.ck + my.theme
pt.ck <- pt.ck + labs(x='日期', y='存款余额(单位：亿元)', title='存款科目每日趋势图')
pt.ck <- pt.ck + scale_x_date(breaks = "months", labels=date_format("%Y%m%d"))
pt.ck

# 生产主要存款一级科目趋势图
start <- min(l1.debit$采集日期)
end <- max(l1.debit$采集日期)
pt <- qplot(采集日期, 贷方金额, data = l1.debit, geom='path') + my.theme
pt <- pt + geom_smooth()
pt <- pt + labs(x='日期', y='存款余额(单位：亿元)', title='主要存款科目每日趋势图')
pt <- pt + scale_x_date(limits = c(start, end), labels=date_format("%Y%m%d"),
                        breaks = "months")
pt <- pt + facet_grid(科目名称 ~ ., scale="free_y") 
pt


library(ggplot2)
library(scales)
library(ggthemes)

cnames <- c("科目编码", "科目名称", "科目层级", "科目类别", 
              "借贷","借方金额", "贷方金额", "采集日期")
zzqkm <- read.csv("~/workspace/dast/data/zzqkm_T_RMB_L31.csv", header = F, 
                 col.names = cnames, encoding='utf-8')
zzqkm <- transform(zzqkm, 科目编码 = as.factor(科目编码),
                   科目名称 = as.factor(科目名称),
                   科目类别 = as.factor(科目类别),
                   借贷 = as.factor(借贷),
                   借方金额 = 借方金额 / 100000000,
                   贷方金额 = 贷方金额 / 100000000,
                   采集日期 = as.Date(as.character(采集日期), "%Y%m%d"))

l1 <- zzqkm[which(zzqkm$科目层级 == 1),]
l1 <- l1[!duplicated(l1),]
km.codes <- c("2001", "2002", "2005", "2010", "2011", "2012", "2036", "2038")
l1.debit <- l1[l1$科目编码 %in% km.codes,]
l1.debit <- l1.debit[order(l1.debit$采集日期),]

# 生成存款余额趋势图
library(reshape2)
l1.debit.total <- melt(l1.debit[, c(5:8)], id=c("采集日期", "借贷"))
l1.debit.total <- dcast(l1.debit.total, 采集日期+借贷~variable, sum)
tt <- qplot(采集日期, 贷方金额, data = l1.debit.total, geom='path')
tt <- tt + geom_smooth()
tt <- tt + theme(text = element_text(family='STKaiti'))
tt <- tt + labs(x='日期', y='存款余额(单位：亿元)', title='存款科目每日趋势图')
tt <- tt + scale_x_date(breaks = "months")
tt

# 生产主要存款一级科目趋势图
start <- min(l1.debit$采集日期)
end <- max(l1.debit$采集日期)
pt <- qplot(采集日期, 贷方金额, data = l1.debit, geom='path')
# pt <- pt + theme_economist() + theme(text = element_text(family='STKaiti')) 
pt <- pt + geom_smooth()
pt <- pt + theme(text = element_text(family='STKaiti'))
pt <- pt + labs(x='日期', y='存款余额(单位：亿元)', title='主要存款科目每日趋势图')
pt <- pt + scale_x_date(limits = c(start, end), breaks = "months")
# pt + theme(aspect.ratio = 1 / 2) + scale_x_date()
# pt + scale_x_date(labels = date_format('%m/%y'),breaks = "3 months") + scale_y_log10()
pt <- pt + facet_grid(科目名称 ~ ., scale="free_y") 
pt


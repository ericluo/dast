cnames <- c("科目编码", "", "", "科目名称", "科目层级", "科目类别", 
              "借贷","借方金额", "贷方金额", "采集日期")
zzqkm <- read.csv("~/workspace/dast/data/zzqkm_T_RMB_L3.csv", header = F, 
                 col.names = cnames, encoding='utf-8')
zzqkm <- transform(zzqkm, 科目编码 = as.factor(科目编码),
                   科目名称 = as.factor(科目名称),
                   科目类别 = as.factor(科目类别),
                   借贷 = as.factor(借贷),
                   借方金额 = 借方金额 / 100000000,
                   贷方金额 = 贷方金额 / 100000000,
                   采集日期 = as.Date(as.character(采集日期), "%Y%m%d"))

l1 <- zzqkm[which(zzqkm$科目层级 == 1),]
l1.debit <- l1[l1$科目编码 %in% c("2001", "2010", "2015"),]
l1.debit <- l1.debit[order(l1.debit$采集日期),]

library(ggplot2)
library(scales)
library(ggthemes)

start <- min(l1.debit$采集日期)
end <- max(l1.debit$采集日期)
pt <- qplot(采集日期, 贷方金额, data = l1.debit, geom='path', xlab='日期', ylab='金额')
# pt <- pt + theme_economist() + theme(text = element_text(family='STKaiti')) 
pt <- pt + geom_smooth()
pt <- pt + theme(text = element_text(family='STKaiti'))
pt <- pt + scale_x_date(limits = c(start, end), labels = date_format('%m/%y'), breaks = "months")
# pt + theme(aspect.ratio = 1 / 2) + scale_x_date()
# pt + scale_x_date(labels = date_format('%m/%y'),breaks = "3 months") + scale_y_log10()
pt <- pt + facet_grid(科目名称 ~ ., scale="free_y") 
pt

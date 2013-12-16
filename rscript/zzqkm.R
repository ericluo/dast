zzqmk = read.csv("~/workspace/dast/data/zzqkm_T_RMB_L3.csv", header = F, encoding='utf-8')
zzqmk$V10 = as.Date(as.character(zzqmk$V10), "%Y%m%d")

library(ggplot2)
library(scales)
library(ggthemes)

km <- zzqmk[which(zzqmk$V1 == '2001'), ]
km <- km[order(km$V10),]
km <- transform(km,V9 = (V9 / 10000))
pt <- qplot(V10, V9, data = km, geom='path', xlab='日期', ylab='金额')
# pt <- pt + theme_economist() + theme(text = element_text(family='STKaiti')) 
pt <- pt + theme(text = element_text(family='STKaiti')) 
# pt + theme(aspect.ratio = 1 / 2) + scale_x_date()
# pt + scale_x_date(labels = date_format('%m/%y'),breaks = "3 months") + scale_y_log10()
pt + scale_x_date(breaks = "3 months")

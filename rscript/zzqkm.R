zzqmk = read.csv("~/workspace/dast/data/zzqkm_T_RMB_L3.csv", header = F)
zzqmk$V10 = as.Date(as.character(zzqmk$V10), "%Y%m%d")

library(ggplot2)

km = zzqmk[which(zzqmk$V1 == '2001'), ]
km = km[order(km$V10),]
options(encoding='CP1250.enc')
pt <- qplot(V10, V9, data = km, geom='path', xlab='日期')
# pt + theme(aspect.ratio = 1 / 2) + scale_x_date()
pt + scale_x_date(breaks = "months")
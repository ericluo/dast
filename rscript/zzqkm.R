library(ggplot2)
library(scales)

# pt <- pt + theme_economist() + theme(text = element_text(family='STKaiti')) 
my.theme = theme_bw(base_size = 20, base_family = 'STKaiti') +
    theme(axis.text.x=element_text(angle=45))

cnames <- c("科目编码", "科目名称", "科目层级", "科目类别", 
              "借贷","借方金额", "贷方金额", "采集日期")
zzqkm <- read.csv("~/workspace/dast/data/zzqkm_T_RMB_L31.csv", header = F, 
                 col.names = cnames, encoding='gbk')
zzqkm <- transform(zzqkm, 科目编码 = as.factor(科目编码),
                   科目名称 = as.factor(科目名称),
                   科目类别 = as.factor(科目类别),
                   借贷 = as.factor(借贷),
                   借方金额 = 借方金额 / 100000000,
                   贷方金额 = 贷方金额 / 100000000,
                   采集日期 = as.Date(as.character(采集日期), "%Y%m%d"))

zzqkm.draw <- function(data, img_file, img_title = "每日趋势图", is.facet = TRUE) {
    df <- data[!duplicated(data),]
    df <- df[order(df$采集日期),]

    plot <- qplot(采集日期, 贷方金额, data=df, geom='path') + geom_smooth() + my.theme
    plot <- plot + scale_x_date(labels=date_format("%Y%m%d"), breaks="months")
    if (is.facet) plot <- plot + facet_grid(科目名称 ~ ., scale="free_y")
    plot <- plot + labs(x='日期', y='期末余额（单位：亿元）', title=img_title)

    ggsave(img_file)
}

# 生成存款余额趋势图
library(reshape2)
codes <- c("2001", "2002", "2005", "2010", "2011", "2012", "2036", "2038")
debit <- zzqkm[zzqkm$科目编码 %in% codes,]
debit <- debit[order(debit$采集日期),]
debit.total <- melt(debit[, c(5:8)], id=c("采集日期", "借贷"))
debit.total <- dcast(debit.total, 采集日期+借贷~variable, sum)
zzqkm.draw(debit.total,"~/workspace/dast/data/debit.png", '存款科目每日趋势图', is.facet = FALSE )

# 生产主要存款一级科目趋势图
zyck <- zzqkm[zzqkm$科目编码 %in% codes,]
zzqkm.draw(zyck, "~/workspace/dast/data/zyck.png", '主要存款科目每日趋势图')

# 生成单位活期存款约趋势图(3级)
codes <- c("200101", "200102", "200103", "200107", "200108", "200109", "200111", "200199")
dwhq <- zzqkm[zzqkm$科目编码 %in% codes,]
zzqkm.draw(dwhq, "~/workspace/dast/data/dwhq.png", '单位活期存款科目每日趋势图')






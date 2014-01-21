d <- read.csv("~/workspace/dast/data/staff.csv", header=F)
names(d) <- c("id", "name", "dept", "job", "years", "salary", "comm")

library("ggplot2")
qplot(years, salary, data=d)

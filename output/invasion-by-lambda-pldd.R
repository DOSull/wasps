library(dplyr)
library(ggplot2)

setwd('~/Documents/code/working/wasps/output')
wasps <- read.csv("wasps experiment-base-1-table.csv", skip=6)

wasps <- select(wasps, 1:5,21:23)
svg("invasion-by-lambda-pldd.svg")
ggplot(wasps) + 
  geom_bin2d(aes(x=X.step., y=prop.occupied), bins=10) + 
  scale_fill_distiller(palette='Reds', direction=1) + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)
dev.off()


##

library(dplyr)
library(ggplot2)

setwd('~/Documents/wasps/output/')
wasps <- read.csv("wasps experiment-nozero-table.csv", skip=6)

wasps <- select(wasps, 1:5,11, 21:23)
svg("invasion-by-lambda-pldd.svg")
ggplot(wasps) + 
  geom_bin2d(aes(x=X.step., y=prop.occupied), bins=10) + 
  scale_fill_distiller(palette='Reds', direction=1) + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)

ggplot(wasps) + 
  geom_line(aes(x=X.step., y=prop.occupied, group = X.run.number.)) + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)


dev.off()


##


  
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

library(dplyr)
library(ggplot2)

setwd('~/Documents/code/working/wasps/output/')
wasps <- read.csv("wasps experiment-nozero-table.csv", skip=6)

wasps <- select(wasps, 1:5,11, 21:23)

wasps.t <- wasps %>% 
  group_by(X.run.number.) %>%
  summarise_at('X.step.', max) %>%
  merge(wasps) %>%
  filter(total.pop > 0) %>%
  mutate(LDD = as.factor(p.ldd))

svg("time-series-by-lambda-pldd.svg")
ggplot(wasps, aes(x=X.step., y=prop.occupied)) + 
  geom_line(aes(group=X.run.number.), color='grey', lwd=.1) + 
  xlim(0, 50) + ylim(0, 1) +
  scale_fill_distiller(palette='Reds', direction=1) + 
  geom_smooth() +
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)
dev.off()

svg("time-to-95-by-lambda-pldd.svg")
ggplot(wasps.t) + 
  geom_smooth(aes(x=lambda.1, y=X.step., group=LDD, color=LDD))
dev.off()


  
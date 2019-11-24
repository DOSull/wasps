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

wasps <- select(wasps, 1:5,11, 15, 21:23)

wasps.t <- wasps %>% 
  group_by(X.run.number., r.mean) %>%
  summarise_at('X.step.', max) %>%
  merge(wasps) %>%
  filter(total.pop > 0) %>%
  mutate(P.LDD = as.factor(p.ldd),
         R.MEAN = as.factor(r.mean))

svg("time-series-by-lambda-pldd.svg")
ggplot(wasps, aes(x=X.step., y=prop.occupied, color=r.mean)) + 
  geom_line(aes(group=X.run.number.), lwd=.2, alpha=0.35) + 
  xlim(0, 50) + ylim(0, 1) +
  scale_color_viridis_c(option='D') + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)
dev.off()

svg("time-to-95-by-lambda-pldd.svg")
ggplot(wasps.t) + 
  geom_smooth(aes(x=lambda.1, y=X.step., group=p.ldd, color=P.LDD)) +
  scale_color_viridis_d(option='C', direction=-1) +
  facet_wrap(vars(r.mean), nrow=1, labeller=label_both)
dev.off()


  
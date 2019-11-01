setwd('~/Documents/code/working/wasps/output')
wasps <- read.csv("wasps experiment-base-1-table.csv", skip=6)

wasps <- select(wasps, 1:5,21:23)

png(filename='invasion-by-lambda-pldd.png', units='mm', width=200, height=200, res=300)
ggplot(wasps) + 
  geom_bin2d(aes(x=X.step., y=prop.occupied), bins=10) + 
  scale_fill_distiller(palette='Reds', direction=1) + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE)
dev.off()

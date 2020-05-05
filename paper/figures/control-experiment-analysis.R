# load libraries
library(dplyr)
library(ggplot2)

# read data
setwd('~/Documents/code/wasps/paper/figures')
wasps.control <- read.csv("data/wasps CONTROL-EXPERIMENT-table.csv", skip=6)

# Select the variables we need. 
# Also determine total wild and GM populations and do some renaming.
wasps.sel <- wasps.control %>%
  select(X.run.number., lambda.1, p.ldd, r.mean, X.step., 
          total.pop, prop.occupied, 
          sum..item.1.pops..of.the.habitable.land, 
          sum..item.2.pops..of.the.habitable.land) %>%
  rename(type1.pop = sum..item.1.pops..of.the.habitable.land,
         type2.pop = sum..item.2.pops..of.the.habitable.land) %>%
  mutate(gm.pop = type1.pop + type2.pop,
         wild.pop = total.pop - gm.pop)

# Determine initial populations, and add to the data
wasps.start.pop <- wasps.sel %>%
  filter(X.step. == 0) %>%
  select(X.run.number., total.pop) %>%
  rename(initial.pop = total.pop)

# Use to calculate population relative to initial.
wasps.sel <- wasps.sel %>%
  merge(wasps.start.pop, all.x=TRUE) %>%
  mutate(relative.pop = total.pop / initial.pop)


## Time series of the occupancy and population relative to initial
plot_occ_pop_by_lambda_pldd <- function(data, r, save=TRUE) {
  d.to_analyse <- data %>%
    filter(r.mean==r)
  g <- ggplot(d.to_analyse, aes(x=X.step., group=X.run.number.)) + 
    geom_line(aes(y=prop.occupied, colour='Occupied area'), lwd=0.5, alpha=0.25) +
    geom_line(aes(y=relative.pop, colour='Population'), lwd=0.25, alpha=0.25) +
    labs(x = 'Time, generations', y='Fraction of initial value', colour='Parameter') + 
    facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE) +
    ggtitle(paste('Population and occupancy by lambda and p_LDD, r_mean=', as.character(r), sep=''))
  fig_name <- paste('pops_by_lambda_pldd_rmean_', as.character(r), '.pdf', sep='')
  ggsave(fig_name, device='pdf')
}


## Time series of the occupancy and population relative to initial
plot_occ_pop_by_lambda_rmean <- function(data, pldd) {
  d.to_analyse <- data %>%
    filter(p.ldd==pldd)
  ggplot(d.to_analyse, aes(x=X.step., group=X.run.number.)) + 
    geom_line(aes(y=prop.occupied, colour='Occupied area'), lwd=0.5, alpha=0.25) +
    geom_line(aes(y=relative.pop, colour='Population'), lwd=0.25, alpha=0.25) +
    labs(x = 'Time, generations', y='Fraction of initial value', colour='Parameter') + 
    facet_grid(r.mean ~ lambda.1, labeller=label_both, as.table=FALSE) +
    ggtitle(paste('Population and occupancy by lambda and r_mean, p_LDD=', as.character(pldd), sep=''))
  fig_name <- paste('pops_by_lambda_rmean_pldd_', as.character(pldd), '.pdf', sep='')
  ggsave(fig_name, device='pdf')
}




## ----------------------------------------
## BOXPLOTS and VIOLIN PLOTS
## ----------------------------------------
## BY R.MEAN
d.to_analyse <- wasps.sel %>%
  filter(X.step. >= 40, X.step. <=60) %>%
  mutate(pldd = as.factor(p.ldd))

ggplot(d.to_analyse, aes(x=pldd)) + 
  geom_boxplot(aes(y=prop.occupied, fill='Occupied area'), lwd=0.25) +
  geom_boxplot(aes(y=relative.pop, fill='Population'), lwd=0.25) +
  labs(x = 'Proportion long distance dispersal', y='Fraction of initial value', colour='Parameter') + 
  facet_grid(r.mean ~ lambda.1, labeller=label_both, as.table=FALSE) +
  ggtitle('Variation from generation 40-60')
  
ggplot(d.to_analyse, aes(x=pldd)) + 
  geom_violin(aes(y=prop.occupied, fill='Occupied area'), alpha=0.65, lwd=0) +
  geom_violin(aes(y=relative.pop, fill='Population'), alpha=0.65, lwd=0) +
  labs(x = 'Proportion long distance dispersal', y='Fraction of initial value', fill='') + 
  facet_grid(r.mean ~ lambda.1, labeller=label_both, as.table=FALSE) +
  ggtitle('Variation from generation 40-60')

## BY P.LDD
d.to_analyse <- wasps.sel %>%
  filter(X.step. >= 40, X.step. <=60) %>%
  mutate(rmean = as.factor(r.mean))

ggplot(d.to_analyse, aes(x=rmean)) + 
  geom_boxplot(aes(y=prop.occupied, fill='Occupied area'), lwd=0.25) +
  geom_boxplot(aes(y=relative.pop, fill='Population'), lwd=0.25) +
  labs(x = 'Mean population growth rate', y='Fraction of initial value', colour='Parameter') + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE) +
  ggtitle('Variation from generation 40-60')

ggplot(d.to_analyse, aes(x=rmean)) + 
  geom_violin(aes(y=prop.occupied, fill='Occupied area'), alpha=0.65, lwd=0) +
  geom_violin(aes(y=relative.pop, fill='Population'), alpha=0.65, lwd=0) +
  labs(x = 'Mean population growth rate', y='Fraction of initial value', fill='') + 
  facet_grid(p.ldd ~ lambda.1, labeller=label_both, as.table=FALSE) +
  ggtitle('Variation from generation 40-60')


# ----------------------------------
# Output the image files
# ----------------------------------
for (r in unique(wasps.sel$r.mean)) {
  plot_occ_pop_by_lambda_pldd(wasps.sel, r)
}

for (pldd in unique(wasps.sel$p.ldd)) {
  plot_occ_pop_by_lambda_rmean(wasps.sel, pldd)
}


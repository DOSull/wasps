# load libraries
library(dplyr)
library(ggplot2)

# read data
setwd("~/Documents/code/wasps/experiments")
wasps.control <- read.csv("abstract-space CONTROL-EXPERIMENT-RELEASE-AND-FORGET-ABSTRACT-SPACE-table.csv", skip=6)

## Time series of the occupancy and population relative to initial
plot_occ_pop_by_dmean_pldd <- function(data, r, save=TRUE) {
  d.to_analyse <- data %>%
    filter(R.mean == r)
  g <- ggplot(d.to_analyse, aes(x = X.step., group = X.run.number.)) + 
    geom_line(aes(y = prop.occupied, colour = 'Occupied area'), lwd = 0.5, alpha = 0.25) +
    geom_line(aes(y = relative.pop, colour = 'Population'), lwd = 0.25, alpha = 0.25) +
    labs(x = 'Time, generations', y='Fraction of initial value', colour = 'Parameter') + 
    facet_grid(p.ldd ~ d.mean, labeller=label_both, as.table = FALSE) +
    ggtitle(paste('Population and occupancy by d_mean and p_LDD, R_mean=', as.character(r), sep = ''))
  fig_name <- paste('pops_by_dmean_pldd_Rmean_', as.character(r), '.pdf', sep = '')
  ggsave(fig_name, device = 'pdf')
}

## Time series of the occupancy and population relative to initial
plot_occ_pop_by_lambda_rmean <- function(data, pldd) {
  d.to_analyse <- data %>%
    filter(p.ldd == pldd)
  ggplot(d.to_analyse, aes(x = X.step., group = X.run.number.)) + 
    geom_line(aes(y = prop.occupied, colour = 'Occupied area'), lwd = 0.5, alpha = 0.25) +
    geom_line(aes(y = relative.pop, colour = 'Population'), lwd = 0.25, alpha = 0.25) +
    labs(x = 'Time, generations', y = 'Fraction of initial value', colour = 'Parameter') + 
    facet_grid(R.mean ~ d.mean, labeller = label_both, as.table = FALSE) +
    ggtitle(paste('Population and occupancy by mean_d and r_mean, p_LDD=', as.character(pldd), sep = ''))
  fig_name <- paste('pops_by_R_mean_d_mean_pldd_', as.character(pldd), '.pdf', sep = '')
  ggsave(fig_name, device = 'pdf')
}



# Select the variables we need. 
# Also determine total wild and GM populations and do some renaming.
wasps.sel <- wasps.control %>%
  select(X.run.number., d.mean, p.ldd, R.mean, X.step., 
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



# ----------------------------------
# Output the image files
# ----------------------------------
for (r in unique(wasps.sel$R.mean)) {
  plot_occ_pop_by_dmean_pldd(wasps.sel, r)
}

for (pldd in unique(wasps.sel$p.ldd)) {
  plot_occ_pop_by_lambda_rmean(wasps.sel, pldd)
}



## ----------------------------------------
## BOXPLOTS and VIOLIN PLOTS
## ----------------------------------------
## BY R.MEAN
d.to_analyse <- wasps.sel %>%
  filter(X.step. >= 40, X.step. <=60) %>%
  mutate(pldd = as.factor(p.ldd))

ggplot(d.to_analyse, aes(x = pldd)) + 
  geom_boxplot(aes(y = prop.occupied, fill = 'Occupied area'), lwd = 0.25) +
  geom_boxplot(aes(y = relative.pop, fill = 'Population'), lwd = 0.25) +
  labs(x = 'Proportion long distance dispersal', y = 'Fraction of initial value', colour = 'Parameter') + 
  facet_grid(R.mean ~ d.mean, labeller = label_both, as.table = FALSE) +
  ggtitle('Variation from generation 40-60')

ggplot(d.to_analyse, aes(x = pldd)) + 
  geom_violin(aes(y = prop.occupied, fill = 'Occupied area'), alpha = 0.65, lwd = 0) +
  geom_violin(aes(y = relative.pop, fill = 'Population'), alpha = 0.65, lwd = 0) +
  labs(x = 'Proportion long distance dispersal', y = 'Fraction of initial value', fill = '') + 
  facet_grid(R.mean ~ d.mean, labeller=label_both, as.table=FALSE) +
  ggtitle('Variation from generation 40-60')

## BY P.LDD
d.to_analyse <- wasps.sel %>%
  filter(X.step. >= 40, X.step. <= 60) %>%
  mutate(Rmean = as.factor(R.mean))

ggplot(d.to_analyse, aes(x = Rmean)) + 
  geom_boxplot(aes(y = prop.occupied, fill='Occupied area'), lwd=0.25) +
  geom_boxplot(aes(y = relative.pop, fill='Population'), lwd=0.25) +
  labs(x = 'Mean population growth rate', y='Fraction of initial value', colour = 'Parameter') + 
  facet_grid(p.ldd ~ d.mean, labeller = label_both, as.table = FALSE) +
  ggtitle('Variation from generation 40-60')

ggplot(d.to_analyse, aes(x = Rmean)) + 
  geom_violin(aes(y = prop.occupied, fill = 'Occupied area'), alpha = 0.65, lwd = 0) +
  geom_violin(aes(y = relative.pop, fill = 'Population'), alpha = 0.65, lwd = 0) +
  labs(x = 'Mean population growth rate', y = 'Fraction of initial value', fill = '') + 
  facet_grid(p.ldd ~ d.mean, labeller = label_both, as.table = FALSE) +
  ggtitle('Variation from generation 40-60')


# Analysis of control experiments
## Load libraries
library(dplyr)
library(ggplot2)
library(tidyr)

## Read and pre-process data
setwd("~/Documents/code/wasps/abstract-space")
wasps.control <- read.csv("abstract-space experiment-grid-releases-table.csv", skip=6)


# Select needed variables, determine total wild and GM populations 
# and do some renaming
wasps.sel <- wasps.control %>%
  select(X.run.number., grid.resolution, colonies.per.site, periodicity, X.step., 
         total.pop, prop.occupied, number.of.sites, seed,
         sum..item.1.pops..of.the.habitable.land, 
         sum..item.2.pops..of.the.habitable.land) %>%
  rename(type1.pop = sum..item.1.pops..of.the.habitable.land,
         type2.pop = sum..item.2.pops..of.the.habitable.land) %>%
  mutate(gm.pop = type1.pop + type2.pop,
         wild.pop = total.pop - gm.pop,
         periodicity = as.factor(periodicity))

# Determine initial populations, and add to the data
wasps.start.pop <- wasps.sel %>%
  filter(X.step. == 0) %>%
  select(X.run.number., total.pop, wild.pop) %>%
  rename(initial.pop = total.pop,
         initial.wild.pop = wild.pop)
wasps.sel <- wasps.sel %>%
  merge(wasps.start.pop, all.x = TRUE) %>%
  mutate(relative.pop = total.pop / initial.pop,
         relative.wild.pop = wild.pop / initial.wild.pop)

last.step <- wasps.sel %>%
  group_by(X.run.number.) %>%
  summarise(final.step = max(X.step.)) %>%
  ungroup()
wasps.sel <- wasps.sel %>% 
  merge(last.step)

final.pops <- wasps.sel %>% 
  filter(X.step. > 130) %>%
  group_by(X.run.number.) %>%
  summarise(final.pop = mean(relative.pop),
            final.wild.pop = mean(relative.wild.pop),
            final.occ = mean(prop.occupied))
wasps.sel <- wasps.sel %>%
  merge(final.pops)

wasps.sel <- wasps.sel %>% 
  mutate(final.pop = replace_na(final.pop, 0),
         final.wild.pop = replace_na(final.wild.pop, 0))

wasps.sel.2 <- wasps.sel %>% 
  pivot_longer(final.pop:final.wild.pop)


filter(wasps.sel.2, colonies.per.site == 9, grid.resolution == 2) %>%
  ggplot() +
    geom_boxplot(aes(x = periodicity, y = value, colour = name))
    # geom_point(aes(x = periodicity, y = value, colour = name))



ggplot(wasps.sel.2) +
  geom_violin(aes(x = periodicity, y = value, colour = name)) +
  facet_grid(grid.resolution ~ colonies.per.site, 
             labeller = labeller(.rows = label_both, .cols = label_both))



ggplot(wasps.sel.2) +
  geom_point(aes(x = periodicity, y = value, colour = name), 
             alpha = 0.35, pch = 21) +
  facet_grid(grid.resolution ~ colonies.per.site, 
             labeller = labeller(.rows = label_both, .cols = label_both))


ggplot(wasps.sel) +
  geom_violin(aes(x = periodicity, y = final.wild.pop, 
                  group = periodicity)) +
  facet_grid(grid.resolution ~ colonies.per.site, 
             labeller = labeller(.rows = label_both, .cols = label_both)) +
  theme_minimal()


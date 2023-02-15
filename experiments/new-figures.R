# Analysis of control experiments
## Load libraries
library(dplyr)
library(ggplot2)
library(tidyr)

## Read and pre-process data
setwd("~/Documents/code/wasps/experiments")
wasps.control <- read.csv("wasps CONTROL-EXPERIMENT-070322-table.csv", skip=6)


# Select needed variables, determine total wild and GM populations 
# and do some renaming
wasps.sel <- wasps.control %>%
  select(X.run.number., d.mean, p.ldd, birth.rate, X.step., 
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
wasps.sel <- wasps.sel %>%
  merge(wasps.start.pop, all.x = TRUE) %>%
  mutate(relative.pop = total.pop / initial.pop)

# Determine final populations and add to data
final.pops <- wasps.sel %>% 
  filter(X.step. >= 180) %>%
  group_by(X.run.number.) %>%
  summarise(final.pop = mean(relative.pop),
            final.occ = mean(prop.occupied))
wasps.sel <- wasps.sel %>%
  merge(final.pops)

# Make some plots
# Population and occupancy by R_mean

# Function to make facet small multiples of population and 
# occupancy time series for a given birth rate
plot_occupancy_population_by_dmean_pldd <- function(data, birth_rate, 
                                                    save = TRUE, 
                                                    fname, fmt = "pdf") {
  d.to_analyse <- data %>%
    filter(birth.rate == birth_rate)

  g <- ggplot(d.to_analyse, aes(x = X.step., group = X.run.number.)) + 
    geom_line(aes(y = relative.pop, colour = 'Population'), lwd = 0.25, alpha = 0.25) +
    geom_line(aes(y = prop.occupied, colour = 'Occupied area'), lwd = 0.5, alpha = 0.25) +
    labs(x = 'Time, generations', y = 'Fraction of initial value', colour = 'Parameter') + 
    facet_grid(p.ldd ~ d.mean, labeller=label_both, as.table = FALSE) +
    ggtitle(paste(
      'Population and occupancy by d_mean and p_LDD, birth_rate=', 
      format(birth_rate, nsmall = 1), sep = '')
    )
  if (save) {
    fig_name <- paste(fname, format(birth_rate, nsmall = 1), '.', fmt, sep = '')
    ggsave(fig_name, device = fmt, 
           width = 4, height = 3, units = "in", scale = 2)
  }
  g
}

for (r in unique(wasps.sel$birth.rate)) {
  plot_occupancy_population_by_dmean_pldd(
    wasps.sel, r, fname = "pops_by_dmean_pldd_birth_rate_", fmt = "png"
  )
}


# Population and occupancy by a given p_ldd
plot_occupancy_population_by_dmean_birthrate <- function(data, pldd, 
                                                         save = TRUE, 
                                                         fname, fmt = "pdf") {
  d.to_analyse <- data %>%
    filter(p.ldd == pldd)
  g <- ggplot(d.to_analyse, aes(x = X.step., group = X.run.number.)) + 
    geom_line(aes(y = prop.occupied, colour = 'Occupied area'), alpha = 0.25) +
    geom_line(aes(y = relative.pop, colour = 'Population'), alpha = 0.25) +
    labs(x = 'Time, generations', y = 'Fraction of initial value', colour = 'Parameter') + 
    facet_grid(birth.rate ~ d.mean, labeller = label_both, as.table = FALSE) +
    ggtitle(
      paste('Population and occupancy by mean_d and birth_rate, p_LDD=',
            format(pldd, scientific = TRUE), sep = '')
    )
  fig_name <- paste(
    'pops_by_birth_rate_d_mean_pldd_', format(pldd, scientific = TRUE), '.pdf', sep = '')
  if (save) {
    fig_name <- paste(fname, format(pldd, scientific = TRUE), '.', fmt, sep = '')
    ggsave(fig_name, device = fmt, 
           width = 4, height = 3, units = "in", scale = 2)
  }
  g
}

for (pldd in unique(wasps.sel$p.ldd)) {
  plot_occupancy_population_by_dmean_birthrate(
    wasps.sel, pldd,
    fname = "pops_by_dmean_birth_rate_pldd_", fmt = "png")
}


grid.plot.data <- wasps.sel %>%
  group_by(birth.rate, d.mean, p.ldd) %>%
  summarise(final.population = mean(final.pop),
            final.occupancy = mean(final.occ)) %>%
  ungroup()

ggplot(filter(grid.plot.data)) + 
  geom_contour_filled(aes(x = birth.rate, y = d.mean, z = final.population)) +
  facet_wrap(~ p.ldd) +
  ggtitle("Final mean population")

ggplot(filter(grid.plot.data)) + 
  geom_contour_filled(aes(x = birth.rate, y = d.mean, z = final.occupancy)) +
  facet_wrap(~ p.ldd) +
  ggtitle("Final mean occupancy")



ggplot(filter(wasps.sel)) + 
  geom_boxplot(aes(x = birth.rate, y = final.pop, group = birth.rate)) +
  facet_grid(d.mean ~ p.ldd) +
  ggtitle("Final mean occupancy")



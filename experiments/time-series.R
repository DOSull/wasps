library(ggplot2)
library(raster)
library(tmap)
library(dplyr)
library(tidyr)


setwd("~/Documents/code/wasps/experiments")


basename <- "monitor-dmean2-pldd1.0E-4-rmean1-01:17:53.437_PM_01-Sep-2022"
d <- read.table(paste(basename, ".txt", sep = ""), header = TRUE)

d <- d %>%
  mutate(total = p_wild + p_gm + p_sterile, 
         wild_prop = if_else(total == 0, 0, p_wild / total), #if_else(p1 > k, 1, p1 / k), 
         gm_prop = if_else(total == 0, 0, p_gm / total), #if_else(p2 > k, 1, p2 / k), 
         sterile_prop = if_else(total == 0, 0, p_sterile / total), #if_else(p3 > k, 1, p3 / k),
         total = if_else(total > capacity, 1, total / capacity))

time_step_range <- seq(20, 47, 3)

# Data prep
# Have to assign unique id to every row in the table
# to be able to use hexcolours...
d_to_map <- d %>%
  filter(t %in% time_step_range) %>%
  mutate(hexcolour = rgb(wild_prop, sterile_prop, gm_prop),
         id = row_number())

pdf(paste("time-series/", basename, ".pdf", sep = ""), 
    width = 4, height = 3)
ggplot(d_to_map) +
  geom_raster(aes(x = x, y = y, fill = as.factor(id), alpha = total),
              show.legend = FALSE) +
  # geom_tile(aes(x = x, y = y, width = 1, height = 1,
  #               fill = as.factor(id), alpha = total),
  #           show.legend = FALSE) +
  scale_fill_manual(values = d_to_map$hexcolour) + 
  coord_equal() +
  facet_wrap(~ t, ncol = 5) +
  theme_minimal() +
  theme(panel.grid = element_blank(),
        axis.line = element_blank(), 
        axis.text = element_blank(),
        axis.title = element_blank())
dev.off()

## An alternative using raster and tmap...
library(raster)
library(tmap)
raster_maps <- list()
for (tstep in time_step_range) {
  r <- d %>%
    filter(t == tstep) %>%
    dplyr::select(x, y, wild_prop, sterile_prop, gm_prop, total) %>%
    rasterFromXYZ(crs = 9156)
  raster_maps <- append(
    raster_maps,
    list(tm_shape(r) + tm_rgba(max.value = 1, interpolate = FALSE))
  )
}
tmap_arrange(raster_maps, nrow = 2)




d_chasing <- d %>%
  pivot_longer(cols = wild_prop:sterile_prop) %>%
  mutate(name = factor(name, 
                       levels = c("sterile_prop", "gm_prop", "wild_prop")))

time_step_range <- seq(26, 32, 2)

# Chasing plots
d_chasing %>%
  filter(t %in% time_step_range, t %% 2 == 0) %>%
  # ggplot(aes(x = x, y = y, fill = name, alpha = value)) +
  ggplot(aes(x = x, y = y, fill = value)) +
    geom_raster() + 
    # scale_fill_brewer(palette = "Set1", direction = -1) +
    scale_fill_distiller(palette = "Reds", direction = 1) +
    coord_equal() +
    facet_grid(name ~ t) +
    theme_minimal()


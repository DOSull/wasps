library(ggplot2)
library(raster)
library(tmap)
library(dplyr)
library(tidyr)


setwd("~/Documents/code/wasps/experiments")

basename <- "monitor-dmean1-pldd1.0E-4-birthrate2.5-01:52:25.840_PM_01-Sep-2022"
d <- read.table(paste(basename, ".txt", sep = ""), header = TRUE)

d <- d %>%
  mutate(p_total = p_wild + p_gm + p_sterile, 
         wild_prop = if_else(p_total == 0, 0, p_wild / p_total), 
         gm_prop = if_else(p_total == 0, 0, p_gm / p_total), 
         sterile_prop = if_else(p_total == 0, 0, p_sterile / p_total))

max_pop <- max(d$p_total)

d <- d %>% 
  mutate(total = p_total / max_pop,
         p_total = if_else(p_total > capacity, 1, p_total / capacity))

time_step_range <- c(0, seq(20, 44, 3))
time_step_range <- seq(0, 45, 5)
# time_step_range <- seq(110, 137, 3)

# Data prep
# Have to assign unique id to every row in the table
# to be able to use hexcolours...
d_to_map <- d %>%
  filter(t %in% time_step_range) %>%
  mutate(land = TRUE)

# Make a grid covering the full extent so we can assign
# a background colour to the maps
xyt <- expand_grid(seq(min(d_to_map$x), max(d_to_map$x)),
                   seq(min(d_to_map$y), max(d_to_map$y)),
                   unique(d_to_map$t))
names(xyt) <- c("x", "y", "t")
xyt <- xyt %>%
  left_join(d_to_map)

xyt <- xyt %>% 
  # this sets up the sea with proportions to give a sea blue background
  replace_na(list(p_total = 1, total = 1, wild_prop = 0.25, 
                  sterile_prop = 0.6, gm_prop = 0.8, land = FALSE)) %>%
  mutate(hexcolour = if_else(land & (t == 0),
                             rgb(0, 0, 0, total),
                             rgb(wild_prop, sterile_prop, gm_prop, p_total)),
         id = row_number())

pdf(paste("time-series/", basename, ".pdf", sep = ""), 
    width = 4, height = 3)

ggplot(xyt) +
  geom_raster(aes(x = x, y = y, fill = as.factor(id), alpha = total),
              show.legend = FALSE) +
  scale_fill_manual(values = xyt$hexcolour) + 
  coord_equal(expand = FALSE) +
  facet_wrap(~ t, ncol = 5) +
  theme_void() +
  theme(panel.grid = element_blank(),
        axis.line = element_blank(), 
        axis.text = element_blank(),
        axis.title = element_blank())

dev.off()


# ## An alternative using raster and tmap...
# library(raster)
# library(tmap)
# raster_maps <- list()
# for (tstep in time_step_range) {
#   r <- d %>%
#     filter(t == tstep) %>%
#     dplyr::select(x, y, wild_prop, sterile_prop, gm_prop, total) %>%
#     rasterFromXYZ(crs = 9156)
#   raster_maps <- append(
#     raster_maps,
#     list(tm_shape(r) + tm_rgba(max.value = 1, interpolate = FALSE))
#   )
# }
# tmap_arrange(raster_maps, nrow = 2)
# 
# 
# 
# 
# d_chasing <- d %>%
#   pivot_longer(cols = wild_prop:sterile_prop) %>%
#   mutate(name = factor(name, 
#                        levels = c("sterile_prop", "gm_prop", "wild_prop")))
# 
# time_step_range <- c(0, seq(20, 45, 3))
# 
# # Chasing plots
# d_chasing %>%
#   filter(t %in% time_step_range, t %% 2 == 0) %>%
#   # ggplot(aes(x = x, y = y, fill = name, alpha = value)) +
#   ggplot(aes(x = x, y = y, fill = value)) +
#     geom_raster() + 
#     # scale_fill_brewer(palette = "Set1", direction = -1) +
#     scale_fill_distiller(palette = "Reds", direction = 1) +
#     coord_equal() +
#     facet_grid(name ~ t) +
#     theme_minimal()
# 

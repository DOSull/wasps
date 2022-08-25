library(ggplot2)
library(raster)
library(tmap)
library(dplyr)
library(tidyr)


# Ternary Color Maps ------------------------------------------------------
#' CIE-Lch Mixture of Ternary Composition
#'
#' Return the ternary balance scheme colors for a matrix of ternary compositions.
#' adapted from Tricolore
ColorMapTricolore <- function (p1, p2, p3, 
                               c_ = 200, l_ = 50,
                               contrast = 1) {
  C <- c(p1, p2, p3) * c_
  phi <- c(0, 60, 240) %% 360 * pi / 180
  Z <- matrix(complex(argument = phi, modulus = c(t(C))),
              ncol = 3, byrow = TRUE)
  z <- rowSums(Z)
  M <- cbind(h = (Arg(z) * 57.3) %% 360, c = Mod(z), l = l_)
  cfactor <- M[, 2] * contrast / c_ + 1 - contrast
  M[, 3] <- cfactor * M[, 3]
  M[, 2] <- cfactor * M[, 2]
  
  rgb <- hcl(h = M[,1], c = M[,2], l = M[,3],
             alpha = 1, fixup = TRUE)
  rgb <- substr(rgb, 1, 7)
  return(rgb)
}





setwd("~/Documents/code/wasps/abstract-space")

d <- read.table(
  "monitor-dmean1-pldd0-rmean1-01:37:28.161_PM_17-Mar-2022.txt", 
  header = TRUE)

d <- d %>%
  mutate(total = p1 + p2 + p3, 
         wild_prop = if_else(total == 0, 0, p1 / total), #if_else(p1 > k, 1, p1 / k), 
         gm_prop = if_else(total == 0, 0, p2 / total), #if_else(p2 > k, 1, p2 / k), 
         sterile_prop = if_else(total == 0, 0, p3 / total), #if_else(p3 > k, 1, p3 / k),
         total = if_else(total > k, 1, total / k))

# d$hexcolour <- mapply(ColorMapTricolore, 
#                       d$wild_prop, d$gm_prop, d$sterile_prop)

time_step_range <- seq(5, 75, 4)

# Data prep
# Have to assign unique id to every row in the table
# to be able to use hexcolours...
d_to_map <- d %>%
  filter(t %in% time_step_range) %>%
  mutate(hexcolour = rgb(wild_prop, sterile_prop, gm_prop),
         id = row_number())

ggplot(d_to_map) +
  geom_tile(aes(x = x, y = y, width = 1, height = 1,
                fill = as.factor(id), alpha = total),
            show.legend = FALSE) +
  scale_fill_manual(values = d_to_map$hexcolour) + 
  coord_equal() +
  facet_wrap(~ t, ncol = 6) +
  theme_minimal()


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


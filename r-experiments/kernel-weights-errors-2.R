library(tidyr)
library(dplyr)
library(ggplot2)

dist <- function(x, y) {
  return(sqrt(x ^ 2 + y ^ 2))
}

interpolate <- function(z, range, res) {
  return(z - (range / 2) + 0:(range / res) * res)
}

mean_d_in_square_at <- function(cx, cy, range, res) {
  square <- tidyr::crossing(x = interpolate(cx, range, res), y = interpolate(cy, range, res))%>%
    mutate(d = dist(x, y))
  return(mean(square$d))
}

mean_d_in_square_at_V <- Vectorize(mean_d_in_square_at)

centres <- tidyr::crossing(x = interpolate(1, 2, 0.05) , y = interpolate(1, 2, 0.05)) %>% 
  mutate(d.est = mean_d_in_square_at_V(x, y, 0.1, 0.025),
         d.c = dist(x, y), 
         correction = d.est / d.c)

ggplot(centres) + 
  geom_rect(aes(xmin = x - 0.025, ymin = y - 0.025, xmax = x + 0.025, ymax = y + 0.025, fill = correction)) + 
  coord_equal() + 
  scale_fill_viridis_c()

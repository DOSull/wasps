library(dplyr)
library(ggplot2)

distance <- function(x1 = 0, y1 = 0, x2 = 1, y2 = 1) {
  return(sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2))
}

integral_under_2d_exponential <- function(lambda = 1, x1 = 0, x2 = 1, y1 = 0, y2 = 1) {
  h <- dexp(distance(x2 = (x1 + x2) / 2, y2 = (y1 + y2) / 2), rate = lambda)
  return(h * (x2 - x1) * (y2 - y1))
}


dxdy <- expand.grid(0.5 + 0:20 / 2, 0.5 + 0:20 / 2)

lambda <- 1

df <- data.frame(x2 = dxdy[, 1], y2 = dxdy[, 2]) %>%
  mutate(x1 = if_else(x2 - 1 < 0, 0, x2 - 1), 
         y1 = if_else(y2 - 1 < 0, 0, y2 - 1)) %>%
  select(x1, x2, y1, y2) %>%
  mutate(v = integral_under_2d_exponential(lambda = lambda, x1 = x1, x2 = x2, y1 = y1, y2 = y2))

ggplot(df) + 
  geom_rect(aes(xmin = x1, xmax = x2, ymin = y1, ymax = y2, fill = v)) +
  coord_equal() + 
  scale_fill_viridis_c()
  


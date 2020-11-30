library(tidyr)
library(directlabels)


hypot <- function(a, b) {
  return(sqrt(a ^ 2 + b^ 2))
}

mean_d_to_square <- function(x, y, a = 1, i = 0) {
  x0 <- x - a / 2
  x1 <- x + a / 2
  y0 <- y - a / 2
  y1 <- y + a / 2
  
  r0 <- hypot(x0, y0)
  r1 <- hypot(x1, y0)
  r2 <- hypot(x1, y1)
  r3 <- hypot(x0, y1)
  
  result <- c(  8 *  a ^ 2  * r2, 
              - 8 *  a * x0 * (r3 - r2), 
              - 8 *  a * y0 * (r1 - r2),
              + 8 * x0 * y0 * (r0 - r1 + r2 - r3), 
              +     x1 ^ 3  * (log(r2 - y1) - log(r1 - y0)),
              + 4 * y1 ^ 3  * (log(x1 + r2) - log(x0 + r3)),
              + 5 * x1 ^ 3  * (log(y1 + r2) - log(y0 + r1)),
              + 2 * x0 ^ 3  * asinh(y0 / x0),
              - 2 * x0 ^ 3  * asinh(y1 / x0),
              + 4 * x0 ^ 3  * log(r0 + y0), 
              + 2 * x0 ^ 3  * log(r0 - y0),
              - 4 * x0 ^ 3  * log(r3 + y1),
              - 2 * x0 ^ 3  * log(r3 - y1), 
              + 4 * y0 ^ 3  * log(r0 + x0), 
              - 4 * y0 ^ 3  * log(r1 + x1)) / 24
  if (i == 0) {
    return(sum(result))
  } else {
    return(result[i])
  }
}

mean_d_to_square_v <- Vectorize(mean_d_to_square)


df <- crossing(x = 1:20, y = 1:20) %>%
  mutate(d = mean_d_to_square_v(x, y),
         h = hypot(x, y),
         underestimate = h / d,
         diff = h - d)

ggplot(df) +
  geom_tile(aes(x = x, y = y, fill = diff)) + 
  scale_fill_viridis_c() + 
  coord_equal() +
  theme_minimal()

df2 <- tibble(z = 1:1000, 
              hypot = hypot(z, 1), 
              mean_d = mean_d_to_square(z, 1), 
              underestimate = hypot / mean_d)

threshold <- 500
dz <- 100

ggplot(filter(df2, z > threshold - dz, z < threshold + dz)) + 
  geom_line(aes(x = z, y = underestimate))


df3 <- tibble(z = 10 ^ (seq(3.9, 4.1, length.out = 10000)),
              d = hypot(z, z + 1) - hypot(z, z))

ggplot(df3) + 
  geom_line(aes(x = z, y = d))


df4 <- crossing(z = 1:1000, i = 1:15) %>%
  mutate(d_parts = mean_d_to_square_v(z, z, i = i),
         i = as.factor(i))

ggplot(df4, aes(x = z, y = d_parts, colour = i)) + 
  geom_line(aes(group = i)) +
  geom_dl(aes(label = i), method = "last.points", 
          cex = 0.5, position = position_dodge(width = 200, preserve = "total"))

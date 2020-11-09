library(ggplot2)
library(dplyr)
library(tidyr)

K <- 1000

next_N <- function(N, lambda, type = "discrete", randomness = "stochastic") {
  N1 <- 0
  if (is.na(N) || N > 0) {
    if (type == "map") {
      N1 <- N * lambda * (K - N) / K
    } 
    else {
      r <- lambda - 1
      N1 <- N + r * N * (K - N) / K
    }
  }
  return(ifelse(randomness == "deterministic", N1, rpois(1, N1)))
}


pop_series <- function(N0, lambda, type, randomness, t = 50) {
  N <- c(N0)
  for (i in 1:t) {
    N_last <- tail(N, 1)[1]
    N <- c(N, next_N(N_last, lambda, type = type, randomness = randomness))
  }
  return(data.frame(t = 0:t, 
                    lambda = rep(lambda, t + 1), 
                    N = N,
                    type = type, 
                    randomness = randomness))
}


lambdas <- 0:40 / 10

combos <- crossing(c("map", "discrete"), c("deterministic", "stochastic"), lambdas)
names(combos) <- c("type", "randomness", "lambda")

df <- pop_series(500, combos$lambda[1], combos$type[1], combos$randomness[1])

for (i in 2:dim(combos)[1]) {
  df <- bind_rows(df, pop_series(500, combos$lambda[i], combos$type[i], combos$randomness[i]))
}

# for (lambda in tail(lambdas, -1)) {
#   df <- bind_rows(df, 
#                   pop_series(500, lambda, type = "map"), 
#                   pop_series(500, lambda, type = "discrete"))
# }

ggplot(df) +
  geom_line(aes(x = t, y = N, colour = lambda, group = lambda)) +
  # facet_wrap(~ type) + 
  facet_grid(randomness ~ type) +
  scale_colour_viridis_c(option = "B") +
  xlab("Time") + ylab("Population, n")


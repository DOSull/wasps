max_denom <- 43

# code based on
# https://www.johndcook.com/blog/2010/10/20/best-rational-approximation/
farey <- function(x, N = max_denom) {
  a <- 0; b <- 1; c <- 1; d <- 1;
  while (b <= N && d <= N) {
    mediant <- (a + c) / (b + d)
    if (x == mediant) {
      if (b + d <= N) {
        return (c(a + c, b + d)) 
      } else if (d > b) {
        return (c(c, d))
      } else {
        return (c(a, b))
      }
    } else if (x > mediant) {
      a <- a + c
      b <- b + d
    } else {
      c <- a + c
      d <- b + d
    }
  }
  if (b > N) {
    return (c(c, d))
  } else {
    return (c(a, b))
  }
}

make_pattern <- function(x = 2/7, 
                         shuffle = TRUE, N = max_denom) {
  f <- farey(x, N = N)
  off <- f[2] - f[1]
  on <- f[1]
  base <- c(rep(1, on), rep(0, off))
  if (shuffle) {
    return (sample(base, on + off, replace = FALSE))
  }
  base
}

spiral_sequence <- function(n) {
  rows <- c(0)
  cols <- c(0)
  for (loop in 1:(n %/% 2)) {
    rows <- c(rows, 
              (1-loop):loop, rep(loop, loop*2),
              (loop-1):(-loop), rep(-loop, loop*2))
    cols <- c(cols, 
              rep(-loop, loop*2), (1-loop):loop,
              rep(loop, loop*2), (loop-1):(-loop))
    loop <- loop + 1
  }
  return(list(rows = rows + n %/% 2 + 1, cols = cols + n %/% 2 + 1))
}

reorder_matrix <- function(m, rc) {
  m[cbind(rc$rows, rc$cols)]
}

make_pattern_matrix <- function(x = 5/13, d = 97, 
                                shuffle = TRUE, spiral = TRUE, 
                                N = max_denom) {
  p <- make_pattern(x = x, shuffle = shuffle)
  n <- d ^ 2
  p <- rep(p, ceiling(n / length(p)))[1:n]
  m <- matrix(0, nrow = d, ncol = d)
  if (spiral) {
    ss <- spiral_sequence(d)
    m[cbind(ss$rows, ss$cols)] <- p
  } else {
    m[cbind(rep(1:d, d), rep(1:d, each=d))] <- p
  }
  m
}



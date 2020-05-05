library(grid)
library(gridExtra)
library(ggpubr)
library(svglite)

get_file_name <- function(lambda, rmean) {
  return(paste('./data/monitor-lambda', lambda, '-pldd1.0E-4-rmean', rmean, '.txt', sep=''))
}

get_data_set <- function(f, time_steps) {
  w <- read.csv(f, sep=' ') %>%
    filter(t %in% time_steps) %>%
    mutate(population = p1 + p2 + p3)
  return(w)
}
  
map_snapshots <- function(w, max_pop, viridis_palette=TRUE, palette='A') {
  p <- ggplot(w, aes(x=x, y=y)) + 
    geom_raster(aes(fill=population))
  if (viridis_palette) { 
    p <- p + scale_fill_viridis_c(option=palette, limits=c(0, max_pop)) 
  } else {
    p <- p + scale_fill_distiller(palette=palette, limits=c(0, max_pop))
  }
  p <- p + 
    facet_wrap(facets=vars(t), nrow=3) + 
    coord_fixed() +
    theme(title=element_text(size=8), 
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank())
  return(p)
}

setwd("~/Documents/code/wasps/paper/figures")
dir("./data")

lambda <- c('0.5', '5')
rmean <- c('1.5', '2.5')
lr.pairs <- data.frame(lambda=as.character(rep(lambda, 2)), rmean=as.character(sort(rep(rmean, 2)))) %>%
  mutate(fname = get_file_name(lambda, rmean))

results <- list()
for (r in 1:dim(lr.pairs)[1]) {
  results[[r]] <- list(lambda = as.character(lr.pairs$lambda[r]),
                       rmean = as.character(lr.pairs$rmean[r]),
                       fname = as.character(lr.pairs$fname[r]))
} 

time_steps <- seq(5, 85, 5)
max_pop <- 0
for (i in 1:length(results)) {
  results[[i]]$time_steps <- time_steps
  d <- get_data_set(results[[i]]$fname, time_steps=results[[i]]$time_steps)
  results[[i]]$data <- d 
  max_pop <- max(c(max_pop, max(d)))
}

pal = 'C'
for (i in 1:length(results)) {
  plot <- map_snapshots(results[[i]]$data, max_pop=1100, viridis_palette=TRUE, palette=pal) + 
    ggtitle(paste('lambda=', results[[i]]$lambda, ' rmean=', results[[i]]$rmean, ' pldd=1.0e-4', sep=''))
  ggsave(paste('./data/snapshots-lambda', results[[i]]$lambda, 
               '-rmean', results[[i]]$rmean,
               '-pldd1E-4-', pal, '.pdf', sep=''), plot, width=8, height=6, units='in')
}


all_data <- bind_rows(results[[1]]$data, results[[2]]$data, results[[3]]$data, results[[4]]$data, .id = 'id')


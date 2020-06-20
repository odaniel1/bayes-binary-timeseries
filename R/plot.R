
plot_acceptance_rate <- function(data){
 
  plot <-   ggplot(data = data) + 
    geom_line(aes(date, p)) +
    geom_ribbon(aes(date,ymin = lwr_80, ymax = upr_80), alpha = 0.2) +
    labs(x = "Date", y = "Acceptance Rate")
    
  return(plot)
}
  


### 1. Moyenne et quantile en fonction de la somme des primes pures 
quantiles_prime <- function(mean_ptf = mean_ptf, rbootclaimagg=rbootclaimagg, pure_premium_sum=pure_premium_sum) {
mean_ptf <- mean(rbootclaimagg)

gap_mean <- (mean_ptf - pure_premium_sum)/pure_premium_sum *100  #écart de 3.5456% à la somme des primes pures
quant_mean <- ecdf(rbootclaimagg)(mean_ptf) # la moyenne charge ptf correspond au quantile 0.5352
#
gap_pure <- 0
quant_pure <- ecdf(rbootclaimagg)(pure_premium_sum)# la somme des primes pures correspond au quantile .0924

quant95 <- quantile(rbootclaimagg, probs=.95) 
gap95 <- (quant95- pure_premium_sum)/pure_premium_sum *100 # écart de 8.551%

quant99 <- quantile(rbootclaimagg, probs=.99) 
gap99 <- (quant99- pure_premium_sum)/pure_premium_sum *100 # écart de 11.212%

quant995 <- quantile(rbootclaimagg, probs=.995)
gap995 <- (quant995 - pure_premium_sum)/pure_premium_sum *100 # écart de 12.568% 

quant <- c(quant_pure, quant_mean, 0.950, 0.990, 0.995)
gap <- c(gap_pure, gap_mean,gap95, gap99, gap995)
value <- c(pure_premium_sum,mean_ptf, quant95, quant99, quant995)/1e6
 return(list( 'quant' = quant, "gap"=gap, "value"= value))
}


### 2. Taux de chargement

findrate <- function(rbootclaimagg=rbootclaimagg, pure_premium_sum= pure_premium_sum){
  return((quantile(rbootclaimagg, probs =0.95) -pure_premium_sum)/ pure_premium_sum *100)
} #calcul le taux de chargement pour la couverture du quantile 95%
  

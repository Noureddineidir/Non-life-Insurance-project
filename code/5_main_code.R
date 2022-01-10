library(corrplot)
library(gridExtra)
library(data.table)
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plotly)
library(knitr)
library(DT)
library(pals)
library(splines)
library(MASS)
library(xtable)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) #set as working directory 
#setwd(getwd()) 
#######################################################################################################
### 1. Calibration des modèles et visualisation des résultats
source('1_calibr_reg_frequence.R') #fréquence
source('1_calibr_reg_severity.R') #sévérité 

summary(fnb4) #performance fréquence

#performance sévérité 
perf_model(reg.gamma)
perf_model(reg.invgaus) 

reg.invgaus$call #get the formula 

##################################################################################################"
### 2. Prédiction de la prime pure à partir des fonctions de pure_premium
source("2_pure_premium.R") # charge les bonnes données ainsi que les fonctions de primes pures. 

df_premium_year0 = df_year0 %>% dplyr::select(id_client, id_vehicle, id_policy) %>% 
  mutate(premium = predict_nbclaim(df_year0, fnb4)*predict_amountclaim(df_year0, reg.invgaus))

pure_premium_sum <- sum(df_premium_year0$premium) #prédiction sur year0

df_premium_year1 = df_year1 %>% dplyr::select(id_client, id_vehicle, id_policy) %>% 
  mutate(premium = predict_nbclaim(df_year1, fnb4)*predict_amountclaim(df_year1, reg.invgaus)) #prédiction sur year1

write.csv(df_premium_year1, file = "../TARIFPUR.csv") #écriture d'un fichier TARIFPUR.CSV


##################################################################################################
### 3. Modélisation d'une charge portefeuille et histogramme 
source("3_bootstrapSimu.R")

#10 000 simulation 
rbootclaimagg <-rclaimagg(1e4, df_claims_nb, df_claims_amount, varnb = "claim_nb", varamount = "claim_amount")

hist(rbootclaimagg/1e6, # histogram
     col = "peachpuff", # column color
     border = "black", 
     prob = TRUE, # show densities instead of frequencies
     xlim = c(13,16.5),
     #ylim = c(0,3),
     xlab = "millions d'euros",
     main = "Histogram of agg.claim amount (100 000 policies)")
lines(density(rbootclaimagg/1e6), # density plot
      lwd = 2, # thickness of line
      col = "chocolate3")
abline(v = mean(rbootclaimagg/1e6),
       col = "royalblue",
       lwd = 2)
abline(v =  pure_premium_sum/1e6,
       col = "red",
       lwd = 2)
abline(v =  quantile(rbootclaimagg/1e6, probs=.95),
       col = "green",
       lwd = 2)
abline(v =  quantile(rbootclaimagg/1e6, probs=.99),
       col = "green",
       lwd = 2, lty=2)
abline(v =  quantile(rbootclaimagg/1e6, probs=.995),
       col = "green",
       lwd = 2, lty =3)
legend(x = "topright", # location of legend within plot area
       c("boot. agg. claim ", "mean", "pure premium sum", "quantile at 0.95", "quantile at 0.99", "quantile at 0.99"),
       col = c("chocolate3", "royalblue", "red", "green", "green", "green"),
       lwd = c(2, 2, 2),
       lty = c(1,1,1,1,2,3))

#############################################################################################
### 4. Taux de chargement pour tarification en prime commerciale 
source("4_com_premium.R") #calculs des quantiles de la charge sinistre totale et l'écart à la somme des primes pures

quant <- quantiles_prime(mean_ptf, rbootclaimagg, pure_premium_sum)$quant
value <- quantiles_prime(mean_ptf, rbootclaimagg, pure_premium_sum)$value
gap <- quantiles_prime(mean_ptf, rbootclaimagg, pure_premium_sum)$gap
quantile_agg <- data.frame(value,quant, gap,
                           row.names = c("somme prime pure","moyenne charge ptf", "quant95", "quant99", "quant995"))
xtable(quantile_agg) #sortie Latex propre 


# graphique du taux de chargement 

p <-c(70:99/100, 0.995, 1) #niveau de confiance
quantiles <- quantile(rbootclaimagg, probs =p)
com_rate <- (quantiles - pure_premium_sum)/pure_premium_sum *100

rate95 <- findrate(rbootclaimagg, pure_premium_sum) #calcul le taux de chargement pour la couverture du quantile 95%

fig <- plot_ly(x = p, y = com_rate, type= "scatter",name ='Taux' , mode = "lines", color = "red")
fig %>% layout(title = "Taux de chargement", xaxis = list(title="niveau de confiance p"),
               yaxis = list(title="taux de charg. kappa (%)"))  %>%
  add_lines(x = p, y = rate95, name = "Taux charg. kappa", color ="blue") %>%
  add_annotations(x= 0.9, y=9.5,xref = "x",
                  yref = "y",
                  text = paste("Taux de chargement : ",as.character(round(rate95, 4)), "%"),
                  showarrow = F)

#############################################################################
### 5. Tarification en prime commerciale :

df_premium_year0_charge <- df_premium_year0 %>% mutate(premium = premium * (1+ rate95/100))
(sum(df_premium_year0_charge$premium) - quantile(rbootclaimagg, probs = 0.95))/sum(df_premium_year0_charge$premium) 
#vérifions que la couverture marche sur l'an 0

#sum(df_premium_year1$premium) 
df_premium_year1_charge <- df_premium_year1 %>% mutate(premium = premium * (1+ rate95/100))
#sum(df_premium_year1$premium)

write.csv(df_premium_year1_charge, file = "../TARIFCOM.csv") #écriture d'un fichier TARIFCOM.csv
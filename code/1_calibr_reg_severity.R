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

df_claims = read.csv("../data/14OURE-PG_2017_CLAIMS_YEAR0.csv")
df_year0 = read.csv("../data/14OURE-PG_2017_YEAR0.csv")
df_year1 = read.csv("../data/14OURE-PG_2017_YEAR1.csv")
df_regions = read.csv("../data/departements_francais.csv", sep = ";") %>% dplyr::select(NUMERO, REGION, "DENSITE..habitants.km2.")
df_year0 = df_year0 %>% mutate(NUMERO = substr(df_year0$pol_insee_code,1,2))
df_year0 = left_join(df_year0, df_regions, by = "NUMERO" )
df_year0$DENSITE..habitants.km2. <- as.numeric(gsub(",", ".", df_year0$DENSITE..habitants.km2.)) #convert density to numeric
names(df_year0)[names(df_year0)=="DENSITE..habitants.km2."] <- 'density'
df_claims_0 = df_claims[(df_claims$claim_amount >= 0),]


# create final merged df
df = left_join(df_year0, df_claims_0, by = c("id_policy")) %>%
  mutate(claim_nb = ifelse(is.na(claim_nb), 0, claim_nb), claim_amount=ifelse(is.na(claim_amount), 0, claim_amount)) 
df <-  df[df$claim_amount > 0,] #keep individuals claims for modelisation

amount_group <- function(df){
  df <-  df[df$claim_amount > 0,]
  df$drv_age1G <- cut(df$drv_age1, c(17, 2:8*10, 104))
  df$drv_age2G <- cut(df$drv_age1, c(17, 25, 45,104))
  df$vh_ageG <- cut(df$vh_age, c(0, 10, 25, 30, 100))#no vehicle with age 0, min value is 1 in the dataset
  df$vh_valueG = cut(df$vh_value, c(0, 8000, 15000, 22000, Inf), include.lowest = TRUE)
  df$vh_dinG = cut(df$vh_din, c(13, 50, 220, 555), include.lowest = TRUE)
  df$vh_makeG = ifelse(df$vh_make %in% c("RENAULT", "NISSAN", "CITROEN"), "A", 
                       ifelse(df$vh_make %in% c("VOLKSWAGEN", "AUDI", "SKODA", "SEAT"), "B",
                              ifelse(df$vh_make %in% c("OPEL", "GENERAL MOTORS", "FORD"), "C",
                                     ifelse(df$vh_make %in% c("FIAT"), "D",
                                            ifelse(df$vh_make %in% c("MERCEDES BENZ", "BMW", "CHRYSLER"), "E", "G")))))
  df$pol_bonusG = cut(df$pol_bonus, c(0.5, 0.9, 1.2, 1.4, 1.95), include.lowest = TRUE)
  df$pol_durationG = cut(df$pol_duration, c(1,10, 20,25,30, 42), include.lowest = TRUE)
  df$pol_coverageG = ifelse(df$pol_coverage %in% c("Median1", "Median2"), "Median", df$pol_coverage)
  
  u = 6000 
  su = sum(ifelse(df$claim_amount - u > 0, df$claim_amount - u, 0))/length(df$claim_amount) #charge surcrête moyenne
  df$surcrete = ifelse (df$claim_amount<u, df$claim_amount, u) + su
  return(df) 
}

perf_model <- function(model){
  print(as.character(substitute(model)))
  return(list("AIC"= AIC(model), "BIC"= BIC(model), "log-vraisemblance" = logLik(model), "Deviance" =model$deviance, "Null dev." = model$null.deviance))
}

reg.logn <- lm(formula = log(surcrete) ~ drv_age1 + vh_ageG + vh_dinG +
                 vh_type + pol_bonus + pol_durationG + pol_coverageG, data =amount_group(df))


reg.gamma <- glm(surcrete~ drv_age1 + vh_ageG + vh_dinG + vh_value+
                   vh_type + pol_bonus + pol_durationG + pol_coverageG ,family=Gamma(link="log"),data=amount_group(df))

reg.invgaus <- glm(formula = surcrete ~ drv_age1 + vh_ageG + vh_dinG + vh_value +
                     vh_type + pol_bonus + pol_durationG + pol_coverageG, family = inverse.gaussian(link = "log"), 
                   data = amount_group(df), start=coefficients(reg.gamma)) #1/mu^2

reg.loggamma <- glm(log(surcrete)~ drv_age1 + vh_ageG + vh_dinG + vh_value +
                      vh_type + pol_bonus + pol_durationG + pol_coverageG ,family=Gamma(link='identity'),data=amount_group(df))

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
df_regions = read.csv("../data/departements_francais.csv", sep = ";") %>% dplyr::select(NUMERO, REGION)
df_year0 = df_year0 %>% mutate(NUMERO = substr(df_year0$pol_insee_code,1,2))
df_year0 = left_join(df_year0, df_regions, by = "NUMERO" )
df_claims_0 = df_claims[df_claims$claim_amount > 0, ] %>% group_by(id_policy) %>% dplyr::summarise(claim_nb = n(), claim_amount = sum(claim_amount))

df = left_join(df_year0, df_claims_0, by = c("id_policy")) %>%
  mutate(claim_nb = ifelse(is.na(claim_nb), 0, claim_nb), claim_amount = ifelse(is.na(claim_amount), 0, claim_amount))

freq_group <- function(df){
  df$drv_age1G = cut(df$drv_age1, c(19, 4:18*5, 104), include.lowest = TRUE)
  df$vh_ageG = cut(df$vh_age, c(1, 1:12*5, 67), include.lowest = TRUE)
  df$pol_durationG = cut(df$pol_duration, c(1, 1:7*5, 42), include.lowest = TRUE)
  df$pol_bonusG = cut(df$pol_bonus, c( 5:16*(1/10), max(df$pol_bonus)), include.lowest = TRUE)
  df$vh_valueG = cut(df$vh_value, c(0, 6000, 10000, 15000, 20000, Inf), include.lowest = TRUE)
  df$vh_dinG = cut(df$vh_din, c(13, 50, 220, 290, 555), include.lowest = TRUE)
  df$pol_coverageG = ifelse(df$pol_coverage %in% c("Median1", "Median2"), "Median", df$pol_coverage)
  df$vh_makeG = ifelse(df$vh_make %in% c("RENAULT", "NISSAN", "CITROEN"), "A", 
                       ifelse(df$vh_make %in% c("VOLKSWAGEN", "AUDI", "SKODA", "SEAT"), "B",
                              ifelse(df$vh_make %in% c("OPEL", "GENERAL MOTORS", "FORD"), "C",
                                     ifelse(df$vh_make %in% c("FIAT"), "D",
                                            ifelse(df$vh_make %in% c("MERCEDES BENZ", "BMW", "CHRYSLER"), "E", "G")))))
  df$pol_usageG = ifelse(df$pol_usage == "Professional", "Professional", "Other")
  return(df)
}

fnb4 <-  glm(claim_nb ~  drv_age1G + vh_ageG + pol_durationG  + vh_valueG + vh_dinG
           + pol_bonusG + pol_coverageG + pol_usageG + vh_fuel, 
           family = negative.binomial(1/0.53477), data = freq_group(df))

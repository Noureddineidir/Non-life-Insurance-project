
df_claims = read.csv("../data/14OURE-PG_2017_CLAIMS_YEAR0.csv")
df_year0 = read.csv("../data/14OURE-PG_2017_YEAR0.csv")

df_claims_nb <- df_claims %>% group_by(id_policy) %>% dplyr::summarise(claim_nb = n()) %>%
  left_join(df_year0, df_claims_0, by = c("id_policy")) %>%
  mutate(claim_nb = ifelse(is.na(claim_nb), 0, claim_nb)) %>% dplyr::select(claim_nb)

df_claims_amount= df_claims[(df_claims$claim_amount >= 0),] %>% dplyr::select(claim_amount)

#### simulation de charge sinistre portefeuille non parametrique ####
rclaimnb <- function(n, mydata, var="ClaimNb")
{
  nbrow <- NROW(mydata)
  rclaimnb1 <- function()
  {
    rrow <- sample.int(nbrow, replace=TRUE)
    sum(mydata[rrow, var])
  }
  replicate(n, rclaimnb1())
}
#rclaimnb(5, df_claims_nb, var='claim_nb')


rclaimagg <- function(n, mydatanb, mydataamount, varnb="ClaimNb", varamount="ClaimAmount")
{
  nbrow <- NROW(mydataamount)
  ragg1 <- function(nbclaim)
  {
    rrow <- sample(nbrow, size=nbclaim, replace=TRUE)
    sum(mydataamount[rrow, varamount])
  }
  rnb <- rclaimnb(n, mydatanb, var=varnb)
  sapply(rnb, ragg1)
}
#essai
#rclaimagg(5, df_claims_nb, df_claims_amount, varnb = "claim_nb", varamount = "claim_amount")



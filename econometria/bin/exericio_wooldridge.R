# exercicio wooldridge

# analisar como a variavel dummy se comporta na funcao
# no caso, tanto faz se o dataframe esta ajustado para a dummy
# ou se ha apenas uma coluna factor com os niveis
# no caso do Wooldrige o dataframe continha as dummy tradicionais
# sendo y72 a base e y74, y76,y,78,y80,y82,y84 as demais.
# criei uma nova variavel 'years' com os anos
# resultado igual ao da dummy tradicional


# setup

library(wooldridge)
library(stargazer)
library(readxl)           # leitura de arquivos Excel
library(magrittr)         # pipe
library(tidyverse)        # manipulação de dados
library(janitor)          # organiza e limpa os cabeçalhos de data
library(lubridate)        # Simplifica trabalho com datas e horas
library(here)             # ajusta PATH
library(plm)              # modelos de regressao em panel data
library(stargazer)        # analise estatistica
library(performance)      # Analisa regressão
library(broom)            # Converte saídas de modelos estatísticos em tibbles
library(car)              # Companion to Applied Regression
library(DescTools)        # Windsorizar vetores
library(lmtest)           # Tests for linear regression models
library(sandwich)         # Robust covariance matrix estimators
library(nortest)          # Anderson-Darling Test for normality
library(dunn.test)        # Dunn's test for multiple comparisons
library(knitr)
library(kableExtra)

## clean workbench ----
rm(list = ls())


# get data
fertil <- wooldridge::fertil1
summary(fertil)

# model 1 (igual ao Wooldridge) ----
md1 <- lm(kids ~ 
            educ + 
            age + 
            agesq + 
            black + 
            east + 
            northcen + 
            west + 
            farm + 
            othrural + 
            town + 
            smcity + 
            y74 + 
            y76 + 
            y78 + 
            y80 + 
            y82 + 
            y84, 
          data = fertil
)
stargazer(md1, type = "text")
# OK, igual aos coeficientes do livro


# model 2 (com a variavel ´years´ como fator) ----
fertil.2 <- fertil

# cria a variavel ´years´ e preenche com os anos
fertil.2 <- fertil.2 %>%
  mutate(year = case_when(
    y74 == 1 ~ 1974,
    y76 == 1 ~ 1976,
    y78 == 1 ~ 1978,
    y80 == 1 ~ 1980,
    y82 == 1 ~ 1982,
    y84 == 1 ~ 1984,
    TRUE ~ 1972
  ))
# transforma a variavel ´years´ em factor
df$year <- factor(df$year)

summary(fertil.2)

# cria um pd
pdata.fertil.2 <- pdata.frame(fertil.2, index = c("year"))

# roda o modelo na funcao plm() no formato OLS POOLED (model = "pooling")
md2 <- plm(kids ~ 
             educ + 
             age + 
             agesq + 
             black + 
             east + 
             northcen + 
             west + 
             farm + 
             othrural + 
             town + 
             smcity + 
             year, 
           data = pdata.fertil.2, 
           model = "pooling"
)
stargazer(md2, type = "text")


# Testando se os coeficientes são iguais
md1$coefficients == md2$coefficients


# EXERCICIO crime

crime <- wooldridge::crime2
str(crime)
crime <- crime |> 
  mutate(across(c(year), as.factor))
str(crime)
pcrime <-  pdata.frame(crime, index = c("year"))
# Renomear a variável 'time' para 'individual'
pcrime <- pcrime  |>  rename(individual = time)


crime87 <- crime |> 
  filter(year == 87)

# estes dois são IGUAIS
ols <- lm(crmrte ~ unem, crime87)
summary(ols)
stargazer(ols, type = "text")

pooled.ols <- lm(crmrte ~ unem + year, crime)
summary(pooled.ols)
stargazer(pooled.ols, type = "text")

coeftest(pooled.ols, vcov = vcovHC(pooled.ols, type = "HC1"))    # robust; HC1 (Stata default)



pooled.ols <- plm(crmrte ~ 0 + unem, pcrime, model = "fd", effect = "individual")
summary(pooled.ols)
stargazer(pooled.ols, type = "text")


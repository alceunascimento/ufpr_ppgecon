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

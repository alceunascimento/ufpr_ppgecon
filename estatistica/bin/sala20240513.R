### UFPR PPGEcon Econometria 

# SETUP
library(tidyverse)
library(stargazer)

rm(list = ls())


# GET DATA
y <- c()
x <- c()


df0 <- read_csv("~/proj/ufpr_ppgecon/estatistica/data/df1.csv")
df <- read_csv("~/proj/ufpr_ppgecon/estatistica/data/df1.csv")
plot(df)


# LM manual

# obter a média de X
X_bar <- mean(df$renda)
# obter a média de Y
Y_bar <- mean(df$consumo)
# obter X centrado na média (x)
df$x <- df$renda - X_bar
# obter X^2
df$x2 <- (df$x)^2
# obter Y centrado na média (y)
df$y <- df$consumo - Y_bar
# obter produto xY
df$xY <- df$x*df$consumo
# obter a soma de xY e de x^2 
soma_x2 <- sum(df$x2)
soma_xY <- sum(df$xY)
# obter Beta
beta_estimado <- soma_xY/soma_x2
#obter Alpha
alpha_estimado <- Y_bar - (beta_estimado*X_bar)
# produzir tabela final com as variaveis incluidas e os valores de Alpha e Beta
df



# LM base R
modelo1 <- lm(consumo ~ renda, data=df0)
stargazer(modelo1, type="text")
predict(modelo1, se.fit = TRUE)
sum(modelo1$residuals)
plot(df0)
abline(modelo1)


plot(modelo1)


# exerc 1
rm(list = ls())
df1 <- read_csv("~/proj/ufpr_ppgecon/estatistica/data/exerc1.csv")

head(df1)


#1
plot(df1$depois ~ df1$antes)

#2(i)



#2(ii)
modelo1 <- lm(depois ~ antes, data = df1)
summary(modelo1)
plot(df1$depois ~ df1$antes)
abline(modelo1)

#3
sum(modelo1$residuals)
var(modelo1$residuals)
sd(modelo1$residuals)

#3a

#4
correlation::correlation(df1)

#5

#6

#7

#8
##############################################################################
######            Script basico de regressao linear simples
##############################################################################

# SETUP ----
install.packages(c("readxl","stargazer","broom","lmtest","modelsummary","performance","here", "tidyverse"))
library(readxl)                # Reads Microsoft Excel spreadsheets.
library(stargazer)             # analise estatistica
library(broom)                 # Convert statistical analysis objects into tidy data frames.
library(lmtest)                # Hypothesis testing for linear regression models.
library(modelsummary)          # faz um grafico de intervalo bom
library(performance)           # Analisa regressão 
library(here)                  # ajusta os caminhos de arquivos
library(tidyverse)             # manipulação de dados

#limpar mesa de trabalho
rm(list = ls())


# OBTER DADOS ----
caminho <- here("./estatistica/lm/exemplo_1.xls")
dados <- read_excel(caminho, sheet = "Plan1")


# MODELOS DE REGRESSAO LINEAR

# 1. CALCULANDO MANUALMENTE A REGRESSÃO ----

# Ajustando a matriz
Y <- dados$apos
X <- dados$antes
matriz <- tibble(Y = Y, X = X)
matriz

# obter a média de X
X_bar <- mean(matriz$X)

# obter a média de Y
Y_bar <- mean(matriz$Y)

# obter X centrado na média (x)
matriz$x <- matriz$X - X_bar

# obter X^2
matriz$x2 <- (matriz$x)^2

# obter Y centrado na média (y)
matriz$y <- matriz$Y - Y_bar

# obter produto xY
matriz$xY <- matriz$x * matriz$Y

# obter a soma de xY e de x^2 
soma_x2 <- sum(matriz$x2)
soma_xY <- sum(matriz$xY)

# obter Beta 1 (estimador de x)
beta_1 <- soma_xY / soma_x2

# obter Beta zero (intercepto)
beta_0 <- Y_bar - (beta_1 * X_bar)

# produzir tabela final com as variaveis incluidas e os valores de Alpha e Beta
matriz
beta_1
beta_0

# X estimado
fx <- function(x) { beta_0 + (beta_1) * x }
matriz$x_estimado <- fx(X)

# Erro do modelo
matriz$e <- Y - fx(X)
matriz
# soma dos erros
sum(matriz$e)
sum((matriz$e)^2)



# 2. CALCULANDO PELO R A REGRESSÃO ----

# Ajustando os ddos
Y <- dados$apos
X <- dados$antes
matriz <- tibble(Y = Y, X = X)
matriz

### Criando o modelo pela função lm() do pacote base do R
modelo1 <- lm(Y ~ X, data = matriz)

### Tabela com o pacote Stargazer::
stargazer(modelo1, type = "text", digits = 3, report = "vcstp")

# checando o modelo com o pacote performance::
check_autocorrelation(modelo1)
check_collinearity(modelo1)
check_normality(modelo1)
check_heteroscedasticity(modelo1)
check_model(modelo1)










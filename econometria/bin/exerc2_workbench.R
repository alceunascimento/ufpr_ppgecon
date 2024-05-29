## EXERCICIO 02

# SETUP ----
## base ----
library(writexl)               # Salva as tabelas elaboradas em formato .xls
library(readxl)                # Reads Microsoft Excel spreadsheets.
library(knitr)
library(kableExtra)
library(readr)                 # A fast and friendly way to read tabular data into R.
library(MASS)                  # visualiza decimal em fracoes
library(xtable)                # transforma tabela Excel para Latex
library(ggplot2)               # graficos
library(gridExtra)
library(grid)                  # Para configurações adicionais de grid
library(here)
library(xtable)
## data manipulation ----
library(tidyverse)             # Inclui dplyr, forcats, ggplto2, lubridate, purrr, stringr, tibble, tidyr
library(broom)                 # Converte saídas de modelos estatísticos em tibbles
library(dbplyr)                # Interface dplyr para bancos de dados
library(lubridate)             # Simplifica trabalho com datas e horas
library(janitor)
## statistics ----
library(stargazer)             # analise estatistica
library(skimr)                 # Compact and flexible summaries of data, a frictionless, pipeable approach to dealing with summary statistic
library(broom)                 # Convert statistical analysis objects into tidy data frames.
library(lmtest)                # Hypothesis testing for linear regression models.
library(modelsummary)          # faz um grafico de intervalo bom
library(strucchange)           # analisar quebras estruturais (Chow Test)
library(mctest)                # teste para multicolinearidad
library(performance)           # Analisa regressão 
library(broom)                 # takes the messy output of built-in functions in R, such as lm, nls, or t.test, and turns them into tidy tibbles.
library(Hmisc)
library(pastecs)
library(nortest)               # Anderson-Darling Test for normality


# clean workbench ----
rm(list = ls())


# GET DATA ----
df <- read_xlsx(here("econometria/data/Base_2024.xlsx"))
glimpse(df)



# WRANGLING DATA ----

variables <- names(df)
kableExtra::kable(variables)

# Converter a coluna "corporategovernancelevel" para factor
df$corporategovernancelevel <- as.factor(df$corporategovernancelevel)
levels(df$corporategovernancelevel)
glimpse(df)
str(df)

md.pattern(df)

# ANALIZING DATA ----

# Regressão múltipla removendo automaticamente linhas com NA (método casewise deletion)
modelo <- lm(y ~ x1 + x2 + x3, data = df, na.action = na.omit)
summary(modelo)



# REPORTS ----




# Criar o histograma da variável 'alavancagem'
ggplot(df, aes(x = alavancagem)) +
  geom_histogram(binwidth = 1000, fill = "blue", color = "black", alpha = 0.7) +
  labs(title = "Distribuição da Alavancagem", x = "Alavancagem", y = "Frequência") +
  theme_minimal()

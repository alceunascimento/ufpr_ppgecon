###############################################################################
######                 PANEL DATA ANALYSIS                              #######
###############################################################################

# 1. SETUP ----
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

# clean workbench
rm(list = ls())

# 2. GET DATA ----
df.raw <- read_xlsx(here("econometria/data/base_2024.xlsx"))


# 3. WRANGLING DATA ----

# Select variables ----
df <- df.raw |> 
  select(companyname, 
         setor_economia,
         corporate_governance_level,
         total_asset,
         permanent_asset,
         short_term_debt,
         long_term_debt,
         patrimonio_liquido,
         ebit,
         net_profit,
         firm_market_value,
         quarter,
         year)

## Cleaning ----

## Se o YEAR is NA, excluir
df <- df %>%
  filter(!is.na(year))

## Excluir o ano de 2014 pois só tem o 1º trimestre
df <- df %>%
  filter(year != 2014)

## Excluir os trimestres intermediarios 1 a 3
df <- df |> 
  filter(quarter == 4) |> 
  select(-quarter)


# Excluir dados ausentes da variavel governanca
df <- df |> 
  filter(corporate_governance_level != "NDISPO")

# Excluir dados sem valor de `equity`
df <- df |> 
  filter(patrimonio_liquido != 0)

# Excluir empresas financeiras
df <- df |> 
  filter(setor_economia != "Finanças e Seguros")


# Trimming ----
# Função para identificar observações com valores extremos e excluir estas observações
exclude_extreme_values <- function(data, variables, probs = c(0.05, 0.95)) {
  extreme_indices <- sapply(variables, function(var) {
    x <- data[[var]]
    lower_bound <- quantile(x, probs[1], na.rm = TRUE)
    upper_bound <- quantile(x, probs[2], na.rm = TRUE)
    (x < lower_bound | x > upper_bound) & !is.na(x)
  })
  # Combina as condições de todas as variáveis para identificar linhas extremas
  extreme_rows <- apply(extreme_indices, 1, any)
  return(data[!extreme_rows, ])
}

# Lista de variáveis para verificar valores extremos
variables_to_check <- c(
  "total_asset",
  "permanent_asset",
  "short_term_debt",
  "long_term_debt",
  "patrimonio_liquido",
  "ebit",
  "net_profit",
  "firm_market_value"
)
# Aplicar a função para excluir observações com valores extremos
df_trimmed <- exclude_extreme_values(df, variables_to_check)
# Comparação de tamanho do dataframe original e do dataframe limpo
cat("Tamanho do dataframe original:", nrow(df), "\n")
cat("Tamanho do dataframe após exclusão de valores extremos:", nrow(df_trimmed), "\n")




## Create new variables ----
df <- df_trimmed  |> 
  mutate(
    alavancagem = (short_term_debt + long_term_debt) / patrimonio_liquido,
    imobilizacao = (permanent_asset / total_asset),  
    roa = (net_profit / total_asset),
    qtobin = (firm_market_value / total_asset),
    bep = (ebit / total_asset),
    log_size = log(total_asset)
  )

# Verificar a estrutura dos dados limpos
str(df)
summary(df)

# Transformar em factor
df <- df |> 
  mutate(across(c(setor_economia, corporate_governance_level, year), as.factor))

# Verificar a estrutura dos dados limpos
str(df)
summary(df)
plot(df)

# 5. MODELS ----

modelo <- alavancagem ~ 
  corporate_governance_level +
  log_size + 
  imobilizacao +
  roa + 
  qtobin + 
  bep +
  year

ols <- lm(modelo, df, na.action = na.omit)
stargazer(ols, type = "text")
#stargazer(modelo_lm, type = "html", out = "modelos.html", report = "vcstp*")



# Pooled OLS ----
# Creating a pdata.frame
pdata <- pdata.frame(df, index = c("companyname", "year"))
# Verificar os índices do pdata.frame
str(pdata)
summary(pdata)
# check if balanced
pdata |> is.pbalanced()
# Identificar combinações duplicadas
head(table(index(pdata), useNA = "ifany"))
# Esta aqui é IGUAL ao lm()
pooled.ols <- plm(modelo, data = pdata, model = "pooling")
stargazer(pooled.ols, type = "text")


# Fixed effect
md.fixed.effect <- plm(modelo, data = pdata, model = "within")
stargazer(md.fixed.effect, type = "text")

# 7. REPORTS ----

# 8. PLOTS ----


# Plotar a relação entre 'alavancagem' e cada uma das outras variáveis individualmente

# Criar um novo data frame com 'alavancagem' e as demais variáveis
df_plot <- df %>% select(alavancagem, log_size, imobilizacao, roa, qtobin, bep)

# Relação entre alavancagem e log_size
plot(df$log_size, df$alavancagem, 
     xlab = "log_size", ylab = "alavancagem",
     main = "Relação entre alavancagem e log_size",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ log_size, data = df), col = "red")

# Relação entre alavancagem e imobilizacao
plot(df$imobilizacao, df$alavancagem, 
     xlab = "imobilizacao", ylab = "alavancagem",
     main = "Relação entre alavancagem e imobilizacao",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ imobilizacao, data = df), col = "red")

# Relação entre alavancagem e roa
plot(df$roa, df$alavancagem, 
     xlab = "roa", ylab = "alavancagem",
     main = "Relação entre alavancagem e roa",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ roa, data = df), col = "red")

# Relação entre alavancagem e qtobin
plot(df$qtobin, df$alavancagem, 
     xlab = "qtobin", ylab = "alavancagem",
     main = "Relação entre alavancagem e qtobin",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ qtobin, data = df), col = "red")

# Relação entre alavancagem e bep
plot(df$bep, df$alavancagem, 
     xlab = "bep", ylab = "alavancagem",
     main = "Relação entre alavancagem e bep",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ bep, data = df), col = "red")


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

# Excluir dados ausentes da variavel governanca
df <- df |> 
  filter(corporate_governance_level != "NDISPO")

# Excluir dados sem valor de `equity`
df <- df |> 
  filter(patrimonio_liquido != 0)

# Excluir empresas financeiras
df <- df |> 
  filter(setor_economia != "Finanças e Seguros")


# Windsorize ----
# Lista de variáveis para winsorizar
variables_to_winsorize <- c(
  "total_asset",
  "permanent_asset",
  "short_term_debt",
  "long_term_debt",
  "patrimonio_liquido",
  "ebit",
  "net_profit",
  "firm_market_value"
)

# Função para winsorizar as variáveis especificadas, preservando NAs
winsorize_preserve_na <- function(x, probs = c(0.05, 0.95)) {
  na_indices <- is.na(x)
  x_non_na <- x[!na_indices]
  x_winsorized <- Winsorize(x_non_na, probs = probs)
  x[!na_indices] <- x_winsorized
  return(x)
}

# Função para winsorizar as variáveis do dataframe
winsorize_dataframe <- function(data, variables, probs = c(0.05, 0.95)) {
  for (var in variables) {
    data[[var]] <- winsorize_preserve_na(data[[var]], probs = probs)
  }
  return(data)
}

# Aplicar a winsorização ao dataframe `df`
df_winsorized <- winsorize_dataframe(df, variables_to_winsorize)

# Comparação entre o dataframe original e o dataframe windsorizado
comparison <- cbind(
  original = as.vector(t(df)),
  windsorized = as.vector(t(df_winsorized))
)
comparison <- data.frame(
  variable = rep(names(df), each = nrow(df)),
  original = as.vector(t(df)),
  windsorized = as.vector(t(df_winsorized))
)

# Exibir a comparação
print(comparison)

# Exibir os dataframes para conferência visual
print("Dataframe Original:")
print(df)
print("Dataframe Windsorizado:")
print(df_winsorized)











## Create new variables ----
df <- df  |> 
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
  mutate(across(c(setor_economia, corporate_governance_level), as.factor))

# Verificar a estrutura dos dados limpos
str(df)
summary(df)


# Criar data frames para cada ano contendo apenas o quarto trimestre ----
anos <- unique(df$year)
for (ano in anos) {
  assign(paste0("df", ano), df |>  
    filter(year == ano & quarter == "4") |>  
    select(-quarter, -year))
}




# 5. MODELS ----

modelo <- alavancagem ~ 
  corporate_governance_level +
  log_size + 
  imobilizacao +
  roa + 
  qtobin + 
  bep

# Executar a regressão linear regressão linear para cada ano
modelos <- list()

for (ano in anos) {
  df <- get(paste0("df", ano))
  
  # Verificar se há dados suficientes para ajustar o modelo
  if (nrow(df) > 0) {
    modelo_lm <- try(lm(modelo, data = df, na.action = na.exclude), silent = TRUE)
    if (inherits(modelo_lm, "lm")) {
      modelos[[as.character(ano)]] <- modelo_lm
    } else {
      message(paste("Erro ao ajustar o modelo para o ano", ano))
    }
  } else {
    message(paste("Dados insuficientes para ajustar o modelo para o ano", ano))
  }
}

# Exibir os sumários dos modelos ajustados usando stargazer
if (length(modelos) > 0) {
  stargazer(modelos, type = "html", out = "modelos.html", report = "vcstp*")
} else {
  message("Nenhum modelo ajustado disponível para exibição.")
}

# 7. REPORTS ----

# 8. PLOTS ----


# Plotar a relação entre 'alavancagem' e cada uma das outras variáveis individualmente

# Criar um novo data frame com 'alavancagem' e as demais variáveis
df_plot <- df %>% select(alavancagem, log_size, imobilizacao, roa, qtobin, bep)


for (var in colnames(df_plot)[-1]) { # Ignora a primeira coluna 'alavancagem'
  plot(df_plot[[var]], df_plot$alavancagem,
       xlab = var, ylab = "alavancagem",
       main = paste("Relação entre alavancagem e", var),
       pch = 21, bg = "blue")
}

# Relação entre alavancagem e log_size
plot(df$log_size, df$alavancagem, 
     xlab = "log_size", ylab = "alavancagem",
     main = "Relação entre alavancagem e log_size",
     pch = 21, bg = "blue")

# Relação entre alavancagem e imobilizacao
plot(df$imobilizacao, df$alavancagem, 
     xlab = "imobilizacao", ylab = "alavancagem",
     main = "Relação entre alavancagem e imobilizacao",
     pch = 21, bg = "blue")

# Relação entre alavancagem e roa
plot(df$roa, df$alavancagem, 
     xlab = "roa", ylab = "alavancagem",
     main = "Relação entre alavancagem e roa",
     pch = 21, bg = "blue")

# Relação entre alavancagem e qtobin
plot(df$qtobin, df$alavancagem, 
     xlab = "qtobin", ylab = "alavancagem",
     main = "Relação entre alavancagem e qtobin",
     pch = 21, bg = "blue")

# Relação entre alavancagem e bep
plot(df$bep, df$alavancagem, 
     xlab = "bep", ylab = "alavancagem",
     main = "Relação entre alavancagem e bep",
     pch = 21, bg = "blue")


# Criar um novo data frame com 'alavancagem' e as demais variáveis
df_plot <- df %>% select(alavancagem, log_size, imobilizacao, roa, qtobin, bep)

# Plotar a relação entre 'alavancagem' e cada uma das outras variáveis individualmente
for (var in colnames(df_plot)[-1]) { # Ignora a primeira coluna 'alavancagem'
  plot(df_plot[[var]], df_plot$alavancagem,
       xlab = var, ylab = "alavancagem",
       main = paste("Relação entre alavancagem e", var),
       pch = 21, bg = "blue")
  abline(lm(df_plot$alavancagem ~ df_plot[[var]]), col = "red") # Adiciona a linha de regressão
}

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


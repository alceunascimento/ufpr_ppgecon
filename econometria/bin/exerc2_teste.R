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
library(car)


# clean workbench
rm(list = ls())

options(max.print = 10000)

# 2. GET DATA ----
df.raw <- read_xlsx(here("econometria/data/base_2024.xlsx"))


# 3. WRANGLING DATA ----

# Get variables
df <- df.raw |> 
  select(companyname, 
         setor_economia,
         corporate_governance_level,
         total_asset,
         permanent_asset,
         short_term_debt,
         long_term_debt,
         equity,
         ebit,
         net_profit,
         firm_market_value,
         quarter,
         year
  )

# Cleaning

## Se o YEAR is NA, excluir
any(is.na(df$year))
df <- df %>%
  filter(!is.na(year))
any(is.na(df$year))

## Excluir o ano de 2014 pois só tem o 1º trimestre
df <- df %>%
  filter(year != 2014)

# Excluir dados ausentes da variavel governanca
df <- df |> 
  filter(corporate_governance_level != "NDISPO")

# Verificar a estrutura dos dados limpos
str(df)
summary(df)


# Converter as variáveis 'quarter' "setor_economia' e 'corporate_governance_level' em factor (para uso como dummy)
df <- df  |> 
  mutate(quarter = factor(quarter, levels = c(1, 2, 3, 4), labels = c("Q1", "Q2", "Q3", "Q4"))) |> 
  mutate(setor_economia = factor(setor_economia)) |> 
  mutate(corporate_governance_level = factor(corporate_governance_level))

# Verificar a estrutura dos dados limpos
str(df)
summary(df)


## Create new variables
df <- df  |> 
  mutate(
    alavancagem = (short_term_debt + long_term_debt) / equity,
    imobilizacao = (permanent_asset / total_asset),  
    roa = (net_profit / total_asset),
    qtobin = (firm_market_value / total_asset),
    bep = (ebit / total_asset),
    log_size = log(total_asset)
)

# Verificar a estrutura dos dados limpos
str(df)
summary(df)




# 4. Creating a pdata.frame ----
pdata <- pdata.frame(df, index = c("companyname", "year", "quarter"))

# Verificar os índices do pdata.frame
str(pdata)
summary(pdata)

# check if balanced
pdata |> is.pbalanced()

# Identificar combinações duplicadas
head(table(index(pdata), useNA = "ifany"))






# 5. MODELS ----

# model
modelo <- alavancagem ~ 
  corporate_governance_level + 
  log_size + 
  imobilizacao +
  roa + 
  qtobin + 
  bep +
  year +
  quarter



# Regressão linear padrão, sem considerar panel data
lm1 <- lm(modelo, data = df)
stargazer(lm1, type = "text")



pooled.ols <- plm(modelo, data = pdata, model = "pooling")
stargazer(ols.plm, type = "text")



ols.plm <- plm(update(modelo,.~.+ year), data = pdata, model = "pooling", na.action = na.omit)
summary(ols.plm)

# 6. CHECK MODELS ----

# Calcular VIF para verificar colinearidade
vif_model <- lm(modelo, data = pdata)
vif(vif_model)


# 7. REPORTS ----


# 8. PLOTS ----
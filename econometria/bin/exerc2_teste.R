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



# 2. GET DATA ----
df.raw <- read_xlsx(here("econometria/data/base_2024.xlsx"))

# 3. WRANGLING DATA ----

# Get variables
df <- df.raw |> 
  select(companyname, 
         corporate_governance_level,
         total_asset,
         permanent_asset,
         passivo_pl,
         short_term_debt,
         long_term_debt,
         net_profit,
         ebit,
         firm_market_value,
         setor_economia,
         quarter,
         year
  )

# Cleaning NAs



## Se o YEAR is NA, excluir
any(is.na(df$year))
df <- df %>%
  filter(!is.na(year))
any(is.na(df$year))

## Excluir o ano de 2014 pois só tem o 1º trimestre
df <- df %>%
  filter(year != 2014)


# Excluir setores da economia
df <- df |> 
  filter(setor_economia != "Finanças e Seguros")


df <- df %>%
  filter(complete.cases(.))

# Verificar a estrutura dos dados limpos
str(df)
summary(df)







# Converter a variável 'quarter' em um fator (para uso como dummy)
df <- df  |> 
  mutate(quarter = factor(quarter, levels = c(1, 2, 3, 4), labels = c("Q1", "Q2", "Q3", "Q4")))


## Create new variables
df <- df  |> 
  mutate(
    alavancagem = passivo_pl,
    imobilizacao = (permanent_asset / total_asset),  
    roa = (net_profit / total_asset),
    qtobin = (short_term_debt + long_term_debt + firm_market_value) / total_asset,
    bep = (ebit / total_asset),
    log_total_asset = log(total_asset)
  )


# 3. Creating a pdata.frame
pdata <- pdata.frame(df, index = c("companyname", "year", "quarter"))

# Verificar os índices do pdata.frame
str(pdata)
summary(pdata)


## 3.1. checking erros
# Identificar combinações duplicadas
table(index(pdata), useNA = "ifany")


# Verificar se há valores NA nas variáveis do modelo
NAs <- sapply(variaveis_modelo, function(var) sum(is.na(pdata[[var]])))
NAs






# 4. MODEL DATA ----

# model
modelo <- alavancagem ~ corporate_governance_level + 
  roa + 
  log_total_asset + 
  imobilizacao +
  qtobin + 
  bep


ols.plm <- plm(modelo, data = pdata, model = "pooling")
summary(ols.plm)

ols.plm <- plm(update(modelo,.~.+ year), data = pdata, model = "pooling")
summary(ols.plm)


# 5. REPORTS ----

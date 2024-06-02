# PANEL DATA ANALYSIS                          ################################
# (Pooled OLS : panel data analysis )      ################################


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
library(lmtest)           # Tests for linear regression models
library(sandwich)         # Robust covariance matrix estimators
library(nortest)          # Anderson-Darling Test for normality
library(dunn.test)        # Dunn's test for multiple comparisons
library(knitr)
library(kableExtra)

## clean workbench ----
rm(list = ls())

# 2. GET DATA ----
df.raw <- read_xlsx(here("econometria/data/base_2024.xlsx"))


# 3. WRANGLING DATA ----

## Select variables ----
df <- df.raw |> 
  select(year,
         quarter,
         companyname, 
         setor_economia,
         corporate_governance_level,
         total_asset,
         permanent_asset,
         short_term_debt,
         long_term_debt,
         patrimonio_liquido,
         ebit,
         net_profit,
         firm_market_value
)

## Cleaning ----

## Se o YEAR is NA, excluir
df <- df %>%
  filter(!is.na(year))

## Excluir o ano de 2014 pois só tem o 1º trimestre
df <- df %>%
  filter(year != 2014)

# Excluir dados ausentes da variavel governanca
df <- df |> 
  filter(corporate_governance_level != "NDISPO") |> 
  filter(corporate_governance_level != "N1") |> 
  filter(corporate_governance_level != "N2") |> 
  filter(corporate_governance_level != "BOV+")

# Excluir dados sem valor de `patrimonio_liquido`
df <- df |> 
  filter(patrimonio_liquido != 0)

# Excluir empresas financeiras
df <- df |> 
  filter(setor_economia != "Finanças e Seguros")


# Excluir observações onde tanto `short_term_debt` quanto `long_term_debt` são NA
df <- df[!(is.na(df$short_term_debt) & is.na(df$long_term_debt)), ]

# Substituir NAs por zero nas variáveis `short_term_debt` e `long_term_debt`
df$short_term_debt[is.na(df$short_term_debt)] <- 0
df$long_term_debt[is.na(df$long_term_debt)] <- 0


## Trimming ----
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
df <- exclude_extreme_values(df, variables_to_check)


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





## Transformar em factor ----
df <- df |> 
  mutate(across(c(setor_economia, corporate_governance_level, year, quarter), as.factor))


## Organize variables ----
df <- df |> 
  select(year,
         quarter,
         companyname, 
         setor_economia,
         alavancagem,
         corporate_governance_level,
         imobilizacao,
         roa,
         qtobin,
         bep,
         log_size,
         total_asset
  )


# Comparação de tamanho do dataframe original e do dataframe limpo
cat("Tamanho do dataframe original:", nrow(df.raw), "\n")
cat("Tamanho do dataframe após limpeza:", nrow(df), "\n")


# Verificar a estrutura dos dados limpos
str(df)
summary(df)


# 4. CREATE pdata.frame ----

pdata <- pdata.frame(df, index = c("companyname", "year", "quarter"))

# Verificar os índices do pdata.frame
str(pdata)
summary(pdata)

# check if balanced
pdata |> is.pbalanced()

# Identificar combinações duplicadas
head(table(index(pdata), useNA = "ifany"))


## Criar lags das variáveis independentes ----
pdata$lag_corporate_governance_level <- lag(pdata$corporate_governance_level, k = 1)
pdata$lag_imobilizacao <- lag(pdata$imobilizacao, k = 1)
pdata$lag_roa <- lag(pdata$roa, k = 1)
pdata$lag_qtobin <- lag(pdata$qtobin, k = 1)
pdata$lag_bep <- lag(pdata$bep, k = 1)
pdata$lag_log_size <- lag(pdata$log_size, k = 1)
pdata$lag_total_asset <- lag(pdata$total_asset, k = 1)


# 5. OBSERVE DATA ----

## Plots ----

# Criar um novo data frame com 'alavancagem' e as demais variáveis
df_plot <- df |> 
  select(alavancagem, corporate_governance_level, log_size, imobilizacao, roa, qtobin, bep)
plot(df_plot)


# Criar um histograma suave (density plot) para cada ano
ggplot(df, aes(x = log(alavancagem), color = factor(year), fill = factor(year))) +
  geom_density(alpha = 0.15) +
  scale_color_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Distribuição de Frequência da Alavancagem por Ano",
       x = "Alavancagem",
       y = "Densidade",
       color = "Ano",
       fill = "Ano") +
  theme_bw() +
  theme(legend.position = "bottom")


# Criar um histograma suave (density plot) para cada segmento de governança
ggplot(df, aes(x = log(alavancagem), color = factor(corporate_governance_level), fill = factor(corporate_governance_level))) +
  geom_density(alpha = 0.15) +
  scale_color_brewer(palette = "Set1") +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Distribuição de Frequência da Alavancagem por Segmento de Governança",
       x = "Alavancagem",
       y = "Densidade",
       color = "Governança",
       fill = "Governança") +
  theme_bw() +
  theme(legend.position = "bottom")



# Relação entre alavancagem e corporate_govenance_level
plot(df$corporate_governance_level, df$alavancagem, 
     xlab = "corporate_governance_level", ylab = "alavancagem",
     main = "Relação entre alavancagem e log_size",
     pch = 21, bg = "blue")
abline(lm(alavancagem ~ log_size, data = df), col = "red")

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



## Medias e Medianas ----
# Função para calcular resumos estatísticos
calculate_summary <- function(group_data) {
  summary_stats <- (summary(group_data$alavancagem))
  return(summary_stats)
}

# Aplicar a função a cada nível de corporate_governance_level e construir o dataframe
summary_table <- df %>%
  group_by(corporate_governance_level) %>%
  summarise(
    Min = min(alavancagem, na.rm = TRUE),
    `1st Qu.` = quantile(alavancagem, 0.25, na.rm = TRUE),
    Median = median(alavancagem, na.rm = TRUE),
    Mean = mean(alavancagem, na.rm = TRUE),
    `3rd Qu.` = quantile(alavancagem, 0.75, na.rm = TRUE),
    Max = max(alavancagem, na.rm = TRUE)
  ) %>%
  rename(Group = corporate_governance_level)
# Exibir a tabela formatada usando kable
kable(summary_table, caption = "Resumos Estatísticos de Alavancagem por Segmento de Governança")
# Realizar a ANOVA
anova_result <- aov(alavancagem ~ corporate_governance_level, data = df)
anova_table <- tidy(anova_result)
kable(anova_table, caption = "Tabela de ANOVA")
anova_summary <- summary(anova_result)
# Se a ANOVA for significativa, realizar o teste post-hoc de Tukey
if (anova_summary[[1]]$`Pr(>F)`[1] < 0.05) {
  tukey_result <- TukeyHSD(anova_result)
  print(tukey_result)
} else {
  cat("As diferenças entre as médias dos grupos não são estatisticamente significativas.\n")
}
# Realizar o teste de Kruskal-Wallis
kruskal_result <- kruskal.test(alavancagem ~ corporate_governance_level, data = df)
# Se o teste de Kruskal-Wallis for significativo, realizar o teste post-hoc de Dunn
if (kruskal_result$p.value < 0.05) {
  dunn_result <- dunn.test(df$alavancagem, df$corporate_governance_level, method = "bonferroni")
  print(dunn_result)
} else {
  cat("As diferenças entre as medianas dos grupos não são estatisticamente significativas.\n")
}
print(kruskal_result)



# Aplicar a função a cada nível de ano e construir o dataframe
summary_table <- df %>%
  group_by(year) %>%
  summarise(
    Min = min(alavancagem, na.rm = TRUE),
    `1st Qu.` = quantile(alavancagem, 0.25, na.rm = TRUE),
    Median = median(alavancagem, na.rm = TRUE),
    Mean = mean(alavancagem, na.rm = TRUE),
    `3rd Qu.` = quantile(alavancagem, 0.75, na.rm = TRUE),
    Max = max(alavancagem, na.rm = TRUE)
  ) %>%
  rename(Group = year)

# Exibir a tabela formatada usando kable
kable(summary_table, caption = "Resumos Estatísticos de Alavancagem por Ano")

# Realizar a ANOVA
anova_result <- aov(alavancagem ~ year, data = df)
# Resumo da ANOVA
anova_table <- tidy(anova_result)
kable(anova_table, caption = "Tabela de ANOVA")
anova_summary <- summary(anova_result)

# Se a ANOVA for significativa, realizar o teste post-hoc de Tukey
if (anova_summary[[1]]$`Pr(>F)`[1] < 0.05) {
  tukey_result <- TukeyHSD(anova_result)
  print(tukey_result)
} else {
  cat("As diferenças entre as médias dos grupos não são estatisticamente significativas.\n")
}




# 6. MODELS ----

## model 1 ----
model.years <- alavancagem ~ 
  lag_corporate_governance_level +
  lag_imobilizacao +
  lag_roa + 
  lag_qtobin + 
  lag_bep +
  lag_roa +
  lag_log_size +
  year

## model 2 ----
model.quarter <- alavancagem ~ 
  lag_corporate_governance_level +
  lag_imobilizacao +
  lag_roa + 
  lag_qtobin + 
  lag_bep +
  lag_roa +
  lag_log_size +
  quarter

## model 3 ----
model.sectors <- alavancagem ~ 
  lag_corporate_governance_level +
  lag_imobilizacao +
  lag_roa + 
  lag_qtobin + 
  lag_bep +
  lag_roa +
  lag_log_size +
  setor_economia



## Pooled OLS ----
pooled.ols.years <- plm(model.years, data = pdata, model = "pooling")
pooled.ols.quarter <- plm(model.quarter, data = pdata, model = "pooling")
pooled.ols.sectors <- plm(model.sectors, data = pdata, model = "pooling")

# 6. CHECK MODELS ----
stargazer(pooled.ols.years, pooled.ols.quarter, pooled.ols.sectors, type = "html", report = "vcsp*", out = "./econometria/exerc2_pooledols.html")
stargazer(pooled.ols.years, pooled.ols.quarter, pooled.ols.sectors, type = "text", report = "vcsp*")

## Robustness ----
# In R the function coeftest from the lmtest package can be used in combination 
# with the function vcovHC from the sandwich package to do this.
# The first argument of the coeftest function contains the output of the 
# lm function and calculates the t test based on the variance-covariance matrix 
# provided in the vcov argument. 
# The vcovHC function produces that matrix and allows to obtain several types of
# heteroskedasticity robust versions of it. In our case we obtain a simple 
# White standard error, which is indicated by type = "HC0" and the 
# Stata vce(robust) é "HC1"

# Robust t test of SE (vce(robust) option do Stata)
# check that "sandwich" returns HC0
coeftest(pooled.ols.years, vcov = vcovHC(pooled.ols.years, type = "HC0"))    # robust; HC0 
# check that the default robust var-cov matrix is HC3
coeftest(pooled.ols.years, vcov = vcovHC(pooled.ols.years, type = "HC3"))    # robust; HC3 (default)
# reproduce the Stata default
coeftest(pooled.ols.years, vcov = vcovHC(pooled.ols.years, type = "HC1"))    # robust; HC1 (Stata default)


# Calcular VIF para verificar colinearidade
vif_model <- lm(pooled.ols.years, data = pdata)
vif(vif_model)


performance::check_autocorrelation(pooled.ols.years)
performance::check_heteroskedasticity(pooled.ols.years)
performance::check_collinearity(pooled.ols.years)
performance::check_distribution(pooled.ols.years)
performance::check_model(pooled.ols.years)




# PLOTS ----
densityPlot(pooled.ols.years$residuals)

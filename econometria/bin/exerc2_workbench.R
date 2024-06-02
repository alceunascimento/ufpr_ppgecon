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
library(dunn.test)

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







md.test <- alavancagem ~ 
  corporate_governance_level +
  log_size + 
  imobilizacao +
  roa + 
  qtobin + 
  bep

ols.md.test <- lm(md.test, df)
ols.md.test
summary(ols.md.test)
tidy(ols.md.test)
glance(ols.md.test)
augment(ols.md.test)
# Plot the model 
# Rsiidual vs Fitteted, Normal Q-Q, scale-location, etc
plot(ols.md.test)
# Plot residuals against the fitted values
residualPlots(ols.md.test)
densityPlot(ols.md.test$residuals)
# Perform anova on the model
anova(ols.md.test)
# Plot partial regression plots for the variables in the model
par(mfrow=c(2,2))
plot(ols.md.test, which=c(1,2,3,4,5))



performance::check_model(ols.md.test)

performance::check_autocorrelation(ols.md.test)
performance::check_heteroskedasticity(ols.md.test)
performance::check_outliers(ols.md.test)
performance::check_collinearity(ols.md.test)
performance::check_distribution(ols.md.test)
performance::check_residuals(ols.md.test)
performance::check_normality(ols.md.test)
performance::check_posterior_predictions(ols.md.test)
performance::check_predictions(ols.md.test)
performance::print_md(ols.md.test)





alavancagem.reg <- df |> 
  filter(corporate_governance_level == "REG")
alavancagem.nm <- df |> 
  filter(corporate_governance_level == "NM")
alavancagem.n1 <- df |> 
  filter(corporate_governance_level == "N1")
alavancagem.n2 <- df |> 
  filter(corporate_governance_level == "N2")
alavancagem.bov <- df |> 
  filter(corporate_governance_level == "BOV+")

summary(alavancagem.reg$alavancagem)
summary(alavancagem.nm$alavancagem)
summary(alavancagem.n1$alavancagem)
summary(alavancagem.n2$alavancagem)
summary(alavancagem.bov$alavancagem)


# Obter os resumos estatísticos e transformar em vetores numéricos
summary_reg <- as.numeric(summary(alavancagem.reg$alavancagem))
summary_nm <- as.numeric(summary(alavancagem.nm$alavancagem))
summary_n1 <- as.numeric(summary(alavancagem.n1$alavancagem))
summary_n2 <- as.numeric(summary(alavancagem.n2$alavancagem))
summary_bov <- as.numeric(summary(alavancagem.bov$alavancagem))

# Combinar os resumos estatísticos em um dataframe
summary_table <- data.frame(
  Group = c("REG", "NM", "N1", "N2", "BOV"),
  Min = c(summary_reg[1], summary_nm[1], summary_n1[1], summary_n2[1], summary_bov[1]),
  `1st Qu.` = c(summary_reg[2], summary_nm[2], summary_n1[2], summary_n2[2], summary_bov[2]),
  Median = c(summary_reg[3], summary_nm[3], summary_n1[3], summary_n2[3], summary_bov[3]),
  Mean = c(summary_reg[4], summary_nm[4], summary_n1[4], summary_n2[4], summary_bov[4]),
  `3rd Qu.` = c(summary_reg[5], summary_nm[5], summary_n1[5], summary_n2[5], summary_bov[5]),
  Max = c(summary_reg[6], summary_nm[6], summary_n1[6], summary_n2[6], summary_bov[6])
)

# Exibir a tabela formatada usando kable
kable(summary_table, caption = "Resumos Estatísticos de Alavancagem", col.names = c("Group", "Min.", "1st Qu.", "Median", "Mean", "3rd Qu.", "Max."))



# Realizar a ANOVA
anova_result <- aov(alavancagem ~ corporate_governance_level, data = df)

# Resumo da ANOVA
anova_table <- tidy(anova_result)
kable(anova_table, caption = "Tabela de ANOVA")


# Se a ANOVA for significativa, realizar o teste post-hoc de Tukey
if (anova_summary[[1]]$`Pr(>F)`[1] < 0.05) {
  tukey_result <- TukeyHSD(anova_result)
  print(tukey_result)
} else {
  cat("As diferenças entre as médias dos grupos não são estatisticamente significativas.\n")
}

# Realizar o teste de Kruskal-Wallis
kruskal_result <- kruskal.test(alavancagem ~ corporate_governance_level, data = df)
print(kruskal_result)

# Se o teste de Kruskal-Wallis for significativo, realizar o teste post-hoc de Dunn
if (kruskal_result$p.value < 0.05) {
  dunn_result <- dunn.test(df$alavancagem, df$corporate_governance_level, method = "bonferroni")
  print(dunn_result)
} else {
  cat("As diferenças entre as medianas dos grupos não são estatisticamente significativas.\n")
}



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

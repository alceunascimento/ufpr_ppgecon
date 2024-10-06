---
title: "UFPR PPGEcon 2024"
subtitle: "Econometria (Prof. Adalto Acir Althaus Jr.): exercício 03 (Determinantes da estrutura de capital)"
author: "Alceu Nascimento, Renan Perozin"
date: "2024-04-21"
output:
  html_document: 
    toc: yes
    toc_float: yes
    toc_depth: 5
    keep_md: yes
header-includes:
- \usepackage{fontspec}
- \setmainfont{Arial}
---





``` r
df.raw <- read_xlsx(here("econometria/data/base_2024.xlsx"))
```



``` r
df <- df.raw %>%
  select(year,
         quarter,
         companyname, 
         setor_economia,
         total_asset,
         permanent_asset,
         short_term_debt,
         long_term_debt,
         patrimonio_liquido,
         ebit,
         net_profit,
         firm_market_value,
         net_revenue
)

## Cleaning ----
## Se o YEAR is NA, excluir
df <- df %>%
  filter(!is.na(year))
## Excluir o ano de 2014 pois só tem o 1º trimestre
df <- df %>%
  filter(year != 2014)
# Excluir dados sem valor de `patrimonio_liquido`
df <- df |> 
  filter(patrimonio_liquido != 0)
# Excluir dados sem valor de `net_revenue`
df <- df |> 
  filter(net_revenue != 0)
# Excluir dados sem valor de `firm_market_value`
df <- df |> 
  filter(firm_market_value != 0)
# Excluir empresas financeiras
df <- df |> 
  filter(setor_economia != "Finanças e Seguros")
# Excluir observações onde tanto `short_term_debt` quanto `long_term_debt` são NA
df <- df[!(is.na(df$short_term_debt) & is.na(df$long_term_debt)), ]
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
  group_by(companyname) |>  # Agrupa os dados por empresa
  arrange(companyname, year) |>  # Ordena os dados por ano
  mutate(
    alavancagem = (short_term_debt + long_term_debt) / patrimonio_liquido,
    imobilizacao = (permanent_asset / total_asset),  
    roa = (net_profit / total_asset),
    qtobin = (firm_market_value / total_asset),
    bep = (ebit / total_asset),
    log_size = log(total_asset)
  ) |> 
  ungroup()  # Desagrupa os dados
## Transformar em factor ----
df <- df |> 
  mutate(across(c(setor_economia, year, quarter), as.factor))
## Organize variables ----
df <- df |> 
  select(year,
         quarter,
         companyname, 
         setor_economia,
         alavancagem,
         imobilizacao,
         roa,
         qtobin,
         bep,
         log_size,
         total_asset
  )
# 4. CREATE pdata.frame ----
pdata <- pdata.frame(df, index = c("companyname", "year", "quarter"))
```

```
## Warning in pdata.frame(df, index = c("companyname", "year", "quarter")): duplicate couples (id-time) in resulting pdata.frame
##  to find out which, use, e.g., table(index(your_pdataframe), useNA = "ifany")
```

# 1. Verifique as variáveis e apresente estatísticas descritivas



``` r
stargazer(pdata, type = "html")
```


<table style="text-align:center"><tr><td colspan="6" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Statistic</td><td>N</td><td>Mean</td><td>St. Dev.</td><td>Min</td><td>Max</td></tr>
<tr><td colspan="6" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">alavancagem</td><td>4,621</td><td>1.477</td><td>17.036</td><td>-835.147</td><td>462.466</td></tr>
<tr><td style="text-align:left">imobilizacao</td><td>4,776</td><td>0.342</td><td>0.234</td><td>0.001</td><td>0.941</td></tr>
<tr><td style="text-align:left">roa</td><td>4,853</td><td>0.024</td><td>0.050</td><td>-0.371</td><td>0.476</td></tr>
<tr><td style="text-align:left">qtobin</td><td>4,854</td><td>3.328</td><td>10.206</td><td>0.0005</td><td>181.052</td></tr>
<tr><td style="text-align:left">bep</td><td>4,854</td><td>0.051</td><td>0.061</td><td>-0.458</td><td>0.674</td></tr>
<tr><td style="text-align:left">log_size</td><td>4,854</td><td>13.498</td><td>1.320</td><td>10.196</td><td>16.300</td></tr>
<tr><td style="text-align:left">total_asset</td><td>4,854</td><td>1,525,508.605</td><td>1,896,370.069</td><td>26,799</td><td>12,000,000</td></tr>
<tr><td colspan="6" style="border-bottom: 1px solid black"></td></tr></table>


# Construindo os modelos


``` r
## model 2a ----
alavancagem <- alavancagem ~ 
  imobilizacao +
  roa + 
  qtobin + 
  bep +
  roa +
  log_size


## Pooled OLS ----
mod2a <- plm(alavancagem, data = pdata, model = "pooling")
mod2b <- plm(update(alavancagem, . ~ . + factor(quarter)), data = pdata, model = "pooling")  # pooled OLS dummies for `quarter`
mod2c <- plm(update(alavancagem, . ~ . + factor(quarter) + factor(companyname)), data = pdata, model = "pooling")  # pooled OLS dummies for `quarter` and `companyname`

## Random Effects ----
mod3a <- plm(alavancagem, data = pdata, model = "random")
mod3b <- plm(update(alavancagem, . ~ . + factor(quarter)), data = pdata, model = "random")  # random effects dummies for `quarter`

## Fixed Effects ----
mod4a <- plm(alavancagem, data = pdata, model = "within")  # fixed effects 
mod4b <- plm(update(alavancagem, . ~ . + factor(quarter)), data = pdata, model = "within")  # fixed effects dummies for `quarter`
mod4c <- plm(update(alavancagem, . ~ . + factor(quarter) + factor(companyname)), data = pdata, model = "within")  # fixed effects dummies for `quarter` and `companyname`
mod4d <- plm(update(alavancagem, . ~ . + factor(quarter) + factor(companyname)), data = pdata, model = "within", index = "companyname")  # fixed effect dummies for `quarter` and `companyname` and cluster for `companyname`




# Generate robust standard errors
robust_mod2a <- coeftest(mod2a, vcov = vcovHC(mod2a, type = "HC1"))
robust_mod2b <- coeftest(mod2b, vcov = vcovHC(mod2b, type = "HC1"))
robust_mod2c <- coeftest(mod2c, vcov = vcovHC(mod2c, type = "HC1"))
robust_mod3a <- coeftest(mod3a, vcov = vcovHC(mod3a, type = "HC1"))
robust_mod3b <- coeftest(mod3b, vcov = vcovHC(mod3b, type = "HC1"))
robust_mod4a <- coeftest(mod4a, vcov = vcovHC(mod4a, type = "HC1"))
robust_mod4b <- coeftest(mod4b, vcov = vcovHC(mod4b, type = "HC1"))
robust_mod4c <- coeftest(mod4c, vcov = vcovHC(mod4c, type = "HC1"))
robust_mod4d <- coeftest(mod4d, vcov = vcovHC(mod4d, type = "HC1"))
```



``` r
# Function to extract robust standard errors
robust_se <- function(model) {
  sqrt(diag(vcovHC(model, type = "HC1")))
}

# Extract coefficients and robust standard errors
coefs_robust <- list(
  mod2a = coeftest(mod2a, vcov = vcovHC(mod2a, type = "HC1")),
  mod2b = coeftest(mod2b, vcov = vcovHC(mod2b, type = "HC1")),
  mod2c = coeftest(mod2c, vcov = vcovHC(mod2c, type = "HC1")),
  mod3a = coeftest(mod3a, vcov = vcovHC(mod3a, type = "HC1")),
  mod3b = coeftest(mod3b, vcov = vcovHC(mod3b, type = "HC1")),
  mod4a = coeftest(mod4a, vcov = vcovHC(mod4a, type = "HC1")),
  mod4b = coeftest(mod4b, vcov = vcovHC(mod4b, type = "HC1")),
  mod4c = coeftest(mod4c, vcov = vcovHC(mod4c, type = "HC1")),
  mod4d = coeftest(mod4d, vcov = vcovHC(mod4d, type = "HC1"))
)

# Extract robust standard errors from coeftest results
se_robust <- lapply(coefs_robust, function(x) x[, 2])

# Stargazer output with robust standard errors
stargazer(
  mod2a, mod2b, mod2c, mod3a, mod3b, mod4a, mod4b, mod4c,
  type = "html", 
  report = "vcs*", 
  omit = c("factor\\(quarter\\)", "factor\\(companyname\\)"),
  column.labels = c("2.a Poooled OLS", "2.b Pooled OLS dummies quarter", "2.c Pooled OLS dummies quarter/firms ", "3.a RE", "3.b RE dummies quarter", "4.a FE", "4.b FE dummies quarter", "4.c FE dummies quarter/firms", "4.d"),
  se = se_robust
)
```


<table style="text-align:center"><tr><td colspan="9" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"></td><td colspan="8"><em>Dependent variable:</em></td></tr>
<tr><td></td><td colspan="8" style="border-bottom: 1px solid black"></td></tr>
<tr><td style="text-align:left"></td><td colspan="8">alavancagem</td></tr>
<tr><td style="text-align:left"></td><td>2.a Poooled OLS</td><td>2.b Pooled OLS dummies quarter</td><td>2.c Pooled OLS dummies quarter/firms</td><td>3.a RE</td><td>3.b RE dummies quarter</td><td>4.a FE</td><td>4.b FE dummies quarter</td><td>4.c FE dummies quarter/firms</td></tr>
<tr><td style="text-align:left"></td><td>(1)</td><td>(2)</td><td>(3)</td><td>(4)</td><td>(5)</td><td>(6)</td><td>(7)</td><td>(8)</td></tr>
<tr><td colspan="9" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">imobilizacao</td><td>-0.122</td><td>-0.135</td><td>0.030</td><td>-0.114</td><td>-0.123</td><td>0.090</td><td>0.030</td><td>0.030</td></tr>
<tr><td style="text-align:left"></td><td>(0.575)</td><td>(0.546)</td><td>(1.845)</td><td>(0.576)</td><td>(0.548)</td><td>(1.717)</td><td>(1.798)</td><td>(1.798)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">roa</td><td>-27.668</td><td>-27.987</td><td>-5.340</td><td>-26.432</td><td>-26.559</td><td>-7.276</td><td>-5.340</td><td>-5.340</td></tr>
<tr><td style="text-align:left"></td><td>(13.101)<sup>**</sup></td><td>(11.974)<sup>**</sup></td><td>(12.933)</td><td>(13.091)<sup>**</sup></td><td>(11.916)<sup>**</sup></td><td>(14.406)</td><td>(12.601)</td><td>(12.601)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">qtobin</td><td>0.002</td><td>0.003</td><td>-0.068</td><td>0.003</td><td>0.003</td><td>-0.067</td><td>-0.068</td><td>-0.068</td></tr>
<tr><td style="text-align:left"></td><td>(0.020)</td><td>(0.021)</td><td>(0.105)</td><td>(0.021)</td><td>(0.022)</td><td>(0.102)</td><td>(0.102)</td><td>(0.102)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">bep</td><td>13.224</td><td>13.837</td><td>-6.593</td><td>12.122</td><td>12.448</td><td>-3.080</td><td>-6.593</td><td>-6.593</td></tr>
<tr><td style="text-align:left"></td><td>(9.109)</td><td>(7.016)<sup>**</sup></td><td>(7.379)</td><td>(9.118)</td><td>(6.966)<sup>*</sup></td><td>(8.562)</td><td>(7.190)</td><td>(7.190)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">log_size</td><td>0.117</td><td>0.114</td><td>1.531</td><td>0.149</td><td>0.148</td><td>1.557</td><td>1.531</td><td>1.531</td></tr>
<tr><td style="text-align:left"></td><td>(0.264)</td><td>(0.255)</td><td>(1.531)</td><td>(0.274)</td><td>(0.265)</td><td>(1.464)</td><td>(1.492)</td><td>(1.492)</td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left">Constant</td><td>-0.089</td><td>-0.118</td><td>-16.517</td><td>-0.522</td><td>-0.596</td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left"></td><td>(3.773)</td><td>(3.552)</td><td>(19.163)</td><td>(3.904)</td><td>(3.690)</td><td></td><td></td><td></td></tr>
<tr><td style="text-align:left"></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>
<tr><td colspan="9" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left">Observations</td><td>4,542</td><td>4,542</td><td>4,542</td><td>4,542</td><td>4,542</td><td>4,542</td><td>4,542</td><td>4,542</td></tr>
<tr><td style="text-align:left">R<sup>2</sup></td><td>0.002</td><td>0.002</td><td>0.059</td><td>0.002</td><td>0.002</td><td>0.003</td><td>0.003</td><td>0.003</td></tr>
<tr><td style="text-align:left">Adjusted R<sup>2</sup></td><td>0.001</td><td>0.0003</td><td>0.007</td><td>0.001</td><td>0.0001</td><td>-0.051</td><td>-0.052</td><td>-0.052</td></tr>
<tr><td style="text-align:left">F Statistic</td><td>1.840 (df = 5; 4536)</td><td>1.179 (df = 8; 4533)</td><td>1.140<sup>*</sup> (df = 237; 4304)</td><td>8.522</td><td>8.701</td><td>2.799<sup>**</sup> (df = 5; 4307)</td><td>1.812<sup>*</sup> (df = 8; 4304)</td><td>1.812<sup>*</sup> (df = 8; 4304)</td></tr>
<tr><td colspan="9" style="border-bottom: 1px solid black"></td></tr><tr><td style="text-align:left"><em>Note:</em></td><td colspan="8" style="text-align:right"><sup>*</sup>p<0.1; <sup>**</sup>p<0.05; <sup>***</sup>p<0.01</td></tr>
</table>

# Questões

2. Faça uma regressão Pooled OLS usando erros robustos  
a. Usando apenas as variáveis principais.  
b. Usando apenas as variáveis principais e os dummies de trimestre  
c. Usando apenas as variáveis principais, dummies de trimestre e dummies de firma  


3) Faça uma regressão usando efeitos aleatórios e erros robustos:  
a. Usando apenas as variáveis principais.  
b. Usando apenas as variáveis principais e os dummies de trimestre  
c. Usando apenas as variáveis principais, dummies de trimestre e dummies de firma.  
d. Usando apenas as variáveis principais, dummies de trimestre, dummies de firma e cluster por firma.  


4) Faça regressões usando efeitos fixos e erros robustos:  
a. Usando apenas as variáveis principais.  
b. Usando apenas as variáveis principais e os dummies de trimestre.     
c. Usando apenas as variáveis principais, dummies de trimestre e dummies de firma.  
d. Usando apenas as variáveis principais, dummies de trimestre, dummies de firma e cluster por firma.  


# 5) Execute um teste de Hausman para os modelos RE e FE usando o modelo da letra (a) e conclua qual seria a técnica indicada neste caso


``` r
hausman_test <- phtest(mod3a, mod4a)
hausman_test
```

```
## 
## 	Hausman Test
## 
## data:  alavancagem
## chisq = 22.124656, df = 5, p-value = 0.0004957847
## alternative hypothesis: one model is inconsistent
```

``` r
# Interpretar os resultados do teste de Hausman
if (hausman_test$p.value < 0.05) {
  print("O modelo de Efeitos Fixos (FE) é preferível.")
} else {
  print("O modelo de Efeitos Aleatórios (RE) é preferível.")
}
```

```
## [1] "O modelo de Efeitos Fixos (FE) é preferível."
```

# 6) Sinta-se à vontade para adicionar qualquer análise extra que desejar. 

# 7) Faça breves comentários comparando as regressões. O que você conclui?

Observa-se que todos os testes tem poder pretiditivo (R2) muito baixo. 
Além disto, apenas a variável ROA apresenta algum efeito estatisticamente significante.


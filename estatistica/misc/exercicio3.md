---
title: "UFPR PPGEcon 2024"
subtitle: "Estatística (Prof. Adalto Acir Althaus Jr.): exercícios"
author: "Alceu Eilert Nascimento"
date: "2024-04-21"
output: 
  html_document: 
    keep_md: yes
---



# Exerício 03

## Questão A

O gerente de controle de qualidade de uma fábrica de lâmpadas precisa estimar a durabilidade média de uma nova remessa de lâmpadas.  
Uma amostra aleatória de 64 lâmpadas foi selecionada nessa remessa e indicou média de vida útil de 350 horas e desvio-padrão de 100 horas. 


### a) Entenda as etapas dos cálculos executadas abaixo.


```r
# Parâmetros da amostra
n <- 64  # Tamanho da amostra
x_hat <- 350  # Média amostral
sd <- 100  # Desvio padrão amostral
gamma <- 0.95 
gl <- n - 1  # Graus de liberdade

# apuração
gl <- n -1
erro_padrao <- sd / sqrt(n)
alpha <- (1 - gamma)
t_alpha_meio <- qt( (1 - (alpha/2) ), gl)
m <- t_alpha_meio * erro_padrao
x_hat_menos_m <- x_hat - m 
x_hat_mais_m <-x_hat + m

# tabela
parametros <- c(n, x_hat, sd, gamma)
nomes_parametros <- c("Tamanho da Amostra (n)", "Média Amostral (x_hat)", "Desvio Padrão (sd)", "Nível de Confiança (gamma)")

apuracao <- c(gl, erro_padrao, alpha, t_alpha_meio, m, x_hat_menos_m, x_hat_mais_m)
nomes_apuracao <- c("Graus de Liberdade (gl)", "Erro Padrao", "Nivel de Significancia(alpha)", "Valor crítico de t (t_alpha_meio)", "Margem de Erro (m)", "Limite Inferior do IC", "Limite Superior do IC")

# Combinando todos os valores e nomes em um dataframe
tabela <- data.frame(
  Variavel = c(nomes_parametros, nomes_apuracao),
  Valor = c(parametros, apuracao)
)

# Mostrando a tabela
print(tabela)
```

```
##                             Variavel         Valor
## 1             Tamanho da Amostra (n)  64.000000000
## 2             Média Amostral (x_hat) 350.000000000
## 3                 Desvio Padrão (sd) 100.000000000
## 4         Nível de Confiança (gamma)   0.950000000
## 5            Graus de Liberdade (gl)  63.000000000
## 6                        Erro Padrao  12.500000000
## 7      Nivel de Significancia(alpha)   0.050000000
## 8  Valor crítico de t (t_alpha_meio)   1.998340543
## 9                 Margem de Erro (m)  24.979256782
## 10             Limite Inferior do IC 325.020743218
## 11             Limite Superior do IC 374.979256782
```


```r
# Calculando os valores t críticos
t_negativo <- qt((1 - gamma) / 2, gl)  # Valor t para a cauda inferior
t_positivo <- qt(gamma + (1 - gamma) / 2, gl)  # Valor t para a cauda superior


# Plotando a distribuição t
curve(dt(x, df = gl), from = -4, to = 4, lwd = 2, col = "black", main = "Distribuição t de Student com Área Sombreada e Valores Críticos", xlab = "Valor t", ylab = "Densidade", xlim = c(-4, 4), ylim = c(0, 0.4), xaxt = "n")

# Sombreando a área entre os pontos críticos
t_values <- seq(t_negativo, t_positivo, length.out = 100)
d_values <- dt(t_values, df = gl)
polygon(c(t_negativo, t_values, t_positivo), c(0, d_values, 0), col = "lightgrey", border = NA)

# Adicionando pontos críticos
points(x = c(t_negativo, t_positivo), y = c(dt(t_negativo, gl), dt(t_positivo, gl)), col = "black", pch = 19, cex = 1.5)

# Adicionando os valores críticos no eixo x, sem outras marcas
axis(1, at = c(t_negativo, t_positivo), labels = c(format(t_negativo, digits = 4), format(t_positivo, digits = 4)))
```

![](exercicio3_files/figure-html/q1 a grafico, options-1.png)<!-- -->


```r
# Definindo os parâmetros
mu <- 0
sigma <- 1
x_range <- seq(mu - 4*sigma, mu + 4*sigma, length.out = 1000)
y_values <- dnorm(x_range, mean = mu, sd = sigma)

# Plotando a curva
plot(x_range, y_values, type = "l", main = "Teste Unilateral à Direita", xlab = "z", ylab = "Densidade")

# Área crítica
z_critico <- qnorm(0.95, mean = mu, sd = sigma)
polygon(c(z_critico, seq(z_critico, max(x_range), length = 100), max(x_range)),
        c(0, dnorm(seq(z_critico, max(x_range), length = 100), mean = mu, sd = sigma), 0),
        col = "skyblue")
abline(v = z_critico, col = "blue")
```

![](exercicio3_files/figure-html/q1 a graficos genericos, options-1.png)<!-- -->


```r
# Definindo os parâmetros
mu <- 0
sigma <- 1
x_range <- seq(mu - 4*sigma, mu + 4*sigma, length.out = 1000)
y_values <- dnorm(x_range, mean = mu, sd = sigma)

# Plotando a curva
plot(x_range, y_values, type = "l", main = "Teste Unilateral à Esquerda", xlab = "z", ylab = "Densidade")

# Área crítica
z_critico <- qnorm(0.05, mean = mu, sd = sigma)
polygon(c(min(x_range), seq(min(x_range), z_critico, length = 100), z_critico),
        c(0, dnorm(seq(min(x_range), z_critico, length = 100), mean = mu, sd = sigma), 0),
        col = "skyblue")
abline(v = z_critico, col = "blue")
```

![](exercicio3_files/figure-html/unnamed-chunk-1-1.png)<!-- -->


```r
# Definindo os parâmetros
mu <- 0
sigma <- 1
x_range <- seq(mu - 4*sigma, mu + 4*sigma, length.out = 1000)
y_values <- dnorm(x_range, mean = mu, sd = sigma)

# Plotando a curva com porcentagens
plot(x_range, y_values, type = "l", main = "Distribuição Normal com Porcentagens", xlab = "z", ylab = "Densidade")

# Adicionando porcentagens
z_scores <- qnorm(c(0.0033, 0.1587, 0.8413, 0.9967), mean = mu, sd = sigma)
abline(v = z_scores, col = "blue", lty = "dotted")
text(z_scores, rep(0, 4), labels = c("-3σ", "-1σ", "1σ", "3σ"), pos = 1, col = "blue")

# Área crítica bilateral
z_critico_left <- qnorm(0.025, mean = mu, sd = sigma)
z_critico_right <- qnorm(0.975, mean = mu, sd = sigma)

polygon(c(min(x_range), seq(min(x_range), z_critico_left, length = 100), z_critico_left),
        c(0, dnorm(seq(min(x_range), z_critico_left, length = 100), mean = mu, sd = sigma), 0),
        col = "skyblue")
polygon(c(z_critico_right, seq(z_critico_right, max(x_range), length = 100), max(x_range)),
        c(0, dnorm(seq(z_critico_right, max(x_range), length = 100), mean = mu, sd = sigma), 0),
        col = "skyblue")
abline(v = c(z_critico_left, z_critico_right), col = "blue")
```

![](exercicio3_files/figure-html/unnamed-chunk-2-1.png)<!-- -->







### b) Modifique a confiança e veja o que acontece com a precisão do intervalo.


```r
# Parâmetros da amostra
n <- 64  # Tamanho da amostra
x_hat <- 350  # Média amostral
sd <- 100  # Desvio padrão amostral
gl <- n - 1  # Graus de liberdade


# Níveis de confiança para avaliar
confiancas <- c(0.90, 0.95, 0.99, 0.995, 0.999, 0.9995)

# Inicializar um data frame para os resultados
resultados <- data.frame(
  Confianca = numeric(),
  LimiteInferior = numeric(),
  LimiteSuperior = numeric()
)

# Cálculo dos intervalos de confiança para cada nível de confiança
for (confianca in confiancas) {
  alpha <- 1 - confianca
  t_alpha_meio <- qt(1 - alpha / 2, gl)
  erro_padrao <- sd / sqrt(n)
  m <- t_alpha_meio * erro_padrao
  limite_inferior <- x_hat - m
  limite_superior <- x_hat + m
  
  # Adicionar os resultados ao data frame
  resultados <- rbind(resultados, data.frame(Confianca = confianca,
                                             LimiteInferior = limite_inferior,
                                             LimiteSuperior = limite_superior,
                                             Intervalo = m))
}

# Mostrar a tabela
print(resultados)
```

```
##   Confianca LimiteInferior LimiteSuperior   Intervalo
## 1    0.9000    329.1324722    370.8675278 20.86752777
## 2    0.9500    325.0207432    374.9792568 24.97925678
## 3    0.9900    316.7981872    383.2018128 33.20181281
## 4    0.9950    313.6342223    386.3657777 36.36577770
## 5    0.9990    306.8528882    393.1471118 43.14711181
## 6    0.9995    304.1158826    395.8841174 45.88411739
```

\  

### c) Seria possível aceitar a reivindicação do fornecedor de que as lâmpadas duram 400 horas?

Para determinar se é possível aceitar a reivindicação do fornecedor de que as lâmpadas duram em média 400 horas, podemos realizar um teste de hipóteses com as seguintes hipóteses:  

$H_0:μ=400$   (hipótese nula: a média da população é 400 horas)  
$H_a:μ<400$   (hipótese alternativa: a média da população é menor que 400 horas)  

Considerando o nível de confiança de 95% e a média amostral de 350 horas com desvio padrão de 100 horas para uma amostra de 64 lâmpadas, o teste de hipóteses pode ser conduzido da seguinte maneira:


```r
mu_0 <- 400

# Cálculo da estatística de teste (t)
t <- (x_hat - mu_0) / erro_padrao

# P-valor para o teste unicaudal à esquerda
p_valor <- pt(t, gl)

# Teste de hipótese
if (p_valor < alpha) {
  resultado <- "Rejeita H_0"
} else {
  resultado <- "Não rejeita H_0"
}

# Resultados
list(t = t, p_valor = p_valor, resultado = resultado)
```

```
## $t
## [1] -4
## 
## $p_valor
## [1] 0.00008452626054
## 
## $resultado
## [1] "Rejeita H_0"
```




\  

## Questão B

### Dados

```r
# carregando o dataset
path = "C:/Users/DELL/OneDrive/R/Rprojetos/ufpr_ppgecon/estatistica/data/exerc3_dataset.csv"
dados <- read_csv2(path)
```


### Questão:  

A planilha DEMO traz informações de 1.000 respondentes quanto à sua 
idade em anos, 
o seu estado civil (1- casado , 0- não casado), 
quanto tempo (em anos) vive no endereço atual,
sua renda anual (em milhares de reais), 
o preço do carro principal (em milhares de reais),
sua escolaridade (1- primeiro grau, 2- segundo grau, 3- terceiro grau, 4- Pós graduação especialização, 5- mestrado/doutorado),  
quanto tempo, em anos, está no emprego atual (t_emp_atual),
se é (1) ou não (0) aposentado, 
o sexo (m- masc e f- femin) e
sua satisfação no trabalho (de 1- Nada satisfeito a 5- Muito satisfeito).

\  

#### Item 2

##### a) Calcule um intervalo de confiança de $95%$ para a média de idade da população sob amostragem.

```r
confianca_95 <- 0.95
error_padrao <- sd(dados$idade) / sqrt(nrow(dados))
margem_erro <- qt(1 - (1 - confianca_95) / 2, df = nrow(dados) - 1) * error_padrao
limite_inferior <- mean(dados$idade) - margem_erro
limite_superior <- mean(dados$idade) + margem_erro
c(limite_inferior, limite_superior)
```

```
## [1] 40.66239729 42.17760271
```

\  

##### b) A mesma técnica utilizada no item anterior poderia ser usada para estimar a renda média populacional?

```r
# A mesma técnica pode ser utilizada para qualquer variável quantitativa contínua.
```

\  

##### c) Podemos estimar e interpretar intervalos de confiança da mesma forma que na letra "a" para a variável casados? E para a variável aposentado?

```r
# Variável casados (est_civil) é binária, assim como aposentado. Usaremos uma proporção para o IC.
# Para casados
prop_casados <- mean(dados$est_civil)
se_casados <- sqrt(prop_casados * (1 - prop_casados) / nrow(dados))
me_casados <- qt(1 - (1 - confianca) / 2, df = nrow(dados) - 1) * se_casados
c(prop_casados - me_casados, prop_casados + me_casados)
```

```
## [1] 0.4557965994 0.5662034006
```

```r
# Para aposentados
prop_aposentado <- mean(dados$aposentado)
se_aposentado <- sqrt(prop_aposentado * (1 - prop_aposentado) / nrow(dados))
me_aposentado <- qt(1 - (1 - confianca) / 2, df = nrow(dados) - 1) * se_aposentado
c(prop_aposentado - me_aposentado, prop_aposentado + me_aposentado)
```

```
## [1] 0.01688552504 0.05911447496
```

\  

##### d) Qual será a interpretação correta ao estimarmos um intervalo de 95% para a média dos casados?

```r
# A interpretação seria a proporção de casados na população, com 95% de confiança.
# Isso não é uma média, mas sim uma proporção, portanto, o intervalo reflete a incerteza na estimativa da proporção de casados.
```

\  

##### e) Calcule um intervalo de confiança de 90% para a média de tempo no emprego atual da população.

```r
confianca_90 <- 0.90
error_padrao_emprego <- sd(dados$t_empr_atual) / sqrt(nrow(dados))
margem_erro_emprego <- qt(1 - (1 - confianca_90) / 2, df = nrow(dados) - 1) * error_padrao_emprego
limite_inferior_emprego <- mean(dados$t_empr_atual) - margem_erro_emprego
limite_superior_emprego <- mean(dados$t_empr_atual) + margem_erro_emprego
c(limite_inferior_emprego, limite_superior_emprego)
```

```
## [1]  9.936381613 10.949618387
```

\  

##### f) Calcule um intervalo de confiança de 99% para a proporção de mulheres na população.

```r
prop_mulheres <- mean(dados$sexo == "f")
se_mulheres <- sqrt(prop_mulheres * (1 - prop_mulheres) / nrow(dados))
confianca_99 <- 0.99
me_mulheres <- qt(1 - (1 - confianca_99) / 2, df = nrow(dados) - 1) * se_mulheres
c(prop_mulheres - me_mulheres, prop_mulheres + me_mulheres)
```

```
## [1] 0.4302632998 0.5117367002
```

\  


#### Item 3

Calcule o valor-p e decida se rejeita ou não a hipótese nula para cada afirmação abaixo.   
Adote o nível de significância de 5%.

\  

##### a) A média de idade populacional é de 40 anos.
$H_O:\mu = 40$ (teste bilateral)

```r
h_0_idade <- 40
t_teste_idade <- (mean(dados$idade) - h_0_idade) / (sd(dados$idade) / sqrt(nrow(dados)))
p_valor_idade <- 2 * pt(-abs(t_teste_idade), df = nrow(dados) - 1)
p_valor_idade < 0.05
```

```
## [1] TRUE
```

```r
list(t_teste_idade = t_teste_idade)
```

```
## $t_teste_idade
## [1] 3.678081992
```


```r
n <- nrow(dados)
df <- n - 1

# Criar dados para o gráfico
x <- seq(-4, 4, length.out = 300)
df_t <- data.frame(x = x, y = dt(x, df))

# Adicionar regiões críticas
critical_left <- qt(0.025, df, lower.tail = TRUE)
critical_right <- qt(0.025, df, lower.tail = FALSE)

# Gráfico
p <- ggplot(df_t, aes(x = x, y = y)) +
  geom_line(color = "black", size = 1) +
  geom_vline(xintercept = t_teste_idade, color = "blue", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_left, color = "red", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_right, color = "red", linetype = "dashed", linewidth = 1) +
  geom_area(data = df_t %>% filter(x <= critical_left), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  geom_area(data = df_t %>% filter(x >= critical_right), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  labs(title = "Distribuição t e Estatística de Teste",
       subtitle = paste("Teste de hipótese para média de idade, p-valor:", round(p_valor_idade, 4)),
       x = "Valores t", y = "Densidade") +
  theme_minimal()

print(p)
```

![](exercicio3_files/figure-html/q2 3a grafico, options-1.png)<!-- -->

\  

##### b) A população sob amostragem vive, em média, 11 anos no mesmo endereço.
$H_O:\mu = 11$

```r
h_0_endereco <- 11
t_teste_endereco <- (mean(dados$endereco) - h_0_endereco) / (sd(dados$endereco) / sqrt(nrow(dados)))
p_valor_endereco <- 2 * pt(-abs(t_teste_endereco), df = nrow(dados) - 1)
p_valor_endereco < 0.05
```

```
## [1] FALSE
```


```r
n <- nrow(dados)
df <- n - 1

# Criar dados para o gráfico
x <- seq(-4, 4, length.out = 300)
df_t <- data.frame(x = x, y = dt(x, df))

# Adicionar regiões críticas
critical_left <- qt(0.025, df, lower.tail = TRUE)
critical_right <- qt(0.025, df, lower.tail = FALSE)

# Gráfico
p <- ggplot(df_t, aes(x = x, y = y)) +
  geom_line(color = "black", size = 1) +
  geom_vline(xintercept = t_teste_endereco, color = "blue", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_left, color = "red", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_right, color = "red", linetype = "dashed", linewidth = 1) +
  geom_area(data = df_t %>% filter(x <= critical_left), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  geom_area(data = df_t %>% filter(x >= critical_right), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  labs(title = "Distribuição t e Estatística de Teste",
       subtitle = paste("Teste de hipótese para tempo de moradia, p-valor:", round(p_valor_endereco, 4)),
       x = "Valores t", y = "Densidade") +
  theme_minimal()

print(p)
```

![](exercicio3_files/figure-html/q2 3b grafico, options-1.png)<!-- -->

\  

##### c) Quais as chances de termos cometido um erro de decisão no item (a) e no item (b)?

```r
# O nível de significância é a chance de erro tipo I (rejeitar H0 quando é verdadeira).
alfa <- 0.05
alfa
```

```
## [1] 0.05
```

\  


##### d) A média de preço do carro principal das famílias nessa população está acima de R$ 30.000,00.
$H_O:\mu \geq 30000$ (teste unilateral à esquerda)

```r
h_0_carro <- 30
t_teste_carro <- (mean(dados$carro) - h_0_carro) / (sd(dados$carro) / sqrt(nrow(dados)))
p_valor_carro <- pt(-abs(t_teste_carro), df = nrow(dados) - 1)
p_valor_carro < 0.05
```

```
## [1] FALSE
```
Dado que o p-valor é menor que o nível de significância, rejeita-se $H_0$, sugerindo que a média de preço do carro principal é significativamente menor que R$ 30.000,00.


```r
n <- nrow(dados)
df <- n - 1

# Criar dados para o gráfico
x <- seq(-4, 4, length.out = 300)
df_t <- data.frame(x = x, y = dt(x, df))

# Adicionar regiões críticas
critical_left <- qt(0.025, df, lower.tail = TRUE)
critical_right <- qt(0.025, df, lower.tail = FALSE)

# Gráfico
p <- ggplot(df_t, aes(x = x, y = y)) +
  geom_line(color = "black", size = 1) +
  geom_vline(xintercept = t_teste_carro, color = "blue", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_left, color = "red", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_right, color = "red", linetype = "dashed", linewidth = 1) +
  geom_area(data = df_t %>% filter(x <= critical_left), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  geom_area(data = df_t %>% filter(x >= critical_right), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  labs(title = "Distribuição t e Estatística de Teste",
       subtitle = paste("Teste de hipótese para média de idade, p-valor:", round(p_valor_carro, 4)),
       x = "Valores t", y = "Densidade") +
  theme_minimal()

print(p)
```

![](exercicio3_files/figure-html/q2 3d grafico, options-1.png)<!-- -->

\  

##### e) Em média, permanece-se menos de 11 anos no mesmo emprego.
$H_O:\mu \leq 11$ (teste unilateral à direita)

```r
h_0_emprego <- 11
t_teste_emprego <- (mean(dados$t_empr_atual) - h_0_emprego) / (sd(dados$t_empr_atual) / sqrt(nrow(dados)))
p_valor_emprego <- pt(-abs(t_teste_emprego), df = nrow(dados) - 1)
p_valor_emprego < 0.05
```

```
## [1] TRUE
```
Não é possível rejeita $H_0$


```r
n <- nrow(dados)
df <- n - 1

# Criar dados para o gráfico
x <- seq(-4, 4, length.out = 300)
df_t <- data.frame(x = x, y = dt(x, df))

# Adicionar regiões críticas
critical_left <- qt(0.025, df, lower.tail = TRUE)
critical_right <- qt(0.025, df, lower.tail = FALSE)

# Gráfico
p <- ggplot(df_t, aes(x = x, y = y)) +
  geom_line(color = "black", size = 1) +
  geom_vline(xintercept = t_teste_emprego, color = "blue", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_left, color = "red", linetype = "dashed", linewidth = 1) +
  geom_vline(xintercept = critical_right, color = "red", linetype = "dashed", linewidth = 1) +
  geom_area(data = df_t %>% filter(x <= critical_left), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  geom_area(data = df_t %>% filter(x >= critical_right), aes(x = x, y = y), fill = "red", alpha = 0.5) +
  labs(title = "Distribuição t e Estatística de Teste",
       subtitle = paste("Teste de hipótese para média de idade, p-valor:", round(p_valor_emprego, 4)),
       x = "Valores t", y = "Densidade") +
  theme_minimal()

print(p)
```

![](exercicio3_files/figure-html/q2 3e grafico, options-1.png)<!-- -->


\  


##### f) Metade da população é casada.
$H_O: $

```r
h_0_casados <- 0.5
prop_casados <- mean(dados$est_civil)  # Calcular a proporção de casados na amostra
se_casados <- sqrt(prop_casados * (1 - prop_casados) / nrow(dados))  # Calcular o erro padrão da proporção
z_teste_casados <- (prop_casados - h_0_casados) / se_casados # Calcular a estatística Z
p_valor_casados <- 2 * pnorm(-abs(z_teste_casados)) # Calcular o p-valor para um teste bilateral
p_valor_casados < 0.05 # Decisão sobre a hipótese nula baseada no p-valor
```

```
## [1] FALSE
```
Rejeita-se $H_0$


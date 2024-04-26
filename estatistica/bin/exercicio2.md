---
title: "UFPR PPGEcon 2024"
subtitle: "Estatística (Prof. Adalto Acir Althaus Jr.): exercícios"
author: "Alceu Eilert Nascimento"
date: "2024-04-21"
output: 
  html_document: 
    keep_md: yes
---



# Exerício 02

## Questão:  
Escolha uma das planilhas com os bancos de dados disponibilizados a seguir.  
Realize estatísticas descritivas do banco de dados escolhido.  
Para cada variável calcule médias, medianas, desvios padrão e outras estatísticas que queira calcular.  
Explore e desenvolva alguma conclusão original sobre o banco de dados escolhido.  

## Analise:

Foi escolhido o dataset nº 02, que continha os dados de mortaldade infantil para os municípios do Paraná para os anos de 1980, 1991 e 2000.  

```r
# carregando o dataset
path = "C:/Users/DELL/OneDrive/R/Rprojetos/ufpr_ppgecon/estatistica/data/dataset2.csv"
df <- read_csv2(path)

# Calculando a variação percentual ano a ano
df$variacao_1980_1991 <- (df$`1991` - df$`1980`) / df$`1980` * 100
df$variacao_1991_2000 <- (df$`2000` - df$`1991`) / df$`1991` * 100
df$variacao_1980_2000 <- (df$`2000` - df$`1980`) / df$`1980` * 100
df
```

```
## # A tibble: 150 × 7
##    municipio          `1980` `1991` `2000` variacao_1980_1991 variacao_1991_2000
##    <chr>               <dbl>  <dbl>  <dbl>              <dbl>              <dbl>
##  1 Abatiá               55.4   30.1   19.5             -45.7               -35.2
##  2 Adrianópolis         67.9   41.5   18.9             -38.8               -54.4
##  3 Agudos do Sul        65.1   45.1   25.1             -30.7               -44.4
##  4 Almirante Tamanda…   57.5   45.3   28               -21.3               -38.1
##  5 Bela Vista do Par…   39.4   26.3   14.1             -33.2               -46.3
##  6 Bituruna             55.5   61.0   28.1               9.97              -53.9
##  7 Boa Esperança        96.3   46.7   35               -51.5               -25.0
##  8 Cascavel             75.1   39.9   19.5             -46.9               -51.1
##  9 Castro               66.7   45.0   27.8             -32.6               -38.2
## 10 Catanduvas           56.6   49.4   25.2             -12.8               -49.0
## # ℹ 140 more rows
## # ℹ 1 more variable: variacao_1980_2000 <dbl>
```


### indicadores estatísticos

O conjunto de dados apresenta os seguintes indicadores estatísticos:


```r
# obtendo os indicadores estatísticos básicos
estats <- pastecs::stat.desc(df)
estats <- estats |> 
  select(`1980`,`1991`, `2000`) |> 
  filter(row.names(estats) %in% c("mean", "median", "std.dev"))
kable(estats)
```



|        |        1980|         1991|        2000|
|:-------|-----------:|------------:|-----------:|
|median  | 62.02000000| 39.390000000| 19.56000000|
|mean    | 62.97613333| 39.909666667| 20.41246667|
|std.dev | 11.53429807|  9.691026114|  6.29711204|

É possivel identificar que além da redução na taxa de mortalidade, há uma redução na variação entre os munícipios, dada a redução no desvio padrão.

Analisando apenas a variação total no período, temos:

```r
# obtendo os indicadores estarísticos da variaçõ
estats_2 <- stat.desc(df$variacao_1980_2000)
kable(estats_2)
```



|             |                 x|
|:------------|-----------------:|
|nbr.val      |    150.0000000000|
|nbr.null     |      0.0000000000|
|nbr.na       |      0.0000000000|
|min          |    -88.7789753433|
|max          |    -27.3687298328|
|range        |     61.4102455105|
|sum          | -10024.4651928693|
|median       |    -67.9944199416|
|mean         |    -66.8297679525|
|SE.mean      |      0.8823656884|
|CI.mean.0.95 |      1.7435662279|
|var          |    116.7853812193|
|std.dev      |     10.8067285160|
|coef.var     |     -0.1617053126|


### Analise da heterogeniedade da variação na taxa de mortalidade entre os municípios

Para analisar a heterogeinedade da variação na vataxa de mortalidade entre os municípios, optou-se por separa-los em clusters, conforme a variação apresentada.
Primeiro, para identificação do número adequado de clusters, utilizamos o "método do cotovelo", conforme:


```r
# Determinar o número adequado de clusters - Método do Cotovelo
set.seed(123)  # Para reprodutibilidade
wss <- (nrow(df)-1)*sum(apply(df,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(df$variacao_1980_2000, centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Número de Clusters", ylab="Soma dos Quadrados Internos")
```

![](exercicio2_files/figure-html/clusters 2, options-1.png)<!-- -->

Em seguida, produzimos uma analise gráfica dos clusters:


```r
# Aplicar k-means com um número adequado de clusters escolhido
kmeans_result <- kmeans(df$variacao_1980_2000, centers=6, nstart=25)  # Ajuste o 'centers' conforme necessário

# Adicionar os resultados do cluster de volta ao dataframe
df$cluster <- kmeans_result$cluster


# Gráfico de dispersão com os clusters
ggplot(df, aes(x=`1980`, y=`2000`, color=factor(cluster))) +
  geom_point(alpha=0.5) +
  labs(title = "Cluster de Redução da Mortalidade Infantil entre 1980 e 2000",
       x = "Taxa de Mortalidade em 1980",
       y = "Taxa de Mortalidade em 2000",
       color = "Cluster") +
  theme_bw()
```

![](exercicio2_files/figure-html/grafico clusters, options-1.png)<!-- -->


Por fim, analisando os clusters temos:


```r
medias_por_cluster <- df %>%
  group_by(cluster) %>%
  summarise(
    media_reducao = mean(variacao_1980_2000, na.rm = TRUE),
    desvio_padrao = sd(variacao_1980_2000, na.rm = TRUE),
    mediana_reducao = median(variacao_1980_2000, na.rm = TRUE)
  )

# Exibindo as estatísticas calculadas
print(medias_por_cluster)
```

```
## # A tibble: 6 × 4
##   cluster media_reducao desvio_padrao mediana_reducao
##     <int>         <dbl>         <dbl>           <dbl>
## 1       1         -74.9          2.08           -74.6
## 2       2         -83.6          2.90           -82.9
## 3       3         -68.1          1.74           -68.1
## 4       4         -61.8          2.30           -62.1
## 5       5         -50.1          3.54           -50.3
## 6       6         -31.4          5.68           -31.4
```

```r
# Utilizando kable para uma apresentação formal, se necessário
kable(medias_por_cluster, caption = "Estatísticas de Redução da Mortalidade Infantil por Cluster")
```



Table: Estatísticas de Redução da Mortalidade Infantil por Cluster

| cluster| media_reducao| desvio_padrao| mediana_reducao|
|-------:|-------------:|-------------:|---------------:|
|       1|  -74.92805206|   2.082105756|    -74.63454496|
|       2|  -83.64552668|   2.897630068|    -82.86569987|
|       3|  -68.10777506|   1.743936927|    -68.09241336|
|       4|  -61.76501744|   2.298494137|    -62.07961007|
|       5|  -50.11348573|   3.537441237|    -50.32232858|
|       6|  -31.38591215|   5.681153712|    -31.38591215|

Na comparação entre os anos de 1980 e 2000, é possível identificar que a redução na taxa de mortalidade infantil não foi homogênea entre os municípios.  
Ao segregar os dados em seis clusters, foi possível identificar que há uma heterogeniedade na redução da taxa de mortalidade.   
É possivel que isto se dê em função de outros fatores que impactaram estes municípios, como aumento da renda, investimentos públicos, entre outros.


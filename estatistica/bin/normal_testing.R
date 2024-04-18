qqnorm(df1$idade)
qqline(df1$idade, col = "red")
qqnorm(df1$renda)
qqline(df1$renda, col = "red")

hist(df1$idade, probability = TRUE, main = "Histograma com Curva de Densidade")
curve(dnorm(x, mean = mean(df1$idade), sd = sd(df1$idade)), 
      add = TRUE, col = "red", lwd = 2)

hist(df1$renda, probability = TRUE, main = "Histograma com Curva de Densidade")
curve(dnorm(x, mean = mean(df1$renda), sd = sd(df1$renda)), 
      add = TRUE, col = "red", lwd = 2)
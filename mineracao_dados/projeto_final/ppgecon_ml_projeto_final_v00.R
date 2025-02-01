# SETUP ----

# Pacotes utilizados no modelo de previsão de inadimplência

# dplyr: Manipulação eficiente de dados com funções do tidyverse
library(dplyr)

# ggplot2: Criação de gráficos avançados e customizáveis
library(ggplot2)

# gridExtra: Combinação de múltiplos gráficos em um único layout
library(gridExtra)

# recipes: Pré-processamento de dados, incluindo normalização, imputação e balanceamento
library(recipes)

# caret: Utilizado para particionar os dados, treinar modelos e calcular métricas de desempenho
library(caret)

# themis: Técnicas de balanceamento de classes, incluindo SMOTE
library(themis)

# class: Implementação do algoritmo KNN (K-Nearest Neighbors)
library(class)

# randomForest: Implementação do algoritmo de Random Forest para classificação e regressão
library(randomForest)

# xgboost: Implementação otimizada de Gradient Boosting para aprendizado supervisionado
library(xgboost)


# ELT ----
# Carregar os dados (substituir pelo caminho correto)
data <- read.csv2("C:/Users/DELL/OneDrive/R/Rprojetos/ufpr_ppgecon/mineracao_dados/projeto_final/data/credit_data.csv")


# Remover a coluna ID, pois não é relevante para a modelagem
data <- data %>% select(-ID)

# Renomear a coluna alvo corretamente
colnames(data)[colnames(data) == "default.payment.next.month"] <- "Y"

# Converter a variável Y para fator
data$Y <- as.factor(data$Y)

# Verificar a estrutura corrigida dos dados
str(data)

# Separar em treino (70%) e teste (30%)
set.seed(123)
index <- createDataPartition(data$Y, p = 0.7, list = FALSE)
train_data <- data[index, ]
test_data <- data[-index, ]

# Normalizar os dados (exceto a variável resposta)
norm_params <- preProcess(train_data[,-ncol(train_data)], method = c("range"))
train_data[,-ncol(train_data)] <- predict(norm_params, train_data[,-ncol(train_data)])
test_data[,-ncol(train_data)] <- predict(norm_params, test_data[,-ncol(train_data)])

# Definir os preditores e a variável resposta
train_x <- train_data[, -ncol(train_data)]
train_y <- train_data$Y
test_x <- test_data[, -ncol(test_data)]
test_y <- test_data$Y


# MODELOS ----
## KNN ----
# Treinar modelo KNN (k=5)
k_value <- 5
knn_model <- knn(train = train_x, test = test_x, cl = train_y, k = k_value)

# Avaliação do modelo
conf_matrix <- confusionMatrix(knn_model, test_y)
print(conf_matrix)

# Métricas de performance
accuracy <- conf_matrix$overall["Accuracy"]
precision <- conf_matrix$byClass["Precision"]
recall <- conf_matrix$byClass["Recall"]
F1_score <- 2 * (precision * recall) / (precision + recall)

cat("\nDesempenho do modelo KNN:\n")
cat("Acurácia:", accuracy, "\n")
cat("Precisão:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1-score:", F1_score, "\n")


## RANDOM FOREST ----

# Treinar modelo Random Forest
set.seed(123)
rf_model.1 <- randomForest(Y ~ ., 
                           data = train_data, 
                           ntree = 100, 
                           mtry = sqrt(ncol(train_data) - 1), 
                           importance = TRUE)

# Fazer previsões
rf_pred.1 <- predict(rf_model.1, test_data, type = "class")

# Avaliação do modelo
conf_matrix.1 <- confusionMatrix(rf_pred.1, test_data$Y)
print(conf_matrix.1)

# Métricas de performance
accuracy.1 <- conf_matrix.1$overall["Accuracy"]
precision.1 <- conf_matrix.1$byClass["Precision"]
recall.1 <- conf_matrix.1$byClass["Recall"]
F1_score.1 <- 2 * (precision * recall) / (precision + recall)

cat("\nDesempenho do modelo Random Forest:\n")
cat("Acurácia:", accuracy.1, "\n")
cat("Precisão:", precision.1, "\n")
cat("Recall:", recall.1, "\n")
cat("F1-score:", F1_score.1, "\n")

# Importância das variáveis
varImpPlot(rf_model.1)



# Random Forest pode ser ajustado para dar mais peso para inadimplentes (classwt)
rf_model.2 <- randomForest(Y ~ ., 
                           data = train_data, 
                           ntree = 100, 
                           classwt = c(0.5, 1.5))

# Fazer previsões
rf_pred.2 <- predict(rf_model.2, test_data, type = "class")

# Avaliação do modelo
conf_matrix.2 <- confusionMatrix(rf_pred.2, test_data$Y)
print(conf_matrix.2)

# Métricas de performance
accuracy.2 <- conf_matrix.2$overall["Accuracy"]
precision.2 <- conf_matrix.2$byClass["Precision"]
recall.2 <- conf_matrix.2$byClass["Recall"]
F1_score.2 <- 2 * (precision * recall) / (precision + recall)

cat("\nDesempenho do modelo Random Forest:\n")
cat("Acurácia:", accuracy.2, "\n")
cat("Precisão:", precision.2, "\n")
cat("Recall:", recall.2, "\n")
cat("F1-score:", F1_score.2, "\n")

# Importância das variáveis
varImpPlot(rf_model.2)






# Usar Oversampling/SMOTE
# Como há mais adimplentes do que inadimplentes, técnicas como SMOTE podem ajudar a equilibrar as classes.

train_data.3 <- train_data %>%  
  recipe(Y ~ .) %>%             # pré-processamento para a variável resposta `Y` com todas as outras variáveis como preditoras
  step_smote(Y) %>%             # SMOTE para balancear as classes da variável `Y` (gera novos exemplos sintéticos da classe minoritária)
  prep() %>%                    # Prepara a receita, estimando os parâmetros necessários para a transformação
  juice()                       # Extrai os dados transformados para serem usados no modelo



# Aumentar ntree para 500 ou 1000 pode melhorar o desempenho
rf_model.3 <- randomForest(Y ~ ., 
                           data = train_data.3, 
                           ntree = 1000)


# Fazer previsões
rf_pred.3 <- predict(rf_model.3, 
                     test_data, 
                     type = "class")

# Avaliação do modelo
conf_matrix.3 <- confusionMatrix(rf_pred.3, test_data$Y)
print(conf_matrix.3)

# Métricas de performance
accuracy.3 <- conf_matrix.3$overall["Accuracy"]
precision.3 <- conf_matrix.3$byClass["Precision"]
recall.3 <- conf_matrix.3$byClass["Recall"]
F1_score.3 <- 2 * (precision * recall) / (precision + recall)

cat("\nDesempenho do modelo Random Forest:\n")
cat("Acurácia:", accuracy.3, "\n")
cat("Precisão:", precision.3, "\n")
cat("Recall:", recall.3, "\n")
cat("F1-score:", F1_score.3, "\n")

# Importância das variáveis
varImpPlot(rf_model.3)



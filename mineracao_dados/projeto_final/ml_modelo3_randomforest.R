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

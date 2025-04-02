
## Random Forest ----

{
tic("Tempo de treinamento do modelo")
rf_model <- randomForest(Y ~ .,
                         data = train_data, 
                         ntree = 100,         # Número de árvores na floresta
                         mtry = sqrt(ncol(train_data) - 1),  # Número de variáveis usadas em cada divisão
                         importance = TRUE)   # Habilitar cálculo de importância das variáveis
toc()
}

# Prever probabilidades no conjunto de teste
rf_probs <- predict(rf_model, test_x, type = "prob")

# Probabilidades associadas à classe positiva
positive_probs <- rf_probs[, 2]  # Coluna para a classe "1" (positiva)

# Avaliação do modelo
rf_predictions <- predict(rf_model, test_x)  # Previsões de classe
conf_matrix <- confusionMatrix(rf_predictions, test_y)
print(conf_matrix)

# Métricas de performance
accuracy <- conf_matrix$overall["Accuracy"]
precision <- conf_matrix$byClass["Precision"]
recall <- conf_matrix$byClass["Recall"]
F1_score <- 2 * (precision * recall) / (precision + recall)

cat("\nDesempenho do modelo Random Forest:\n")
cat("Acurácia:", accuracy, "\n")
cat("Precisão:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1-score:", F1_score, "\n")


# Criar dataframe para o Lift Chart
lift_data <- data.frame(
  true_labels = as.integer(as.factor(test_y)) - 1,  # Converter para 0/1
  positive_probs = positive_probs
)

# Ordenar por probabilidade predita e calcular cumulativos
lift_data <- lift_data %>%
  arrange(desc(positive_probs)) %>%
  mutate(
    cum_positives = cumsum(true_labels),  # Soma cumulativa dos positivos
    total_instances = row_number()       # Número total acumulado
  )

# Criar baseline (reta diagonal perfeita)
total_positives <- sum(lift_data$true_labels)
lift_data_baseline <- data.frame(
  total_instances = 1:nrow(lift_data),
  cum_positives_baseline = seq(0, total_positives, length.out = nrow(lift_data))
)

# Criar curva ideal (ótimo teórico)
lift_data_best <- lift_data %>%
  arrange(desc(true_labels)) %>%  # Ordenar todos os positivos antes
  mutate(
    cum_positives_best = cumsum(true_labels),  # Soma cumulativa dos positivos
    total_instances_best = row_number()       # Instâncias acumuladas
  )

# Lift Chart
ggplot() +
  geom_line(data = lift_data, aes(x = total_instances, y = cum_positives, color = "Modelo"), size = 1) +
  geom_line(data = lift_data_baseline, aes(x = total_instances, y = cum_positives_baseline, color = "Baseline"), linetype = "dotted", size = 1) +
  geom_line(data = lift_data_best, aes(x = total_instances_best, y = cum_positives_best, color = "Ótimo Teórico"), linetype = "dashed", size = 1) +
  labs(title = "Lift Chart - Modelo Random Forest",
       x = "Número Total de Dados",
       y = "Número Cumulativo de Positivos",
       color = "Curvas") +
  theme_minimal() +
  scale_color_manual(values = c("Modelo" = "blue", "Baseline" = "red", "Ótimo Teórico" = "black"))

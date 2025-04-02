



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
  labs(title = "Lift Chart - Modelo KNN",
       x = "Número Total de Dados",
       y = "Número Cumulativo de Positivos",
       color = "Curvas") +
  theme_minimal() +
  scale_color_manual(values = c("Modelo" = "blue", "Baseline" = "red", "Ótimo Teórico" = "black"))

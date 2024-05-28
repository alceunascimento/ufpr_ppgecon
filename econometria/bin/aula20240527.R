unique_name_count <- df %>%
  summarise(unique_count = n_distinct(name_short))

unique_name_count



# Obter valores únicos da variável setor_naics
unique_setor_economia <- df %>%
  distinct(setor_economia)

# Exibir o resultado
unique_setor_economia

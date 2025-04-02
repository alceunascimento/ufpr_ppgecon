#!/usr/bin/env Rscript


# Remover a coluna ID, pois não é relevante para a modelagem
data <- data %>% select(-ID)

# Renomear a coluna alvo corretamente
colnames(data)[colnames(data) == "DEFAULT"] <- "Y"

# Converter a variável Y para fator
data$Y <- as.factor(data$Y)

# Verificar a estrutura corrigida dos dados
str(data)

# Separar em treino (70%) e teste (30%)
set.seed(123)
index <- createDataPartition(data$Y, 
                             p = 0.7, 
                             list = FALSE)
train_data <- data[index, ]
test_data <- data[-index, ]

# Lista de variáveis categóricas que não devem ser normalizadas
categorical_vars <- c("SEX", 
                      "EDUCATION", 
                      "MARRIAGE", 
                      "PAY_0", 
                      "PAY_2", 
                      "PAY_3", 
                      "PAY_4", 
                      "PAY_5", 
                      "PAY_6")

# Função para converter colunas específicas em fatores
convert_to_factors <- function(df, cat_vars) {
  df[cat_vars] <- lapply(df[cat_vars], as.factor)
  return(df)
}

# Aplicar a conversão para fatores no conjunto de treino e teste
train_data <- convert_to_factors(train_data, categorical_vars)
test_data <- convert_to_factors(test_data, categorical_vars)

# Verificar a conversão
str(train_data[categorical_vars])
str(test_data[categorical_vars])

# Identificar as colunas numéricas que devem ser normalizadas
numeric_vars <- setdiff(names(train_data), c(categorical_vars, "Y"))  # Excluir as categóricas e a variável resposta

# Normalizar apenas as variáveis numéricas
norm_params <- preProcess(train_data[, numeric_vars], method = c("range"))
train_data[, numeric_vars] <- predict(norm_params, train_data[, numeric_vars])
test_data[, numeric_vars] <- predict(norm_params, test_data[, numeric_vars])


# Definir os preditores e a variável resposta
train_x <- train_data[, -ncol(train_data)]
train_y <- train_data$Y
test_x <- test_data[, -ncol(test_data)]
test_y <- test_data$Y

str(train_x)

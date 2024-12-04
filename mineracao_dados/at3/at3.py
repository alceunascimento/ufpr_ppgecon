


# 15.	Resolva as questões abaixo (valor: 30 pontos)
# a)	Resolver utilizando o ID3 com recursividade no Excel e apresentar as árvores finais:
"""
| ESPORTE PREFERIDO?  | PAÍS?    | ALIMENTO PREFERIDO  | COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA? |
|---------------------|----------|---------------------|----------------------------------------------|
| Futebol             | Brasil   | Feijoada            | Sim                                          |
| Natação             | EUA      | Salada              | Sim                                          |
| Futebol             | França   | Macarronada         | Não                                          |
| Natação             | Brasil   | Salada              | Não                                          |
| Futebol             | Brasil   | Macarronada         | Não                                          |
| Triatlo             | França   | Macarronada         | Não                                          |
| Triatlo             | EUA      | Salada              | Sim                                          |
| Futebol             | EUA      | Feijoada            | Sim                                          |
| Triatlo             | Brasil   | Feijoada            | Não                                          |
| Triatlo             | França   | Feijoada            | Sim                                          |
| Futebol             | Brasil   | Macarronada         | Não                                          |
| Natação             | França   | Salada              | Sim                                          |
| Futebol             | Brasil   | Feijoada            | Não                                          |
"""

import math
import pandas as pd
import numpy as np

# Dataset
data = [
    {'Esporte Preferido': 'Futebol', 'País': 'Brasil', 'Alimento Preferido': 'Feijoada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Natação', 'País': 'EUA', 'Alimento Preferido': 'Salada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Futebol', 'País': 'França', 'Alimento Preferido': 'Macarronada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Natação', 'País': 'Brasil', 'Alimento Preferido': 'Salada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Futebol', 'País': 'Brasil', 'Alimento Preferido': 'Macarronada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Triatlo', 'País': 'França', 'Alimento Preferido': 'Macarronada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Triatlo', 'País': 'EUA', 'Alimento Preferido': 'Salada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Futebol', 'País': 'EUA', 'Alimento Preferido': 'Feijoada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Triatlo', 'País': 'Brasil', 'Alimento Preferido': 'Feijoada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Triatlo', 'País': 'França', 'Alimento Preferido': 'Feijoada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Futebol', 'País': 'Brasil', 'Alimento Preferido': 'Macarronada', 'Comprou Livro Vegetariano': 'Não'},
    {'Esporte Preferido': 'Natação', 'País': 'França', 'Alimento Preferido': 'Salada', 'Comprou Livro Vegetariano': 'Sim'},
    {'Esporte Preferido': 'Futebol', 'País': 'Brasil', 'Alimento Preferido': 'Feijoada', 'Comprou Livro Vegetariano': 'Não'}
]

df = pd.DataFrame(data)

# Function to calculate entropy
def entropy(target_col):
    elements, counts = np.unique(target_col, return_counts=True)
    entropy_value = 0
    for i in range(len(elements)):
        probability = counts[i]/np.sum(counts)
        entropy_value -= probability * math.log2(probability)
    return entropy_value

# Function to calculate Information Gain
def info_gain(data, split_attribute_name, target_name="Comprou Livro Vegetariano"):
    total_entropy = entropy(data[target_name])
    # Calculate the values and the corresponding counts for the split attribute
    vals, counts = np.unique(data[split_attribute_name], return_counts=True)
    # Calculate the weighted entropy
    weighted_entropy = 0
    for i in range(len(vals)):
        subset = data[data[split_attribute_name] == vals[i]]
        probability = counts[i]/np.sum(counts)
        subset_entropy = entropy(subset[target_name])
        weighted_entropy += probability * subset_entropy
    # Information Gain
    information_gain = total_entropy - weighted_entropy
    return information_gain

# ID3 Algorithm
def ID3(data, originaldata, features, target_attribute_name="Comprou Livro Vegetariano", parent_node_class = None):
    # If all target_values have the same value, return this value
    if len(np.unique(data[target_attribute_name])) <= 1:
        return np.unique(data[target_attribute_name])[0]
    # If the dataset is empty, return the mode target feature value in the original dataset
    elif len(data)==0:
        return np.unique(originaldata[target_attribute_name])[np.argmax(np.unique(originaldata[target_attribute_name], return_counts=True)[1])]
    # If the feature space is empty, return the parent node class
    elif len(features) ==0:
        return parent_node_class
    else:
        # Set the parent node class to the mode target feature value of the current node
        parent_node_class = np.unique(data[target_attribute_name])[np.argmax(np.unique(data[target_attribute_name], return_counts=True)[1])]
        # Select the feature which best splits the dataset
        item_values = [info_gain(data, feature, target_attribute_name) for feature in features]
        best_feature_index = np.argmax(item_values)
        best_feature = features[best_feature_index]
        # Create the tree structure
        tree = {best_feature:{}}
        # Remove the best feature from the feature list
        features = [i for i in features if i != best_feature]
        # Grow a branch under the root node for each possible value of the best feature
        for value in np.unique(data[best_feature]):
            # Create a subset of the data
            sub_data = data[data[best_feature] == value]
            # Call ID3 algorithm for each subset
            subtree = ID3(sub_data, data, features, target_attribute_name, parent_node_class)
            # Add the subtree to the tree
            tree[best_feature][value] = subtree
        return tree

# Features
features = df.columns.tolist()
features.remove('Comprou Livro Vegetariano')

# Build the tree
tree = ID3(df, df, features)

# Function to print the tree
def print_tree(tree, indent=""):
    if isinstance(tree, dict):
        for key in tree.keys():
            print(f"{indent}{key}")
            for value in tree[key].keys():
                print(f"{indent}  {value} ->")
                print_tree(tree[key][value], indent + "    ")
    else:
        print(f"{indent}{tree}")

# Print the tree
print_tree(tree)














# b)	Resolver utilizando o ID3 com recursividade no Excel e apresentar as árvores finais:

"""
| ID  | PAÍS       | DOCE       | FRUTA     | IDADE | Compra? |
|-----|------------|------------|-----------|-------|---------|
| 1   | Argentina  | Bala       | Banana    | A     | Sim     |
| 2   | Brasil     | Chocolate  | Banana    | A     | Sim     |
| 3   | Brasil     | Bala       | Laranja   | C     | Não     |
| 4   | Brasil     | Sorvete    | Banana    | C     | Não     |
| 5   | Brasil     | Sorvete    | Laranja   | B     | Não     |
| 6   | Brasil     | Chocolate  | Banana    | A     | Não     |
| 7   | EUA        | Chocolate  | Laranja   | A     | Sim     |
| 8   | EUA        | Sorvete    | Laranja   | B     | Sim     |
| 9   | EUA        | Sorvete    | Laranja   | B     | Sim     |
| 10  | Suíça      | Chocolate  | Laranja   | A     | Sim     |
| 11  | Suíça      | Chocolate  | Banana    | A     | Não     |
| 12  | Suíça      | Bala       | Banana    | C     | Sim     |
"""

# Agora utilize o Weka com a opção de teste Dados de Treinamento, método C4.5 (J48), execute, visualize a árvore, insira aqui e compare os resultados obtidos.

# c)	Resolver pelo C4.5 : Três faixas para temperatura e duas para umidade, apresentar as árvores sem recursividade com e sem poda. 
# # Utilize o pelo método de corte fechando o intervalo  no <=	

"""
| ID  | Tempo       | Temperatura | Umidade | Vento | Joga? |
|-----|-------------|-------------|---------|-------|-------|
| 1   | Ensolarado  | 85          | 85      | Não   | Não   |
| 2   | Ensolarado  | 80          | 90      | Sim   | Não   |
| 3   | Nublado     | 83          | 86      | Não   | Sim   |
| 4   | Chuvoso     | 70          | 96      | Não   | Sim   |
| 5   | Chuvoso     | 68          | 80      | Não   | Sim   |
| 6   | Chuvoso     | 65          | 70      | Sim   | Não   |
| 7   | Nublado     | 64          | 65      | Sim   | Sim   |
| 8   | Ensolarado  | 72          | 95      | Não   | Não   |
| 9   | Ensolarado  | 69          | 70      | Não   | Sim   |
| 10  | Chuvoso     | 75          | 80      | Não   | Sim   |
| 11  | Ensolarado  | 75          | 70      | Sim   | Sim   |
| 12  | Nublado     | 72          | 90      | Sim   | Sim   |
| 13  | Nublado     | 81          | 75      | Não   | Sim   |
| 14  | Chuvoso     | 71          | 91      | Sim   | Não   |
"""			
									
# Classificar, utilizando a árvore de decisão após a poda e os seguintes exemplos:

"""
| ID  | Tempo       | Temperatura | Umidade | Vento | Joga? | Classificação prevista? |
|-----|-------------|-------------|---------|-------|-------|--------------------------|
| 15  | Ensolarado  | 52          | 70      | Sim   | Não   |                          |
| 16  | Ensolarado  | 84          | 52      | Não   | Sim   |                          |
| 17  | Chuvoso     | 68          | 87      | Não   | Sim   |                          |
| 18  | Ensolarado  | 77          | 84      | Não   | Não   |                          |
| 19  | Chuvoso     | 86          | 65      | Sim   | Sim   |                          |
"""

# Qual a taxa de acerto encontrada? _______________
									
									
# Classificar, utilizando a árvore de decisão após a poda e os seguintes exemplos:

"""
| ID  | Tempo       | Temperatura | Umidade | Vento | Classificação prevista? |
|-----|-------------|-------------|---------|-------|--------------------------|
| 20  | Nublado     | 84          | 65      | Sim   |                          |
| 21  | Nublado     | 90          | 58      | Sim   |                          |
| 22  | Ensolarado  | 86          | 86      | Sim   |                          |
| 23  | Ensolarado  | 59          | 90      | Sim   |                          |
| 24  | Chuvoso     | 69          | 89      | Sim   |                          |
| 25  | Chuvoso     | 80          | 87      | Sim   |                          |
"""
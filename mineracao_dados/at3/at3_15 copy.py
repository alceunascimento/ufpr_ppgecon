import math
from collections import Counter

def calculate_entropy(data, target_attribute):
    target_values = [row[target_attribute] for row in data]
    value_counts = Counter(target_values)
    total_instances = len(data)

    entropy = 0
    for count in value_counts.values():
        probability = count / total_instances
        entropy -= probability * math.log2(probability)

    return entropy

def calculate_information_gain(data, split_attribute, target_attribute):
    total_entropy = calculate_entropy(data, target_attribute)
    
    # Group data by the values of the split_attribute
    grouped_data = {}
    for row in data:
        grouped_data.setdefault(row[split_attribute], []).append(row)

    split_entropy = 0
    total_instances = len(data)

    for subset in grouped_data.values():
        subset_probability = len(subset) / total_instances
        split_entropy += subset_probability * calculate_entropy(subset, target_attribute)

    information_gain = total_entropy - split_entropy
    return information_gain

def find_best_attribute(data, attributes, target_attribute):
    best_attribute = None
    best_gain = -float('inf')

    for attribute in attributes:
        gain = calculate_information_gain(data, attribute, target_attribute)
        if gain > best_gain:
            best_gain = gain
            best_attribute = attribute

    return best_attribute

def id3(data, attributes, target_attribute):
    # Base cases
    target_values = [row[target_attribute] for row in data]
    if len(set(target_values)) == 1:
        return target_values[0]  # Pure node

    if not attributes:
        # Return the majority class if no attributes are left
        return Counter(target_values).most_common(1)[0][0]

    # Recursive case
    best_attribute = find_best_attribute(data, attributes, target_attribute)
    tree = {best_attribute: {}}

    grouped_data = {}
    for row in data:
        grouped_data.setdefault(row[best_attribute], []).append(row)

    for value, subset in grouped_data.items():
        if not subset:
            # If subset is empty, use majority class of current node
            tree[best_attribute][value] = Counter(target_values).most_common(1)[0][0]
        else:
            remaining_attributes = [attr for attr in attributes if attr != best_attribute]
            tree[best_attribute][value] = id3(subset, remaining_attributes, target_attribute)

    return tree

def print_tree(tree, depth=0):
    if not isinstance(tree, dict):
        print("|   " * depth + f"-> {tree}")
        return
    
    for key, subtree in tree.items():
        if isinstance(subtree, dict):
            print("|   " * depth + f"[{key}]")
            print_tree(subtree, depth + 1)
        else:
            print("|   " * depth + f"[{key}] -> {subtree}")

# Dataset
columns = ["ESPORTE PREFERIDO", "PAÍS", "ALIMENTO PREFERIDO", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA"]
data = [
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Feijoada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Natação", "PAÍS": "EUA", "ALIMENTO PREFERIDO": "Salada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "França", "ALIMENTO PREFERIDO": "Macarronada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Natação", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Salada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Macarronada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Triatlo", "PAÍS": "França", "ALIMENTO PREFERIDO": "Macarronada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Triatlo", "PAÍS": "EUA", "ALIMENTO PREFERIDO": "Salada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "EUA", "ALIMENTO PREFERIDO": "Feijoada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Triatlo", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Feijoada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Triatlo", "PAÍS": "França", "ALIMENTO PREFERIDO": "Feijoada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Macarronada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"},
    {"ESPORTE PREFERIDO": "Natação", "PAÍS": "França", "ALIMENTO PREFERIDO": "Salada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Sim"},
    {"ESPORTE PREFERIDO": "Futebol", "PAÍS": "Brasil", "ALIMENTO PREFERIDO": "Feijoada", "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA": "Não"}
]

# Attributes and target attribute
attributes = ["ESPORTE PREFERIDO", "PAÍS", "ALIMENTO PREFERIDO"]
target_attribute = "COMPROU NOVO LIVRO DE CULINÁRIA VEGETARIANA"

# Build the decision tree
decision_tree = id3(data, attributes, target_attribute)

# Print the decision tree
print("Decision Tree:")
print_tree(decision_tree)

# Save the decision tree to a .txt file
def save_tree_to_file(tree, file_path):
    with open(file_path, "w") as file:
        def write_tree(subtree, depth=0):
            if not isinstance(subtree, dict):
                file.write("|   " * depth + f"-> {subtree}\n")
                return
            
            for key, branch in subtree.items():
                if isinstance(branch, dict):
                    file.write("|   " * depth + f"[{key}]\n")
                    write_tree(branch, depth + 1)
                else:
                    file.write("|   " * depth + f"[{key}] -> {branch}\n")
        
        write_tree(tree)

save_tree_to_file(decision_tree, "./mineracao_dados/at3/decision_tree.txt")

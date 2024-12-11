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

def find_best_attribute(data, attributes, target_attribute, thresholds):
    best_attribute = None
    best_gain = -float('inf')
    best_threshold = None

    for attribute in attributes:
        if attribute in thresholds:
            for threshold in thresholds[attribute]:
                data_split = [{**row, attribute: f"<= {threshold}" if row[attribute] <= threshold else f"> {threshold}"} for row in data]
                gain = calculate_information_gain(data_split, attribute, target_attribute)
                if gain > best_gain:
                    best_gain = gain
                    best_attribute = attribute
                    best_threshold = threshold

    return best_attribute, best_threshold

def c45(data, attributes, target_attribute, thresholds):
    target_values = [row[target_attribute] for row in data]
    if len(set(target_values)) == 1:
        return target_values[0]  # Pure node

    if not attributes:
        return Counter(target_values).most_common(1)[0][0]  # Majority class

    best_attribute, best_threshold = find_best_attribute(data, attributes, target_attribute, thresholds)

    if best_attribute is None:
        return Counter(target_values).most_common(1)[0][0]  # Fallback to majority class

    if best_attribute in thresholds:
        data = [{**row, best_attribute: f"<= {best_threshold}" if row[best_attribute] <= best_threshold else f"> {best_threshold}"} for row in data]

    tree = {best_attribute: {}}

    grouped_data = {}
    for row in data:
        grouped_data.setdefault(row[best_attribute], []).append(row)

    for value, subset in grouped_data.items():
        remaining_attributes = [attr for attr in attributes if attr != best_attribute]
        tree[best_attribute][value] = c45(subset, remaining_attributes, target_attribute, thresholds)

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
columns = ["Tempo", "Temperatura", "Umidade", "Vento", "Joga?"]
data = [
    {"Tempo": "Ensolarado", "Temperatura": 85, "Umidade": 85, "Vento": "Não", "Joga?": "Não"},
    {"Tempo": "Ensolarado", "Temperatura": 80, "Umidade": 90, "Vento": "Sim", "Joga?": "Não"},
    {"Tempo": "Nublado", "Temperatura": 83, "Umidade": 86, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 70, "Umidade": 96, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 68, "Umidade": 80, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 65, "Umidade": 70, "Vento": "Sim", "Joga?": "Não"},
    {"Tempo": "Nublado", "Temperatura": 64, "Umidade": 65, "Vento": "Sim", "Joga?": "Sim"},
    {"Tempo": "Ensolarado", "Temperatura": 72, "Umidade": 95, "Vento": "Não", "Joga?": "Não"},
    {"Tempo": "Ensolarado", "Temperatura": 69, "Umidade": 70, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 75, "Umidade": 80, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Ensolarado", "Temperatura": 75, "Umidade": 70, "Vento": "Sim", "Joga?": "Sim"},
    {"Tempo": "Nublado", "Temperatura": 72, "Umidade": 90, "Vento": "Sim", "Joga?": "Sim"},
    {"Tempo": "Nublado", "Temperatura": 81, "Umidade": 75, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 71, "Umidade": 91, "Vento": "Sim", "Joga?": "Não"}
]

# Attributes and target attribute
attributes = ["Tempo", "Temperatura", "Umidade", "Vento"]
target_attribute = "Joga?"
thresholds = {
    "Temperatura": [65, 75, 85],
    "Umidade": [70, 80, 90]
}

# Build the decision tree
decision_tree = c45(data, attributes, target_attribute, thresholds)

# Print the decision tree
print("Decision Tree:")
print_tree(decision_tree)


def classify(tree, instance):
    if not isinstance(tree, dict):
        return tree
    attribute = next(iter(tree))
    value = instance[attribute]
    for condition, subtree in tree[attribute].items():
        threshold = float(condition.split()[1])
        if ("<=" in condition and value <= threshold) or (">" in condition and value > threshold):
            return classify(subtree, instance)

# Novos exemplos
new_data = [
    {"Tempo": "Ensolarado", "Temperatura": 52, "Umidade": 70, "Vento": "Sim", "Joga?": "Não"},
    {"Tempo": "Ensolarado", "Temperatura": 84, "Umidade": 52, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 68, "Umidade": 87, "Vento": "Não", "Joga?": "Sim"},
    {"Tempo": "Ensolarado", "Temperatura": 77, "Umidade": 84, "Vento": "Não", "Joga?": "Não"},
    {"Tempo": "Chuvoso", "Temperatura": 86, "Umidade": 65, "Vento": "Sim", "Joga?": "Sim"}
]

# Classificar os novos exemplos
correct = 0
for instance in new_data:
    predicted = classify(decision_tree, instance)
    print(f"Instance: {instance} => Predicted: {predicted}, Actual: {instance['Joga?']}")
    if predicted == instance["Joga?"]:
        correct += 1

# Taxa de acerto
accuracy = correct / len(new_data)
print(f"Accuracy: {accuracy * 100:.2f}%")



# New examples
new_data = [
    {"Tempo": "Nublado", "Temperatura": 84, "Umidade": 65, "Vento": "Sim"},
    {"Tempo": "Nublado", "Temperatura": 90, "Umidade": 58, "Vento": "Sim"},
    {"Tempo": "Ensolarado", "Temperatura": 86, "Umidade": 86, "Vento": "Sim"},
    {"Tempo": "Ensolarado", "Temperatura": 59, "Umidade": 90, "Vento": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 69, "Umidade": 89, "Vento": "Sim"},
    {"Tempo": "Chuvoso", "Temperatura": 80, "Umidade": 87, "Vento": "Sim"}
]

# Classify new examples
for idx, instance in enumerate(new_data, start=20):
    predicted = classify(decision_tree, instance)
    print(f"ID {idx}: Predicted = {predicted}")
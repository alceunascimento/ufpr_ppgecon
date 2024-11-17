import math

# DATA
data = [
    ['A', 'Azul', 'G', 'Sim'],
    ['A', 'Vermelho', 'M', 'Não'],
    ['B', 'Azul', 'M', 'Não'],
    ['B', 'Vermelho', 'P', 'Não'],
    ['A', 'Azul', 'G', 'Sim'],
    ['A', 'Azul', 'P', 'Não'],
    ['A', 'Vermelho', 'P', 'Sim'],
    ['B', 'Azul', 'G', 'Não'],
    ['A', 'Azul', 'P', 'Sim']
]

def calculate_entropy(subset):
    total = len(subset)
    if total == 0:
        return 0
    sim_count = sum(1 for row in subset if row[-1] == 'Sim')
    nao_count = sum(1 for row in subset if row[-1] == 'Não')
    p_sim = sim_count / total
    p_nao = nao_count / total
    
    entropy = 0
    if p_sim > 0:
        entropy -= p_sim * math.log2(p_sim)
    if p_nao > 0:
        entropy -= p_nao * math.log2(p_nao)
    return entropy

def calculate_gain(subset, attr_idx):
    if not subset:
        return 0
        
    total_entropy = calculate_entropy(subset)
    values = set(row[attr_idx] for row in subset)
    weighted_entropy = 0
    
    for value in values:
        value_subset = [row for row in subset if row[attr_idx] == value]
        prob = len(value_subset) / len(subset)
        weighted_entropy += prob * calculate_entropy(value_subset)
    
    return total_entropy - weighted_entropy

# FIRST LEVEL - Root calculations
print("=== FIRST LEVEL - ROOT NODE ===")
total_entropy = calculate_entropy(data)
print(f"\nEntropia Total do Dataset = {total_entropy:.4f}")

attributes = ['Faixa etária', 'Cor', 'Tamanho']
first_level_gains = {}
for attr_idx, attr_name in enumerate(attributes):
    gain = calculate_gain(data, attr_idx)
    first_level_gains[attr_name] = gain
    print(f"Ganho({attr_name}) = {gain:.4f}")

# SECOND LEVEL - After choosing Faixa etária
print("\n=== SECOND LEVEL - AFTER FAIXA ETÁRIA SPLIT ===")

# Split data by Faixa etária
faixa_values = {'A': [], 'B': []}
for row in data:
    faixa_values[row[0]].append(row)

remaining_attributes = ['Cor', 'Tamanho']

for faixa, subset in faixa_values.items():
    print(f"\nFaixa etária = {faixa} (n={len(subset)})")
    print(f"Entropia do subconjunto = {calculate_entropy(subset):.4f}")
    
    # Calculate gains for remaining attributes
    second_level_gains = {}
    for attr_name in remaining_attributes:
        attr_idx = attributes.index(attr_name)
        gain = calculate_gain(subset, attr_idx)
        second_level_gains[attr_name] = gain
        print(f"Ganho({attr_name}) = {gain:.4f}")
    
    # Sort and display ranking for this subset
    sorted_gains = sorted(second_level_gains.items(), key=lambda x: x[1], reverse=True)
    print(f"\nRanking for Faixa etária = {faixa}:")
    print("Feature | Gain")
    print("-" * 20)
    for i, (feature, gain) in enumerate(sorted_gains, 1):
        rank = "Most gain" if i == 1 else "Second most gain"
        print(f"{feature} | {gain:.4f} ({rank})")

# Summary of best splits for each branch
print("\n=== TREE STRUCTURE BASED ON GAINS ===")
print("Root (Faixa etária):")
for faixa, subset in faixa_values.items():
    print(f"└── Faixa etária = {faixa}:")
    sorted_gains = sorted([(attr, calculate_gain(subset, attributes.index(attr))) 
                          for attr in remaining_attributes], 
                         key=lambda x: x[1], reverse=True)
    best_attr, best_gain = sorted_gains[0]
    print(f"    ├── Best split: {best_attr} (Gain = {best_gain:.4f})")
    values = set(row[attributes.index(best_attr)] for row in subset)
    for value in values:
        final_subset = [row for row in subset if row[attributes.index(best_attr)] == value]
        sim_count = sum(1 for row in final_subset if row[-1] == 'Sim')
        nao_count = sum(1 for row in final_subset if row[-1] == 'Não')
        print(f"    │   ├── {value}: {len(final_subset)} examples (Sim={sim_count}, Não={nao_count})")
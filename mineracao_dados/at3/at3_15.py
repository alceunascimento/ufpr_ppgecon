import math
import pandas as pd
import numpy as np
from sklearn import tree
import matplotlib.pyplot as plt
from sklearn.preprocessing import LabelEncoder
import graphviz

# Inform the user that the process is starting
print("Starting decision tree process...")

# Step 1: Load the dataset
print("\nStep 1: Loading dataset...")
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

# Convert dataset into a pandas DataFrame
df = pd.DataFrame(data)
print("Dataset loaded successfully!")
print(df)

# Step 2: Encode categorical variables
print("\nStep 2: Encoding categorical variables...")
label_encoders = {}
for column in df.columns:
    print(f"Encoding column: {column}")
    le = LabelEncoder()
    df[column] = le.fit_transform(df[column])
    label_encoders[column] = le
    print(f"Mapping for '{column}': {dict(zip(le.classes_, le.transform(le.classes_)))}")
print("Encoding complete!")
print("\nEncoded DataFrame:")
print(df)

# Step 3: Separate features (X) and target (y)
print("\nStep 3: Separating features and target...")
X = df.drop('Comprou Livro Vegetariano', axis=1)
y = df['Comprou Livro Vegetariano']
print("Features (X):")
print(X)
print("Target (y):")
print(y)

# Step 4: Build the decision tree classifier
print("\nStep 4: Building the decision tree classifier...")
clf = tree.DecisionTreeClassifier(criterion='entropy', random_state=0)
clf = clf.fit(X, y)
print("Decision tree classifier built successfully!")

# Step 5: Visualize the decision tree
print("\nStep 5: Visualizing the decision tree...")
feature_names = X.columns
class_names = label_encoders['Comprou Livro Vegetariano'].classes_
print(f"Feature names: {list(feature_names)}")
print(f"Class names: {list(class_names)}")

dot_data = tree.export_graphviz(
    clf,
    out_file=None,
    feature_names=feature_names,
    class_names=class_names,
    filled=True,
    rounded=True,
    special_characters=True,
    label='all',
    impurity=False
)

graph = graphviz.Source(dot_data)
output_path = "/mineracao_dados/at3/decision_tree"
graph.render(output_path)
print(f"Decision tree visualization saved at: {output_path}.pdf")

# Final message to user
print("\nProcess complete! The decision tree has been generated and saved.")

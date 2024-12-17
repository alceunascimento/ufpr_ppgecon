import os
import duckdb
import glob
import json
from tqdm import tqdm
from datetime import datetime

# Paths
data_path = os.path.expanduser("~/Documents/data/alvaras")  # JSON directory
db_path = "~/Documents/data/alvaras.duckdb"  # DuckDB file

# Connect to the DuckDB database
conn = duckdb.connect(db_path)

# Helper functions
def to_integer(value):
    """Convert a string to an integer."""
    try:
        return int(value) if value else None
    except ValueError:
        return None

def to_real(value):
    """Convert a string to a float, replacing ',' with '.'."""
    try:
        return float(value.replace(",", ".")) if value else None
    except ValueError:
        return None

def to_date(value):
    """Convert a string to a date."""
    try:
        return datetime.strptime(value, "%d/%m/%Y").date() if value else None
    except ValueError:
        return None

def get_or_create_tipo_doc_id(conn, descricao):
    """Retrieve or create `tipo_doc_id` for a given `descricao`."""
    query = """
    SELECT tipo_doc_id FROM imobiliario.dim_tipo_documento WHERE descricao = ?;
    """
    result = conn.execute(query, (descricao,)).fetchone()
    if result:
        return result[0]
    conn.execute("INSERT INTO imobiliario.dim_tipo_documento (descricao) VALUES (?);", (descricao,))
    query_new_id = "SELECT tipo_doc_id FROM imobiliario.dim_tipo_documento WHERE descricao = ?;"
    return conn.execute(query_new_id, (descricao,)).fetchone()[0]

def insert_data(conn, table_name, data):
    """Insert data into a specified table."""
    placeholders = ", ".join(["?"] * len(data))
    query = f"INSERT INTO imobiliario.{table_name} VALUES ({placeholders})"
    conn.execute(query, data)

# Get list of JSON files
json_files = glob.glob(os.path.join(data_path, "*.json"))

# Check if there are JSON files
if not json_files:
    print("No JSON files found in the specified directory.")
    exit()

# Initialize progress bar
print(f"Found {len(json_files)} JSON files.")
progress_bar = tqdm(total=len(json_files), desc="Processing files", unit="file")

# Process each JSON file
for file in json_files:
    try:
        # Read the JSON file
        with open(file, "r", encoding="utf-8") as f:
            json_data = json.load(f)

        # Resolve `tipo_doc_id`
        tipo_doc_id = get_or_create_tipo_doc_id(conn, json_data.get("Tipo do Documento:"))

        # Insert into `fato_permits`
        fato_permits = (
            to_integer(json_data.get("Número do Documento:")),
            json_data.get("Indicação Fiscal:"),
            tipo_doc_id,
            None,  # Resolve `finalidade_id` dynamically if needed
            None,  # Resolve `proprietario_id` dynamically if needed
            json_data.get("Localização:"),
            json_data.get("Inscrição Imobiliária:"),
            json_data["Autor Projeto:"].get("Nome"),
            to_integer(json_data["Autor Projeto:"].get("Número ART/RRT:")),
            json_data["Responsável Técnico:"].get("Nome"),
            to_integer(json_data["Responsável Técnico:"].get("Número ART/RRT:")),
            to_integer(json_data.get("Construtora:")),
            to_date(json_data.get("Limite Início Obra:")),
            to_date(json_data.get("Limite Conclusão Obra:")),
            to_integer(json_data.get("Concluído de Acordo com o Alvará:")),
            json_data.get("Processo Vistoria:"),
            json_data.get("Vistoriado por:"),
            json_data.get("Tipo da Vistoria:"),
            json_data.get("Observações:"),
        )
        insert_data(conn, "fato_permits", fato_permits)

        # Insert into `fato_dados_lote`
        fato_dados_lote = (
            to_integer(json_data.get("Número do Documento:")),
            to_real(json_data.get("Área Atingida:")),
            to_real(json_data.get("Área Remanescente:")),
            to_real(json_data.get("Área Total (m2):")),
            to_real(json_data.get("Área Original do Lote (m2):")),
        )
        insert_data(conn, "fato_dados_lote", fato_dados_lote)

        # Insert into `fato_dados_edificacao`
        fato_dados_edificacao = (
            to_integer(json_data.get("Número do Documento:")),
            None,  # Resolve `uso_id` dynamically if needed
            to_integer(json_data["DadosEdificacao"].get("Qtde Unidades")),
            to_real(json_data["DadosEdificacao"].get("Área Total Destinada ao Uso")),
            json_data["DadosEdificacao"].get("Estrutura / Vedação"),
            to_integer(json_data.get("Qtde de Pavimentos:")),
            to_integer(json_data.get("Qtde de Elevadores:")),
            to_integer(json_data.get("Qtde de Subsolos:")),
            to_real(json_data.get("Extenção do Muro Frontal:")),
            to_integer(json_data.get("Qtde de Blocos:")),
            to_real(json_data.get("Altura total da Edificação(m):")),
            to_integer(json_data.get("Qtde Vagas Estac. Coberto:")),
            to_integer(json_data.get("Qtde Vagas Estac. Descoberto:")),
        )
        insert_data(conn, "fato_dados_edificacao", fato_dados_edificacao)

        # Insert into `fato_areas_computaveis`
        fato_areas_computaveis = (
            to_integer(json_data.get("Número do Documento:")),
            to_real(json_data["Áreas Computáveis (m2)"].get("Anterior / Existente:")),
            to_real(json_data["Áreas Computáveis (m2)"].get("A Demolir / Suprimir:")),
            to_real(json_data["Áreas Computáveis (m2)"].get("Pavimento Térreo:")),
            to_real(json_data["Áreas Computáveis (m2)"].get("Outros Pavimentos:")),
            to_real(json_data["Áreas Computáveis (m2)"].get("Total:")),
        )
        insert_data(conn, "fato_areas_computaveis", fato_areas_computaveis)

        # Insert into `fato_areas_nao_computaveis`
        fato_areas_nao_computaveis = (
            to_integer(json_data.get("Número do Documento:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Anterior / Existente:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("A Demolir / Suprimir:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Subsolo:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Sótão:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Ático:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Outras Áreas:")),
            to_real(json_data["Áreas Não Computáveis (m2)"].get("Total:")),
        )
        insert_data(conn, "fato_areas_nao_computaveis", fato_areas_nao_computaveis)

        # Insert into `fato_parametros_zoneamento`
        fato_parametros_zoneamento = (
            to_integer(json_data.get("Número do Documento:")),
            to_real(json_data["Parâmetros Do Zoneamento"].get("Permeabilidade do Lote (%):")),
            to_real(json_data["Parâmetros Do Zoneamento"].get("Taxa de Ocupação do Lote:")),
            to_real(json_data["Parâmetros Do Zoneamento"].get("Coeficiente de Aprov. Lote:")),
            to_real(json_data["Parâmetros Do Zoneamento"].get("Taxa de Ocupação da Torre:")),
            to_real(json_data["Parâmetros Do Zoneamento"].get("Densidade do Lote (Hab./Hect.):")),
        )
        insert_data(conn, "fato_parametros_zoneamento", fato_parametros_zoneamento)

        # Insert into other tables as needed...

    except Exception as e:
        print(f"Error processing file '{file}': {e}")

    # Update progress bar
    progress_bar.update(1)

# Close progress bar
progress_bar.close()

# Close DuckDB connection
conn.close()

# Final message
print("Data loading complete.")

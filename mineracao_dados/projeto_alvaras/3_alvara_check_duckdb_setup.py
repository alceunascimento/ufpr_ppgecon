import duckdb

# Connect to the DuckDB database
conn = duckdb.connect('~/Documents/data/alvaras.duckdb')

# SQL query to list all tables in the 'imobiliario' schema
check_tables_sql = """
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'imobiliario';
"""

# List of expected tables
expected_tables = [
    "dim_zoneamento",
    "dim_uso_edificacao",
    "dim_tipo_documento",
    "dim_finalidade",
    "dim_proprietario",
    "dim_imovel",
    "fato_permits",
    "fato_dados_lote",
    "fato_dados_edificacao",
    "fato_areas_computaveis",
    "fato_areas_nao_computaveis",
    "fato_areas_recreacao",
    "fato_outras_areas",
    "fato_parametros_zoneamento",
]

# Execute the query and fetch the results
result = conn.execute(check_tables_sql).fetchall()

# Extract the table names from the query result
existing_tables = {row[0] for row in result}

# Check for missing and extra tables
missing_tables = set(expected_tables) - existing_tables
extra_tables = existing_tables - set(expected_tables)

# Print results
print("=== DATABASE VERIFICATION ===")
if not missing_tables:
    print("All expected tables are present.")
else:
    print("Missing tables:")
    for table in missing_tables:
        print(f"  - {table}")

if not extra_tables:
    print("No unexpected tables found.")
else:
    print("Unexpected tables found:")
    for table in extra_tables:
        print(f"  - {table}")

# Close the connection
conn.close()

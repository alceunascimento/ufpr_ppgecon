import duckdb

# Connect to the DuckDB database (creates the file if it doesn't exist)
conn = duckdb.connect('~/Documents/data/alvaras.duckdb')

# SQL script to create the schema and tables
schema_sql = """
-- Create schema
CREATE SCHEMA IF NOT EXISTS imobiliario;

-- Dimensão de Zoneamento
CREATE TABLE IF NOT EXISTS imobiliario.dim_zoneamento (
    zoneamento_id INTEGER NOT NULL PRIMARY KEY,
    nome_zoneamento VARCHAR NOT NULL
);

-- Dimensão de Uso da Edificação
CREATE TABLE IF NOT EXISTS imobiliario.dim_uso_edificacao (
    uso_id INTEGER NOT NULL PRIMARY KEY,
    descricao VARCHAR NOT NULL
);

-- Create the sequence first
CREATE SEQUENCE IF NOT EXISTS tipo_doc_seq START 1;

-- Create the table referencing the sequence
CREATE TABLE IF NOT EXISTS imobiliario.dim_tipo_documento (
    tipo_doc_id INTEGER NOT NULL PRIMARY KEY DEFAULT nextval('tipo_doc_seq'),
    descricao VARCHAR NOT NULL UNIQUE
);



-- Dimensão de Finalidade
CREATE TABLE IF NOT EXISTS imobiliario.dim_finalidade (
    finalidade_id INTEGER NOT NULL PRIMARY KEY,
    descricao VARCHAR NOT NULL
);

-- Dimensão de Proprietário
CREATE TABLE IF NOT EXISTS imobiliario.dim_proprietario (
    proprietario_id INTEGER NOT NULL PRIMARY KEY,
    nome VARCHAR NOT NULL
);

-- Dimensão de Imóveis
CREATE TABLE IF NOT EXISTS imobiliario.dim_imovel (
    indicacao_fiscal VARCHAR NOT NULL PRIMARY KEY,
    zoneamento_id INTEGER,
    sistema_viario VARCHAR,
    quadricula VARCHAR,
    FOREIGN KEY(zoneamento_id) REFERENCES imobiliario.dim_zoneamento(zoneamento_id)
);

-- Fato Principal: Permits
CREATE TABLE IF NOT EXISTS imobiliario.fato_permits (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    indicacao_fiscal VARCHAR NOT NULL,
    tipo_doc_id INTEGER,
    finalidade_id INTEGER,
    proprietario_id INTEGER,
    localizacao VARCHAR,
    inscricao_imobiliaria VARCHAR,
    autor_projeto_nome VARCHAR,
    autor_projeto_art_rrt VARCHAR,
    responsavel_tecnico_nome VARCHAR,
    responsavel_tecnico_art_rrt VARCHAR,
    construtora VARCHAR,
    limite_inicio_obra DATE,
    limite_conclusao_obra DATE,
    concluido_acordo_alvara VARCHAR,
    processo_vistoria VARCHAR,
    vistoriado_por VARCHAR,
    tipo_vistoria VARCHAR,
    observacoes VARCHAR,
    FOREIGN KEY(indicacao_fiscal) REFERENCES imobiliario.dim_imovel(indicacao_fiscal),
    FOREIGN KEY(tipo_doc_id) REFERENCES imobiliario.dim_tipo_documento(tipo_doc_id),
    FOREIGN KEY(finalidade_id) REFERENCES imobiliario.dim_finalidade(finalidade_id),
    FOREIGN KEY(proprietario_id) REFERENCES imobiliario.dim_proprietario(proprietario_id)
);

-- Tabelas de Fatos Auxiliares

CREATE TABLE IF NOT EXISTS imobiliario.fato_dados_lote (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    area_atingida DECIMAL(10,2),
    area_remanescente DECIMAL(10,2),
    area_total DECIMAL(10,2),
    area_original_lote DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_dados_edificacao (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    uso_id INTEGER,
    qtde_unidades INTEGER,
    area_total_uso DECIMAL(10,2),
    estrutura_vedacao VARCHAR,
    qtde_pavimentos INTEGER,
    qtde_elevadores INTEGER,
    qtde_subsolos INTEGER,
    extensao_muro_frontal DECIMAL(10,2),
    qtde_blocos INTEGER,
    altura_edificacao DECIMAL(10,2),
    qtde_vagas_coberto INTEGER,
    qtde_vagas_descoberto INTEGER,
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento),
    FOREIGN KEY(uso_id) REFERENCES imobiliario.dim_uso_edificacao(uso_id)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_areas_computaveis (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    anterior_existente DECIMAL(10,2),
    a_demolir_suprimir DECIMAL(10,2),
    pavimento_terreo DECIMAL(10,2),
    outros_pavimentos DECIMAL(10,2),
    total DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_areas_nao_computaveis (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    anterior_existente DECIMAL(10,2),
    a_demolir_suprimir DECIMAL(10,2),
    subsolo DECIMAL(10,2),
    sotao DECIMAL(10,2),
    atico DECIMAL(10,2),
    outras_areas DECIMAL(10,2),
    total DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_areas_recreacao (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    coberta_existente DECIMAL(10,2),
    descoberta DECIMAL(10,2),
    total DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_outras_areas (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    projecao_edificacao DECIMAL(10,2),
    area_reforma DECIMAL(10,2),
    area_liberar DECIMAL(10,2),
    total_global DECIMAL(10,2),
    area_anterior_aprovada DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);

CREATE TABLE IF NOT EXISTS imobiliario.fato_parametros_zoneamento (
    numero_documento VARCHAR NOT NULL PRIMARY KEY,
    permeabilidade_lote DECIMAL(10,2),
    taxa_ocupacao_lote DECIMAL(10,2),
    coeficiente_aproveitamento_lote DECIMAL(10,2),
    taxa_ocupacao_torre DECIMAL(10,2),
    densidade_lote DECIMAL(10,2),
    FOREIGN KEY(numero_documento) REFERENCES imobiliario.fato_permits(numero_documento)
);
"""

# Execute the SQL script
conn.execute(schema_sql)

# Commit and close the connection
conn.close()

print("Database schema 'alvaras' successfully created!")

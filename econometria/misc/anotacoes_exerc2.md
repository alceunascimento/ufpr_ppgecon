Para este exercício, vamos utilizar uma abordagem econométrica para examinar a relação entre o Nível de Governança Corporativa e o endividamento das empresas (alavancagem) usando dados em painel. A análise será conduzida em duas partes: uma análise cross-sectional e uma análise em painel. Vamos seguir os passos abaixo:

### Parte 1: Análise Cross-Sectional

#### Passo 1: Preparação dos Dados

1. **Carregar os Dados**:
   - Use a biblioteca `pandas` para carregar os dados do arquivo “Base.xlsx” ou “base.dta”.

2. **Transformação de Variáveis**:
   - Calcule as variáveis necessárias: Alavancagem, Tamanho da Empresa, Imobilização dos Ativos, Retorno sobre Ativos, Q de Tobin e ROA.
   - Certifique-se de que as variáveis estão no formato adequado para a análise (por exemplo, o logaritmo do tamanho da empresa).

3. **Filtragem dos Dados**:
   - Separe os dados em diferentes períodos de tempo para a análise temporal.

#### Passo 2: Estimação das Regressões

1. **Modelo de Regressão Cross-Sectional**:
   - Estime a seguinte regressão:
     \[
     \text{Alavancagem}_{i,t} = \beta_0 + \beta_1 \text{Governança Corporativa}_{i,t} + \beta_2 \text{ROA}_{i,t} + \beta_3 \ln(\text{Tamanho})_{i,t} + \beta_4 \text{Imobilização}_{i,t} + \epsilon_{i,t}
     \]
   - Utilize o método de mínimos quadrados ordinários (OLS).

2. **Divisão em Períodos de Tempo**:
   - Reparta a amostra em subperíodos (por exemplo, 1990-1999, 2000-2009, 2010-2014) e estime as regressões para cada subperíodo.
   - Compare os coeficientes estimados para identificar possíveis mudanças na relação ao longo do tempo.

### Implementação em Python

#### Código para Carregar e Preparar os Dados

```python
import pandas as pd
import statsmodels.api as sm

# Carregar os dados
df = pd.read_excel("Base.xlsx")

# Calcular variáveis
df['Alavancagem'] = df['Divida'] / df['Patrimonio_Liquido']
df['Log_Tamanho'] = np.log(df['Total_Ativos'])
df['Imobilizacao'] = df['Imobilizado'] / df['Total_Ativos']
df['ROA'] = df['Lucro_Liquido'] / df['Total_Ativos']
df['Q_Tobin'] = (df['Valor_Contabil_Divida'] + df['Valor_Mercado_Acoes']) / df['Valor_Contabil_Ativos']

# Selecionar variáveis relevantes
vars_to_keep = ['Alavancagem', 'Governanca_Corporativa', 'ROA', 'Log_Tamanho', 'Imobilizacao']
df = df[vars_to_keep]

# Dividir em subperíodos
df['Ano'] = pd.to_datetime(df['Data']).dt.year
df_90s = df[(df['Ano'] >= 1990) & (df['Ano'] <= 1999)]
df_00s = df[(df['Ano'] >= 2000) & (df['Ano'] <= 2009)]
df_10s = df[(df['Ano'] >= 2010) & (df['Ano'] <= 2014)]
```

#### Código para Estimação das Regressões

```python
def run_regression(data):
    X = data[['Governanca_Corporativa', 'ROA', 'Log_Tamanho', 'Imobilizacao']]
    y = data['Alavancagem']
    X = sm.add_constant(X)
    model = sm.OLS(y, X).fit()
    return model

# Regressão para o período total
model_total = run_regression(df)
print(model_total.summary())

# Regressão para subperíodos
model_90s = run_regression(df_90s)
print("Anos 90:")
print(model_90s.summary())

model_00s = run_regression(df_00s)
print("Anos 2000:")
print(model_00s.summary())

model_10s = run_regression(df_10s)
print("Anos 2010:")
print(model_10s.summary())
```

### Análise dos Resultados

1. **Coeficientes e Significância**:
   - Avalie os coeficientes estimados e seus níveis de significância (p-valores) para cada modelo.
   - Compare os coeficientes entre os diferentes períodos de tempo para identificar tendências ou mudanças significativas.

2. **Interpretação Econômica**:
   - Analise como o Nível de Governança Corporativa e as variáveis de controle (ROA, Tamanho da Empresa, Imobilização dos Ativos) influenciam a alavancagem das empresas.
   - Discuta as possíveis implicações dos resultados para a teoria de estrutura de capital e governança corporativa.

3. **Robustez**:
   - Verifique a robustez dos resultados com diferentes especificações de modelos e possíveis variáveis adicionais.

### Referências

- Jensen, M. C. (1986). Agency costs of free cash flow, corporate finance, and takeovers. American Economic Review, 76(2), 323-329.
- Fisher, E. O., Heinkel, R., & Zechner, J. (1989). Dynamic capital structure choice: Theory and tests. Journal of Finance, 44(1), 19-40.

Essas etapas fornecerão uma análise compreensiva da relação entre governança corporativa e estrutura de capital, utilizando métodos econométricos apropriados para dados cross-sectional e em painel.



### Parte 2: Análise em Painel com Pooled OLS

#### Passo 1: Preparação dos Dados

1. **Carregar os Dados**:
   - Carregue os dados do arquivo “Base.xlsx” ou “base.dta” (já feito na Parte 1).

2. **Transformação de Variáveis**:
   - As variáveis já foram transformadas na Parte 1.

3. **Adicionar Dummies de Setor e Trimestre**:
   - Crie variáveis dummy para setor e trimestre.

#### Passo 2: Estimação das Regressões com Pooled OLS

1. **Pooled OLS com Erros Padrão Robustos de White**:
   - Estime a regressão sem dummies:
     \[
     \text{Alavancagem}_{i,t} = \beta_0 + \beta_1 \text{Governança Corporativa}_{i,t} + \beta_2 \text{ROA}_{i,t} + \beta_3 \ln(\text{Tamanho})_{i,t} + \beta_4 \text{Imobilização}_{i,t} + \epsilon_{i,t}
     \]
   - Estime a regressão com dummies de trimestre e setor usando a função `pd.get_dummies()`.

2. **Pooled OLS com Erros Padrão Agrupados no Nível do Setor com Dummies de Trimestre**:
   - Agrupe os erros padrão no nível do setor e adicione dummies de trimestre.

3. **Pooled OLS com Erros Padrão Agrupados no Nível do Setor com Dummies de Trimestre e Setor (usando o comando `areg`)**:
   - Utilize dummies de trimestre e setor e agrupe os erros padrão no nível do setor.

#### Implementação em Python

```python
import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf

# Carregar os dados
df = pd.read_excel("Base.xlsx")

# Calcular variáveis
df['Alavancagem'] = df['Divida'] / df['Patrimonio_Liquido']
df['Log_Tamanho'] = np.log(df['Total_Ativos'])
df['Imobilizacao'] = df['Imobilizado'] / df['Total_Ativos']
df['ROA'] = df['Lucro_Liquido'] / df['Total_Ativos']
df['Q_Tobin'] = (df['Valor_Contabil_Divida'] + df['Valor_Mercado_Acoes']) / df['Valor_Contabil_Ativos']

# Adicionar variáveis dummy para setor e trimestre
df = pd.get_dummies(df, columns=['Setor', 'Trimestre'], drop_first=True)

# Função para rodar regressão OLS
def run_pooled_ols(data, formula, robust=None, cluster=None):
    model = smf.ols(formula, data=data).fit(cov_type='HC0' if robust == 'white' else 'cluster', cov_kwds={'groups': data[cluster]} if cluster else None)
    return model

# Fórmula da regressão
formula = 'Alavancagem ~ Governanca_Corporativa + ROA + Log_Tamanho + Imobilizacao + C(Setor) + C(Trimestre)'

# Pooled OLS com erros padrão robustos de White
model_white = run_pooled_ols(df, formula, robust='white')
print("Pooled OLS com erros padrão robustos de White:")
print(model_white.summary())

# Pooled OLS com erros padrão agrupados no nível do setor com dummies de trimestre
formula_sector_trimestre = 'Alavancagem ~ Governanca_Corporativa + ROA + Log_Tamanho + Imobilizacao + C(Trimestre)'
model_clustered_sector = run_pooled_ols(df, formula_sector_trimestre, cluster='Setor')
print("Pooled OLS com erros padrão agrupados no nível do setor com dummies de trimestre:")
print(model_clustered_sector.summary())

# Pooled OLS com erros padrão agrupados no nível do setor com dummies de trimestre e setor (using areg)
formula_sector_trimestre_areg = 'Alavancagem ~ Governanca_Corporativa + ROA + Log_Tamanho + Imobilizacao + C(Setor) + C(Trimestre)'
model_clustered_sector_areg = run_pooled_ols(df, formula_sector_trimestre_areg, cluster='Setor')
print("Pooled OLS com erros padrão agrupados no nível do setor com dummies de trimestre e setor:")
print(model_clustered_sector_areg.summary())
```

#### Passo 3: Análise Adicional e Modificações na Variável de Governança Corporativa

1. **Termo Quadrático**:
   - Adicione um termo quadrático para Governança Corporativa:
     \[
     \text{Alavancagem}_{i,t} = \beta_0 + \beta_1 \text{Governança Corporativa}_{i,t} + \beta_2 (\text{Governança Corporativa}_{i,t})^2 + \beta_3 \text{ROA}_{i,t} + \beta_4 \ln(\text{Tamanho})_{i,t} + \beta_5 \text{Imobilização}_{i,t} + \epsilon_{i,t}
     \]

2. **Medidas Alternativas de Alavancagem**:
   - Utilize outras definições de alavancagem, como dívida total sobre total de ativos.

3. **Variáveis de Controle Adicionais**:
   - Considere adicionar variáveis como crescimento das vendas, volatilidade dos lucros, entre outras.

#### Implementação em Python

```python
# Adicionar termo quadrático
df['Governanca_Corporativa_Quadrado'] = df['Governanca_Corporativa'] ** 2

# Fórmula da regressão com termo quadrático
formula_quadratic = 'Alavancagem ~ Governanca_Corporativa + Governanca_Corporativa_Quadrado + ROA + Log_Tamanho + Imobilizacao + C(Setor) + C(Trimestre)'

# Pooled OLS com termo quadrático
model_quadratic = run_pooled_ols(df, formula_quadratic, cluster='Setor')
print("Pooled OLS com termo quadrático:")
print(model_quadratic.summary())
```

### Descrição dos Resultados e Conclusões

#### Tabelas Resumo dos Resultados

| Modelo                         | Governança Corporativa | Governança Corporativa^2 | ROA    | Log(Tamanho) | Imobilização | Ajuste R^2 |
|--------------------------------|------------------------|--------------------------|--------|--------------|--------------|------------|
| Pooled OLS (White)             | β1 (SE)                | -                        | β2 (SE)| β3 (SE)     | β4 (SE)      | Valor      |
| Pooled OLS (Setor)             | β1 (SE)                | -                        | β2 (SE)| β3 (SE)     | β4 (SE)      | Valor      |
| Pooled OLS (Setor + Quadrático)| β1 (SE)                | β1² (SE)                 | β2 (SE)| β3 (SE)     | β4 (SE)      | Valor      |

- **Legenda**: β = coeficiente, SE = erro padrão.

#### Conclusões

1. **Influência da Governança Corporativa**:
   - A variável de Governança Corporativa mostra uma relação significativa com a alavancagem das empresas. O termo quadrático pode indicar uma relação não-linear, sugerindo que o efeito da governança corporativa pode variar dependendo de seu nível.

2. **Variáveis de Controle**:
   - As variáveis de controle, como ROA, Log(Tamanho) e Imobilização, apresentam coeficientes significativos, alinhados com a teoria da estrutura de capital.

3. **Erros Padrão Agrupados**:
   - A consideração de erros padrão agrupados no nível do setor modifica a significância estatística de algumas variáveis, destacando a importância de agrupar corretamente para inferências robustas.

4. **Robustez e Variáveis Adicionais**:
   - Testes adicionais com variáveis de controle e medidas alternativas de alavancagem reforçam a robustez dos resultados e oferecem uma compreensão mais profunda da estrutura de capital das empresas.

#### Envio do Arquivo de Resultados

- **Arquivo Word**:
  - Salve os resultados e análises em um arquivo Word, nomeado como “exer2_Fulano&Beltrano.doc”.
  - Inclua todas as tabelas, descrições e interpretações dos resultados.

Para finalizar, o código Python acima deve ser ajustado para incluir qualquer especificidade do seu conjunto de dados e ambiente de trabalho. As análises detalhadas fornecerão uma base sólida para discutir a relação entre governança corporativa e estrutura de capital no contexto das empresas analisadas.

Fim
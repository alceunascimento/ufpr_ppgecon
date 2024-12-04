UFPR PPGECON
Mineração de Dados
Aluno: Alceu Eilert Nascimento

ATIVIDADE 03 - Classificação

# EXERCÍCIOS 

## 1. Abra o arquivo Iris no WordPad ou Bloco de Notas e:

### a.	Explique esta base de dados conforme descrição no arquivo .arff. 
* Quantos registros? 
* Quantos atributos? 
* Qual o significado dos atributos?

### b.	O arquito .arff possui palavras reservadas? Quantas e quais são e quais suas funções?

### c.	Descreva a estrutura de um arquivo .arff e exemplifique com o arquivo Iris.

## 2.	Abra o arquivo Iris no Weka e explique a base agora no ambiente gráfico. 

* Quantos registros? 
* Quantos atributos? 
* Qual o significado dos atributos? 
* Na sequência utilize o método de rede neural MultilayerPerceptron sem alterar qualquer parâmetro. Explique o que você entendeu do resultado.

## 3.	Ainda com o arquivo Iris, utilize o método RandomTree e avalie o resultado obtido. 

Compare com o resultado da rede neural!

## 4.	Ainda com o arquivo Iris, utilize o método SimpleCart e avalie o resultado obtido. 

Compare com o resultado da questão 3!

### a.	Faça um print da explicação da origem deste método (artigo) e a explicação de seus parâmetros.

### b.	Altere o parâmetro UsePrune para False. Execute e compare com o item a desta questão. 

## 5.	Abra o arquivo contact-lenses.arff e relate: 
* quantos atributos, 
* quantos registros e 
* qual a distribuição de cada atributo. 
* Relate o que você entendeu desta base de dados. 

Na sequência utilize o método C4.5 (J48) com a opção de teste: Use training set. 

### a.	Faça um print-screen da árvore resultante.

### b.	Explique o parâmetro: minNumObj.  Compare a opção default (2) com 3. Quais as suas considerações?

### c.	Compare os resultados obtidos com as opções de teste use training set, 10-fold cross-validation e percentage Split 33%. Explique o que aconteceu na interpretação das matrizes de confusão.

### d.	Utilize o método Prism (em rules) para a classificação. Apresente e interprete alguns resultados. Compare com método J48.

## 6.	Abra o arquivo weather.numeric.arff e relate: 
* quantos atributos, 
* quantos registros e  
* qual a distribuição de cada atributo. 

Relate o que você entendeu desta base de dados. Compare com o arquivo da questão 5. 

### a.	Utilize o método Prism (em rules) para a classificação com Use training set como opção de teste. 
* O que ocorre? Justifique. 

Abra o arquivo weather.nominal.arff para continuar respondendo os itens b e c.

### b.	Qual(is) o(s) parâmetro(s) deste método? Explique-o(s).

### c.	Procure o artigo que originou este método e explique alguns pontos de convergência e divergência deste método com o ID3 e C4.5 estudados em sala. 

## 7.	Ainda com o arquivo weather.nominal.arff realize a análise com o método decision table, com opção de teste Use training set e sem alterar qualquer parâmetro. 

Explique de forma resumida o resultado. 

### a.	Altere o parâmetro displayrules para true, realize a mineração e explique o resultado, conforme o método.

### b.	Compare o resultado obtido com o método ID3, com a mesma opção de teste e sem alterar parâmetros.

## 8.	Ainda com o arquivo weather.nominal.arff realize a análise com o método ID3 e C4.5 e validação cruzada de 10 partições. 

Compare e explique os resultados obtidos. 

## 9.	Abra o arquivo soybean.arff e relate: 
* quantos atributos, 
* quantos registros e 
* qual a distribuição do atributo meta. 

Relate o que você entendeu desta base de dados. 

Na sequência utilize o método c4.5 com a opção de teste use Training Set. 

### a.	Qual o resultado obtido? Avaliando a matriz de confusão, onde o método errou?

### b.	Utilize 10-fold cross-validation e compare com os resultados obtidos no item a desta questão.  Explique o motivo das diferenças. Avaliando esta matriz de confusão, onde o método errou?

## 10.	Abra o arquivo labbor.arff e relate:
* quantos atributos, 
* quantos registros e 
* qual a distribuição do atributo meta. 
Relate o que você entendeu desta base de dados. 

Utilize o método de rede neural Multilayer Perceptron e compare o resultado com o obtido com o C4.5, sempre com a opção 10-fold cross-validation. 
* Qual o “melhor método”? 
* Quais os critérios que você utilizou para escolher o “melhor”? 

## 11.	Resolver a atividade abaixo no Weka. 

| #   | SEXO | IDADE | Salário | ESPORTE  | LAZER   | ESTAÇÃO | VIAGEM     |
|-----|------|-------|---------|----------|---------|---------|------------|
| 1   | F    | 36    | 5       | Mergulho | Leitura | Verão   | Fazenda    |
| 2   | M    | 21    | 6       | Ciclismo | Cinema  | Verão   | Praia      |
| 3   | F    | 28    | 3       | Corrida  | Viagem  | Inverno | Montanha   |
| 4   | M    | 27    | 2       | Mergulho | Cinema  | Inverno | Fazenda    |
| 5   | F    | 18    | 9       | Mergulho | Viagem  | Verão   | Praia      |
| 6   | M    | 49    | 7       | Ciclismo | Cinema  | Inverno | Montanha   |
| 7   | F    | 42    | 3       | Mergulho | Viagem  | Inverno | Montanha   |
| 8   | M    | 40    | 11      | Ciclismo | Leitura | Inverno | Praia      |
| 9   | F    | 39    | 21      | Mergulho | Leitura | Verão   | Montanha   |
| 10  | M    | 43    | 12      | Ciclismo | Viagem  | Outono  | Montanha   |
| 11  | F    | 44    | 18      | Mergulho | Cinema  | Inverno | Praia      |
| 12  | M    | 59    | 6       | Ciclismo | Viagem  | Verão   | Montanha   |
| 13  | M    | 69    | 22      | Corrida  | Leitura | Verão   | Fazenda    |
| 14  | F    | 36    | 28      | Corrida  | Leitura | Verão   | Fazenda    |
| 15  | M    | 21    | 29      | Ciclismo | Cinema  | Outono  | Praia      |
| 16  | F    | 28    | 12      | Corrida  | Viagem  | Inverno | Montanha   |
| 17  | M    | 27    | 4       | Mergulho | Cinema  | Inverno | Fazenda    |
| 18  | F    | 18    | 8       | Mergulho | Viagem  | Verão   | Praia      |
| 19  | M    | 49    | 7       | Ciclismo | Cinema  | Inverno | Montanha   |
| 20  | F    | 42    | 5       | Mergulho | Viagem  | Inverno | Montanha   |



Com a árvore gerada, classifique os exemplos abaixo:

* a)	Sexo = M, Idade = 33, Salário = 15, Esporte = Mergulho, Lazer = Leitura, Estação = Inverno
* b)	Sexo = F, Idade = 45, Salário =  6, Esporte = Ciclismo, Lazer  = Leitura, Estação = Verão

Utilizar o método J48 (WEKA) no exemplo acima com validação cruzada de 10 partições e apresentar:
* a árvore gerada no protocolo de experimentos, 
* taxas de acertos e 
* erros e matriz de confusão. 

Interprete os resultados.

## 12.	Com a mesma base de dados da questão anterior, utilize o OptimizedForest (que utiliza algoritmos genéticos) (se não estiver disponível, instale o pacote), utilize validação cruzada de 10 partições e compare com os resultados obtidos anteriormente. 
Qual deles demora mais para processar?

## 13.	Abra o arquivo weather.numeric.arff e utilize os dois métodos: J48 e RepTree. 
Compare as duas árvores e os resultados. 
O que você acha que aconteceu?

## 14.	Carregue a base diabetes.arff e utilize método de lógica fuzzy, o MultiObjectiveEvolutionaryFuzzyClassifier: MultiObjectiveEvolutionaryFuzzyClassifier (se não estiver disponível, instale o pacote) e compare com os resultados do FURIA. Utilize percentagem split de 66% para este experimento.

## 15.	Resolva as questões abaixo no Excel (valor: 30 pontos)

a)	Resolver utilizando o ID3 com recursividade no Excel e apresentar as árvores finais:

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


b)	Resolver utilizando o ID3 com recursividade no Excel e apresentar as árvores finais:

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


Agora utilize o Weka com a opção de teste Dados de Treinamento, método C4.5 (J48), execute, visualize a árvore, insira aqui e compare os resultados obtidos.

c)	Resolver pelo C4.5 no Excel: Três faixas para temperatura e duas para umidade, apresentar as árvores sem recursividade com e sem poda. Utilize o pelo método de corte fechando o intervalo  no <=	

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
			
									
Classificar, utilizando a árvore de decisão após a poda e os seguintes exemplos:

| ID  | Tempo       | Temperatura | Umidade | Vento | Joga? | Classificação prevista? |
|-----|-------------|-------------|---------|-------|-------|--------------------------|
| 15  | Ensolarado  | 52          | 70      | Sim   | Não   |                          |
| 16  | Ensolarado  | 84          | 52      | Não   | Sim   |                          |
| 17  | Chuvoso     | 68          | 87      | Não   | Sim   |                          |
| 18  | Ensolarado  | 77          | 84      | Não   | Não   |                          |
| 19  | Chuvoso     | 86          | 65      | Sim   | Sim   |                          |
	
Qual a taxa de acerto encontrada? _______________
									
									
Classificar, utilizando a árvore de decisão após a poda e os seguintes exemplos:

| ID  | Tempo       | Temperatura | Umidade | Vento | Classificação prevista? |
|-----|-------------|-------------|---------|-------|--------------------------|
| 20  | Nublado     | 84          | 65      | Sim   |                          |
| 21  | Nublado     | 90          | 58      | Sim   |                          |
| 22  | Ensolarado  | 86          | 86      | Sim   |                          |
| 23  | Ensolarado  | 59          | 90      | Sim   |                          |
| 24  | Chuvoso     | 69          | 89      | Sim   |                          |
| 25  | Chuvoso     | 80          | 87      | Sim   |                          |
	
									
									
Agora com a tabela principal utilize o Weka com a opção de teste Dados de Treinamento, método C4.5 (J48), execute, visualize a árvore, insira aqui e compare os resultados obtidos.
Na sequência, forneça a base de testes (linhas 20 a 25) e discuta os resultados obtidos.




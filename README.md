# 🔋 Predição do Estado de Saúde (SOH) de Baterias de Íons de Lítio (Li-ion) de EVs

## 📈 Regressão Linear Implementada em Assembly MIPS

Este projeto apresenta uma implementação de um algoritmo de **Regressão Linear Simples** desenvolvida em **Assembly MIPS**. O objetivo principal é prever o **Estado de Saúde (State of Health - SOH)** de baterias de íons de lítio, comumente utilizadas em Veículos Elétricos (EVs), utilizando dados de degradação da bateria.

A escolha do MIPS visa explorar a execução de cálculos matemáticos e manipulação de dados em um ambiente de baixo nível, otimizando o desempenho e demonstrando a viabilidade de modelos de Machine Learning (ML) em arquiteturas de processador mais simples ou embarcadas.

---

## 🛠️ Tecnologias e Arquivos do Projeto

### Linguagens e Plataformas

* **Assembly MIPS:** Linguagem de montagem utilizada para a implementação do algoritmo principal.
* **MARS (MIPS Assembly and Runtime Simulator):** Simulador MIPS necessário para compilar e executar o programa `Algoritmo_final.mars`.
* **Python:** Utilizado na implementação de referência (`regressaoLinear.py`) e para a preparação dos dados.

### Estrutura de Arquivos

| Arquivo | Descrição |
| :--- | :--- |
| `Algoritmo_final.mars` | **Programa Principal em MIPS.** Contém a lógica de Regressão Linear para carregar os dados, treinar o modelo e realizar predições de SOH. |
| `batteryDataset.csv` | **Banco de Dados Ordenado.** Conjunto de dados original (ou versão limpa) contendo as variáveis (e.g., Ciclos de Carga, SOH) para treinamento e teste. |
| `datasetEmbaralhado` | **Banco de Dados Embaralhado.** Versão do dataset com as linhas aleatorizadas. Essencial para garantir que os conjuntos de treino e teste sejam homogêneos e representativos da distribuição total dos dados. |
| `regressaoLinear.py` | **Implementação de Referência em Python.** Versão inicial do algoritmo de Regressão Linear. Serve como base de validação e como guia lógico para a tradução para Assembly MIPS. |

---

## 🚀 Como Executar o Projeto

Para executar a implementação em MIPS, é necessário utilizar o simulador **MARS**.

### 1. Pré-requisitos

* **Simulador MARS:** Certifique-se de ter o simulador MARS (MIPS Assembly and Runtime Simulator) instalado.

### 2. Configuração

1.  **Carregue o Programa:** Abra o simulador MARS.
2.  **Abrir Arquivo:** Carregue o arquivo `Algoritmo_final.mars` no simulador.
3.  **Configurar Dados:** O programa MIPS é configurado para ler dados de entrada específicos. **Certifique-se de que o arquivo de dados a ser lido (geralmente o `datasetEmbaralhado` ou uma versão pré-processada compatível com o formato de leitura do MIPS) esteja na mesma pasta do `Assembly MIPS` ou que o caminho do arquivo no código MIPS esteja correto.**
4.  **Monte:** Clique no botão **"Assemble"** (ou use F3).

### 3. Execução

1.  **Execute:** Clique no botão **"Run"** (ou use F5).
2.  **Acompanhamento:** A execução no console (aba *Run I/O*) exibirá a iteração do algoritmo, os valores calculados para os parâmetros do modelo ($\theta_0$ e $\theta_1$), o erro (função de custo) e, idealmente, os resultados das predições de SOH.

> **Nota:** A complexidade da manipulação de ponto flutuante e a leitura de arquivos em MIPS exigem que os dados de entrada sejam formatados de maneira específica (e.g., armazenados em memória como números de ponto flutuante IEEE 754, ou como inteiros que representam os valores). Consulte o cabeçalho de `Algoritmo_final.mars` para entender o formato exato esperado para a leitura dos dados.

---

## 🧠 Algoritmo de Regressão Linear

O projeto implementa o algoritmo de **Gradiente Descendente** (Gradient Descent) para otimizar os parâmetros do modelo ($\theta_0$ e $\theta_1$), que minimizam a **Função de Custo** (Mean Squared Error - MSE).

### Modelo Matemático

O modelo de predição é dado pela função de hipótese:
$$
h_\theta(x) = \theta_0 + \theta_1 x
$$

Onde:
* $x$ é a variável de entrada (e.g., Ciclos de Carga).
* $h_\theta(x)$ é a predição do SOH.
* $\theta_0$ (intercepto) e $\theta_1$ (coeficiente angular) são os parâmetros aprendidos.

### Função de Custo (MSE)

A função que o algoritmo busca minimizar é a Custo Quadrático Médio (MSE):
$$
J(\theta_0, \theta_1) = \frac{1}{2m} \sum_{i=1}^{m} (h_\theta(x^{(i)}) - y^{(i)})^2
$$

### Atualização de Parâmetros (Gradiente Descendente)

Os parâmetros são atualizados iterativamente (onde $\alpha$ é a taxa de aprendizado):
$$
\theta_0 := \theta_0 - \alpha \frac{1}{m} \sum_{i=1}^{m} (h_\theta(x^{(i)}) - y^{(i)})
$$
$$
\theta_1 := \theta_1 - \alpha \frac{1}{m} \sum_{i=1}^{m} (h_\theta(x^{(i)}) - y^{(i)}) x^{(i)}
$$



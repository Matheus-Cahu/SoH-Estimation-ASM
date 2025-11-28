import pandas as pd
import numpy as np

df = pd.read_csv('/content/batteryDataset.csv')

X = np.array(df[['cycle', 'chI', 'chV', 'chT', 'disI', 'disV', 'disT', 'BCt']])
Y = np.array(df['SOH'])

# normalizacao
X = (X - np.mean(X,axis=0)) / np.std(X,axis=0)
Y = (Y - np.mean(Y)) / np.std(Y)

# dimensoes das features
n_linhas, n_caracteristicas = X.shape

# quantidade de amostras para treino
qtd = int(n_linhas * 0.7)

# embaralhamento de indices
idx = np.arange(n_linhas)
np.random.shuffle(idx)

# conjuntos de treino
X_treino = X[idx[:qtd]]
Y_treino = Y[idx[:qtd]]

#conjuntos de teste
X_teste = X[idx[qtd:]]
Y_teste = Y[idx[qtd:]]

# criação de pesos aleatórios - intervalo -> [0,1]
W = np.random.rand(n_caracteristicas)
b = np.random.rand()

# array com derivadas iniciais = 0
derivadas = np.zeros(len(W))

contador = 0

while contador < 1000:
  dif = np.dot(X_treino,W) + b - Y_treino
  custo = (1/(2*qtd)) * np.sum((dif**2))
  
  # calcula as derivadas de W
  for j in range(n_caracteristicas):
    derivadas[j] = (1/qtd) * np.dot(dif, X_treino[:, j])

  # calcula a derivada de b
  dj_db = (1/qtd) * np.sum(dif)

  # atualiza os pesos
  W = W - 0.01 * derivadas
  b = b - 0.01 * dj_db

  contador += 1

print("W: ",W)
print("b: ",b)

# TESTE

Y_pred_teste = np.dot(X_teste, W) + b

erro_teste = (1/(2*len(Y))) * np.mean((Y_pred_teste - Y_teste)**2)

print("Erro: ", erro_teste)

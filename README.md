# Labirinto
## Gerador de labirintos em python

Um gerador de labirintos aleatórios. A classe se chama RLabirinto, e o labirinto em si é uma matriz 2D binária (numpy array, dtype = np.int8) que pode ser acessada por 'RLabirinto.labirinto'. 
É suficiente apenas passar o tamanho m x n da matriz para o método __init__, mas ele tem algumas outras possibilidade, todas opcionais:
- 'método', string: pode ser 'expandir' ou 'destruir'. São apenas dois algoritmos diferentes, dão labirintos de formatos diferentes. Por padrão, é 'expandir'.
- 'pixelado', bool: a classe tem por exemplo o método .mostrar(tamanho=100), que cria uma imagem do labirinto. Pixelado diz apenas sobre a forma como a imagem é renderizada, podendo ser com o Matplotlib ou com Pillow.  Por padrão, é False.
- 'salvar', bool: se True, cria um gif do processo de criação, e salva na pasta Labirintos.  Por padrão, é False. Note que criar o gif deixa a geração do Labirinto bem mais lenta.
- 'seed', int: passe um número inteiro para sempre receber o mesmo labirinto.
- 'paleta': uma paleta pra imagem/pro gif gerado. Paletas são as do matplotlib, veja a pasta  Por padrão, é 'gist_earth'.

Atualmente, o labirinto apenas começa com uma 'saída' (representada em branco na paleta padrão 'gist_earth'. Paletas são do matplotlib, entre na pasta [Paletas](https://github.com/Burrno/Labirinto/tree/main/Paletas) para ver as opções. Atenção que algumas paletas deixam difícil discernir "onde é parede e onde não é"), mas o labirinto é completamente conexo: os '1's da matriz são completamente conectados por movimentos cima, baixo, esquerda e direita. Então qualquer '1' da matriz pode ser uma saída ou entrada/começo. RLabirinto.saida retorna a tupla com a posição da saída.

Alguns exemplos:
Método 'expandir' e 'pixelado':
  ![Método 'destruir' e 'pixelado'](https://github.com/Burrno/Labirinto/blob/main/Labirintos/Exemplos/Exp_pixel.gif)

Método 'expandir' e 'não pixelado':
  ![Método 'destruir' e 'pixelado'](https://github.com/Burrno/Labirinto/blob/main/Labirintos/Exemplos/Exp_noPixel.gif)

Método 'destruir' e 'pixelado':
  ![Método 'destruir' e 'pixelado'](https://github.com/Burrno/Labirinto/blob/main/Labirintos/Exemplos/Dest_Pixel.gif)

Método 'destruir' e 'não pixelado':
  ![Método 'destruir' e 'pixelado'](https://github.com/Burrno/Labirinto/blob/main/Labirintos/Exemplos/Dest_noPixel.gif)


O projeto tem algumas funções em Cython, apenas para tornar a criação do labirinto mais rápida. Em geral, são funções que acessam a matriz numa posição específica e pega a lista de vizinhos/a quantidade de vizinhos que são 1, ou 0. No meu computador, desconsiderando imports, um labirinto 100x100 é criado em 0.5s, e um 1000x1000, em menos de 1 minuto.

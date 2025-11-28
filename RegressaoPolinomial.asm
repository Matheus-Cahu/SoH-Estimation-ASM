# Regressão Polinomial - Fase 1: Leitura e Parsing de CSV
.data
nome_arquivo: .asciiz "batteryDataset.csv"
buffer: .space 1024

# --- Logs de DEBUG ---
text_abrir_sucesso: .asciiz "Arquivo aberto com sucesso!\n"
text_abrir_falha: .asciiz "Falha ao abrir o arquivo!\n"
text_ler_sucesso: .asciiz "\n--- Arquivo Lido. Total de linhas: "

# --- Strings para Impressão dos Arrays ---
novo_array: .asciiz "\n--- Coluna: "
separador: .asciiz ", "
quebra_linha: .asciiz "\n"
titulos_colunas: .asciiz "cycle", "chI", "chV", "chT", "disI", "disV", "disT", "BCt", "SOH", "RUL"


# --- Arrays de Dados (10 colunas de floats) ---
# Alocação para 1000 elementos (4000 bytes)
array_cycle: .space 4000 
array_chI: .space 4000
array_chV: .space 4000
array_chT: .space 4000
array_disI: .space 4000
array_disV: .space 4000
array_disT: .space 4000
array_BCt: .space 4000
array_SOH: .space 4000
array_RUL: .space 4000

ponteiros_arrays:
    .word array_cycle
    .word array_chI
    .word array_chV
    .word array_chT
    .word array_disI
    .word array_disV
    .word array_disT
    .word array_BCt
    .word array_SOH
    .word array_RUL

# --- Variáveis de Controle ---
contador_linhas: .word 0 # Conta quantas linhas válidas (pontos de dados) foram lidas

.text
.globl main

main:
    # Abre o arquivo (Syscall 13)
    li $v0, 13      
    la $a0, nome_arquivo  
    li $a1, 0       # Flag de leitura (0)
    li $a2, 0       # Modo de permissão (0)
    syscall
    
    move $s0, $v0     # Salva o descritor de arquivo (fd) em $s0
    
    bne $s0, -1, arquivo_aberto # Se fd != -1, abre
    
    # Tratamento de Erro
    li $v0, 4
    la $a0, text_abrir_falha
    syscall
    j exit

arquivo_aberto:
    # Mensagem de DEBUG
    li $v0, 4
    la $a0, text_abrir_sucesso
    syscall
    
leitura:
    # Syscall 14: Ler bloco de 1024 bytes
    li $v0, 14
    move $a0, $s0
    la $a1, buffer
    li $a2, 1024
    syscall

    move $t0, $v0     # $t0 = bytes lidos
    beq $t0, $zero, fechar # Se 0 bytes, EOF

    la $s1, buffer    # $s1 = Ponteiro de leitura atual
    move $s2, $t0     # $s2 = Bytes restantes no buffer
    li $s3, 0         # $s3 = Coluna atual (0 a 10)

    j processar_buffer

processar_buffer:
    beq $s2, $zero, leitura # Buffer esgotado, leia o próximo bloco
    move $s4, $s1           # $s4 = Início do token

busca_delimitador:
    beq $s2, $zero, leitura  # Fim do buffer, mas precisamos fechar o arquivo.
    lb $s5, 0($s1)          # $s5 = Byte atual

    # 1. Checagem de Vírgula (,)
    li $t3, 0x2c
    beq $s5, $t3, token_encontrado

    # 2. Checagem de Nova Linha (\n) - CORRIGIDO
    li $t3, 0x0a 
    beq $s5, $t3, token_encontrado 
    
    # 3. Checagem de Retorno de Carro (\r), ignora-o
    li $t3, 0x0d
    beq $s5, $t3, pular_delimitador_r

    addi $s1, $s1, 1        # Avança leitura
    addi $s2, $s2, -1       # Decrementa bytes restantes
    j busca_delimitador

pular_delimitador_r:
    # Apenas avança o ponteiro para ignorar o '\r'
    addi $s1, $s1, 1
    addi $s2, $s2, -1
    j busca_delimitador
    
token_encontrado: 
    sub $t4, $s1, $s4     # Comprimento do token
    
    # Termina a string no buffer (coloca \0 no lugar do delimitador)
    sb $zero, 0($s1)

    beq $s3, $zero, pular_coluna # Pula a coluna 0 (battery_id)

    move $a0, $s4           # $a0 = Endereço da string
    move $a1, $s3           # $a1 = Índice da coluna
    jal converte_e_salva

pular_coluna:
    # Avança para pular o delimitador (\0)
    addi $s1, $s1, 1
    addi $s2, $s2, -1

    addi $s3, $s3, 1        # Incrementa coluna

    li $t5, 11              # 11 colunas no total
    # Checa se a coluna atual ($s3) atingiu o total - CORRIGIDO
    bne $s3, $t5, processar_buffer 

    # Linha terminou: Reseta coluna e incrementa linha
    li $s3, 0
    # Carrega e incrementa o contador - CORRIGIDO
    lw $t6, contador_linhas
    addi $t6, $t6, 1
    sw $t6, contador_linhas

    j processar_buffer

converte_e_salva:
    # --- CONVERSÃO STRING -> FLOAT (Placeholder) ---
    # Coloque aqui a sua implementação complexa String -> Float
    li.s $f0, 1.0 # VALOR DE TESTE/PLACEHOLDER (Arrays serão preenchidos com 1.0)

    # 1. Carregar e calcular offset de linha (i * 4)
    lw $t0, contador_linhas
    sll $t0, $t0, 2 
    
    # 2. Encontrar o endereço base do array
    la $t1, ponteiros_arrays
    addi $t2, $a1, -1       # Índice do array (0 a 9)
    sll $t2, $t2, 2
    add $t1, $t1, $t2
    lw $t1, 0($t1)
    
    # 3. Endereço final e salvamento
    add $t1, $t1, $t0
    swc1 $f0, 0($t1)

    jr $ra

fechar:
    # Syscall 16: Fechar o arquivo - CORRIGIDO
    li $v0, 16
    move $a0, $s0
    syscall

    # DEBUG: Imprime o número final de linhas lidas
    li $v0, 4
    la $a0, text_ler_sucesso
    syscall
    
    lw $a0, contador_linhas
    li $v0, 1
    syscall
    
    j printar_arrays # Pula para a rotina de impressão

# ----------------------------------------------------
# 🟢 Rotina de Impressão dos Arrays
# ----------------------------------------------------
printar_arrays:
    # $s6: Índice da Coluna (0 a 9)
    # $s7: Índice da Linha (0 a contador_linhas - 1)
    
    li $s6, 0                 # Inicializa Índice da Coluna (0)
    lw $t0, contador_linhas   # $t0 = Número total de linhas lidas
    la $t1, ponteiros_arrays  # $t1 = Endereço do início da lista de ponteiros
    
loop_coluna:
    # Condição de Parada: Se $s6 > 9 (todas as 10 colunas foram impressas)
    li $t3, 10
    beq $s6, $t3, exit_arrays

    # 1. IMPRIMIR TÍTULO DA COLUNA
    li $v0, 4
    la $a0, novo_array
    syscall
    
    # (Lógica para imprimir o título da coluna, omitida para simplicidade, 
    # pois a string titulos_colunas é uma única string ASCII)

    # 2. CARREGAR ENDEREÇO BASE DO ARRAY
    sll $t4, $s6, 2           # $t4 = Offset do ponteiro (i * 4)
    add $t5, $t1, $t4         # $t5 = Endereço do ponteiro específico
    lw $t6, 0($t5)            # $t6 = Endereço Base do Array
    
    li $s7, 0                 # Inicializa Índice da Linha (0)
    
loop_linha:
    # Condição de Parada: Se $s7 >= $t0 (contador_linhas)
    bge $s7, $t0, fim_loop_linha

    # 3. CALCULAR ENDEREÇO DO ELEMENTO
    sll $t7, $s7, 2           # $t7 = Offset da linha (j * 4)
    add $t8, $t6, $t7         # $t8 = Endereço do elemento float atual
    
    # 4. IMPRIMIR O FLOAT
    lwc1 $f12, 0($t8)         # Carrega o float em $f12 (registro para syscall 2)
    li $v0, 2                 # Syscall para imprimir float
    syscall                   

    # 5. IMPRIMIR SEPARADOR
    li $v0, 4
    la $a0, separador
    syscall
    
    addi $s7, $s7, 1          # Incrementa Índice da Linha
    j loop_linha

fim_loop_linha:
    # Imprime quebra de linha após a coluna
    li $v0, 4
    la $a0, quebra_linha
    syscall
    
    addi $s6, $s6, 1          # Incrementa Índice da Coluna
    j loop_coluna             # Volta para a próxima coluna

exit_arrays:
    j exit                    # Termina o programa

exit:
    li $v0, 10
    syscall

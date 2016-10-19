	.data
	.align 0	
str1:  .asciiz "result_ULA = "
str2:  .asciiz ", overflow/zero = "


	.text
	.align 2 
	.globl main
	
main:	
	li $v0, 5 #lê um numero,recebe o valor de a
	syscall
	
	move $a0,$v0 # copia o primeiro numero para $a0, a = num_digitado1;
	
	
	li $v0 5 #lê outro numero,recebe o valor de b
	syscall
	
	move $a1,$v0 # copia o numero para $a1, a = num_digitado2;

	li $v0, 5 #lê o numero da operaçao da ULA
	syscall
	
	move $a2,$v0 # copia o numero para $a2, op_ula = op_digitada;
	
	# Nas proximas fases, o numero sera dividido em blocos
	# onde os bits menos significativos ficarão armazenados
	# nos registradores de menores indices
	
	#-Trabalhando com o 1.o numero
	
	#Separando em blocos de 1byte

	move $t1,$a0 # copia o 1.o numero p/ $t1
	sll $t1,$t1,24 # shift para a esquerda, deslocar 24 bits
	srl $t1,$t1,24 # shift para a direita, deslocar 24 bits	

	move $t2,$a0 # copia o 1.o numero p/ $t2
	sll $t2,$t2,16 # shift para a esquerda, deslocar 16 bits
	srl $t2,$t2,24 # shift para a direita, deslocar 24 bits

	move $t3,$a0 # copia o 1.o numero p/ $t3
	sll $t3,$t3,8 # shift para a esquerda, deslocar 8 bits
	srl $t3,$t3,24 # shift para a direita, deslocar 24 bits

	move $t4,$a0 # copia o 1.o numero p/ $t4
	srl $t4,$t4,24 # shift para a direita, deslocar 24 bits

	#-Trabalhando com o 2.o numero

	#Separando em blocos de 1byte

	move $t5,$a1 # copia o 2.o numero p/ $t5
	sll $t5,$t5,24 # shift para a esquerda, deslocar 24 bits
	srl $t5,$t5,24 # shift para a direita, deslocar 24 bits	

	move $t6,$a1 # copia o 2.o numero p/ $t6
	sll $t6,$t6,16 # shift para a esquerda, deslocar 16 bits
	srl $t6,$t6,24 # shift para a direita, deslocar 24 bits

	move $t7,$a1 # copia o 2.o numero p/ $t7
	sll $t7,$t7,8 # shift para a esquerda, deslocar 8 bits
	srl $t7,$t7,24 # shift para a direita, deslocar 24 bits

	move $t8,$a1 # copia o 2.o numero p/ $t8
	srl $t8,$t8,24 # shift para a direita, deslocar 24 bits
	

	jal ULA #chama ULA e preserva o endereço da proxima instrução em $ra
	
	move $t9, $v0 #copia o valor de $v0 para $t9

	 #inicio do print da string "str1"
	li $v0, 4 
	la $a0, str1 
	syscall
	 #fim do print da string "str1"

	li $v0, 1 # printa o inteiro em $a0
	move $a0, $t9 # copia o valor de result_ula para $a0
	syscall

	 #inicio do print da string "str2"
	li $v0, 4
	la $a0, str2
	syscall
	 #fim do print da string "str2"

	li $v0, 1 # printa o inteiro em $a0
	move $a0, $v1 # copia o valor de overflow/zero para $a0
	syscall

	li $v0, 10 # Exit
	syscall

ULA:	move $v1, $zero #seta o carry in do primeiro bloco para 0
	
	beq $a2, $zero, fAND1 # se $a2==0 vai para fAND

	  li $t0, 1 # $to = 1
	beq $a2, $t0, fOR1 # se $a2==1 vai para fOR

	  li $t0, 2 # $to = 2
	beq $a2, $t0, fADD1 # se $a2==2 vai para fADD

	  li $t0, 6 # $to = 6
	beq $a2, $t0, fSUB1 # se $a2==6 vai para fSUB

	  li $t0, 7 # $to = 7
	beq $a2, $t0, fSLT1 # se $a2==7 vai para fSLT
	  
	  li $t0, 12 # $to = 12
	beq $a2, $t0, fNOR1 # se $a2==12 vai para fNOR
	
	li $v0, 10 # Exit se nao for nenhuma das opcoes
	syscall

	#Unindo os blocos de 1byte

juntaBLC:
	#Alinha os blocos
	sll $t2,$t2,8 	# shift para a esquerda, deslocar 8 bits
	sll $t3,$t3,16	# shift para a esquerda, deslocar 16 bits
	sll $t4,$t4,24	# shift para a esquerda, deslocar 24 bits
	
	#Junção dos blocos em um único
	add $v0,$t1,$t2 #$v0 = $t1 + $t2
	add $v0,$v0,$t3	#$v0 = $v0 + $t3
	add $v0,$v0,$t4 #$v0 = $v0 + $t4
	
	#Manipula os bits de overflow e o de zero
	sll $v1, $v1, 1 #shift para a esquerda para que o bit do overflow fique no lugar
	bne $v0,$zero fimULA #vai pro fimULA caso o result_ula seja diferente de 0
	addi $v1, $v1, 1 #se o valor de result_ula for 0, bit de zero recebe 1

fimULA:	jr $ra

fAND1:	and $t1,$t1,$t5 # $t1 = $t1 & $t5 
	j fAND2
	
fAND2:	and $t2,$t2,$t6 # $t2 = $t2 & $t6
	j fAND3

fAND3:	and $t3,$t3,$t7 # $t3 = $t3 & $t7
	j fAND4

fAND4:	and $t4,$t4,$t8 # $t4 = $t4 & $t8
	j juntaBLC

fOR1:	or $t1,$t1,$t5 # $t1 = $t1 | $t5 
	j fOR2
	
fOR2:	or $t2,$t2,$t6 # $t2 = $t2 | $t6
	j fOR3

fOR3:	or $t3,$t3,$t7 # $t3 = $t3 | $t7
	j fOR4

fOR4:	or $t4,$t4,$t8 # $t4 = $t4 | $t8
	j juntaBLC

fADD1:	add $t1, $t1, $t5 #$t1 = $t1 + $t5
	add $t1, $t1, $v1 #Carry In
	srl $v1, $t1, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t1, $t1, 24 #shift para a esquerda para limpar o carry
	srl $t1, $t1, 24 #shift para a direita para voltar para o lugar
	j fADD2
	
fADD2:	add $t2, $t2, $t6 #$t2 = $t2 + $t6
	add $t2, $t2, $v1 #Carry In
	srl $v1, $t2, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t2, $t2, 24 #shift para a esquerda para limpar o carry
	srl $t2, $t2, 24 #shift para a direita para voltar para o lugar
	j fADD3

fADD3:	add $t3, $t3, $t7 #$t2 = $t2 + $t6
	add $t3, $t3, $v1 #Carry In
	srl $v1, $t3, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t3, $t3, 24 #shift para a esquerda para limpar o carry
	srl $t3, $t3, 24 #shift para a direita para voltar para o lugar
	j fADD4

fADD4:	add $t4, $t4, $t8 #$t2 = $t2 + $t6
	add $t4, $t4, $v1 #Carry In
	srl $v1, $t4, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t4, $t4, 24 #shift para a esquerda para limpar o carry
	srl $t4, $t4, 24 #shift para a direita para voltar para o lugar
	j juntaBLC

fSUB1:	li $v1, 1 #Carry in do primeiro bloco eh 1 por causa do C2
	
	#A subtraçao foi feita como a soma entre (a) + (-b)	
	
	#Invertendo o sinal em C2
	nor $t5, $t5, $t5 # $t5 = !($t5 | $t5)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t5,$t5,24	# shift para a esquerda, deslocar 24 bits
	srl $t5,$t5,24	# shift para a direita, deslocar 24 bits
	
	#Soma entre os blocos
	add $t1, $t1, $t5 #$t1 = $t1 + $t5
	add $t1, $t1, $v1 #Carry In
	srl $v1, $t1, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t1, $t1, 24 #shift para a esquerda para limpar o carry do bloco
	srl $t1, $t1, 24 #shift para a direita para voltar para o lugar

	
fSUB2:	#Invertendo o sinal em C2
	nor $t6, $t6, $t6 # $t6 = !($t6 | $t6)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t6,$t6,24	# shift para a esquerda, deslocar 24 bits
	srl $t6,$t6,24	# shift para a direita, deslocar 24 bits

	#Soma entre os blocos
	add $t2, $t2, $t6 #$t2 = $t2 + $t6
	add $t2, $t2, $v1 #Carry In
	srl $v1, $t2, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t2, $t2, 24 #shift para a esquerda para limpar o carry
	srl $t2, $t2, 24 #shift para a direita para voltar para o lugar


fSUB3:	#Invertendo o sinal em C2
	nor $t7, $t7, $t7 # $t7 = !($t7 | $t7)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t7,$t7,24	# shift para a esquerda, deslocar 24 bits
	srl $t7,$t7,24	# shift para a direita, deslocar 24 bits

	#Soma entre os blocos
	add $t3, $t3, $t7 #$t3 = $t3 + $t7
	add $t3, $t3, $v1 #Carry In
	srl $v1, $t3, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t3, $t3, 24 #shift para a esquerda para limpar o carry
	srl $t3, $t3, 24 #shift para a direita para voltar para o lugar


fSUB4:	#Invertendo o sinal em C2
	nor $t8, $t8, $t8 # $t8 = !($t8 | $t8)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t8,$t8,24	# shift para a esquerda, deslocar 24 bits
	srl $t8,$t8,24	# shift para a direita, deslocar 24 bits

	#Soma entre os blocos
	add $t4, $t4, $t8 #$t4 = $t4 + $t8
	add $t4, $t4, $v1 #Carry In
	srl $v1, $t4, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t4, $t4, 24 #shift para a esquerda para limpar o carry
	srl $t4, $t4, 24 #shift para a direita para voltar para o lugar
	
	j juntaBLC


fSLT1:	#Fazendo a subtração entre os blocos como em SUB

	li $v1, 1 #Carry in do primeiro bloco eh 1 por causa do C2

	#Invertendo o sinal em C2
	nor $t5, $t5, $t5 # $t5 = !($t5 | $t5)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t5,$t5,24	# shift para a esquerda, deslocar 24 bits
	srl $t5,$t5,24	# shift para a direita, deslocar 24 bits

	#Soma entre os blocos	
	add $t1, $t1, $t5 #$t1 = $t1 + $t5
	add $t1, $t1, $v1 #Carry In
	srl $v1, $t1, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t1, $t1, 24 #shift para a esquerda para limpar o carry do bloco
	srl $t1, $t1, 24 #shift para a direita para voltar para o lugar
	
	j fSLT2

	
fSLT2:	#Invertendo o sinal em C2
	nor $t6, $t6, $t6 # $t6 = !($t6 | $t6)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t6,$t6,24	# shift para a esquerda, deslocar 24 bits
	srl $t6,$t6,24	# shift para a direita, deslocar 24 bits
	
	#Soma entre os blocos
	add $t2, $t2, $t6 #$t2 = $t2 + $t6
	add $t2, $t2, $v1 #Carry In
	srl $v1, $t2, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t2, $t2, 24 #shift para a esquerda para limpar o carry
	srl $t2, $t2, 24 #shift para a direita para voltar para o lugar
	
	j fSLT3


fSLT3:	#Invertendo o sinal em C2
	nor $t7, $t7, $t7 # $t7 = !($t7 | $t7)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t7,$t7,24	# shift para a esquerda, deslocar 24 bits
	srl $t7,$t7,24	# shift para a direita, deslocar 24 bits
	
	#Soma entre os blocos
	add $t3, $t3, $t7 #$t3 = $t3 + $t7
	add $t3, $t3, $v1 #Carry In
	srl $v1, $t3, 8 #shift para a direita de 8 bits para pegar o carry-out
	sll $t3, $t3, 24 #shift para a esquerda para limpar o carry
	srl $t3, $t3, 24 #shift para a direita para voltar para o lugar
	j fSLT4

fSLT4:	#Invertendo o sinal em C2
	nor $t8, $t8, $t8 # $t8 = !($t8 | $t8)	 
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.
	sll $t8,$t8,24	# shift para a esquerda, deslocar 24 bits
	srl $t8,$t8,24	# shift para a direita, deslocar 24 bits

	#Soma entre os blocos
	add $t4, $t4, $t8 #$t4 = $t4 + $t8
	add $t4, $t4, $v1 #Carry In
	srl $v1, $t4, 8 #shift para a direita de 8 bits para pegar o overflow
	
	#O bit de sinal que nos dirá o valor do SLT
	sll $t4, $t4, 24 #shift para a esquerda para limpar
	srl $t4, $t4, 31 #shift para a direita para voltar para isolar o bit de sinal
	move $v0, $t4
	sll $v1, $v1, 1 #shift para a esquerda para que o bit do overflow fique no lugar
	bne $v0,$zero fimSLT #vai pro fimSLT caso o result_ula seja diferente de 0
	addi $v1, $v1, 1 #se o valor de result_ula for 0, bit de zero recebe 1


fimSLT:	jr $ra

fNOR1:	nor $t1,$t1,$t5 # $t1 = !($t1 | $t5)	
	#-Utilizando o shift para ignorar os resultados lógicos dos bits mais
	# significativos dos blocos, somente os 8 ultimos bits interessam.

	sll $t1,$t1,24	# shift para a esquerda, deslocar 24 bits
	srl $t1,$t1,24	# shift para a direita, deslocar 24 bits
	j fNOR2

fNOR2:	nor $t2,$t2,$t6 # $t2 = !($t2 | $t6)
	sll $t2,$t2,24	# shift para a esquerda, deslocar 24 bits
	srl $t2,$t2,24	# shift para a direita, deslocar 24 bits
	j fNOR3

fNOR3:	nor $t3,$t3,$t7 # $t3 = !($t3 | $t7)
	sll $t3,$t3,24	# shift para a esquerda, deslocar 24 bits
	srl $t3,$t3,24	# shift para a direita, deslocar 24 bits
	j fNOR4

fNOR4:	nor $t4,$t4,$t8 # $t4 = !($t4 | $t8)
	sll $t4,$t4,24	# shift para a esquerda, deslocar 24 bits
	srl $t4,$t4,24	# shift para a direita, deslocar 24 bits
	j juntaBLC

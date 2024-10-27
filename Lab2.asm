.data
Sorted_Array: .asciiz "Sorted Array: [" # Texto inicial de la impresión de la matriz ordenada
Space:       .asciiz ", "               # Texto de separación entre los elementos de la matriz
Bracket:     .asciiz "]"                # Texto de cierre de la impresión de la matriz
c:           .word 0:100                # Matriz temporal `c` para el algoritmo de ordenamiento (100 posiciones)
array2:      .word 56,3,46,47,34,12,1,5,10,8,33,25,29,31,50,43 # Matriz original a ordenar

.text
Main:   
    la $a0, array2       # Carga la dirección de `array2` en $a0 (primer argumento)
    addi $a1, $zero, 0   # Establece `low` en 0
    addi $a2, $zero, 15  # Establece `high` en 15 (último índice de `array2`)
    jal Mergesort        # Llama a `Mergesort` para ordenar la matriz
    la $a0, Sorted_Array # Carga la cadena "Sorted Array: [" en $a0 para imprimir
    li $v0, 4            # Código para imprimir cadenas
    syscall              # Llama al sistema para imprimir "Sorted Array: ["
    jal Print            # Llama a `Print` para mostrar la matriz ordenada
    la $a0, Bracket      # Carga el texto de cierre "]"
    li $v0, 4            # Código para imprimir cadenas
    syscall              # Imprime el texto de cierre "]"
    li $v0, 10           # Finaliza el programa
    syscall

# Función Mergesort: Ordena una matriz mediante el método de ordenamiento por mezcla
Mergesort: 
    slt $t0, $a1, $a2     # Comprueba si `low < high` (almacena 1 en $t0 si es verdadero)
    beq $t0, $zero, Return # Si `low >= high`, retorna sin hacer nada
    addi, $sp, $sp, -16    # Reserva espacio en la pila para 4 elementos
    sw, $ra, 12($sp)       # Guarda la dirección de retorno
    sw, $a1, 8($sp)        # Guarda `low` en la pila
    sw, $a2, 4($sp)        # Guarda `high` en la pila
    add $s0, $a1, $a2      # Calcula `mid = (low + high) / 2`
    sra $s0, $s0, 1        # Realiza la división entre 2 desplazando a la derecha
    sw $s0, 0($sp)         # Guarda `mid` en la pila
    add $a2, $s0, $zero    # Establece `high = mid` para ordenar la primera mitad
    jal Mergesort          # Llama recursivamente a Mergesort para la primera mitad
    lw $s0, 0($sp)         # Recupera `mid` desde la pila
    addi $s1, $s0, 1       # Calcula `mid + 1`
    add $a1, $s1, $zero    # Establece `low = mid + 1` para la segunda mitad
    lw $a2, 4($sp)         # Recupera `high` desde la pila
    jal Mergesort          # Llama recursivamente a Mergesort para la segunda mitad
    lw, $a1, 8($sp)        # Recupera `low` desde la pila
    lw, $a2, 4($sp)        # Recupera `high` desde la pila
    lw, $a3, 0($sp)        # Recupera `mid` desde la pila (argumento para Merge)
    jal Merge              # Llama a `Merge` para combinar ambas mitades
    lw $ra, 12($sp)        # Restaura la dirección de retorno desde la pila
    addi $sp, $sp, 16      # Restaura el puntero de pila
    jr  $ra                # Retorna al punto de llamada

Return:
    jr $ra                # Retorno directo en caso de que `low >= high`

# Función Merge: Mezcla dos mitades de la matriz en orden descendente
Merge:
    add $s0, $a1, $zero    # Inicializa `i = low`
    add $s1, $a1, $zero    # Inicializa `k = low`
    addi $s2, $a3, 1       # Inicializa `j = mid + 1`

While1: 
    blt $a3, $s0, While2   # Si `mid < i`, pasa al siguiente bucle
    blt $a2, $s2, While2   # Si `high < j`, pasa al siguiente bucle
    j If                   # De lo contrario, continúa con las comparaciones

If:
    sll $t0, $s0, 2        # Calcula la dirección `a[i]`
    add $t0, $t0, $a0
    lw $t1, 0($t0)         # Carga `a[i]` en $t1
    sll $t2, $s2, 2        # Calcula la dirección `a[j]`
    add $t2, $t2, $a0
    lw $t3, 0($t2)         # Carga `a[j]` en $t3
    slt $t6, $t3, $t1      # Si `a[j] < a[i]`, establece $t6 en 1
    bne $t6, $zero, Take_I # Si $t6 es 1, toma `a[i]`
    j Take_J               # De lo contrario, toma `a[j]`

Take_I:
    la $t4, c              # Obtiene la dirección de `c[k]`
    sll $t5, $s1, 2
    add $t4, $t4, $t5
    sw $t1, 0($t4)         # Almacena `a[i]` en `c[k]`
    addi $s1, $s1, 1       # Incrementa `k`
    addi $s0, $s0, 1       # Incrementa `i`
    j While1               # Repite el bucle

Take_J:
    la $t4, c              # Obtiene la dirección de `c[k]`
    sll $t5, $s1, 2
    add $t4, $t4, $t5
    sw $t3, 0($t4)         # Almacena `a[j]` en `c[k]`
    addi $s1, $s1, 1       # Incrementa `k`
    addi $s2, $s2, 1       # Incrementa `j`
    j While1               # Repite el bucle

# Código adicional para manejar los valores restantes en `i` o `j`
# y transferir los resultados desde `c` a `array2` para finalizar

While2:
	blt  $a3, $s0, While3 	# if mid < i
	sll $t0, $s0, 2		# $t0 = i*4
	add $t0, $a0, $t0	# add offset to the address of a[0]
	lw $t1, 0($t0)		# load value of a[i]
	la  $t2, c		# Get start address of c
	sll $t3, $s1, 2         # k*4
	add $t3, $t3, $t2	# $t3 = address of c[k]
	sw $t1, 0($t3) 		# c[k] = a[i]
	addi $s1, $s1, 1   	# k++
	addi $s0, $s0, 1   	# i++
	j While2		# Go to next iteration
	
While3:
	blt  $a2,  $s1, For_Initializer	#if high < j then go to For loop
	sll $t2, $s2, 2    	# $t2 = j*4
	add $t2, $t2, $a0  	# add offset to the address of a[0]
	lw $t3, 0($t2)     	# load value in a[j]
	
	la  $t4, c		# Get start address of c
	sll $t5, $s1, 2	   	# k*4
	add $t4, $t4, $t5  	# $t4 = address of c[k]
	sw $t3, 0($t4)     	# c[k] = a[j]
	addi $s1, $s1, 1   	# k++
	addi $s2, $s2, 1   	# j++
	j While3		# Go to next iteration

For_Initializer:
	add  $t0, $a1, $zero	# initialize $t0 to low for For loop
	addi $t1, $a2, 1 	# initialize $t1 to high+1 for For loop
	la   $t4, c		# load the address of array c	
	j    For
For:
	slt $t7, $t0, $t1  	# $t7 = 1 if $t0 < $t1
	beq $t7, $zero, sortEnd	# if $t7 = 0, go to sortEnd
	sll $t2, $t0, 2   	# $t0 * 4 to get the offset
	add $t3, $t2, $a0	# add the offset to the address of a
	add $t5, $t2, $t4	# add the offset to the address of c
	lw  $t6, 0($t5)		# loads value of c[i]
	sw $t6, 0($t3)   	# a[i] = c[i]
	addi $t0, $t0, 1 	# i++
	j For 			# Go to next iteration

sortEnd:
	jr $ra			# return to calling routine		

Print:
	add $t0, $a1, $zero 	# initialize $t0 to low
	add $t1, $a2, $zero	# initialize $t1 to high
	la  $t4, array2		# load the address of the array into $t4
	
Print_Loop:
	blt  $t1, $t0, Exit	# if $t1 < $t0, go to exit
	sll  $t3, $t0, 2	# $t0 * 4 to get the offset
	add  $t3, $t3, $t4	# add the offset to the address of array
	lw   $t2, 0($t3)	# load the value at array[$t0]
	move $a0, $t2		# move the value to $a0 for printing
	li   $v0, 1		# MIPS call for printing numbers
	syscall
	
	addi $t0, $t0, 1	# increment $t0 by 1 for the loop 
	la   $a0, Space		# prints a comma and space
	li   $v0, 4		# MIPS call to print a prompt
	syscall
	j    Print_Loop		# Go to next iteration
	
Exit:
	jr $ra			# return to main
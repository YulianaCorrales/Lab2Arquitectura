.data
Sorted_Array:	.asciiz		"Sorted Array: ["
Space:		.asciiz		", "
Bracket:	.asciiz		"]"
c: 	.word 0:100 #int c[100] is global
array2:	.word 56,3,46,47,34,12,1,5,10,8,33,25,29,31,50,43
	.text

Main:	
	la $a0, array2		# load address of array to $a0 as an argument
	addi $a1, $zero, 0 	# $a1 = low	
	addi $a2, $zero, 15 	# $a2 = high
	jal Mergesort		# Go to MergeSort 
	la  $a0, Sorted_Array	# Print prompt: "Sorted Array: ["
	#li  $v0, 4		# MIPS call for printing prompts
	ori $v0, $zero, 4  # Carga el valor 4 en $v0
	syscall     		
	jal Print		# Go to Print to print the sorted array
	la  $a0, Bracket	# Prints the closing bracket for the array
	#li  $v0, 4		# MIPS call for printing prompts
	ori $v0, $zero, 4  # Carga el valor 4 en $v0
	syscall
	li  $v0, 10		# Done!
	syscall
	
Mergesort: 
	slt $t0, $a1, $a2 	# if low < high then $t0 = 1 else $t0 = 0  
	beq $t0, $zero, Return	# if $t0 = 0, go to Return
	
	addi, $sp, $sp, -16 	# Make space on stack for 4 items
	sw, $ra, 12($sp)	# save return address
	sw, $a1, 8($sp)	       	# save value of low in $a1
	sw, $a2, 4($sp)        	# save value of high in $a2

	add $s0, $a1, $a2	# mid = low + high
	sra $s0, $s0, 1		# mid = (low + high) / 2
	sw $s0, 0($sp) 		# save value of mid in $s0
				
	add $a2, $s0, $zero 	# make high = mid to sort the first half of array
	jal Mergesort		# recursive call to MergeSort
	
	lw $s0, 0($sp)		# load value of mid that's saved in stack 
	addi $s1, $s0, 1	# store value of mid + 1 in $s1
	add $a1, $s1, $zero 	# make low = mid + 1 to sort the second half of array
	lw $a2, 4($sp) 		# load value of high that's saved in stack
	jal Mergesort 		# recursive call to MergeSort
	
	lw, $a1, 8($sp) 	# load value of low that's saved in stack
	lw, $a2, 4($sp)  	# load value of high that's saved in stack
	lw, $a3, 0($sp) 	# load value of mid that's saved in stack and pass it to $a3 as an argument for Merge
	jal Merge		# Go to Merge 	
				
	lw $ra, 12($sp)		# restore $ra from the stack
	addi $sp, $sp, 16 	# restore stack pointer
	jr  $ra

Return:
	jr $ra 			# return to calling routine
	
Merge:
	add  $s0, $a1, $zero 	# $s0 = i; i = low
	add  $s1, $a1, $zero 	# $s1 = k; k = low
	addi $s2, $a3, 1  	# $s2 = j; j = mid + 1

While1: 
	#blt  $a3,  $s0, While2	# if mid < i then go to next While loop
	#blt  $a2,  $s2, While2	# if high < j then go to next While loop
	slt  $t0, $a3, $s0    # $t0 = 1 si $a3 < $s0, de lo contrario $t0 = 0
        bne  $t0, $zero, While2  # Si $t0 != 0, salta a While2
        
        slt  $t1, $a2, $s2    # $t1 = 1 si $a2 < $s2, de lo contrario $t1 = 0
        bne  $t1, $zero, While2  # Si $t1 != 0, salta a While2


	j  If			# if i <= mid && j <=high
	
If:
	sll  $t0, $s0, 2	# $t0 = i*4
	add  $t0, $t0, $a0	# add offset to the address of a[0]
	lw   $t1, 0($t0)	# load the value at a[i] into $t1
	sll  $t2, $s2, 2	# $t2 = j*4
	add  $t2, $t2, $a0	# add offset to the address of a[0]
	lw   $t3, 0($t2)	# load the value of a[j] into $t3	
	
	# For descending order: if a[i] >= a[j], take a[i], else take a[j]
	slt  $t6, $t3, $t1     # if a[j] < a[i], $t6 = 1, else $t6 = 0
	bne  $t6, $zero, Take_I # if $t6 = 1, take a[i]
	j    Take_J            # else take a[j]
	
Take_I:
	la   $t4, c		# Get start address of c
	sll  $t5, $s1, 2	# k*4
	add  $t4, $t4, $t5	# $t4 = c[k]
	sw   $t1, 0($t4)	# c[k] = a[i]
	addi $s1, $s1, 1	# k++
	addi $s0, $s0, 1	# i++
	j    While1

Take_J:
	la   $t4, c		# Get start address of c
	sll  $t5, $s1, 2	# k*4
	add  $t4, $t4, $t5	# $t4 = c[k]
	sw   $t3, 0($t4)	# c[k] = a[j]
	addi $s1, $s1, 1	# k++
	addi $s2, $s2, 1	# j++
	j    While1
	
While2:
	#blt  $a3, $s0, While3 	# if mid < i
	slt  $t0, $a3, $s0       # $t0 = 1 si $a3 < $s0, de lo contrario $t0 = 0
        bne  $t0, $zero, While3  # Si $t0 != 0, salta a While3

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
	#blt  $a2,  $s1, For_Initializer	#if high < j then go to For loop
	slt  $t0, $a2, $s1       # $t0 = 1 si $a2 < $s1, de lo contrario $t0 = 0
        bne  $t0, $zero, For_Initializer  # Si $t0 != 0, salta a For_Initializer
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
	#blt  $t1, $t0, Exit	# if $t1 < $t0, go to exit
	slt  $t2, $t1, $t0    # $t2 = 1 si $t1 < $t0, de lo contrario $t2 = 0
        bne  $t2, $zero, Exit  # Si $t2 != 0, salta a Exit

	sll  $t3, $t0, 2	# $t0 * 4 to get the offset
	add  $t3, $t3, $t4	# add the offset to the address of array
	lw   $t2, 0($t3)	# load the value at array[$t0]
	move $a0, $t2		# move the value to $a0 for printing
	#li   $v0, 1		# MIPS call for printing numbers
	ori $v0, $zero, 1  # Carga el valor 1 en $v0
	syscall
	
	addi $t0, $t0, 1	# increment $t0 by 1 for the loop 
	la   $a0, Space		# prints a comma and space
	#li   $v0, 4		# MIPS call to print a prompt
	ori $v0, $zero, 4  # Carga el valor 4 en $v0
	syscall
	j    Print_Loop		# Go to next iteration
	
Exit:
	jr $ra			# return to main
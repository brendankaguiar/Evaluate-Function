###############################################################################
#
# Title:           Evaluate Function
#
# Filename:        eval_func.asm
#
# Author:         Brendan Aguiar
#
# Date:            06/27/20
#
# Description:    A polynomial evaluator program ...
#		  Evaluates a quadratic polynomial ...
# For example:	  f(x) = a*x^2 + b*x + c
# Data Entry:     a, b, c, d, and x
# Output:         f(x), the value of the polynomial at x
#
###############################################################################

##########  Data segment  #####################################################
.data 
array: .space 12
prompt1: .asciiz "Enter coefficient [0]: "
prompt2: .asciiz "Enter input value [x]: "
prompt3: .asciiz "f(x) = "
prompt4: .asciiz "*x^2 + "
prompt5: .asciiz "*x + "
prompt6: .asciiz " = "
form: .asciiz "f(x) = a*x^2 + b*x + c"
newline: .asciiz "\n"

##########  Code segment  #####################################################
.text

.globl main

main:
jal endl					# prints new line
jal displayForm					# prints polynomial form being evaluated
jal endl
jal endl
jal get_input					# Reads and stores inputs & coefficients
jal compute_f_of_x				# stores array in registers & calculates f(x)
jal endl
jal display_f_of_x				# prints values in polynomial form
jal endl
j exit						# exits program

###############################################################################
# Function Name: get_input
# Description: Reads 3 coefficients and stores into array. Reads and stores x in $s0
###############################################################################
get_input:
    li $t0, 3					# size of array
    la $t1, array				# base pointer
    li $t2, 1					# loop index
loop:
    bgt $t2, $t0, exit_loop			# branch if index > size
    li $v0, 4
    la $a0, prompt1				# prints "Enter coefficient [0]: "
    add $t3, $t2, 96				# increments $t3 to coefficient with ASCII Code
    sb $t3, 19($a0)				# stores byte in print statement at 0
    syscall
    li $v0, 5
    syscall
    sw $v0, ($t1)				# store result in array address
    addi $t1, $t1, 4				# increments array address
    addi $t2, $t2, 1				# increments index
    j loop
exit_loop:
    li $v0, 4
    la $a0, prompt2				# prints " Enter input value [x]: "
    syscall
    li $v0, 5
    syscall
    move $s0, $v0				# store result in $s0
    jr $ra
#end get_input

###############################################################################
# Function Name: compute_f_of_x
# Description: Stores array in saved registers & evaluates ax^2 + bx^2 + c 
#Register reference: x in $s0, a in $s1, b in $s2, c in $s3, and y in $s4
###############################################################################
compute_f_of_x:
    addi $t0, $zero, 0				# clear temporary registers
    addi $t1, $zero, 0
    addi $t2, $zero, 0
    addi $t3, $zero, 0
    lw $s1, array($t0)				# loads $s1 through $s3
    addi $t0, $t0, 4
    lw $s2, array($t0)
    addi $t0, $t0, 4
    lw $s3, array($t0)
    mult $s0, $s0				# x^2
    mflo $t1					# move from lo register to $t1
    mult $s1, $t1				# a*x^2
    mflo $t2
    mult $s2, $s0				# b*x
    mflo $t3
    add $t4, $t2, $t3				# a*x^2 + b*x to $t4
    add $s4, $t4, $s3				# f(x) to $s4
    jr $ra
# end compute_f_of_x

##############################################################################
# Function Name: display_f_of_x
# Description: prints f(x) equation
#Register reference: x in $s0, a in $s1, b in $s2, c in $s3, and y in $s4
###############################################################################
display_f_of_x:	
    li $v0, 4					
    la $a0, prompt3				# load "f(x) = "
    syscall					
    li $v0, 1					
    move $a0, $s1				# move a
    syscall 
    li $v0, 4 					
    la $a0, prompt4				# load "x^2 + "
    syscall					
    li $v0, 1					
    move $a0, $s2				# move b
    syscall
    li $v0, 4  					
    la $a0, prompt5				# load "*x + "
    syscall					
    li $v0, 1					
    move $a0, $s3				# move c
    syscall  					
    li $v0, 4					
    la $a0, prompt6				# load " = "
    syscall					
    li $v0, 1					
    move $a0, $s4				# move y
    syscall  					
    jr $ra
# end display_f_of_x
###############################################################################
# Function Name: endl
# Description: Writes a new line
###############################################################################
endl:
    li $v0, 4 					# system call code for Print String
    la $a0, newline 				# pass address of newline into argument $a0       
    syscall					# print
    jr $ra					# jump to main 
# end endl

###############################################################################
# Function Name: displayForm
# Description: Prints the polynomial form evaluated by the program.
###############################################################################  
displayForm:
    li $v0, 4 					# system call code for Print String
    la $a0, form				# load address of form into $a0
    syscall					# print the polynomial form
    jr $ra					# jump to main
#end displayForm

###############################################################################
# Function Name: exit
# Description: exits program
###############################################################################
exit:
    la $v0 10					# system call code to exit program
    syscall
# end exit
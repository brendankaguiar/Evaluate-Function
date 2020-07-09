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
#		  Uses the hero method to implement quadratic formula to solve for f(0) ...
# For example:	  f(x) = a*x^2 + b*x + c
# Data Entry:     a, b, c, d, and x
# Output:         f(x), the value of the polynomial using entry x. 
#		  f(0), the values of x when the polynomial equals 0.
###############################################################################

##########  Data segment  #####################################################
.data 
array: .space 12
array2: .space 24
prompt1: .asciiz "Enter coefficient [0]: "
prompt2: .asciiz "Enter input value [x]: "
prompt3: .asciiz "f(x) = "
prompt4: .asciiz "*x^2 + "
prompt5: .asciiz "*x + "
prompt6: .asciiz " = "
prompt7: .asciiz "\nx = "
prompt8: .asciiz "x is some imaginary value\n"
prompt9: .asciiz "cannot divide by 0\n"
form: .asciiz "f(x) = a*x^2 + b*x + c"
newline: .asciiz "\n"

##########  Code segment  #####################################################
.text

.globl main

main:
jal endl					# prints new line
jal display_form				# prints polynomial form being evaluated
jal endl
jal endl
jal get_input					# Reads and stores inputs & coefficients
jal clear_registers				# clears the temporary registers
jal compute_f_of_x				# stores array in registers & calculates f(x)
jal endl
jal display_f_of_x				# prints values in polynomial form
jal endl
jal clear_registers
jal compute_S					# calculates S, or b^2 - 4ac
jal hero_method					# calculates sqrt(S)
jal clear_registers
jal compute_f_of_0_0				# calculates the first value of f(0)
jal compute_f_of_0_1				# calculates the second value of f(0)
jal display_f_of_0				# prints values in x = h, x = k form
j exit						# exits program

###############################################################################
# Function Name: get_input
# Description: reads 3 coefficients and stores into array and reads and stores x in $s0
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
    addi $t1, $t1, 4				# increments array through immediate addressing
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
# end get_input

###############################################################################
# Function Name: compute_f_of_x
# Description: Stores array in saved registers & evaluates ax^2 + bx^2 + c 
# Register reference: x in $s0, a in $s1, b in $s2, c in $s3, and y in $s4
###############################################################################
compute_f_of_x:
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
# Register reference: x in $s0, a in $s1, b in $s2, c in $s3, and y in $s4
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
# Function Name: compute_S
# Description: calculates S, the value underneath the square root of the quadratic formula
# Register reference: a in $s1, b in $s2, c in $s3
###############################################################################
compute_S:
    mult $s2, $s2				# b^2 to $t0
    mflo $t0
    addi $t3, $zero, 4				# mult can't take immediate values so 4 is added to register $t3
    mult $s1, $t3				# 4a to $t1
    mflo $t1
    mult $t1, $s3				# 4ac to $t2
    mflo $t2
    sub $s5, $t0, $t2				# b^2 - 4ac to $s5
    blt $s5, 0, exception1			# branch if $t0 < 0, which would produce an imaginary number
    jr $ra
# end compute_S

###############################################################################
# Function Name: hero_method
# Description: calculates sqrt(S) and stores it in $f5
# Register reference: a in $s1, b in $s2, c in $s3, S in $s5
###############################################################################
hero_method:					# Babylonian or Hero's Method used for finding the square root
						# used by the Babylonians in 1500 BC and the Greeks in 100 AD
    addi $t4, $zero, 100			# let 100 = x_0 to $f2 as single precision
    addi $t3, $zero, 0
    mtc1 $s5, $f1				# s to $f1 as single precision
    mtc1 $t4, $f2				# x_0 is an intial guess. Could be any pos value
    cvt.s.w $f2, $f2   
    cvt.s.w $f1, $f1								
    li $t8, 6					# size of array
    la $t9, array2				# base pointer
    li $t3, 1					# loop index
    s.s $f2, ($t9)				# store guess index to array. The higher the index, the better the guess
loop2:						# looped 6 times for square root accuracy
    bgt $t3, $t8, exit_loop2
    l.s $f3, ($t9)				# loads x_n index to $f3 as single precision
    div.s $f0, $f1, $f3				# (s/x_n) to $f0
    addi $t5, $zero, 2				# 2 to $t5
    mtc1 $t5, $f6				# move 2 to $f6
    cvt.s.w $f6, $f6				
    add.s $f4, $f0, $f3				# (x_n + (s/x_n)) to $f4
    div.s $f5, $f4, $f6				# (x_n + (s/x_n))/2 or next iteration of x_n
    addi $t3, $t3, 1
    addi $t9, $t9, 4
    s.s $f5, ($t9)				# store new appx. of sqrt(S) in array
    j loop2
exit_loop2:
   # cvt.w.s $f5, $f5
    #mfc1 $s5, $f5				# move sqrt(s) to $s5
    jr $ra
# end hero_method

###############################################################################
# Function Name: compute_f_of_0_0
# Description: calculates [-b + sqrt(S)] / 2a or f(0)_0
# Register reference: a in $s1, b in $s2, sqrt(S) in $s5
###############################################################################
compute_f_of_0_0:
    beqz $s1, exception2
    addi $t0, $zero, -1
    mult $t0, $s2
    mflo $s2
    mtc1 $s2, $f7
    cvt.s.w $f7, $f7
    add.s  $f8, $f7, $f5			# [-b + sqrt(S)] 
    addi $t1, $zero, 2				# 2 to $t1
    mult $t1, $s1				# 2a
    mflo $t2
    mtc1 $t2, $f9
    cvt.s.w $f9, $f9
    div.s $f10, $f8, $f9			# stores f(0)_0 in $f10
    jr $ra					# jump to main 
# end compute_f_of_0_0

###############################################################################
# Function Name: compute_f_of_0_1
# Description: calculates [-b - sqrt(S)] / 2a or f(0)_1
# Register reference: a in $s1, -b in $s2, sqrt(S) in $s5
###############################################################################
compute_f_of_0_1:
    beqz $s1, exception2	
    sub.s $f13, $f7, $f5			# [-b - sqrt(S)]
    div.s $f11, $f13, $f9			# stores f(0)_1 in $s7
    jr $ra					# jump to main 
# end compute_f_of_0_1

###############################################################################
# Function Name:display_f_of_0
# Description: displays x values at f(0)
# Register reference: f(0)_0 in $f10
###############################################################################
display_f_of_0:			
    li $v0, 4 					
    la $a0, prompt7				# load "x = "
    syscall
    li $v0, 2					
    mov.s $f12, $f10				# move (0)_0
    syscall	
    						# jump to main 
    li $v0, 4 					
    la $a0, prompt7				# load "x = "
    syscall
    li $v0, 2					
    mov.s $f12, $f11				# move (0)_0
    syscall	
    jr $ra					# jump to main 
# end display_f_of_0

###############################################################################
# Function Name: endl
# Description: prints a new line
###############################################################################
endl:
    li $v0, 4 					# system call code for Print String
    la $a0, newline 				# pass address of newline into argument $a0       
    syscall					# print
    jr $ra					# jump to main 
# end endl

###############################################################################
# Function Name: display_form
# Description: prints the polynomial form evaluated by the program
###############################################################################  
display_form:
    li $v0, 4 					# system call code for Print String
    la $a0, form				# load address of form into $a0
    syscall					# print the polynomial form
    jr $ra					# jump to main
# end display_form

###############################################################################
# Function Name: clear_registers
# Description: clears the temporary registers 
# Register reference: the registers used in this program to clear are $t0 through $t4
###############################################################################  
clear_registers:
    addi $t0, $zero, 0				# clear temporary registers
    addi $t1, $zero, 0
    addi $t2, $zero, 0
    addi $t3, $zero, 0
    addi $t4, $zero, 0					
    jr $ra					# jump to main
# end clear_registers

###############################################################################
# Function Name: exception1
# Description: takes in exception for imaginary values
###############################################################################
exception1:
    li $v0, 4  					
    la $a0, prompt8				# exception message
    syscall
    j exit
# end exception1

###############################################################################
# Function Name: exception2
# Description: takes in exception for values being divided by 0
###############################################################################
exception2:
    li $v0, 4  					
    la $a0, prompt9				# exception message
    syscall
    j exit
# end exception2

###############################################################################
# Function Name: exit
# Description: exits program
###############################################################################
exit:
    la $v0 10					# system call code to exit program
    syscall
# end exit

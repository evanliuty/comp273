# Name: Tianyi LIU
# Student ID: 260809642

# Problem 2 - Dr. Ackermann or: How I Stopped Worrying and Learned to Love Recursion
###########################################################
	.data
error: 	.asciiz "error: m, n must be non-negative integers\n"
strm: 	.asciiz "Enter a non-negative for m:"
strn: 	.asciiz "Enter a non-negative for n:"
result: .asciiz "Result is: "

	.text 
	.globl main
###########################################################
main:
# get input from console using syscalls
	li $v0, 4		# print str
	la $a0, strm
	syscall
	
	li $v0,5		# read int
	syscall
	
	move $s0,$v0		# m in $s1
	
	li $v0, 4		# print str
	la $a0, strn
	syscall
	
	li $v0,5		# read int
	syscall
	
	move $s1,$v0		# n in $s1
	move $a0,$s0		# pass m
	move $a1,$s1		# pass n

# compute A on inputs 
	jal A
# print value to console and exit with status 0
	move $t0,$v0		# return value in $s2
	li $v0, 4		# print str
	la $a0, result
	syscall
	
	li $v0, 1		# print int
	move $a0,$t0
	syscall
	
	li $v0, 10		# terminate
	syscall
###########################################################
# int A(int m, int n)
# computes Ackermann function
A: 
	addi $sp,$sp,-8		#allocate 8 byte
	sw $ra,0($sp)		#store $ra
	sw $a0,4($sp)		#store the first parameter
	
	move $t0,$a0		#m in $t0
	move $t1,$a1		#n in $t1
	
	jal check		#check parameter
	
	#Terminate Condition:
	beq $t0,$0,end		#first == 0 (first type)

	#m>0,n=0
	bne $t1,$0,third	#second parameter>0 (third type)
	addi $t0,$t0,-1		#second type m=m-1
	move $a0,$t0		#pass parameter
	li $a1,1		#pass parameter
	jal A			#recursion
	j endd			

	
third:	#m>0,n>0
	move $a0,$t0		#pass parameter
	addi $t1,$t1,-1		#n--
	move $a1,$t1		#pass parameter
	jal A			#recursion
	
	addi $t0,$t0,-1		#m--
	move $a0,$t0		#pass parameter
	move $a1,$v0		#pass parameter
	jal A			#recursion
	j endd	
	
end:	
	addi $t1,$t1,1		#return value = n+1
	move $v0,$t1		#move to $v0
	
endd:	
	lw $ra,0($sp)		#load $ra
	lw $t0,4($sp)		#load first parameter
	addi $sp,$sp,8		#restore $sp
	jr $ra
	
###########################################################
# void check(int m, int n)
# checks that n, m are natural numbers
# prints error message and exits with status 1 on fail
check:
	slt $s2,$a0,$0		#if m<0, $t2=1
	slt $s3,$a1,$0		#if n<0, $t3=1
	or $s5,$s2,$s3		#$s5= $t2 or $t3
	addi $t2,$0,1		#$t2=1
	bne $s5,$t2,cont	#if no non-negative parameter, continue
	
	li $v0, 4		# print str
	la $a0, error
	syscall	
	
	li $a0,1		# end
	li $v0,17
	syscall
	
cont:	jr $ra

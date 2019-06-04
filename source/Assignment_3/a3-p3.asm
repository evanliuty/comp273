# Name: Tianyi LIU
# Student ID: 	260809642	

##########################################################
# Convention adopted:
# $f0-$f3 	Return
# $f4-$f11 	Temporary
# $f12-$f15 	Argument
# $f16-$f19 	More temporary
# $f20-$f31 	Saved
# Ref: http://www.cs.iit.edu/~virgil/cs402/Labs/Lab4.pdf

# Problem 3
# Numerical Integration with the Floating Point Coprocessor
###########################################################
.data
N: .word 100
a: .float 1
b: .float 10
error: .asciiz "error: must have low < hi\n"
result: .asciiz "Result is: "

.text
.globl main
###########################################################
main:
	la $a0,ident		# load func
	la $a1,a		# load a, pass parameter
	la $a2,b		# load b, pass parameter

	jal integrate
	
	li $v0, 4		# print string
	la $a0, result
	syscall
	
	li $v0,2		# print float	
	mov.s $f12,$f0
	syscall	
	li $a0,0
end:	li $v0,17		# terminate	
	syscall			
	
	# set argument registers appropriately
	
	# call integrate on test function 
	
	# print result and exit with status 0
	
	
###########################################################
# float integrate(float (*func)(float x), float low, float hi)
# integrates func over [low, hi]
# $f12 gets low, $f13 gets hi, $a0 gets address (label) of func
# $f0 gets return value
integrate: 
 	addi $sp,$sp,-4
 	sw $ra,0($sp)
 	
	lwc1 $f12,0($a1)	# load a
	lwc1 $f13,0($a2)	# load b
	la $t0,N		# load addr N
	lw $t0,0($t0)		# load value N
	mtc1 $t0,$f4		# convert
	cvt.s.w $f4,$f4		# $f4==N
	
	jal check		
	bc1f end		# flag==false then end
	
	sub.s $f5,$f13,$f12	# $f5==hi-lo
	div.s $f6,$f5,$f4	# $f6==delta x 
	
	#$f7==float 0
	li $t1,0
	mtc1 $t1,$f7
	cvt.s.w $f7,$f7		
	
	#$f8==float 2
	li $t1,2
	mtc1 $t1,$f8
	cvt.s.w $f8,$f8
	
	#$f9==float 1
	li $t1,1
	mtc1 $t1,$f9
	cvt.s.w $f9,$f9
	
	div.s $f10,$f6,$f8	# $f10==delta x/2	
	
	mov.s $f16,$f12		# $f16==lo
	mov.s $f17,$f13		# $f17==hi
	mov.s $f18,$f7		# initialize $f18==0
	
inte:	

	#terminate condition
	c.eq.s $f4,$f7
	bc1t finish
	add.s $f16,$f16,$f10
	mov.s $f12,$f16		# pass parameter
	jalr $a0		# func
	mov.s $f19,$f0		# return value
	mul.s $f19,$f19,$f6	# area=value*delta x
	add.s $f18,$f18,$f19	# sum+=func
	sub.s $f16,$f16,$f10
	add.s $f16,$f16,$f6	# next interval
	sub.s $f4,$f4,$f9	# length--

	j inte
	
	# initialize $f4 to hold N
	# since N is declared as a word, will need to convert 
	
finish:
	mov.s $f0,$f18
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

###########################################################
# void check(float low, float hi)
# checks that low < hi
# $f12 gets low, $f13 gets hi
# # prints error message and exits with status 1 on fail
check:
	c.lt.s $f12,$f13	# compare
	bc1t cont		# if flag==true, continue
		
	li $v0, 4		# print string
	la $a0, error
	syscall
	li $a0,1
cont:	jr $ra

###########################################################
# float ident(float x) { return x; }
# function to test your integrator
# $f12 gets x, $f0 gets return value
ident:	
	#y=x
	mov.s $f0, $f12
	jr $ra

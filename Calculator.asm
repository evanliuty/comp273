//  Ⓒ Copyright Tianyi Liu 2017, All Rights Reserved.
//  For reference only.
//  If you use or partially use this repo, you shall formally acknowledge this repo.
//  Latest Update: 12:26 June 4th, 2019 CST

	.data
info1:	.asciiz "calculator for MIPS\npress 'c' for clear and 'q' to quit:\nAny unknown key will NOT be stored and echoed!\n"
info2: 	.asciiz "Result: "
info3:	.asciiz "\nProgram Ends"
info4: 	.asciiz "\nProgram Cleared\n"
info5: 	.asciiz "\nERROR\nDivided by zero."
	.text
	.globl main
main:
	li $s7,10		# hard code 10

	la $s0,info1		# print info1
infoloop1:
	lb $a0,0($s0)
	beq $a0,$zero,init
	jal Write
	addi $s0,$s0,1
	j infoloop1

init:				# clear all
	li $t2,0
	li $t3,0
	li $s1,0

cal:
	li $t4,0
	li $t5,0
	li $t6,1		# sign flag for divi
	li $s1,0
	jal Read
	jal check
	beq $v1,$zero,valid1	# validation check
	j cal
valid1:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,43,plus		# +
	beq $v0,45,negormin	# - or negative number
	beq $v0,42,multi	# *
	beq $v0,47,divi		# /
	beq $v0,32,cal		# space ignore

	# FIRST NUMBER FOR ALL
	li $t2,0
	mul $t2,$t2,$s7		# *10
	move $t3,$v0
	andi $t3,$t3,0x0f
	add $t2,$t2,$t3		# first num in $t2
	j cal1

cal1:
	jal Read
	jal check
	beq $v1,$zero,valid2	# validation check
	j cal1
valid2:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,43,plus		# +
	beq $v0,45,negormin	# - or negative
	beq $v0,42,multi	# *
	beq $v0,47,divi		# /
	beq $v0,32,cal		# space ignore

	# FIRST NUMBER FOR ALL
	mul $t2,$t2,$s7		# *10
	move $t3,$v0
	andi $t3,$t3,0x0f
	beq $s1,-1,nega1	# if negative, then subtract
	add $t2,$t2,$t3		# positive add
	j cal1
nega1:
	sub $t2,$t2,$t3
	j cal1

plus:
	jal Read
	jal check		# validation check
	beq $v1,$zero,valid3
	j plus
valid3:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,32,plus		# +
	beq $v0,10,plusresult	# \n disp result

	#SECOND NUMBER FOR PLUS
	beq $v0,45,psn		# plus second negative
	mul $t4,$t4,$s7		# *10
	move $t5,$v0
	andi $t5,$t5,0x0f
	add $t4,$t4,$t5		# second number in $s4
	j plus
psn:
	li $t6,-1		# $t6, sign flag
	j plus

plusresult:
	mul $t4,$t4,$t6		# real $t4
	add $t7,$t2,$t4		# addition
	j disp

multi:
	jal Read
	jal check		# validtion check
	beq $v1,$zero,valid4
	j multi
valid4:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,32,multi	# *
	beq $v0,10,multiresult	# \b display result

	#SECOND NUMBER FOR MULTI
	beq $v0,45,mulsn	# multi second negative
	mul $t4,$t4,$s7		# *10
	move $t5,$v0
	andi $t5,$t5,0x0f
	add $t4,$t4,$t5		# second number in $t4
	j multi
mulsn:
	li $t6,-1		# sign flag
	j multi
multiresult:
	mul $t4,$t4,$t6		# real second number
	mul $t7,$t4,$t2		# result
	j disp

divi:
	jal Read
	jal check		# validtion check
	beq $v1,$zero,valid5
	j divi
valid5:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,32,divi		# /
	beq $v0,10,diviresult	# \n display result
	beq $v0,48,diverr	# divide by zero: error

	#SECOND NUMBER FOR DIVI
	beq $v0,45,divisn	# divi second negative
	mul $t4,$t4,$s7		# *10
	move $t5,$v0
	andi $t5,$t5,0x0f
	add $t4,$t4,$t5		# second number in $t4

divi1:
	jal Read
	jal check		# validation check
	beq $v1,$zero,valid6
	j divi1
valid6:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,32,divi		# /
	beq $v0,10,diviresult	# \n display result

	#SECOND NUMBER FOR DIVI
	mul $t4,$t4,$s7		# *10
	move $t5,$v0
	andi $t5,$t5,0x0f
	add $t4,$t4,$t5		# scond number in $t4
	j divi1

divisn:
	li $t6,-1
	j divi1

diviresult:
	mul $t4,$t4,$t6		# real second number
	div $t2,$t4		# divison
	mflo $t7		# result
	mfhi $t9		# reaminder
	j dispd


negormin:			# to know if it is a negative number or perform minus
	jal Read
	jal check		# validtion check
	beq $v1,$zero,valid7
	j negormin
valid7:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,32,minus	# follow a space means minus
	move $t2,$v0
	andi $t2,$t2,0x0f
	mul $t2,$t2,-1
	li $s1,-1		# negative flag
	j cal1

minus:
	jal Read
	jal check
	beq $v1,$zero,valid8
	j minus
valid8:
	move $a0,$v0
	jal Write
	beq $v0,113,end		# exit
	beq $v0,99,clear	# clear
	beq $v0,10,minusresult	# \n display result

	#SECOND NUMBER FOR MINUS
	beq $v0,45,minsn	# minus second negative
	mul $t4,$t4,$s7		# *10
	move $t5,$v0
	andi $t5,$t5,0x0f
	add $t4,$t4,$t5
	j minus
minsn:
	li $t6,-1		# sign flag
	j minus
minusresult:
	mul $t4,$t4,$t6		# real seccond number
	sub $t7,$t2,$t4		# subtraction
	j disp

# DIVISION ERROR
diverr:
	la $s0,info5		# display info5
infoloop5:
	lb $a0,0($s0)
	beq $a0,$zero,clear	# jump to clear
	jal Write
	addi $s0,$s0,1
	j infoloop5

# DISPLAY RESULT FOR + - * / WITHOUT REMINDER
disp:
	la $s0,info2		# display info2
infoloop2:
	lb $a0,0($s0)
	beq $a0,$zero,disp1
	jal Write
	addi $s0,$s0,1
	j infoloop2

disp1:
	beq $t7,$zero,disspecial# diaplay zero
	li $s5,0		# Counter
	move $s6,$t7
	bgt $0,$t7,dispneg	# negative
	j dispcont
dispneg:
	mul $t7,$t7,-1
	li $a0,45		# negative sign
	jal Write
dispcont:
	beq $t7,$zero,dispfinal
	div $t7,$s7		# /10
	mfhi $t8
	mflo $t7
	addi $s5,$s5,1
	addi $sp,$sp,-4		# store in stack
	sw $t8,0($sp)
	j dispcont
dispfinal:
	beq $s5,$zero,dispdone
	lw $a0,0($sp)		# display and resotre stack
	addi $sp,$sp,4
	addi $s5,$s5,-1
	addi $a0,$a0,48
	jal Write
	j dispfinal
dispdone:
	li $a0,10
	jal Write
	move $t2,$s6		# last result as first number
	j cal
disspecial:			# display 0
	li $a0,48
	jal Write
	li $a0,10
	jal Write
	move $t2,$t7
	j cal

# CLEAR
clear:
	la $s0,info4		# diaplay info4
infoloop4:
	lb $a0,0($s0)
	beq $a0,$zero,init
	jal Write
	addi $s0,$s0,1
	j infoloop4

# END
end:
	la $s0,info3		# display info3
infoloop3:
	lb $a0,0($s0)
	beq $a0,$zero,endd
	jal Write
	addi $s0,$s0,1
	j infoloop3
endd:
	li $v0,10		# terminate
	syscall

# VALIDATION CHECK
check:
	beq $v0,48,valid	#0
	beq $v0,49,valid	#1
	beq $v0,50,valid	#2
	beq $v0,51,valid	#3
	beq $v0,52,valid	#4
	beq $v0,53,valid	#5
	beq $v0,54,valid	#6
	beq $v0,55,valid	#7
	beq $v0,56,valid	#8
	beq $v0,57,valid	#9
	beq $v0,43,valid	#+
	beq $v0,45,valid	#-
	beq $v0,42,valid	#*
	beq $v0,47,valid	#/
	beq $v0,99,valid	#c
	beq $v0,113,valid	#q
	beq $v0,10,valid	#\n
	beq $v0,32,valid	#sapce
	li $v1,1
	jr $ra
valid:
	li $v1,0
	jr $ra
#Have fun!


#TODO:
#main procedure, that will call your calculator

#calculator procedure, that will deal with the input
	#2 cases you must consider:

	#  Number Operation Number <enter is pressed>
	#  Must display the result on the screen

	#  Operation Number <enter is pressed>
	#  uses prior result as the first number
	#  Returns the new result to the display


#driver for getting input from MIPS keyboard
Read:  	lui $t0, 0xffff #ffff0000
Loop1:	lw $t1, 0($t0) #control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1
	lw $v0, 4($t0) #data
	jr $ra

#driver for putting output to MIPS display
Write:  lui $t0, 0xffff #ffff0000
Loop2: 	lw $t1, 8($t0) #control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	sw $a0, 12($t0) #data
	jr $ra

# DISPLAY RESULT FOR / WITH REMINDER ONLY
dispd:
	beq $t9,$0,disp		# no reminder
	mul $t6,$t2,$t4		# $t6 to find sign
	bgt $t6,0,positive
	li $t6,-1
positive:
	la $s0,info2		# info2
infoloop2d:
	lb $a0,0($s0)
	beq $a0,$zero,disp1d
	jal Write
	addi $s0,$s0,1
	j infoloop2d

disp1d:
	# Reminder
	mtc1 $t9,$f4
	cvt.s.w $f4,$f4

	# 10
	mtc1 $s7,$f5
	cvt.s.w $f5,$f5

	# 0.005
	li $t9,5
	mtc1 $t9,$f6
	cvt.s.w $f6,$f6
	div.s $f6,$f6,$f5
	div.s $f6,$f6,$f5
	div.s $f6,$f6,$f5

	# divider
	mtc1 $t4,$f7
	cvt.s.w $f7,$f7

	# -1
	li $s2,-1
	mtc1 $s2,$f16
	cvt.s.w $f16,$f16
	#dIVISION
	div.s $f4,$f4,$f7

	#rounding
	mov.s $f10,$f4

	bne $t6,-1,posres
	sub.s $f10,$f10,$f6	# subtract if negative
	j posres1
posres:
	add.s $f10,$f10,$f6	# add if positive
posres1:
	mul.s $f10,$f10,$f5	# *100
	mul.s $f10,$f10,$f5

	cvt.w.s $f10,$f10
	mfc1 $s4,$f10		# float to int

	bne $t6,-1,posres2
	mul $s4,$s4,$t6
	ble $s4,99,contdivi	# case number >= .995.....
	addi $t7,$t7,-1		# negative case rounding
	j disp
posres2:
	ble $s4,99,contdivi
	addi $t7,$t7,1
	j disp

contdivi:
	beq $t7,$zero,disspeciald	# with decimal part but integer part =0
	li $s5,0		# Counter
	move $s6,$t7
	bgt $0,$t7,dispnegd	# negative
	j dispcontd
dispnegd:
	mul $t7,$t7,-1		# to positive
	li $a0,45		# negative sign
	jal Write
dispcontd:
	beq $t7,$zero,dispfinald
	div $t7,$s7		# /10
	mfhi $t8
	mflo $t7
	addi $s5,$s5,1
	addi $sp,$sp,-4
	sw $t8,0($sp)		# resore in stack
	j dispcontd
dispfinald:
	beq $s5,$zero,dispdoned
	lw $a0,0($sp)		# restore stack
	addi $sp,$sp,4
	addi $s5,$s5,-1
	addi $a0,$a0,48
	jal Write
	j dispfinald
dispdoned:
	li $a0,46
	jal Write
	div $s4,$s7		# / 10
	mflo $s3
	mfhi $s2
	move $a0,$s3
	addi $a0,$a0,48		# int to char
	jal Write
	beq $s2,$0,dispdone2
	move $a0,$s2
	addi $a0,$a0,48
	jal Write
dispdone2:
	li $a0,10
	jal Write
	beq $t6,-1,rounding2		# neagative rounding
	ble $s4,49,noround3
	addi $s6,$s6,1			# rounding
noround3:
	move $t2,$s6
	j cal
rounding2:
	bgt $s4,49,round1
	j noround3
round1:
	addi $s6,$s6,-1
	j noround3

disspeciald:
	bne $t6,-1,dispspeciald2
	li $a0,45		# negative sign
	jal Write
dispspeciald2:
	li $a0,48		# 0
	jal Write

	li $a0,46
	jal Write
	div $s4,$s7		# /10
	mflo $s3
	mfhi $s2
	move $a0,$s3
	addi $a0,$a0,48		# int to char
	jal Write
	beq $s2,$0,dispdone3
	move $a0,$s2
	addi $a0,$a0,48
	jal Write
dispdone3:
	li $a0,10
	jal Write
	beq $t6,-1,rounding	# rounding similar to above
	ble $s4,49,noround2
	addi $t7,$t7,1
noround2:
	move $t2,$t7
	j cal
rounding:
	bgt $s4,49,round
	j noround2
round:
	addi $t7,$t7,-1
	j noround2

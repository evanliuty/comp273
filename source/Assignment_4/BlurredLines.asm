#  Ⓒ Copyright Tianyi Liu 2017, All Rights Reserved.
#  For reference only.
#  If you use or partially use this repo, you shall formally acknowledge this repo.
#  Latest Update: 12:55 June 4th, 2019 CST

	.data

#Must use accurate file path.
#These file paths are EXAMPLES,
#should not work for you
str1:	.asciiz "/Users/Bao/Dropbox/Year 3 Semester 1/COMP 273/Assignment/Assignment 4/test1.txt"
str3:	.asciiz "test-blur.pgm"	#used as output
erre:	.asciiz "ERROR! Cannot Find File!"
errr:	.asciiz "ERROR! Cannot Read File!"
errw:	.asciiz "ERROR! Cannot Write File! "
info: 	.asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes
newbuff: .space 2048

	.text
	.globl main

main:
	la $a0,str1		#readfile takes $a0 as input
	jal readfile

	la $a1,buffer		#$a1 will specify the "2D array" we will be averaging
	la $a2,newbuff		#$a2 will specify the blurred 2D array.
	jal blur

	la $a0, str3		#writefile will take $a0 as file location
	la $a1,newbuff		#$a1 takes location of what we wish to write.
	jal writefile

	li $v0,10		# exit
	syscall

readfile:
	li $v0,13		# syscall for read file
	li $a1,0		# read
	li $a2,0		# mode ignored
	syscall

	addi $v0,$v0,1		#check if file exist
	ble $v0,$0,errore	# if not exist, error and exit
	subi $v0,$v0,1
	move $t0,$v0		# file descriptor in $t0

	li $v0,14		# read file
	la $a1,buffer
	li $a2,2047
	move $a0,$t0
	syscall

	addi $v0,$v0,1		# check if there is any error
	ble $v0,$0,errorr
	subi $v0,$v0,1

	li $v0,16		# close the file
	move $a0,$t0
	syscall

	la $s0,buffer
	move $t0, $s0		# start addr of buffer, ptr1 for read
	move $t1, $s0		# start addr of buffer, ptr2 for write
	li $t7,32		# space
	li $t8,10		# \n
	li $t9,0		# null

cvrt:
	lb $t2,0($t0)		# first digit
	addi $t0,$t0,1
	lb $t3,0($t0)		# second digit
	addi $t0,$t0,1
	beq $t3,$t7,one		# == space, one digit num
	beq $t3,$t8,oneend	# == \n one digit at the end
	lb $t4,0($t0)		# third digit
	addi $t0,$t0,1
	beq $t4,$t7,two		# == space, two digit num
	beq $t4,$t8,twoend	# == \n two digit at the end
	lb $t5,0($t0)		# fourth digit
	addi $t0,$t0,1
	beq $t5,$t8,thrend	# == \n three digit num

	# three digit
	andi $t2,$t2,0x0F	# char to int
	andi $t3,$t3,0x0F	# char to int
	andi $t4,$t4,0x0F	# char to int

	mul $t2,$t2,$t8		# $t2*100
	mul $t2,$t2,$t8
	mul $t3,$t3,$t8		# $t3*10
	add $t4,$t4,$t3
	add $t4,$t4,$t2		# $t4=result
	sb $t4,0($t1)		# store to buffer
	addi $t1,$t1,1		# next write pos
reloop:
	lb $t2,0($t0)		# next byte
	addi $t0,$t0,1
	beq $t2,$t7,reloop	# if space, next
	addi $t0,$t0,-1
	j cvrt
one:
	andi $t2,$t2,0x0F	# int to char
	sb $t2,0($t1)		# store
	addi $t1,$t1,1		# next write pos
	j reloop

oneend:
	andi $t2,$t2,0x0F	# int to char
	sb $t2,0($t1)		# store
	addi $t1,$t1,1		# next write pos
	lb $t4,0($t0)		# next byte
	beq $t4,$t9,endr	# == \0 end
	j cvrt

two:
	andi $t2,$t2,0x0F	# int to char
	andi $t3,$t3,0x0F
	mul $t2,$t2,$t8		# $t2*10
	add $t2,$t2,$t3		# $t2=result
	sb $t2,0($t1)		# store
	addi $t1,$t1,1		# next write pos
	j reloop

twoend:
	andi $t2,$t2,0x0F	# int to char
	andi $t3,$t3,0x0F
	mul $t2,$t2,$t8		# $t2*10
	add $t2,$t2,$t3		# $t2=result
	sb $t2,0($t1)		# store
	addi $t1,$t1,1		# next write pos
	lb $t4,0($t0)		# next byte
	beq $t4,$t9,endr	# == \0 end
	j cvrt
thrend:
		# three digit
	andi $t2,$t2,0x0F	# char to int
	andi $t3,$t3,0x0F	# char to int
	andi $t4,$t4,0x0F	# char to int

	mul $t2,$t2,$t8		# $t2*100
	mul $t2,$t2,$t8
	mul $t3,$t3,$t8		# $t3*10
	add $t4,$t4,$t3
	add $t4,$t4,$t2		# $t4=result
	sb $t4,0($t1)		# store to buffer
	addi $t1,$t1,1		# next write pos
	lb $t4,0($t0)		# next byte
	beq $t4,$t9,endr	# == \0 end
	j cvrt

endr:
	jr $ra

blur:
	move $t0,$a1		# $t0 = addr buffer
	move $t1,$a2		# $t1 = addr newbuff
	la $t2,info
	li $s0,1		# column counter
	li $s1,5		# row counter
	li $s2,24		# column
	li $s3,32		# space
	li $s4,10		# \n
	li $s5,9
	li $s6,99
	li $s7,0xFFFFFFFF	# a large num

loopinfo:
	lb $t3,0($t2)		# read info
	beq $t3,$zero,firstline
	addi $t2,$t2,1		# read next
	sb $t3,0($t1)		# store info
	addi $t1,$t1,1
	j loopinfo

lastline:
	li $s7,23
	li $s0,0xFFFFFFFF	# $s7 override $s0
firstline:
	beq $s7,$zero,lastnum
	beq $s0,$s2,lastnum
	lb $t2,0($t0)
	addi $t2,$t2,1
	bgt $t2,$0,continue0
	addi $t2,$t2,256
continue0:
	addi $t2,$t2,-1
	bgt $t2,$s6,threesave0	# >99
	bgt $t2,$s5,twosave0	# >9
	addi $t2,$t2,48		# int to char
	sb $t2,0($t1)		# save
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1		# next write pos
	addi $t0,$t0,1		# next read pos
	addi $s0,$s0,1		# column counter ++
	addi $s7,$s7,-1		# lastline counter --
	j firstline

threesave0:
	div $t2,$s4
	mflo $t4
	mfhi $t3		# lowest
	div $t4,$s4
	mflo $t5		# highest
	mfhi $t4		# mid
	addi $t3,$t3,48		# int to char
	addi $t4,$t4,48		# int to char
	addi $t5,$t5,48		# int to char
	sb $t5,0($t1)		# save highest
	addi $t1,$t1,1
	sb $t4,0($t1)		# save mid
	addi $t1,$t1,1
	sb $t3,0($t1)		# save lowest
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $s0,$s0,1
	addi $t0,$t0,1
	addi $s7,$s7,-1
	j firstline

twosave0:
	div $t2,$s4
	mflo $t4		# highest
	mfhi $t3		# lowest
	addi $t3,$t3,48
	addi $t4,$t4,48
	sb $t4,0($t1)		# save highest
	addi $t1,$t1,1
	sb $t3,0($t1)		# save lowest
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $s0,$s0,1
	addi $t0,$t0,1
	addi $s7,$s7,-1
	j firstline

lastnum:
	lb $t2,0($t0)
	addi $t2,$t2,1
	bgt $t2,$0,continue1
	addi $t2,$t2,256
continue1:
	addi $t2,$t2,-1
	bgt $t2,$s6,threesavel	# >99
	bgt $t2,$s5,twosavel	# >9
	addi $t2,$t2,48		# int to char
	sb $t2,0($t1)		# save
	addi $t1,$t1,1
	sb $s4,0($t1)		# save \n
	addi $t1,$t1,1
	addi $t0,$t0,1
	beq $s7,$zero,endfile
	beq $s1,$zero,lastline
	li $s0,2		# initial counter
	addi $s1,$s1,-1
	j firstnum

threesavel:
	div $t2,$s4
	mflo $t4
	mfhi $t3		# lowest
	div $t4,$s4
	mflo $t5		# highest
	mfhi $t4		# mid
	addi $t3,$t3,48
	addi $t4,$t4,48
	addi $t5,$t5,48
	sb $t5,0($t1)
	addi $t1,$t1,1
	sb $t4,0($t1)
	addi $t1,$t1,1
	sb $t3,0($t1)
	addi $t1,$t1,1
	sb $s4,0($t1)		# save \n
	addi $t1,$t1,1
	addi $t0,$t0,1
	beq $s7,$zero,endfile
	beq $s7,$zero,lastline
	li $s0,2		# initial counter
	j firstnum

twosavel:
	div $t2,$s4
	mflo $t4		# highest
	mfhi $t3		# lowest
	addi $t3,$t3,48
	addi $t4,$t4,48
	sb $t4,0($t1)
	addi $t1,$t1,1
	sb $t3,0($t1)
	addi $t1,$t1,1
	sb $s4,0($t1)		# save \n
	addi $t0,$t0,1
	beq $s7,$zero,endfile
	addi $t1,$t1,1
	beq $s7,$zero,firstnum
	li $s0,2		# initial counter
	j firstnum

firstnum:
	lb $t2,0($t0)
	addi $t2,$t2,1
	bgt $t2,$0,continue2
	addi $t2,$t2,256
continue2:
	addi $t2,$t2,-1
	bgt $t2,$s6,threesavef	# >99
	bgt $t2,$s5,twosavef	# >9
	addi $t2,$t2,48		# int to char
	sb $t2,0($t1)		# save
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $t0,$t0,1
	li $s0,2		# initial counter
	j convolution

threesavef:
	div $t2,$s4
	mflo $t4
	mfhi $t3		# lowest
	div $t4,$s4
	mflo $t5		# highest
	mfhi $t4		# mid
	addi $t3,$t3,48
	addi $t4,$t4,48
	addi $t5,$t5,48
	sb $t5,0($t1)
	addi $t1,$t1,1
	sb $t4,0($t1)
	addi $t1,$t1,1
	sb $t3,0($t1)
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $t0,$t0,1
	li $s0,2		# initial counter
	j convolution

twosavef:
	div $t2,$s4
	mflo $t4		# highest
	mfhi $t3		# lowest
	addi $t3,$t3,48
	addi $t4,$t4,48
	sb $t4,0($t1)
	addi $t1,$t1,1
	sb $t3,0($t1)
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $t0,$t0,1
	li $s0,2		# initial counter
	j convolution

convolution:
	beq $s0,$s2,lastnum
	li $t5,0		# sum
	lb $t6,0($t0)		# mid
	addi $t6,$t6,1
	bgt $t6,$0,continue3
	addi $t6,$t6,256
continue3:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,1
	lb $t6,0($t0)		# mid right
	addi $t6,$t6,1
	bgt $t6,$0,continue4
	addi $t6,$t6,256
continue4:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,-2
	lb $t6,0($t0)		# mid left
	addi $t6,$t6,1
	bgt $t6,$0,continue5
	addi $t6,$t6,256
continue5:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,-24
	lb $t6,0($t0)		# up left
	addi $t6,$t6,1
	bgt $t6,$0,continue6
	addi $t6,$t6,256
continue6:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,1
	lb $t6,0($t0)		# up mid
	addi $t6,$t6,1
	bgt $t6,$0,continue7
	addi $t6,$t6,256
continue7:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,1
	lb $t6,0($t0)		# up right
	addi $t6,$t6,1
	bgt $t6,$0,continue8
	addi $t6,$t6,256
continue8:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,48
	lb $t6,0($t0)		# down right
	addi $t6,$t6,1
	bgt $t6,$0,continue9
	addi $t6,$t6,256
continue9:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,-1
	lb $t6,0($t0)		# down mid
	addi $t6,$t6,1
	bgt $t6,$0,continue10
	addi $t6,$t6,256
continue10:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,-1
	lb $t6,0($t0)		# down left
	addi $t6,$t6,1
	bgt $t6,$0,continue11
	addi $t6,$t6,256
continue11:
	addi $t6,$t6,-1
	add $t5,$t5,$t6
	addi $t0,$t0,-22	# next pos
	div $t5,$s5
	mflo $t5
	mflo $a3
	ble $a3,4,continue12
	addi $t5,$t5,1
continue12:
	bgt $t5,$s6,threesavecon# three digits
	bgt $t5,$s5,twosavecon	# two disits
	addi $t5,$t5,48		# char to int
	sb $t5,0($t1)
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $s0,$s0,1
	j convolution

threesavecon:
	div $t5,$s4
	mflo $t7
	mfhi $t6		# lowest
	div $t7,$s4
	mflo $t8		# highest
	mfhi $t7		# mid
	addi $t6,$t6,48
	addi $t7,$t7,48
	addi $t8,$t8,48
	sb $t8,0($t1)
	addi $t1,$t1,1
	sb $t7,0($t1)
	addi $t1,$t1,1
	sb $t6,0($t1)
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $s0,$s0,1
	j convolution

twosavecon:
	div $t5,$s4
	mflo $t7		# highest
	mfhi $t6		# lowest
	addi $t7,$t7,48
	addi $t6,$t6,48
	sb $t7,0($t1)
	addi $t1,$t1,1
	sb $t6,0($t1)
	addi $t1,$t1,1
	sb $s3,0($t1)		# save space
	addi $t1,$t1,1
	addi $s0,$s0,1
	j convolution

endfile:
	sb $zero,0($t1)
	jr $ra
#use real values for averaging.
#HINT set of 8 "edge" cases.
#The rest of the averaged pixels will
#default to the 3x3 averaging method
#we will return the address of our
#blurred 2D array in #v1

writefile:
	move $t0,$a1		# save addr
	li $v0,13		# open file
	li $a1,1		# write
	li $a2,0		# ignore
	syscall

	addi $v0,$v0,1		#check if file exist
	ble $v0,$0,errore	# if not exist, error and exit
	subi $v0,$v0,1

	move $t1,$v0		# save file descriptor

	li $v0,15		# write file
	move $a0,$t1		# file descriptor

	addi $v0,$v0,1		# check if file exist
	ble $v0,$0,errorw	# if not exist, error and exit
	subi $v0,$v0,1

	li $v0,15		# write file
	move $a1,$t0
	li $a2,2048
	syscall

	li $v0,16
	syscall

	jr $ra
#done in Q1

errore:
	move $t0,$a0

	li $v0, 4		# print str
	la $a0, erre
	syscall

	li $v0,16		# close the file
	move $a0,$t0
	syscall

	li $v0,10		# exit
	syscall

errorr:
	move $t0,$a0

	li $v0, 4		# print str
	la $a0, errr
	syscall

	li $v0,16		# close the file
	move $a0,$t0
	syscall

	li $v0,10		# exit
	syscall

errorw:
	move $t0,$a0

	li $v0, 4		# print str
	la $a0, errw
	syscall

	li $v0,16		# close the file
	move $t0,$a0
	syscall

	li $v0,10		# exit
	syscall

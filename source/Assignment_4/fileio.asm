#  Ⓒ Copyright Tianyi Liu 2017, All Rights Reserved.
#  For reference only.
#  If you use or partially use this repo, you shall formally acknowledge this repo.
#  Latest Update: 12:55 June 4th, 2019 CST

.data

#Must use accurate file path.
#These file paths are EXAMPLES,
#should not work for you
str1:	.asciiz "/Users/Bao/Dropbox/Year 3 Semester 1/COMP 273/Assignment/Assignment 4/test1.txt"
str2:	.asciiz "/Users/Bao/Dropbox/Year 3 Semester 1/COMP 273/Assignment/Assignment 4/test2.txt"
str3:	.asciiz "test.pgm"	#used as output
erre:	.asciiz "ERROR! Cannot Find File!"
errr:	.asciiz "ERROR! Cannot Read File!"
errw:	.asciiz "ERROR! Cannot Write File! "
info: 	.asciiz "P2\n24 7\n15\n"

buffer:  .space 2048		# buffer for upto 2048 bytes

	.text
	.globl main

main:	la $a0,str1		#readfile takes $a0 as input
	jal readfile

	la $a0, str3		#writefile will take $a0 as file location
	la $a1,buffer		#$a1 takes location of what we wish to write.
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

	addi $v0,$v0,1		# check if therr is any error
	ble $v0,$0,errorr
	subi $v0,$v0,1

	la $a0,buffer		# print buffer
	li $v0,4
	syscall

	li $v0,16		# close the file
	move $a0,$t0
	syscall
	jr $ra

#Open the file to be read,using $a0
#Conduct error check, to see if file exists

# You will want to keep track of the file descriptor*

# read from file
# use correct file descriptor, and point to buffer
# hardcode maximum number of chars to read
# read from file

# address of the ascii string you just read is returned in $v1.
# the text of the string is in buffer
# close the file (make sure to check for errors)


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
	la $a1, info
	li $a2,12
	syscall

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


#open file to be written to, using $a0.
#write the specified characters as seen on assignment PDF:
#P2
#24 7
#15
#write the content stored at the address in $a1.
#close the file (make sure to check for errors)

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
	move $a0,$t0
	syscall

	li $v0,10		# exit
	syscall

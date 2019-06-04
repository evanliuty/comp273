#  Ⓒ Copyright Tianyi Liu 2017, All Rights Reserved.
#  For reference only.
#  If you use or partially use this repo, you shall formally acknowledge this repo.
#  Latest Update: 12:55 June 4th, 2019 CST

	.data
start:	 .asciiz	"Please start to enter character(s)\nCharacters on the keyboard are supported\nAsterisk (*) marks the end.\n\n"
string1: .asciiz	"Input a character: "
newline: .asciiz	"\n"
string2: .asciiz	"Original linked list\n"
string3: .asciiz 	"reversed linked list\n"

	.text
	.globl main
#There are no real limit as to what you can use
#to implement the 3 procedures EXCEPT that they
#must take the specified inputs and return at the
#specified outputs as seen on the assignment PDF.
#If convention is not followed, you will be
#deducted marks.

main:
	#Print string
	li $v0, 4
	la $a0, start
	syscall

	jal build
	move $s1,$v1	#Save addr
	move $s0,$v0	#Save length

	#Print string
	li $v0, 4
	la $a0, string2
	syscall

	move $a0,$s1	#Pass addr
	move $a1,$s0	#Pass length

	jal print

	move $a0,$s1	#Pass addr
	move $a1,$s0	#Pass length

	jal reverse

	move $a2,$v1	#Save addr

	#Print string
	li $v0, 4
	la $a0,newline
	syscall

	#Print string
	li $v0, 4
	la $a0, string3
	syscall

	move $a0,$a2	#Pass addr
	move $a1,$s0	#Pass length
	jal print

	#Terminate
	li $v0,10
	syscall

#build a linked list
#print "Original linked list\n"
#print the original linked list

#reverse the linked list
#On a new line, print "reversed linked list\n"
#print the reversed linked list
#terminate program

build:
	addi $t0,$0,42	#*=42
	addi $t1,$0,0 	#Counter/Length
	#Save $ra
	addi $sp, $sp, -4
	sw $ra,0($sp)

loop:
	#Print string
	li $v0, 4
	la $a0, string1
	syscall

	#Read char
	li $v0,12
	syscall
	move $t2,$v0	#copy char to $t2

	#Print string
	li $v0, 4
	la $a0,newline
	syscall

	#Terminate
	beq $t2,$t0,end

	#Allocate 5 bytes
	li $a0,5
	jal malloc

	beq $t1,$0,build2

	sw $v0,0($t4)	#Save addr

build2:
	move $t3,$v0	#copy addr to $t3

	#Save original address
	bne $t1,$0,cont
	move $v1,$t3

cont:	#Store
	addi $t3,$t3,4
	sb $t2,0($t3)	#Save char

	#Save previous addr
	addi $t3,$t3,-4
	move $t4,$t3

	addi $t1,$t1,1	#Counter++

	#Loop
	j loop

end:
	beq $t1,$0,endd
	#NULL
	li $a0,1
	jal malloc
	move $t3,$v0
	addi $t5,$0,0
	sb $t5,0($t3)
	sw $v0,0($t4)	#Save addr
	#Restore $ra

endd:
	move $v0,$t1 	#Save length
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra

#continually ask for user input UNTIL user inputs "*"
#FOR EACH user inputted character inG, create a new node that hold's inG AND an address for the next node
#at the end of build, return the address of the first node to $v1

print:
	move $t0,$a0

	#If length = 0 end
	beq $a1,$0,endprint

loopp:	addi $t0,$t0,4

	#Load char
	lb $t1,0($t0)

	#Terminate
	beq $t1,$0,endprint

	#Print char
	li $v0,11
	move $a0,$t1
	syscall

	#Next node
	addi $t0,$t0,-4
	lw $t0,0($t0)

	#loop
	j loopp

endprint:
	jr $ra

#$a0 takes the address of the first node
#prints the contents of each node in order

reverse:
	move $t0,$a1	#Save length
	move $t1,$a1	#Copy length
	move $t2,$a0	#Save addr
	move $t3,$a0	#Copy addr
	move $v1,$a0	#If length==0 or ==1 the returned addr is the same
	# length == 0
	beq $t1,$0,endrd
	# length == 1
	addi $t1,$t1,-1
	beq $t1,$0,endrd

#the first and second node
loopr:
	beq $t1,$0,endr
	addi $t1,$t1,-1	#length--
	lw $t4,0($t2)	#$t4=node 1's value
	lw $t5,0($t4)	#$t5=node 2's value
	sw $t2,0($t4)	#store node 1's addr to node 2
	move $t2,$t4	#$t2=node 1's value i.e. next iteration's start addt

#the rest nodes
loo:	beq $t1,$0,endr	#length=0, stop
	addi $t1,$t1,-1	#length--
	move $t4,$t5	#$t4=node 2's value
	lw $t5,0($t4)
	sw $t2,0($t4)
	move $t2,$t4
	j loo

endr:
	sw $t5,0($t3)	#save the null
	move $v1,$t4	#return value
endrd:
	jr $ra

#$a1 takes the address of the first node of a linked list
#reverses all the pointers in the linked list
#$v1 returns the address

malloc:
	#Allocate memory
	li $v0,9
	syscall
	jr $ra

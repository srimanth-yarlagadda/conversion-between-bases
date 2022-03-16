#######################################################################################################################
# File Name		: format_conversion.asm
# Author		: Srimanth Yarlagadda
# Modification History	: Last modified on 10/18/2021. First development.
# Procedures		:
# main			: Read data from file, filename input by user, generate statistics for characters in data
######################################################################################################################      			
      		
      		.globl main				#Define global symbols

#############################################################################################################################
# main
# Author		: Srimanth Yarlagadda
# Modification History	: Last modified on 10/18/2021. First development.
# Description		: Prompt user to enter filename, read and loop through data, summarize and print statistics of data
# Arguments		: None
#############################################################################################################################

main:								#"main" label for following instructions

## DATA SEGMENT
## ============
      		.data						#Data to be stored (under data section)
prompt1:	.asciiz  "Enter filename: "			#Prompt message - ask user to enter name of the file
filename:	.space 	1024					#Reserve 1024 bytes for file name
readdata:	.space 	10240					#Reserve 10240 bytes for data to be read
output: 	.space  40
makenewline:	.asciiz "\n"					#New line: Creates new line when printed
msgd:		.asciiz "\nNumber of Number Symbols: "		#Message to identify Number Symbols
msgu:		.asciiz "\nNumber of Upper Case Letters: "	#Message to identify Upper Case Letters
msgl:		.asciiz "\nNumber of Lower Case Letters: "	#Message to identify Lower Case Letters
hexprefix:	.asciiz "0x"		#Message to identify other symbols
depm:		.asciiz "\nDeprecated Output Function\n"			#Message to identify new lines
enterbinloop:	.asciiz "\n Entering bin loop \n"		#Message to identify signed numbers
enterhexloop:	.asciiz "\n Entering hex loop \n"		#Message to identify signed numbers
nl:		.asciiz "\n"		#Message to identify signed numbers
here:		.asciiz "here \n"		#Message to identify signed numbers
stringz:	.asciiz "d"

## TEXT SEGMENT
## ============

## Read Filename
## ==============

      	 	.text
      		li $v0, 4				#Load system call code to print string
     		la $a0, prompt1				#Load address of prompt1 - ask user to enter file name
     		syscall					#System call: Print
     	
     		li $v0, 8				#Load system call code to read string
     		la $a0, filename			#Buffer is declared under "filename" label
     		li $a1, 1024				#Maximum length of string defined as 1024 bytes
     		syscall					#System call: Read string
     				

## Null terminate filename: Overwrite last byte with zero 
## =======================================================
fixfilename:	li $t0, 0				#Initialize register $t0 to 0 - loop counter
cont_loop:	lb $t2, filename($t0)			#Starting point of the loop, loadbyte from filename string - index $t0 
		addi $t0, $t0, 1			#Increase loop counter (index) by one, in advance
		bne $t2, 0x0A, cont_loop		#If loaded byte is not "newline"character - skip next steps, continue loop
		addi $t0, $t0, -1			#If loaded byte is "newline" character, decrease index by 1, "newline" character 
		sb $zero, filename($t0)			#Storebyte "zero" in the place of "newline" symbol - NULL termination
		j openfile				#Jump to "openfile"

## Open file, read data
## ======================
openfile:	la $a0, filename			#Load address "filename"
     		li $a1, 0				#Set flag 0 [open for reading]
     		li $a2, 0				#Set $a2 as 0, Mode is ignored
     		li $v0, 13				#Load system call code to open file
     		syscall					#System call: open file
     	
readfile:	move $s0, $v0				#Move the file descriptor into saved register
     		move $a0, $s0				#Use to file descriptor as argument to read file
     		la $a1, readdata			#Buffer is declared under "readdata" label
     		li $a2, 10240 				#Maximum length of the data to be read
     		li $v0, 14				#Load system call code to read data
     		syscall					#System call: read data
	     	move $s5, $v0				#Move the number of bytes read into register $s5

## READ: READ DATA AND CALL PROCEDURES 
## ====================================


	     	   

## LOOP: READ AND IDENTIFY EACH CHARACTER 
## =======================================
		li $t0, 0
converter:	
     		li $s1, 0
     		li $t9, 10
     		
     		lb $s0, readdata($t0)
		addi $t0, $t0, 1
		
		lb $t1, readdata($t0)
		
		
		
addtoinlength:	mult $s1, $t9
		mflo $s1
		addi $t1, $t1, -48
		add $s1, $s1, $t1
		addi $t0, $t0, 1
		
		move $a0, $s1
		li $v0, 1
		#syscall
		li $v0, 4
		la $a0, nl
		#syscall
		
		lb $t1, readdata($t0)
		bgt $t1, 0x39, done			
		blt $t1, 0x30, done
		j addtoinlength
		
		lb $s2, readdata($t0)
		addi $s1, $s1, -48
		bgt $s2, 0x39, done			
		blt $s2, 0x30, done	
		addi $s2, $s2, -48
		multu $s1, $t7
		mflo $s1
		add $s1, $s1, $s2
		
		addi $t0, $t0, 1
	done:	lb $s2, readdata($t0)
		
		move $a0, $s2
		li $v0, 1
		#syscall
		li $v0, 4
		la $a0, nl
		#syscall
	
		
		#j exit
		jal reader
		jal outputer
		
readeol:	lb $t1, readdata($t0)
		beq $t1, 10, contnewinput
		addi $t0, $t0, 1
		j readeol
contnewinput:	addi $t0, $t0, 1
		blt $t0, $s5, converter
		j exit
		
outputer:	
		bne $s2, 0x42, dout
		li $t9, 2
		li $t8, 4
		li $t7, 0x20
		li $t6, 4
		j output_val
	dout:   bne $s2, 0x44, hout
		li $t9, 10
		li $t8, 3
		li $t7, 0x2C
		li $t6, 3
		j output_val
	hout:	li $t9, 16
		li $t8, 4
		li $t7, 0x20
		li $t6, 4
		j output_val
		
output_val:	li $t4, 39
		move $s4, $s3
		
	lcont:	bne $t6, $0, createoutput
		li $v1, 4
		la $a0, here
		#syscall
		sb $t7, output($t4)
		subi $t6, $t6, -1
		beq $s4, $0, exit_out_loop
		addi $t4, $t4, -1
		bne $s2, 0x44, load4spaces
		li $t6, 3
		j lcont
load4spaces:	li $t6, 4
		j lcont
	
createoutput:	div $s4, $t9
		mflo $s4
		mfhi $t5
		
		blt $t5, 10, stbyte
		addi $t5, $t5, 7
			
	stbyte:	addi $t5, $t5, 48
		sb $t5, output($t4)
		addi $t6, $t6, -1
		beq $s4, $0, exit_out_loop
		addi $t4, $t4, -1
		j lcont
		
exit_out_loop:	bne $s2, 0x42, format
		li $t5, 0x30
		li $t8, 6
		addi $t6, $t6, 1
	outbin:	blt $t4, $t8, format
		
		bne $t6, $0, loadzero
		sb $t7, output($t4)
		#subi $t6, $t6, -1
		addi $t4, $t4, -1
		li $t6, 4
		j outbin
		
   loadzero:	sb $t5, output($t4)
		addi $t4, $t4, -1
		addi $t6, $t6, -1
		j outbin
		
format:		li $v0, 11
		move $a0, $s0
		syscall
		li $a0, 0x3a
		syscall
		li $a0, 0x20
		syscall
		move $a0, $s1
		addi $a0, $a0, 0
		li $v0, 1
		syscall
		li $v0, 11
		li $a0, 0x3b
		syscall
		li $a0, 0x20
		syscall
		move $a0, $s2
		syscall
		li $a0, 0x3a
		syscall
		li $a0, 0x20
		syscall
		
		bne $s2, 0x48, sk_hx_pfx
		li $v0, 4
		la $a0, hexprefix
		#syscall

sk_hx_pfx:	
		li $t5, 0
		li $t6, 39
		li $v0, 11
		
		
printlp:	lb $a0, output($t5)
		beq $a0, 0, skipprint
		syscall
		j overwrite
skipprint:	#bne $s2, 0x42, overwrite
		#li $a0, 48
		#syscall

overwrite:	sb $0, output($t5)
		addi $t5, $t5, 1
		bgt $t5, $t6, skip
		j printlp

	skip:	la $a0, nl
		li $v0, 4
		syscall
			
		jr $ra
		
## =====================================================================			
## SINGLE READ FUNCTION ================================================
reader:		
		li $s3, 0

		bne $s0, 0x62, dbase
		li $t9, 2
		j read
	dbase:  bne $s0, 0x64, hbase
		li $t9, 10
		j read
	hbase:	li $t9, 16
		j read
		
read:		addi $t0, $t0, 3
		add  $t2, $t0, $s1
		
readloop:	lb $t1, readdata($t0)
		
		
		bge $t1, 0x30, numsym
		addi $t2, $t2, 1
		j contwoadd
		
numsym:		mult $s3, $t9
		mflo $s3
		bgt $t1, 0x39, uc
		addi $t1, $t1, -48
		j addcont
uc:		bgt $t1, 0x5A, lc
		blt $t1, 0x41, lc
		addi $t1, $t1, -65
		addi $t1, $t1, 10
		j addcont
lc:		bgt $t1, 0x7A, lc
		blt $t1, 0x61, lc
		addi $t1, $t1, -97
		addi $t1, $t1, 10
		j addcont
		
addcont:	add $s3, $s3, $t1
contwoadd:	add $t0, $t0, 1
		bge $t0, $t2, exit_read_proc
		
		j readloop
		
exit_read_proc: jr $ra


## EXIT
## ====   	
print:   	move $a0, $s3
		li $v0, 1
		syscall
		
		la $a0, nl
		li $v0, 4
		syscall
		j outputer
		
		addi $t0, $t0, 1
		move $a0, $t0
		li $v0, 1
		#syscall
		#j converter
		
					

end:		la $a0, nl
		li $v0, 4
		syscall
		
		move $a0, $s3
		li $v0, 1
		syscall

exit:		li $v0, 10				#Load system call code to exit
     		syscall					#System call: Exit

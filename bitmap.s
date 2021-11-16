.global main

.include "message.s"
.include "printStuff.s"
.include "createlead.s"
.include "RLE.s"
.include "barcode.s"
.include "XOR.s"
.include "BMP.s"

.data
input:          .asciz "%ld"
firstoutput:    .asciz "Press 0 to create the BMP or 1 to decode it\n"

.bss
BMPToDecrypt:       .space 4096

.text
main:
  pushq %rbp
  movq %rsp, %rbp
  
  # outputting prompt
  movq $0, %rax
  movq $firstoutput, %rdi
  call printf
  
  # reading user input
  subq $16, %rsp
  movq $0, %rax
  movq $input, %rdi
  leaq -16(%rbp), %rsi
  call scanf

  popq %rsi
  
  cmpq $0, %rsi
  je doMake

  call decodeBMP
  jmp done

  doMake:
  call makeBMP

  done:

  popq %r8
  movq %rbp, %rsp
  popq %rbp
end:
  movq $0, %rdi
  call exit


makeBMP:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r12
  pushq %r13
  pushq %r14

  ############################### Creating lead & trail
  movq $MESSAGE, %rdi
  
  call create_lead
  
  movq %rax, %rdi
  movq %rax, %r14
  #call printLead

  ############################### Encoding the message  
  movq $MESSAGE, %rdi

  call encode
  
  movq %rax, %r12
  movq %rax, %rdi
  #call printEncoded
  
  
  ############################### Creating the barcode
  # the number has to be inverted
  movq $1661927679, %rdi

  call create_barcode
  movq %rax, %rdi
  movq %rax, %r13
 # call printSomeBarcode
  
  #call printNewLine
  
  ############################### Encrypting the message
  # %r12 holds the encoded text
  # %r13 holds the barcode key
  # %r14 holds the lead & trail
  
  # encrypting the lead
  movq %r14, %rdi
  movq %r13, %rsi
  call encrypt
  
  # encrypting the encoded text
  movq %r12, %rdi
  movq %rax, %rsi
  call encrypt

  # encrypting the trail
  movq %r14, %rdi
  movq %rax, %rsi
  call encrypt

  
  ############################### Creating the BMP
  # %r13 holds the encrypted barcode
  movq %r13, %rdi
  call createBMP

  movq %rax, %rdi
  movq $1, %rsi
  call printToFile
  
  popq %r14
  popq %r13
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret
decodeBMP:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r12
  pushq %r13

  movq $BMPToDecrypt, %rdi
  call readFromFile
  
  ############################## Change BGR to RGB
  movq $BMPToDecrypt, %rdi
  call decreateBMP

  ############################## Creating the barcode
  movq $1661927679, %rdi
  call create_barcode

  ############################## Decrypting the message
  movq %rax, %rdi
  movq $BMPToDecrypt, %r8
  leaq 54(%r8), %rsi    # we want the result to overwrite the BMP
  call decrypt

  ############################## Finding the length of the lead   
  movq $BMPToDecrypt, %r8
  leaq 54(%r8), %rdi
  call findLead
  movq %rax, %r12
  imulq $2, %r12      # the lead has a number and a letter r12 times

  ############################## Finding the length of the string
  movq $BMPToDecrypt, %r8
  leaq 54(%r8), %rdi
  call findLength
  movq %rax, %r13

  ############################## Decoding the message
  
  # want to find where the message ends
  subq %r12, %r13
  
  # make the message zero terminated
  movq $BMPToDecrypt, %r8
  movb $0, 54(%r8, %r13, 1)

  # decode the message
  movq $BMPToDecrypt, %r8
  addq %r12, %r8        # we can ignore the lead
  leaq 54(%r8), %rdi
  call decode

  ############################## Print the output
  movq %rax, %rdi
  call printString
  
  call printNewLine
  
  popq %r13
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret

.global printSomeBarcode
.global printLead
.global printEncoded
.global printDecoded
.global printNewLine
.global printBMP
.global printToFile
.global readFromFile

output:          .asciz "%ld %c\n"
outputencoded:   .asciz "%ld%c"
outputdecoded:   .asciz "%c"
outputbarcode:   .asciz "(%ld, %ld, %ld) "
outputBMP:       .asciz "%ld "
outputBMPHex:    .asciz "%c"
outputString:    .asciz "%s"
filename:        .asciz "bit.bmp"
backslash:       .asciz "\n"

# Prints a new line
printNewLine:
  pushq %rbp
  movq %rsp, %rbp
  
  movq $0, %rax
  movq $backslash, %rdi
  call printf

  movq %rbp, %rsp
  popq %rbp
  ret

# Prints a string
printString:
  pushq %rbp
  movq %rsp, %rbp
  
  movq %rdi, %rsi
  movq $0, %rax
  movq $outputString, %rdi
  call printf

  movq %rbp, %rsp
  popq %rbp
  ret
# Takes in pointer to lead in %rdi
# Stops when it finds a 0
printLead:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r13
  
  movq %rdi, %r13

  loopmain:
    cmpb $0, (%r13)
    je endloopmain
    
    movq $0, %rax
    movq $output, %rdi
    movq $0, %rsi
    movb (%r13), %sil
    movq $0, %rdx
    movb 1(%r13), %dl
    call printf
    
    addq $2, %r13
    jmp loopmain
  endloopmain:
    
  popq %r13
  
  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to encoded text in %rdi
# Stops when it finds 0
printEncoded:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r13
  
  movq %rdi, %r13
  loopmain2:
    cmpb $0, (%r13)
    je endloopmain2
    
    movq $0, %rax
    movq $outputencoded, %rdi
    movq $0, %rsi
    movb (%r13), %sil
    movq $0, %rdx
    movb 1(%r13), %dl
    call printf
    
    addq $2, %r13
    jmp loopmain2
  endloopmain2:
  
  movq $0, %rax
  movq $backslash, %rdi
  call printf
  
  popq %r13
  
  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to decoded text in %rdi
# Stops when it finds 0
printDecoded:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r13
  
  movq %rdi, %r13
  loopmain3:
    cmpb $0, (%r13)
    je endloopmain3
    
    movq $0, %rax
    movq $outputdecoded, %rdi
    movq $0, %rsi
    movb (%r13), %sil
    call printf
    
    incq %r13
    jmp loopmain3
  endloopmain3:

  movq $0, %rax
  movq $backslash, %rdi
  call printf
  
  popq %r13
  
  movq %rbp, %rsp
  popq %rbp
  ret
  
# Takes in ponter to barcode in %rdi
printSomeBarcode:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r12
  pushq %r13
  pushq %r14
  
  movq %rdi, %r12
  movq $0, %r13

  loopmain4:
    cmpq $32, %r13
    je endloopmain4
    
    movq $0, %r14
    loopmain5:
      cmpq $32, %r14
      je endloopmain5
      
      movq $0, %rsi
      movq $0, %rdx
      movq $0, %rcx
      movq $0, %rax
      movq $outputbarcode, %rdi
      movb (%r12), %sil
      movb 1(%r12), %dl
      movb 2(%r12), %cl
      call printf

      addq $3, %r12
      incq %r14
      jmp loopmain5
    endloopmain5:

    movq $0, %rax
    movq $backslash, %rdi
    call printf

    incq %r13
    jmp loopmain4
  endloopmain4:
  
  movq $0, %rax
  movq $backslash, %rdi
  call printf
  
  popq %r14
  popq %r13
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to BMP in %rdi
# %rsi is 0 if we want output in base 10
# %rsi is 1 is we want output in hex
printBMP:
  pushq %rbp
  movq %rsp, %rbp

  pushq %r12
  pushq %r13
  pushq %r14
  
  movq %rdi, %r12
  movq $3126, %r13
  
  # r14 holds the pointer to the format we print in
  cmpq $0, %rsi
  jne outputInHex

  movq $outputBMP, %r14
  jmp loopPrintBMP
  
  outputInHex:
  movq $outputBMPHex, %r14

  loopPrintBMP:
    cmpq $0, %r13
    je endLoopPrintBMP
    
    movq $0, %rax
    movq $0, %rsi
    movb (%r12), %sil
    movq %r14, %rdi
    call printf
    
    incq %r12
    decq %r13
    jmp loopPrintBMP
  endLoopPrintBMP:

  movq $0, %rax
  movq $backslash, %rdi
  call printf
  
  popq %r14
  popq %r13
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to string to print in %rdi
# File size is 14+40+3*32*32=3126
printToFile:
  pushq %rbp
  movq %rsp, %rbp
  pushq %r12
  
  movq %rdi, %r12
  
  # opening the file
  movq $2, %rax     # sys open
  movq $filename, %rdi
  movq $1, %rsi     # write only
  movq $420,%rdx
  syscall

  # writing
  pushq %rax
  movq %rax, %rdi # file descriptor
  movq $1, %rax   # Write
  movq $3126, %rdx # string size
  movq %r12, %rsi # pointer to string
  syscall

  # closing the file
  movq $3, %rax   # sys close
  popq %rdi       # file descriptor
  syscall

  popq %r12
  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to memory to fill in rdi
readFromFile:
  pushq %rbp
  movq %rsp, %rbp
  pushq %r12
  
  movq %rdi, %r12
  
  # opening the file
  movq $2, %rax     # sys open
  movq $filename, %rdi
  movq $0, %rsi     # read only
  movq $420,%rdx
  syscall

  # reading
  pushq %rax
  movq %rax, %rdi # file descriptor
  movq $0, %rax   # Read
  movq $3126, %rdx # string size
  movq %r12, %rsi # pointer to string
  syscall

  # closing the file
  movq $3, %rax   # sys close
  popq %rdi       # file descriptor
  syscall

  popq %r12
  movq %rbp, %rsp
  popq %rbp
  ret


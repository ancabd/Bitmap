.global encode
.global decode

.bss
newArrayEncode:        .space 256
newArrayDecode:        .space 256

.text
# Takes in the pointer to array that needs encoding in %rdi
encode:
  pushq %rbp
  movq %rsp, %rbp
  
  pushq %r12

  # we use r8 as an index 
  movq $0, %r8
  
  # the number of times a charater is repeted is in r9
  movq $1, %r9

  # the pointer to newArray is in r10
  movq $newArrayEncode, %r10
  
  movq $0, %r11
  movq $0, %r12

  loopEncode:
    movb (%rdi, %r8, 1), %r11b
    cmpb $0, %r11b
    je endLoopEncode
    
    incq %r8

    # compare current character to previous
    movb -1(%rdi, %r8, 1), %r11b
    movb (%rdi, %r8, 1), %r12b
    cmpb %r11b, %r12b

    je ifequals
      
      # add prev character and nr repetitions to array
      movb %r9b, (%r10)
      incq %r10

      movb -1(%rdi, %r8, 1), %r11b
      movb %r11b, (%r10)
      incq %r10
      
      jmp loopEncode
    ifequals:
      incq %r9
      jmp loopEncode

  endLoopEncode:

  movq $newArrayEncode, %rax
  
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to array that needs decoding in %rdi
# the string to be decoded should be zero-terminated
decode:
  pushq %rbp
  movq %rsp, %rbp
  
  # the array index is in %r8
  movq $0, %r8

  # the pointer to newArray is in %r9
  movq $newArrayDecode, %r9
  
  movq $0, %r10
  movq $0, %r11

  loopDecode:
    cmpb $0, (%rdi, %r8, 1)
    je endLoopDecode
    
    # r10 = nr of times a character is repeated
    # r11 = the character 
    movb (%rdi, %r8, 1), %r10b
    movb 1(%rdi, %r8, 1), %r11b

    loopDecode2:
      cmpb $0, %r10b
      je endLoopDecode2
      
      movb %r11b, (%r9)
      incq %r9

      decq %r10
      jmp loopDecode2
    endLoopDecode2:

    addq $2, %r8
    jmp loopDecode
  endLoopDecode:
  
  movq $newArrayDecode, %rax

  movq %rbp, %rsp
  popq %rbp
  ret

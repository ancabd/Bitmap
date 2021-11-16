.global create_lead
.global findLead
.global findLength

.bss

lead:             .space 256
frequencyArray:   .space 128

.text

# Takes pointer to message in %rdi
# Returns pointer to lead/trail in %rax
create_lead:
  pushq %rbp
  movq %rsp, %rbp
  
  # hold the pointer to the frequency array in r8
  movq $frequencyArray, %r8

  # hold the pointer to the part of lead array 
  # we're currently working in in %r9
  movq $lead, %r9
  
  movq $0, %r10

  loopLead:
    cmpb $0, (%rdi)
    je endLoopLead
    
    movb (%rdi), %r10b    # r10 holds the current character 

    incb (%r8, %r10, 1)   # increases frequencyArray[%r10]

    incq %rdi
    jmp loopLead
  endLoopLead:
  
  movq $0, %rdi            # use rdi as counter

  loopLead2:
    cmpq $127, %rdi
    je endLoopLead2
    
    incq %rdi
    
    # test if a character exists in our string
    cmpb $0, -1(%r8, %rdi, 1)
    je loopLead2           # if it doesn't exist we go to the next
    
    # put the number of repetitions in lead
    movq $0, %r10
    movb -1(%r8, %rdi, 1), %r10b
    movb %r10b, (%r9)
    incq %r9
    
    # put the character in lead
    movb %dil, (%r9)
    decq (%r9)
    incq %r9

    jmp loopLead2

  endLoopLead2:
  
  movq $lead, %rax

  movq %rsp, %rbp
  popq %rbp
  ret

# Recieves the pointer to the start of the decrypted message in rdi
# Returns the length of the lead & trail in %rax
findLead:
  pushq %rbp
  movq %rsp, %rbp
  
  movq $0, %rax
  loopFindLead:
    incq %rax
    
    movq $0, %r8
    movq $0, %r9

    movb 1(%rdi, %rax, 2), %r8b   # current letter
    movb -1(%rdi, %rax, 2), %r9b  # previous letter
    cmpb %r8b, %r9b               # if r9 >= r8 loop stops

    jge endLoopFindLead
    jmp loopFindLead
  endLoopFindLead:

  movq %rsp, %rbp
  popq %rbp
  ret

# Recieves a pointer to the string to parse
# Returns the lentgth of a zero terminated string in %rax
findLength:
  pushq %rbp
  movq %rsp, %rbp
  
  movq $0, %rax
  loopFindLength:
    cmpb $0, (%rdi, %rax, 1)
    je endLoopFindLength

    incq %rax
    jmp loopFindLength
  endLoopFindLength:

  movq %rbp, %rsp
  popq %rbp
  ret

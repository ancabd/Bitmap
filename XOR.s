.global encrypt
.global decrypt

# Takes in 2 parameters
# %rdi : pointer to text
# %rsi : pointer to key
# Encrypts/decrypts text and stores result in key
# Returns pointer to first value in key that isn't changed in case of encrypt

encrypt:
  pushq %rbp
  movq %rsp, %rbp
    
  loopEncrypt:
    cmpb $0, (%rdi)
    je endLoopEncrypt
    
    movb (%rdi), %r8b
    xorb %r8b, (%rsi)
    
    incq %rsi
    incq %rdi
    jmp loopEncrypt
  endLoopEncrypt:
  
  movq %rsi, %rax

  movq %rbp, %rsp
  popq %rbp
  ret

decrypt:
  pushq %rbp
  movq %rsp, %rbp
  
  # 32 * 32 * 3 = 3072
  movq $3072, %r9

  loopDecrypt:
    cmpq $0, %r9
    je endLoopDecrypt
    
    movb (%rdi), %r8b
    xorb %r8b, (%rsi)
    
    incq %rsi
    incq %rdi
    decq %r9
    jmp loopDecrypt
  endLoopDecrypt:

  movq %rbp, %rsp
  popq %rbp
  ret


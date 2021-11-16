.global create_barcode

.bss
Barcode:      .space 4096

# Creates a barcode using the sequence of black(0), white(1) provided in %rdi
# adds a red pixel at the end

.text
create_barcode:
  push %rbp
  movq %rsp, %rbp
  
  pushq %r12

  # %r8 holds the current index of the final array
  movq $Barcode, %r8

  # %r9 and %r10 hold the size of the image
  movq $0, %r9
  movq $0, %r10

  loopBarcode:
    cmpq $32, %r9
    je endLoopBarcode
    
    movq $0, %r10


    loopBarcode2:
      cmpq $31, %r10        # 31 bits that are b/w
      je endLoopBarcode2
      
      # %r11 holds the configuration for b/w
      movq %rdi, %r11
      
      movb %r10b, %cl
      shr %cl, %r11         # get the correct bit
      andq $1, %r11         # get the last bit
      imul $255, %r11       # get the correct color

      # add the color to the barcode
      movb %r11b, (%r8)
      movb %r11b, 1(%r8)
      movb %r11b, 2(%r8)

      addq $3, %r8
      
      incq %r10
      jmp loopBarcode2
    endLoopBarcode2:
    
    # add the red
    movb $255, (%r8)
    movb $0, 1(%r8)
    movb $0, 2(%r8)

    addq $3, %r8

    incq %r9
    jmp loopBarcode
  endLoopBarcode:

  movq $Barcode, %rax
  
  popq %r12

  movq %rbp, %rsp
  popq %rbp
  ret

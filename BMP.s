.global createBMP
.global decreateBMP

.bss
BMPfile: .space 4096

.text

# Takes in pointer to barcode in %rdi
createBMP:
  pushq %rbp
  movq %rsp, %rbp
  
  movq $BMPfile, %r8

  ############################# Create File Header

  # signature
  movb $66, (%r8)
  movb $77, 1(%r8)
  addq $2, %r8

  # file size = 14+40+32*32*3=3126 (4 bytes) and 4 reserved bytes
  movl $3126, (%r8)
  addq $8, %r8

  # offset of pixel data inside image (4 bytes)
  movl $54, (%r8)
  addq $4, %r8

  ############################# Create Bitmap Header

  # header size (4 bytes)
  movl $40, (%r8)
  addq $4, %r8

  # width and height of image (4 bytes each)
  movl $32, (%r8)
  addq $4, %r8
  movl $32, (%r8)
  addq $4, %r8
  
  # reserved field = 1 (2 bytes)
  movw $1, (%r8)
  addq $2, %r8

  # the number of bits per pixel (2 bytes)
  movw $24, (%r8)
  addq $2, %r8

  # compression method (4 bytes)
  movl $0, (%r8)
  addq $4, %r8

  # size of pixel data = 32*32*3=3072 (4 bytes)
  movl $3072, (%r8)
  addq $4, %r8

  # horizontal & vertical resolution (4 bytes each)
  movl $2835, (%r8)
  addq $4, %r8
  movl $2835, (%r8)
  addq $4, %r8

  # color pallete information (4 bytes)
  movl $0, (%r8)
  addq $4, %r8

  # number of important colors (4 bytes)
  movl $0, (%r8)
  addq $4, %r8
  
  movq $1024, %r9
  loopCreateBMP:
    cmpq $0, %r9
    je endLoopCreateBMP
      
    # blue
    movb 2(%rdi), %r10b
    movb %r10b, (%r8)

    # green
    movb 1(%rdi), %r10b
    movb %r10b, 1(%r8)

    # red
    movb (%rdi), %r10b
    movb %r10b, 2(%r8)
    
    # padding
    #movb $0, 3(%r8)

    addq $3, %rdi
    addq $3, %r8

    decq %r9
    jmp loopCreateBMP
  endLoopCreateBMP:
  
  movq $BMPfile, %rax

  movq %rbp, %rsp
  popq %rbp
  ret

# Takes in pointer to BMP in rdi
# Switches BGR to RGB
# Returns pointer to output
decreateBMP:
  pushq %rbp
  movq %rsp, %rbp
  
  # counter
  movq $0, %r8

  # The message starts after the file header = 14+40=54
  addq $54, %rdi

  loopDecreateBMP:
    cmpq $1023, %r8
    jg endLoopDecreateBMP
    
####################################### Have to finish
    movq %r8, %r9
    imul $3, %r9
    
    movb (%rdi, %r9, 1), %r10b
    movb 2(%rdi, %r9, 1), %r11b

    movb %r11b, (%rdi, %r9, 1)
    movb %r10b, 2(%rdi, %r9, 1)
    
    incq %r8
    jmp loopDecreateBMP
  endLoopDecreateBMP:
  
  movq %rdi, %rax

  movq %rbp, %rsp
  popq %rbp
  ret


.data
	i: .word 20 
	j: .word 35
	h:  .word 5
	f:  .word 15
.text
lw $8, 12
lw $8, -7($8)
xori $9, $8, 6 # $9 = 3
add $9 ,$8, 1  #$9 = 4
move $10, $9
srl  $10,$10, 2    #$10 = 1
move $11, $10  #$11 = 1
addi $13, $10, 15  #$13 = 16
ori  $14, $10, 2   # $14 = 3
LOOP: sub $9,$9, $11
      beq $9, $11, END
      sll $10, $10, 2
      sw  $13, 4($10)
      jal FUNC
      j LOOP
FUNC:  mul $13, $13, $14
	jr $ra          
END:  lui $15, 4 
      addi $17, $0, 2
      sw   $17,0x7fc($0)
      sw   $17, 0x820($0)
      addi $17, $17, 1
      sw   $17, 0x828($0)
      addi $17, $17, 2
      sw   $17, 0x824($0)
      addi $19, $0, 0x48
      sw   $19, 0x81c($0)
      lw $20, 0x824
      lw $21, 0x828
      lw $22, 0x81c
      lw $23, 0x820
      jal bye
      addi $24 $0 2
bye: srl $17 $17 2

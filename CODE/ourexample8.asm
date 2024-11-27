.data
	i: .word 20 
	j: .word 35
	h:  .word 5
	f:  .word 15
.text

END: 
     addi $k0, $0, 1  # SET GIE to be '1'
     addi $17, $0, 60
     sw $17, 0x82c($0)
      lui $15, 4 
      addi $17, $0, 2
      sw   $17,0x7fc($0)
      sw   $17, 0x820($0)
      addi $17, $17, 1
      sw   $17, 0x828($0)
      addi $17, $17, 2
      sw   $17, 0x824($0)
      addi $19, $0, 0x48
      sw   $19, 0x81c($0)
      addi $24 $0 2
      lw $20,  0x82c($0) # READ IE
      lw $21,  0x82d($0)  # READ IFG
      lw $22,  0x82e($0)   # READ TYPE
bye: srl $17 $17 2

onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mips_tb/reset
add wave -noupdate /mips_tb/U_0/timer_module/actual_clock
add wave -noupdate /mips_tb/OUT_SIGNAL
add wave -noupdate /mips_tb/GPI_write_data
add wave -noupdate /mips_tb/LEDR
add wave -noupdate /mips_tb/HEX0
add wave -noupdate /mips_tb/HEX1
add wave -noupdate /mips_tb/HEX2
add wave -noupdate /mips_tb/HEX3
add wave -noupdate /mips_tb/HEX4
add wave -noupdate /mips_tb/HEX5
add wave -noupdate /mips_tb/PB1
add wave -noupdate /mips_tb/PB2
add wave -noupdate /mips_tb/PB3
add wave -noupdate /mips_tb/U_0/timer_module/set_BTIFG
add wave -noupdate /mips_tb/U_0/timer_module/q_int
add wave -noupdate /mips_tb/U_0/timer_module/btctl
add wave -noupdate /mips_tb/U_0/interupt_controller/IFG_in
add wave -noupdate /mips_tb/U_0/interupt_controller/GIE_IN
add wave -noupdate /mips_tb/U_0/interupt_controller/IE
add wave -noupdate /mips_tb/U_0/interupt_controller/IFG_SIGNAL
add wave -noupdate /mips_tb/U_0/interupt_controller/PENDING
add wave -noupdate /mips_tb/U_0/interupt_controller/TYPE_REG
add wave -noupdate /mips_tb/U_0/interupt_controller/served_int
add wave -noupdate /mips_tb/U_0/CPU/IFE/stall_pc
add wave -noupdate /mips_tb/U_0/CPU/IFE/type_pc
add wave -noupdate /mips_tb/U_0/CPU/IFE/type_en
add wave -noupdate /mips_tb/U_0/CPU/IFE/PC
add wave -noupdate /mips_tb/U_0/CPU/ID/k1en
add wave -noupdate /mips_tb/U_0/CPU/ID/k1val
add wave -noupdate /mips_tb/U_0/CPU/ID/GIE
add wave -noupdate /mips_tb/U_0/CPU/ID/register_array
add wave -noupdate /mips_tb/U_0/CPU/ID/reti
add wave -noupdate /mips_tb/U_0/data_bus_sig
add wave -noupdate /mips_tb/U_0/interupt_controller/inta
add wave -noupdate /mips_tb/U_0/interupt_controller/intr
add wave -noupdate /mips_tb/clock
add wave -noupdate -radix hexadecimal /mips_tb/U_0/CPU/IF_INSTUCTION_out
add wave -noupdate -radix hexadecimal /mips_tb/U_0/CPU/ID_INSTUCTION_out
add wave -noupdate -radix hexadecimal /mips_tb/U_0/CPU/EXE_INSTUCTION_out
add wave -noupdate -radix hexadecimal /mips_tb/U_0/CPU/DM_INSTUCTION_out
add wave -noupdate -radix hexadecimal /mips_tb/U_0/CPU/WB_INSTUCTION_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1383150000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
configure wave -valuecolwidth 287
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1381694224 ps} {1384405776 ps}

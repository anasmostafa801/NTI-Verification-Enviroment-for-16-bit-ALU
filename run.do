vlib work
vlog *.V
vlog *.SV
vsim -voptargs=+acc DUT_TB
add wave ALU_FUN
add wave A B
add wave Carry_Flag
add wave ALU_OUT
add wave Arith_Flag
add wave Logic_Flag
add wave CMP_Flag
add wave Shift_Flag
run -all
package require Img
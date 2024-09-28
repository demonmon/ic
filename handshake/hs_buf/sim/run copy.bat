
set dut_1=../code/stream_remove
set testbentch_module=../code/tb_stream_remove



iverilog -o "test.vvp" -c list.txt 

##iverilog -o "test.vvp" %testbentch_module%.v  %dut_1%.v 
vvp -n "test.vvp"

set gtkw_file="test.gtkw"
gtkwave "test.vcd"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "test.vcd")
pause




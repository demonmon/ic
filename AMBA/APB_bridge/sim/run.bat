##set iverilog_path=C:\iverilog\bin;
##set gtkwave_path=C:\iverilog\gtkwave\bin;
##set path=%iverilog_path%%gtkwave_path%%path%

##在制定源文件的时候可以用通配符*,如本人用的批处理中通常使用这种方式指定RTL文件:set rtl_file="../rtl/*.v"
set dut_1=../code/apb_protocol
set dut_2 = ../code/a_apb_master
set dut_3 = ../code/apb2apb_bridge
set dut_4 = ../code/apb_slave
set dut_5 = ../code/slave_top
set dut_6 = ../code/apb_reg
set testbentch_module=../code/apb_protocol_tb

##set rtl_file = "../code/*.v"
##iverilog -o "test.vvp" -c flist.txt 
##del test.vvp test.vcd
iverilog -o "test.vvp" %testbentch_module%.v  %dut_1%.v %dut_2%.v %dut_3%.v %dut_4%.v %dut_5%.v %dut_6%.v
vvp -n "test.vvp"

set gtkw_file="test.gtkw"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "test.vcd")

pause


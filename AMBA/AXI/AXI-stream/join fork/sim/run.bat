##set iverilog_path=C:\iverilog\bin;
##set gtkwave_path=C:\iverilog\gtkwave\bin;
##set path=%iverilog_path%%gtkwave_path%%path%

##在制定源文件的时候可以用通配符*,如本人用的批处理中通常使用这种方式指定RTL文件:set rtl_file="../rtl/*.v"
set dut_1=../code/stream_fork
set testbentch_module=../code/tb_stream_fork
##set dut_2 = ../code/a_apb_master
##set dut_3 = ../code/apb2apb_bridge



##set rtl_file = "../code/*.v"
##iverilog -o "test.vvp" -c flist.txt 

iverilog -o "test.vvp" %testbentch_module%.v  %dut_1%.v 
vvp -n "test.vvp"

set gtkw_file="test.gtkw"
##gtkwave "test.vcd"
if exist %gtkw_file% (gtkwave %gtkw_file%) else (gtkwave "test.vcd")
pause


onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /async_fifo_tb/u_async_fifo/wclk
add wave -noupdate /async_fifo_tb/u_async_fifo/w_rstn
add wave -noupdate /async_fifo_tb/u_async_fifo/winc
add wave -noupdate /async_fifo_tb/u_async_fifo/rinc
add wave -noupdate /async_fifo_tb/u_async_fifo/rclk
add wave -noupdate /async_fifo_tb/u_async_fifo/r_rstn
add wave -noupdate /async_fifo_tb/u_async_fifo/wdata
add wave -noupdate /async_fifo_tb/u_async_fifo/waddr
add wave -noupdate /async_fifo_tb/u_async_fifo/rdata
add wave -noupdate /async_fifo_tb/u_async_fifo/raddr
add wave -noupdate /async_fifo_tb/u_async_fifo/wfull
add wave -noupdate /async_fifo_tb/u_async_fifo/rempty
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_full
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_empty
add wave -noupdate -radix hexadecimal /async_fifo_tb/u_async_fifo/wptr
add wave -noupdate /async_fifo_tb/u_async_fifo/rptr
add wave -noupdate /async_fifo_tb/u_async_fifo/u_dpram/mem
add wave -noupdate -radix hexadecimal /async_fifo_tb/u_async_fifo/wq2_rptr_bin
add wave -noupdate /async_fifo_tb/u_async_fifo/wq2_wptr_bin
add wave -noupdate -radix binary /async_fifo_tb/u_async_fifo/wq2_rptr
add wave -noupdate /async_fifo_tb/u_async_fifo/wq2_wptr
add wave -noupdate -radix hexadecimal /async_fifo_tb/u_async_fifo/wq2_rptr_bin
add wave -noupdate /async_fifo_tb/u_async_fifo/wq2_wptr_bin
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_empty_val
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_full_val
add wave -noupdate -radix decimal /async_fifo_tb/u_async_fifo/wgap
add wave -noupdate /async_fifo_tb/u_async_fifo/rcap
add wave -noupdate /async_fifo_tb/u_async_fifo/ALMOST
add wave -noupdate -radix binary /async_fifo_tb/u_async_fifo/wbin
add wave -noupdate /async_fifo_tb/u_async_fifo/rbin
add wave -noupdate /async_fifo_tb/u_async_fifo/u_dpram/ena
add wave -noupdate /async_fifo_tb/u_async_fifo/u_dpram/wea
add wave -noupdate /async_fifo_tb/u_async_fifo/u_dpram/enb
add wave -noupdate /async_fifo_tb/u_async_fifo/mem_wr
add wave -noupdate /async_fifo_tb/u_async_fifo/mem_rd
add wave -noupdate /async_fifo_tb/u_async_fifo/rempty_val
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_empty_val
add wave -noupdate /async_fifo_tb/u_async_fifo/almost_full_val
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {72736 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ps} {131456 ps}

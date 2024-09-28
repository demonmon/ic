onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/wdata
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/winc
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/wclk
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/w_rstn
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/rinc
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/rclk
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/r_rstn
add wave -noupdate -radix decimal /async_fifo_2_tb/u_async_fifo_2/rdata
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/wfull
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/rempty
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/waddr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/raddr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/wptr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/rptr
add wave -noupdate -expand /async_fifo_2_tb/u_async_fifo_2/mem
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/aempty_n
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/afull_n
add wave -noupdate -divider cmp
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/rptr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/wptr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/w_rstn
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/aempty_n
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/afull_n
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/direct
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/dirset_n
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/dirclr
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/rst
add wave -noupdate /async_fifo_2_tb/u_async_fifo_2/u_async_cmp/cmp_flag
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {172 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {316 ns}

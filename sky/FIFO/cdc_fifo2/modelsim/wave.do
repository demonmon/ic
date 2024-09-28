onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wclk
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/w_rstn
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/w_en
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wdata
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wrdy
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/rclk
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/r_rstn
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/r_en
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/rrdy
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/rdata
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/rptr
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wptr
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/we
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wq2_rptr
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/re
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/wq2_wptr
add wave -noupdate /cdc_syncfifo_tb/u_cdc_syncfifo/mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {6673095 ns} {6674095 ns}

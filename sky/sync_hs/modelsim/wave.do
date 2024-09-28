onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sync_hs_tb/u_sync_hs/clk_i
add wave -noupdate /sync_hs_tb/u_sync_hs/rstn_i
add wave -noupdate /sync_hs_tb/u_sync_hs/in_vld
add wave -noupdate /sync_hs_tb/u_sync_hs/din
add wave -noupdate /sync_hs_tb/u_sync_hs/din_cap
add wave -noupdate /sync_hs_tb/u_sync_hs/din_r
add wave -noupdate /sync_hs_tb/u_sync_hs/vld_sync_clk_i
add wave -noupdate /sync_hs_tb/u_sync_hs/vld_sync_clk_i_r0
add wave -noupdate /sync_hs_tb/u_sync_hs/vld_sync_clk_i_rise
add wave -noupdate /sync_hs_tb/u_sync_hs/in_vld_lev
add wave -noupdate /sync_hs_tb/u_sync_hs/vld_sync
add wave -noupdate /sync_hs_tb/u_sync_hs/in_vld_clk_o
add wave -noupdate /sync_hs_tb/u_sync_hs/in_vld_r0_clk_o
add wave -noupdate /sync_hs_tb/u_sync_hs/in_vld_rise_clk_o
add wave -noupdate /sync_hs_tb/u_sync_hs/out_ack
add wave -noupdate /sync_hs_tb/u_sync_hs/in_ack
add wave -noupdate /sync_hs_tb/u_sync_hs/clk_o
add wave -noupdate /sync_hs_tb/u_sync_hs/rstn_o
add wave -noupdate /sync_hs_tb/u_sync_hs/out_vld
add wave -noupdate /sync_hs_tb/u_sync_hs/dout_cap
add wave -noupdate /sync_hs_tb/u_sync_hs/dout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {973350 ps} 0}
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
WaveRestoreZoom {0 ps} {2042400 ps}

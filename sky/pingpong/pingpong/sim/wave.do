onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_pingpong/u_pingpong/DATA_WD
add wave -noupdate /tb_pingpong/u_pingpong/clk
add wave -noupdate -radix decimal /tb_pingpong/u_pingpong/data_in
add wave -noupdate -radix decimal /tb_pingpong/u_pingpong/data_out
add wave -noupdate /tb_pingpong/u_pingpong/valid_in
add wave -noupdate /tb_pingpong/u_pingpong/ready_in
add wave -noupdate /tb_pingpong/u_pingpong/fire_in
add wave -noupdate /tb_pingpong/u_pingpong/ready_out
add wave -noupdate /tb_pingpong/u_pingpong/valid_out
add wave -noupdate /tb_pingpong/u_pingpong/fire_out
add wave -noupdate /tb_pingpong/u_pingpong/rd_cnt
add wave -noupdate /tb_pingpong/u_pingpong/rstn
add wave -noupdate /tb_pingpong/u_pingpong/wr_cnt
add wave -noupdate -radix decimal -childformat {{{/tb_pingpong/u_pingpong/buffer[3]} -radix decimal} {{/tb_pingpong/u_pingpong/buffer[2]} -radix decimal} {{/tb_pingpong/u_pingpong/buffer[1]} -radix decimal} {{/tb_pingpong/u_pingpong/buffer[0]} -radix decimal}} -expand -subitemconfig {{/tb_pingpong/u_pingpong/buffer[3]} {-height 15 -radix decimal} {/tb_pingpong/u_pingpong/buffer[2]} {-height 15 -radix decimal} {/tb_pingpong/u_pingpong/buffer[1]} {-height 15 -radix decimal} {/tb_pingpong/u_pingpong/buffer[0]} {-height 15 -radix decimal}} /tb_pingpong/u_pingpong/buffer
add wave -noupdate -radix binary /tb_pingpong/u_pingpong/buffer_vld
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {87481 ps} 0}
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
WaveRestoreZoom {2641 ps} {160452 ps}

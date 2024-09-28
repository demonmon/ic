onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_handshake/u_handshake/data_in
add wave -noupdate /tb_handshake/u_handshake/addr_in
add wave -noupdate /tb_handshake/u_handshake/cmd_in
add wave -noupdate /tb_handshake/u_handshake/c_state
add wave -noupdate /tb_handshake/u_handshake/clk
add wave -noupdate /tb_handshake/u_handshake/data_out
add wave -noupdate /tb_handshake/u_handshake/fire_in
add wave -noupdate /tb_handshake/u_handshake/fire_out
add wave -noupdate /tb_handshake/u_handshake/mem
add wave -noupdate /tb_handshake/u_handshake/n_state
add wave -noupdate /tb_handshake/u_handshake/ready_in
add wave -noupdate /tb_handshake/u_handshake/ready_out
add wave -noupdate /tb_handshake/u_handshake/rstn
add wave -noupdate /tb_handshake/u_handshake/valid_in
add wave -noupdate /tb_handshake/u_handshake/valid_out
add wave -noupdate -divider tb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {473 ns} 0}
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
WaveRestoreZoom {0 ns} {874 ns}

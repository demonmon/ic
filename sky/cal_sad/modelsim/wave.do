onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider sad_model
add wave -noupdate /tb/u_sad_model/clk
add wave -noupdate /tb/u_sad_model/rstn
add wave -noupdate /tb/u_sad_model/din
add wave -noupdate /tb/u_sad_model/refi
add wave -noupdate /tb/u_sad_model/cal_en
add wave -noupdate /tb/u_sad_model/sad_vld
add wave -noupdate /tb/u_sad_model/sad
add wave -noupdate /tb/u_sad_model/cal_en_d
add wave -noupdate -divider cal_sad
add wave -noupdate /tb/u_sad_cal/clk
add wave -noupdate /tb/u_sad_cal/rstn
add wave -noupdate /tb/u_sad_cal/din
add wave -noupdate /tb/u_sad_cal/refi
add wave -noupdate /tb/u_sad_cal/cal_en
add wave -noupdate /tb/u_sad_cal/sad_vld
add wave -noupdate /tb/u_sad_cal/sad
add wave -noupdate /tb/u_sad_cal/acc_4_1
add wave -noupdate /tb/u_sad_cal/cal_en_d
add wave -noupdate /tb/u_sad_cal/acc_16_4
add wave -noupdate /tb/u_sad_cal/acc_4_4
add wave -noupdate -divider tb
add wave -noupdate /tb/din
add wave -noupdate /tb/refi
add wave -noupdate /tb/cal_en
add wave -noupdate /tb/din_w
add wave -noupdate /tb/refi_w
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {207460 ps} 0}
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
WaveRestoreZoom {115140 ps} {322540 ps}

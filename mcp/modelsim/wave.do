onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mcp_tb/u_mcp/clk_a
add wave -noupdate /mcp_tb/u_mcp/rstn_a
add wave -noupdate /mcp_tb/u_mcp/adatain
add wave -noupdate /mcp_tb/u_mcp/adata
add wave -noupdate /mcp_tb/u_mcp/asend
add wave -noupdate /mcp_tb/u_mcp/aready
add wave -noupdate /mcp_tb/u_mcp/din_cap
add wave -noupdate /mcp_tb/u_mcp/a_en
add wave -noupdate /mcp_tb/u_mcp/a_en_sync2
add wave -noupdate /mcp_tb/u_mcp/a_en_sync3
add wave -noupdate /mcp_tb/u_mcp/b_en
add wave -noupdate /mcp_tb/u_mcp/bvalid
add wave -noupdate /mcp_tb/u_mcp/bload
add wave -noupdate /mcp_tb/u_mcp/bload_data
add wave -noupdate /mcp_tb/u_mcp/clk_b
add wave -noupdate /mcp_tb/u_mcp/rstn_b
add wave -noupdate /mcp_tb/u_mcp/bdata
add wave -noupdate /mcp_tb/u_mcp/b_ack_sync2
add wave -noupdate /mcp_tb/u_mcp/b_ack_sync3
add wave -noupdate /mcp_tb/u_mcp/a_ack
add wave -noupdate /mcp_tb/u_mcp/b_ack
add wave -noupdate -divider {qita signals}
add wave -noupdate /mcp_tb/u_mcp/bfsm/clk_b
add wave -noupdate /mcp_tb/u_mcp/bfsm/rstn_b
add wave -noupdate /mcp_tb/u_mcp/bfsm/b_en
add wave -noupdate /mcp_tb/u_mcp/bfsm/bload
add wave -noupdate /mcp_tb/u_mcp/bfsm/bvalid
add wave -noupdate /mcp_tb/u_mcp/bfsm/c_state
add wave -noupdate /mcp_tb/u_mcp/bfsm/n_state
add wave -noupdate -divider afsm
add wave -noupdate /mcp_tb/u_mcp/afsm/clk_a
add wave -noupdate /mcp_tb/u_mcp/afsm/rstn_a
add wave -noupdate /mcp_tb/u_mcp/afsm/asend
add wave -noupdate /mcp_tb/u_mcp/afsm/a_ack
add wave -noupdate /mcp_tb/u_mcp/afsm/aready
add wave -noupdate /mcp_tb/u_mcp/afsm/c_state
add wave -noupdate /mcp_tb/u_mcp/afsm/n_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5 ns} 0}
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
WaveRestoreZoom {0 ns} {216 ns}


# Entity: rcmd_gen 
- **File**: rcmd_gen.v

## Diagram
![Diagram](rcmd_gen.svg "Diagram")
## Ports

| Port name       | Direction | Type         | Description |
| --------------- | --------- | ------------ | ----------- |
| clk             | input     | wire         |             |
| rstn            | input     | wire         |             |
| dma_cmd_sof     | input     | wire         |             |
| cfg_sar         | input     | wire  [31:0] |             |
| cfg_trans_xsize | input     | wire  [15:0] |             |
| cfg_trans_ysize | input     | wire  [15:0] |             |
| cfg_sa_ystep    | input     | wire  [15:0] |             |
| dma_r_req       | output    | wire         |             |
| dma_r_ack       | input     | wire         |             |
| dma_r_addr      | output    | wire  [31:0] |             |
| dma_r_len       | output    | wire  [15:0] |             |
| dma_dvld        | input     | wire         |             |
| dma_rd_last     | input     | wire         |             |
| dma_rdata       | input     | wire  [31:0] |             |
| dma_rbe         | input     | wire  [3:0]  |             |
| dma_dack        | output    | wire         |             |
| buf_wr          | output    | wire         |             |
| buf_wdata       | output    | wire  [31:0] |             |
| buf_empty_word  | input     | wire  [5:0]  |             |

## Signals

| Name          | Type             | Description |
| ------------- | ---------------- | ----------- |
| cmd_sta       | reg       [1:0]  |             |
| dma_ycnt      | reg       [15:0] |             |
| dma_addr      | reg       [31:0] |             |
| dbuf0         | reg   [7:0]      |             |
| dbuf1         | reg   [7:0]      |             |
| dbuf2         | reg   [7:0]      |             |
| dma_d_recv    | wire             |             |
| buf_byte      | reg   [2:0]      |             |
| dma_dlast_r   | reg              |             |
| nxt_buf_byte0 | wire [2:0]       |             |
| nxt_buf_byte1 | wire [2:0]       |             |
| nxt_buf_byte2 | wire [2:0]       |             |
| nxt_buf_byte3 | wire [2:0]       |             |
| nxt_buf_byte  | wire [2:0]       |             |
| last_wr_1d    | wire             |             |
| last_wdata    | wire [31:0]      |             |
| dma_rdata_sf  | reg   [31:0]     |             |

## Constants

| Name   | Type | Value | Description |
| ------ | ---- | ----- | ----------- |
| s_idle |      | 'd0   |             |
| s_req  |      | 'd1   |             |
| s_chk  |      | 'd2   |             |

## Processes
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(posedge clk or negedge rstn) )
  - **Type:** always
- unnamed: ( @(*) )
  - **Type:** always

## State machines

![Diagram_state_machine_0]( fsm_rcmd_gen_00.svg "Diagram")
module apb_reg #(
    parameter ADDR_WIDTH = 12,
              DATA_WIDTH = 32
)(
    input                         pclk,       // clock
    input                         rstn,    // reset
    
    // Register interface
    input   [ADDR_WIDTH-1:0]      addr,
    input                         rd,
    input                         wr,
    input   [3:0]                 b_strobe,
    input   [DATA_WIDTH-1:0]      wdata,
    input   [3:0]                 ecorevnum,

    output reg                    pready_r,
    output reg                    pslverr_r,//传给slave
    output reg  [DATA_WIDTH-1:0]  rdata
);

    reg [DATA_WIDTH-1:0] data0; //0x0000
    reg [DATA_WIDTH-1:0] data1; //0x0004
    reg [DATA_WIDTH-1:0] data2; //0x0008
    reg [DATA_WIDTH-1:0] data3; //0x000c

    wire [3:0] wr_sel;

    localparam  PID4 = 32'h00000004; // 0xFD0 : PID 4 Peripheral ID Register 4:[7:4] Block count.[3:0] jep106_c_code.
    localparam  PID5 = 32'h00000000; // 0xFD4 : PID 5
    localparam  PID6 = 32'h00000000; // 0xFD8 : PID 6
    localparam  PID7 = 32'h00000000; // 0xFDC : PID 7

    localparam  PID0 = 32'h00000019; // 0xFE0 : PID 0 APB4 Example slave part number[7:0]
    localparam  PID1 = 32'h000000B8; // 0xFE4 : PID 1 [7:4] jep106_id_3_0. [3:0] part number [11:8]
    localparam  PID2 = 32'h0000001B; // 0xFE8 : PID 2 [7:4] revision, [3] jedec_used. [2:0] jep106_id_6_4
    localparam  PID3 = 32'h00000000; // 0xFEC : PID 3

    localparam  CID0 = 32'h0000000D; // 0xFF0 : CID 0
    localparam  CID1 = 32'h000000F0; // 0xFF4 : CID 1 PrimeCell class
    localparam  CID2 = 32'h00000005; // 0xFF8 : CID 2
    localparam  CID3 = 32'h000000B1; // 0xFFC : CID 3


    assign wr_sel[0] = ((addr[ADDR_WIDTH-1:2] == 10'b0000_0000_00) && wr) ? 1'b1 : 1'b0;
    assign wr_sel[1] = ((addr[ADDR_WIDTH-1:2] == 10'b0000_0000_01) && wr) ? 1'b1 : 1'b0;
    assign wr_sel[2] = ((addr[ADDR_WIDTH-1:2] == 10'b0000_0000_10) && wr) ? 1'b1 : 1'b0;
    assign wr_sel[3] = ((addr[ADDR_WIDTH-1:2] == 10'b0000_0000_11) && wr) ? 1'b1 : 1'b0;

    integer i;

    always @(posedge pclk or negedge rstn) begin
        //if (~rstn) begin
            // data0 <= 32'b0;
           // data1 <= 32'b0;
          //  data2 <= 32'b0;
          //  data3 <= 32'b0;
      //  end else begin
           
            case (wr_sel)
                4'b0001 :
                    begin
                        for(i=0; i<4; i=i+1'b1) begin
                            if(b_strobe[i])
                                data0[8*i +: 8] <= wdata[8*i +: 8];
                        end 
                        //pready_r <= 1'b1;         
                    end
                4'b0010 :
                    begin
                        for(i=0; i<4; i=i+1'b1) begin
                            if(b_strobe[i])
                                data1[8*i +: 8] <= wdata[8*i +: 8];
                        end 
                        //pready_r <= 1'b1;
                    end
                4'b0100 :
                    begin
                        for(i=0; i<4; i=i+1'b1) begin
                            if(b_strobe[i])
                                data2[8*i +: 8] <= wdata[8*i +: 8];
                        end 
                        //pready_r <= 1'b1;
                    end        
                4'b1000 :
                    begin
                        for(i=0; i<4; i=i+1'b1) begin
                            if(b_strobe[i])
                                data3[8*i +: 8] <= wdata[8*i +: 8];
                        end 
                        //pready_r <= 1'b1;
                    end 
                default : 
                    begin
                        data0 <= data0;
                        data1 <= data1;
                        data2 <= data2;
                        data3 <= data3;
                        //pready_r  <= 1'b1;//如何拉低？
                        //pslverr_r <= 1'b1;
                    end           
            endcase
        //end        
    end

    always @(*) begin
        if (rd) begin
            if(addr[11:6] == 8'b0)begin
                case (addr[3:2])
                    2'b00: rdata =  data0;
                    2'b01: rdata =  data1;
                    2'b10: rdata =  data2;
                    2'b11: rdata =  data3;
                    default: rdata = {32{1'bx}};          
                endcase
            end else if (addr[11:6]==6'b1111_11) begin
                case (addr[5:2])
                    4'b0100: rdata = PID4; 
                    4'b0101: rdata = PID5; 
                    4'b0110: rdata = PID6; 
                    4'b0111: rdata = PID7; 

                    4'b1000: rdata = PID0; 
                    4'b1001: rdata = PID1; 
                    4'b1010: rdata = PID2; 
                    4'b1011: rdata ={PID3[31:8], ecorevnum[3:0], 4'h0};
                                                    
                    4'b1100: rdata = CID0; 
                    4'b1101: rdata = CID1; 
                    4'b1110: rdata = CID2; 
                    4'b1111: rdata = CID3;
                    
                    4'b0000, 4'b0001,4'b0010,4'b0011: rdata = 32'd0;
                    default : rdata <= {32{1'bx}};       
                endcase
            end else
                rdata <= 32'd0;
        end else
            rdata <= 32'b0;
    end

    always @(posedge pclk or negedge rstn) begin
        if (~rstn) begin
            pready_r <= 1'b1;
            pslverr_r <= 1'b0;
        end
        else if (wr) begin
            if( |wr_sel) begin
                pready_r <= 1'b1;
                pslverr_r <= 1'b0;
            end else begin
                pready_r <= 1'b1; 
                pslverr_r <= 1'b1;
            end
        end else if (rd) begin
            if(rdata == {32{1'bx}}) begin
                pready_r <= 1'b1;
                pslverr_r <= 1'b1;
            end else begin
                pready_r <= 1'b1;
                pslverr_r <= 1'b0;
            end

    /* end else if(pready_r || pslverr_r) begin
            pready_r <= 1'b1;
            pslverr_r <= 1'b0;
        end   */ 
    end
    end



endmodule //apb_reg


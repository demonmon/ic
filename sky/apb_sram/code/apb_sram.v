module apb_sram #(
    parameter MEM_ADDR = 12,
    parameter MEM_DATA = 32 
    
)(
    input                   clk,
    input                   rstn,
    input                   psel,
    input                   penable,
    input  [MEM_ADDR-1 : 0] paddr,
    input                   pwrite,
    input  [MEM_DATA-1 : 0] pwdata,
    output reg [MEM_DATA-1 : 0] prdata,
    output                  pready
);

    parameter MEM_DEPTH = 1 << (MEM_ADDR - 2);//10位的地址，1024 byte,字节寻址

    reg [MEM_ADDR-2-1 : 0] apb_addr;

    wire apb_write_w;
    reg  apb_write;
    reg  apb_pwdata;

    reg apb_read;
    wire apb_read_w;

    wire mem_cs;
    wire mem_we;
    wire [MEM_ADDR-2-1 : 0] mem_addr;
    wire [MEM_DATA-1 : 0] mem_dout;
    reg  [1:0] mem_rd;

    assign mem_cs = apb_read || apb_write;
    assign mem_we = apb_write;
    assign mem_addr = apb_addr;
    

    always @(posedge clk ) begin  //or negedge rstn
        if(psel && !penable)
            apb_addr <= paddr[MEM_ADDR-1 : 2];
    end

    //write
    assign apb_write_w = psel && !penable && pwrite;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            apb_write <= 1'b0;
        end else if (apb_write_w) begin
            apb_write <= 1'b1;
        end else if (pready) begin
            apb_write <= 1'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            apb_pwdata <= 'b0;
        end else if (apb_write_w) begin
            apb_pwdata <= pwdata;
        end
    end

    //read 
    assign apb_read_w = psel && !penable && !pwrite;

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            apb_read <= 1'b0;
        end else if (apb_read_w) begin
            apb_read <= 1'b1;
        end 
        //else if (pready) begin
          //  apb_read <= 1'b0;
       // end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mem_rd <= 'b0;
        end else  begin
            mem_rd <= {mem_rd[0],apb_read};
        end

    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prdata <= 'b0;
        end else if(mem_rd[0]) begin
            prdata <= mem_dout;
        end
    end

    assign pready = (pwrite)? apb_write : mem_rd[1];

    spram_generic #(
    .ADDR_WIDTH ( MEM_ADDR-2 ),
    .DATA_WIDTH ( MEM_DATA ))
 u_spram_generic (
    .clk                     ( clk       ),
    .en                      ( mem_cs     ),
    .we                      ( mem_we    ),
    .addr                    ( mem_addr ),
    .din                     ( apb_pwdata),

    .dout                    ( mem_dout )
);










    
    
    




endmodule //apb_sram
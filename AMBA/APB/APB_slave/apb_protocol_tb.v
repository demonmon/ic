module apb_protocol_tb ();
    parameter DATA_WIDTH = 32, ADDR_WIDTH = 12;
    parameter CMD_WIDTH =  DATA_WIDTH + ADDR_WIDTH + 1;

    reg [CMD_WIDTH-1:0]     cmd_in;
    reg                     cmd_vld;
    reg                     clk,rstn,transfer;
    wire [DATA_WIDTH-1 : 0] apb_rdata;
    wire                    cmd_rdy;
    integer                 i;
    reg [DATA_WIDTH-1:0]    data;
    reg [ADDR_WIDTH-1:0]    addr;
    reg                     rw_flag;
//assign cmd_in = {rw_flag,addr,data};  

    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rstn = 0;
        transfer = 0;
        cmd_vld = 0;
        cmd_in = 17'b0;

        @(posedge clk) rstn = 1;
        @(posedge clk)
        transfer = 1; cmd_in[CMD_WIDTH-1] = 1'b1; //writ
        repeat(2) @(posedge clk);
        @(negedge clk); 
        Write_slave1;

        repeat(3) @(posedge clk);
        cmd_in[CMD_WIDTH-1]=0; rstn = 0 ; transfer = 0;
        @(posedge clk) rstn = 1;
        @(posedge clk) transfer = 1; 

        repeat(2) @(posedge clk); read_slave1;
        #200
        $finish();
    end

    task Write_slave1; 
    begin
        transfer = 1;
    
        for ( i=0; i<=12; i=i+4) begin
            repeat(2) @(negedge clk) begin
                cmd_vld = 1;
                data = i;
                addr = i-4;
                rw_flag = 1;
                cmd_in = {rw_flag,addr,data};
            end
            @(negedge clk)  
                cmd_vld = 0;        
        end
    end   
    endtask

    task read_slave1;
    begin
        transfer = 1;
        for ( i=0 ; i<= 12 ; i=i+4 ) begin
            repeat(2)@(negedge clk) begin
                cmd_vld = 1;
                data = 0;
                addr = i-4;
                rw_flag = 0;
                cmd_in = {rw_flag,addr,data};
                
            end
            @(negedge clk)  
                cmd_vld = 0;  
        end
    end
    endtask
    apb_protocol #(.DATA_WIDTH(DATA_WIDTH),.ADDR_WIDTH(ADDR_WIDTH)) dut (
        .cmd_in(cmd_in),
        .cmd_vld(cmd_vld),
        .clk(clk),
        .rstn(rstn),
        .transfer(transfer),
        .apb_rdata(apb_rdata),
        .cmd_rdy(cmd_rdy)
    ); 


endmodule //apb_protocol_tb
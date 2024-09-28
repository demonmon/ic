module pingpong #(
    parameter BUF_NUM = 4,
    parameter DATA_WD = 8
) (
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,//不满的时候可以写--有效

    output                      valid_out,//不空的时候可以读 -- 有效
    output   [DATA_WD-1 : 0]    data_out,
    input                       ready_out

);  
    reg [DATA_WD-1 : 0] buffer [BUF_NUM-1 : 0];
    reg [BUF_NUM-1 : 0] buffer_vld;

    localparam BUF_WD = log2(BUF_NUM);
    
    reg [BUF_WD-1 : 0] wr_cnt;
    reg [BUF_WD-1 : 0] rd_cnt;
    wire fire_in; //write handshake
    wire fire_out; //read handshake
    
    assign fire_in = valid_in && ready_in;
    assign fire_out = ready_out && valid_out;


    assign ready_in = !buffer_vld[wr_cnt];//no full   &buffer_vld
    assign valid_out = buffer_vld[rd_cnt];//no empty  |buffer_vld

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            wr_cnt <= 0;
        end else if (fire_in) begin
            if (wr_cnt == BUF_NUM - 1) begin
                wr_cnt <= 0;
            end else begin
                wr_cnt <= wr_cnt + 1;
            end               
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            rd_cnt <= 0;
        end else if (fire_out) begin
            if (rd_cnt == BUF_NUM - 1) begin
                rd_cnt <= 0;
            end else begin
                rd_cnt <= rd_cnt + 1;
            end               
        end
    end


    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            buffer_vld <= {BUF_NUM{1'b0}};
            //data_out <= {DATA_WD{1'b0}};
        end else begin
            if(fire_in) begin
                buffer_vld[wr_cnt] <= 1'b1;
                buffer[wr_cnt]  <= data_in;
            end 
            if(fire_out) begin
                buffer_vld[rd_cnt] <= 1'b0;
                
            end
        end  
    end

    assign data_out = fire_out ? buffer[rd_cnt] : 0;

    function integer log2(input integer x);
    begin
        log2 = 0;
        while(x >> log2)
            log2 = log2 + 1; 
    end
    endfunction



endmodule //pingpong
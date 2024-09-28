module fsm_hs  #(
    parameter DATA_WD = 32
)(
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,

    output                      valid_out,
    output [DATA_WD-1 : 0]      data_out,
    input                       ready_out
    
);


reg  [DATA_WD-1:0]  data_out_r;
reg  [DATA_WD-1:0]  skid_buffer;

reg                 ready_in_r;
reg                 valid_out_r;

wire                fire_in;
wire                fire_out;
wire                load,flow,fill,flush,unload;

parameter EMPTY = 2'b0,BUSY = 2'b1, FULL = 2'b10;
reg        [1:0]    c_state,n_state; 

assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;

assign load   = (c_state == EMPTY) && (fire_in) && (!fire_out);
assign flow = (c_state == BUSY) && (fire_in) && (fire_out);
assign fill = (c_state == BUSY) && (fire_in) && (!fire_out);
assign flush = (c_state == FULL) && (!fire_in) && (fire_out);
assign unload   = (c_state == BUSY) && (!fire_in) && (fire_out);

assign data_out = data_out_r;
assign ready_in = ready_in_r;
assign valid_out = valid_out_r;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        c_state <= EMPTY;
    else
        c_state <= n_state;    
end

always @(*) begin
    case (c_state)
        EMPTY :
            begin
                if (load) begin
                    n_state = BUSY;
                end else begin
                    n_state = EMPTY;
                end
            end
        BUSY :
            begin
                if (fill) begin
                    n_state = FULL;
                end else if(unload) begin
                    n_state = EMPTY;
                end else if(flow) begin
                    n_state = BUSY;
                end
                
            end 
        FULL :
            begin
                if (flush) begin
                    n_state = BUSY;
                end else
                    n_state = FULL;
            end 
        default : n_state = EMPTY;       
    endcase
end

//
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_out_r <= 1'b0;
        ready_in_r  <= 1'b1;
    end else begin
        case (n_state)
            EMPTY :
                begin
                    valid_out_r <= 1'b0;
                    ready_in_r  <= 1'b1;
                end
            BUSY :
                begin
                    valid_out_r <= 1'b1;
                    ready_in_r  <= 1'b1;
                    
                end
            FULL :
                begin
                    valid_out_r <= 1'b1;
                    ready_in_r  <= 1'b0;
                end
            default : 
                begin
                    valid_out_r <= 1'b0;
                    ready_in_r  <= 1'b1;
                end
                
        endcase
    end
        
end


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_out_r <= 'b0;
        skid_buffer  <= 'b0;
    end else begin
        if (load) begin
            data_out_r <= data_in;
        end else if(fill) begin
            skid_buffer <= data_in; 
        end else if(flow) begin
            data_out_r <= data_in;
        end else if(flush) begin
            data_out_r <= skid_buffer;
        end 
    end
end



  

endmodule //fsm_hs 







module fsm_hs2  #(
    parameter DATA_WD = 32
)(
    input                       clk,
    input                       rstn,

    input                       valid_in,
    input  [DATA_WD-1 : 0]      data_in,
    output                      ready_in,

    output                      valid_out,
    output [DATA_WD-1 : 0]      data_out,
    input                       ready_out
    
);


reg  [DATA_WD-1:0]  data_out_r;
reg  [DATA_WD-1:0]  skid_buffer;

reg                 valid_out_r;
reg                 skid_buffer_valid;
reg                 ready_in_r;


wire                fire_in;
wire                fire_out;
               

localparam  PIPE = 2'b0,SKID = 2'b1;
reg        [1:0]    c_state,n_state; 
wire                ready;

assign fire_in = valid_in && ready_in;
assign fire_out = valid_out && ready_out;


assign data_out = data_out_r;
assign ready_in = ready_in_r;
assign valid_out = valid_out_r;

assign ready = ready_out || !valid_out_r;

always @(posedge clk or negedge rstn) begin
    if(!rstn)
        c_state <= PIPE;
    else
        c_state <= n_state;    
end

always @(*) begin
    case (c_state)
        PIPE :
            begin
                if (!ready_out && valid_out_r) begin
                    n_state <= SKID;
                end else begin
                    n_state <= PIPE;
                end
                    
            end

        SKID :
            begin
                if (ready) begin
                    n_state <= PIPE;
                end else begin
                    n_state <= SKID;
                end
            end
    endcase
end


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        skid_buffer <= 'b0;
        skid_buffer_valid <= 1'b0;
        ready_in_r <= 1'b1;
        valid_out_r <= 1'b0;
        data_out_r <= 1'b0;
    end else begin
        case (n_state)
            PIPE :
                begin
                    if (c_state == SKID) begin
                        
                        data_out_r <= skid_buffer;
                        valid_out_r <= skid_buffer_valid;
                        ready_in_r <= 1'b1;

                    end else if(c_state == PIPE) begin
                        data_out_r <= data_in;
                        valid_out_r <= valid_in;
                        ready_in_r <= 1'b1;
                    end
                end

            SKID :
                begin
                    if (c_state == PIPE) begin//fire_in
                        skid_buffer <= data_in;
                        skid_buffer_valid <= valid_in; 
                        ready_in_r <= 1'b0;
                    end 
                end
        endcase
    end
        
end


endmodule





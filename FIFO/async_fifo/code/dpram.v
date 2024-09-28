module dpram #(
    parameter DATESIZE = 8,
    parameter ADDRSIZE = 4
)(
    input clka,
    input ena,
    input wea,
    input [DATESIZE-1:0] dina,
    input [ADDRSIZE-1:0] addra,

    input clkb,
    input enb,
    input [ADDRSIZE-1:0] addrb,
    output  reg [DATESIZE-1:0]doutb
);
    parameter DEPTH = 1<<ADDRSIZE;
    reg [DATESIZE-1:0] mem [DEPTH-1:0];

    always @(posedge clkb) begin  //read
        if(enb) 
            doutb <= mem[addrb];
    end

    always @(posedge clka) begin //write
        if (ena) begin
            if(wea) 
                mem[addra] <= dina;
        end
    end






endmodule //dpram
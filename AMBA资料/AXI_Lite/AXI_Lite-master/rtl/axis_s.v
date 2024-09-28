// Simple AXI-Stream Slave
// Receives data from the axis_master, it receives just 1 data and enables the finish
// When input ready goes high, than starts receiving the data.


`timescale 1us/1us

module axis_s (
			  input areset_n, aclk, 
			  output reg [31:0] data, 
			  input ready,
			  
			  output reg tready, 
              input  tvalid,
			  input tlast, 
			  input [31:0] tdata,
			 
			  output reg finish
			);

// handshake happened between master and slave
wire handshake;	
assign handshake = tvalid & tready;
			
// tready
always @ (posedge aclk)
	if ( ~areset_n)
		tready <= 1'b0;
	else
		if (ready && ~tready) // first time ready comes
			tready <= 1'b1;
		else
			if (handshake) // handshake happened, ready goes low
				tready <= 1'b0;
			else
				if ( tready && ~ready && ~tvalid ) // for some reason ready goes low, when no handshake happened
					tready <= 1'b1;
				else
					tready <= tready;

// data
always @ (posedge aclk)
	if ( ~areset_n)
		data <= 1'b0;
	else if (handshake)
			data <= tdata;
		else
			data <= data;
			
			
always @ (posedge aclk)
	if ( ~areset_n)
		finish <= 0;
	else if (handshake)
			finish <= 1'b1;
		else
			if (finish == 1 && ready )
				finish <= 0;
			else
				finish <= finish;		

endmodule

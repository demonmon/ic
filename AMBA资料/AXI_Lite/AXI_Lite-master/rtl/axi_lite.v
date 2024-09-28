// Simple AXI-Stream Master
// Takes the data and sends it through the AXIS interface
// When send posedge happens, sends the data


`timescale 1us/1us

module axis_lite ( 
			  /**************** System Signals *******************************/
			  input  wire                            aclk,
			  input  wire                            aresetn
			 /**************** Write Address Channel Signals ******************/
			  output wire [32-1:0]         			 m_axi_awaddr,
			  output wire [3-1:0]                    m_axi_awprot,
			  output reg                             m_axi_awvalid = 1'b0,
			  input  wire                            m_axi_awready,
			  /**************** Write Data Channel Signals *******************/
			  output wire [32-1:0]      			 m_axi_wdata,
			  output wire [32/8-1:0]    			 m_axi_wstrb,
			  output reg                             m_axi_wvalid = 1'b0,
			  input  wire                            m_axi_wready,
			  /**************** Write Response Channel Signals ***************/
			  input  wire [2-1:0]                    m_axi_bresp,
			  input  wire                            m_axi_bvalid,
			  output reg                             m_axi_bready = 1'b0,
			  /**************** Read Address Channel Signals ****************/
			  output wire [32-1:0]       			 m_axi_araddr,
			  output wire [3-1:0]                    m_axi_arprot,
			  output reg                             m_axi_arvalid = 1'b0,
			  input  wire                            m_axi_arready,
			  /**************** Read Data Channel Signals ********************/
			  input  wire [32-1:0]      			 m_axi_rdata,
			  input  wire [2-1:0]                    m_axi_rresp,
			  input  wire                            m_axi_rvalid,
			  output reg                             m_axi_rready = 1'b0,
			  /**************** User Signals *******************************/
			  input	wire [32-1:0]					 app_waddr,
			  input	wire [32-1:0]					 app_wdata,
			  input	wire         					 app_wen,
			  
			  input	wire [32-1:0]					 app_raddr,
			  input	wire         					 app_ren,
			  output reg [32-1:0]					 app_rdata,
			  output reg                             app_wdone = 1'b0,
			  output reg                             app_rdone = 1'b0,
			);



/**************** Write Channel ******************/
wire waddr_done,wdata_done,resp_slave_finish
axis_m axis_waddr ( .areset_n(areset_n), .aclk(aclk), 
					.data		(app_waddr), 
					.send		(app_wen),
					
					.tready		(m_axi_awready), 
					.tvalid		(m_axi_awvalid),
					.tlast		(m_axi_awvalid), 
					.tdata		(m_axi_awaddr),
					
					.finish		(waddr_done)
			);
			
assign m_axi_awprot = 3'o0;
// wdata
axis_m axis_wdata ( .areset_n(areset_n), .aclk(aclk), 
					.data		(app_wdata), 
					.send		(app_wen),
					
					.tready		(m_axi_wready), 
					.tvalid		(m_axi_wvalid),
					.tlast		(m_axi_wvalid), 
					.tdata		(m_axi_wdata),
					
					.finish		(wdata_done)
			);
assign m_axi_wstrb = 1; // all bytes of line contain valid data

// wresponse
axis_s axis_resp ( .areset_n(areset_n), .aclk(aclk),
					.data		(slave_data),
					.ready 		(slave_ready), // user saying slave is ready
					
					.tready 	(m_axi_bready),
					.tvalid		(m_axi_bvalid),
					.tlast		(m_axi_bvalid),
					.tdata		( {30b'0,m_axi_bresp} ),
					
					.finish		(resp_slave_finish)
					);

assign app_wdone = waddr_done && wdata_done && resp_slave_finish;
/**************** Read Channel ******************/
wire raddr_done,

axis_m axis_raddr ( .areset_n(areset_n), .aclk(aclk), 
					.data		(app_raddr), 
					.send		(app_ren),
					
					.tready		(m_axi_arready), 
					.tvalid		(m_axi_arvalid),
					.tlast		(m_axi_arvalid), 
					.tdata		(m_axi_araddr),
					
					.finish		(raddr_done)
			);

axis_s axis_rdata ( .areset_n(areset_n), .aclk(aclk),
					.data		(slave_data),
					.ready 		(slave_ready), // user saying slave is ready
					
					.tready 	(m_axi_rready),
					.tvalid		(m_axi_rvalid),
					.tlast		(m_axi_rvalid),
					.tdata		(m_axi_rdata ),
					
					.finish		(resp_slave_finish)
			);

assign app_rdone = raddr_done && resp_slave_finish;

	

endmodule

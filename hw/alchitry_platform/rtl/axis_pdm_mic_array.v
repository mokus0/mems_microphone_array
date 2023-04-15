module axis_pdm_mic_array #(
  parameter NUM_MIC_PAIRS = 4,
  parameter AXI_STREAM_BYTES = 1
) (
  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m_axis, ASSOCIATED_RESET io_reset, FREQ_HZ 4800000" *)
  input  wire                           pdm_clk,
  input  wire [NUM_MIC_PAIRS-1:0]       pdm_data,

  (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
  input  wire                           io_reset,

  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
  output wire                           m_axis_tvalid,
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
  output wire [8*AXI_STREAM_BYTES-1:0]  m_axis_tdata
);

genvar i;
for (i = 0; i < NUM_MIC_PAIRS; i = i + 1) begin
  IDDR #(
    .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),
    .INIT_Q1(1'b0),
    .INIT_Q2(1'b0),
    .SRTYPE("ASYNC")
  ) IDDR_inst (
    .Q1(m_axis_tdata[2*i+1]), // Select = GND mic
    .Q2(m_axis_tdata[2*i+0]), // Select = VDD mic
    .C(pdm_clk),
    .CE(1'b1),
    .D(pdm_data[i]),
    .R(io_reset),
    .S(1'b0)
  );
end
for (i = NUM_MIC_PAIRS*2; i < AXI_STREAM_BYTES*8; i = i + 1) begin
  assign m_axis_tdata[i] = 0'b0; 
end

reg valid_reg = 0;
always @(posedge pdm_clk or posedge io_reset) begin
  if (io_reset) valid_reg <= 1'b0;
  else          valid_reg <= 1'b1;
end

endmodule;

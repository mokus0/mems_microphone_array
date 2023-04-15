// Adapter to take PDM module output and reformat it to the format wanted as
// input by the Xilinx CIC compiler
module pdm_cic_adapter #(
  parameter NUM_MICS = 8,
  parameter CIC_BYTES = 1,
  parameter CIC_BITS = CIC_BYTES * 8,
  parameter OUT_ZERO_VALUE = -1,
  parameter OUT_ONE_VALUE = 1
) (
  (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF s_axis:m_axis, ASSOCIATED_RESET rst" *)
  input  wire                 clk,
  (* X_INTERFACE_PARAMETER = "POLARITY ACTIVE_HIGH" *)
  input  wire                 rst,

  input  wire                 s_axis_tvalid,
  output wire                 s_axis_tready,
  input  wire  [NUM_MICS-1:0] s_axis_tdata,

  output reg                  m_axis_tvalid,
  input  wire                 m_axis_tready,
  output reg   [CIC_BITS-1:0] m_axis_tdata,
  output reg                  m_axis_tlast
);

localparam COUNTER_WIDTH = $clog2(NUM_MICS);
reg [COUNTER_WIDTH-1:0] counter = 0;

wire skid_tvalid, skid_tready;
wire [NUM_MICS-1:0] skid_tdata;

skidbuf #(.BITS(NUM_MICS)) INPUT_SKIDBUF (
  .clk(clk), .rst(rst),
  .recv_tvalid(s_axis_tvalid), .recv_tready(s_axis_tready), .recv_tdata(s_axis_tdata), 
  .send_tvalid(skid_tvalid),   .send_tready(skid_tready),   .send_tdata(skid_tdata));

assign skid_tready = !skid_tvalid || ((counter == NUM_MICS-1) && (m_axis_tready || !m_axis_tvalid));

always @(posedge clk) begin
  if (rst) begin
    counter <= 0;
  end else if (m_axis_tready || !m_axis_tvalid) begin
    m_axis_tvalid <= skid_tvalid;
    if (skid_tvalid) begin
        if (counter == NUM_MICS-1) begin
          counter <= 0;
        end else begin
          counter <= counter + 1;
        end

        m_axis_tdata  <= skid_tdata[counter] ? OUT_ONE_VALUE : OUT_ZERO_VALUE;
        m_axis_tlast  <= (counter == NUM_MICS-1);
      end
   end
end

endmodule

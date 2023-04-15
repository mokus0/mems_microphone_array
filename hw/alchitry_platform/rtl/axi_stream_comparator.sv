module axi_stream_comparator #(
  parameter DATA_BITS = 32,
  parameter COUNT_BITS = 32
) (
  input  logic                  clk,
  input  logic                  rst,

  input  logic                  in1_tvalid,
  output logic                  in1_tready,
  input  logic [DATA_BITS-1:0]  in1_tdata,

  input  logic                  in2_tvalid,
  output logic                  in2_tready,
  input  logic [DATA_BITS-1:0]  in2_tdata,

  output logic                  transfer,
  output logic [COUNT_BITS-1:0] transfer_count,
  output logic                  transfer_mismatch,
  output logic                  transfer_mismatch_latch,
  output logic [DATA_BITS-1:0]  mismatch_tdata1,
  output logic [DATA_BITS-1:0]  mismatch_tdata2
);

assign in1_tready = in2_tvalid || !in1_tvalid;
assign in2_tready = in1_tvalid || !in2_tvalid;

always_ff @(posedge clk) begin
  if (rst) begin
    transfer                <= 0;
    transfer_count          <= 0;
    transfer_mismatch       <= 0;
    transfer_mismatch_latch <= 0;
    mismatch_tdata1         <= {DATA_BITS{1'bx}};
    mismatch_tdata2         <= {DATA_BITS{1'bx}};
  end else if (in1_tvalid && in2_tvalid) begin
    transfer                <= 1;
    transfer_count          <= transfer_count + 1;
    if (in1_tdata != in2_tdata) begin
      transfer_mismatch       <= 1;
      transfer_mismatch_latch <= 1;
      mismatch_tdata1         <= in1_tdata;
      mismatch_tdata2         <= in2_tdata;
    end
  end else begin
    transfer                <= 0;
    transfer_mismatch       <= 0;
  end
end

endmodule
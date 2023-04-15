module axi_stream_counter #(
  parameter DATA_BITS = 32,
  parameter RANGE = 64'b1 << DATA_BITS
)(
  input  logic clk,
  input  logic rst,

  output logic tvalid,
  input  logic tready,
  output logic [DATA_BITS-1:0] tdata
);

reg [DATA_BITS-1:0] count = 0;
localparam MAX_COUNT = RANGE - 1;

always @(posedge clk) begin
  if (rst) begin
    count <= 0;
    tvalid <= 0;
  end else begin
    if (tvalid && tready) begin
      if (count == MAX_COUNT) begin
        count <= 0;
      end else begin
        count <= count + 1;
      end
    end
    tvalid <= 1;
  end
end

assign tdata = tvalid ? count : {DATA_BITS{1'bx}};

`ifdef FORMAL

bit past_valid = 0;
always @(posedge clk) past_valid <= 1;
always @(posedge clk) if (!past_valid) assume (rst);

// TVALID deasserts after reset
always @(posedge clk) if (past_valid && $past(rst)) assert (!tvalid);

// Data is stable when TVALID & !TREADY
always @(posedge clk) if (past_valid && !rst && $past(!rst)) begin
  if ($past(tvalid && !tready)) assert (tvalid && $stable(tdata));
end

// Output count increases on every transfer
logic [DATA_BITS-1:0] next_output = 0;
always @(posedge clk) begin
  assert(next_output < RANGE);
  assert(tdata < RANGE);
  if (rst) begin
    next_output <= 0;
  end else if (tvalid && tready) begin
    assert(tdata == next_output);
    next_output <= next_output == MAX_COUNT ? 0 : (next_output + 1);
  end

// incidental fact needed to prove inductive case - it's not relevant
// to the instantaneous correctness.
  assert(count == next_output);
end

`endif

endmodule

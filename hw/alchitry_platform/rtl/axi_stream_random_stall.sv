module axi_stream_random_stall #(
  parameter DATA_BITS = 32
) (
  input  logic                  clk,
  input  logic                  rst,

  input  logic                  in_tvalid,
  output logic                  in_tready,
  input  logic [DATA_BITS-1:0]  in_tdata,

  output logic                  out_tvalid,
  input  logic                  out_tready,
  output logic [DATA_BITS-1:0]  out_tdata,

  input  logic                  block,
  input  logic                  stall
);

logic recv_tvalid, recv_tready, send_tvalid, send_tready;
logic [DATA_BITS-1:0] recv_tdata, send_tdata;
skidbuf #(.BITS(DATA_BITS)) SKID (.*);

// Use `block` to modulate input flow
always_comb begin
  recv_tvalid = in_tvalid   && !block;
  in_tready   = recv_tready && !block;
  recv_tdata  = recv_tvalid ? in_tdata : {DATA_BITS{1'bx}};
end

// latch the stall signal whenever a transaction is in progress,
// to make sure that the AXI valid/data stability rules are observed
logic stall_latch = 0;
always_ff @(posedge clk) begin
  if (out_tready && !out_tvalid) stall_latch <= stall;
end

// Use the latched `stall` to modulate output flow
always_comb begin
  out_tvalid  = send_tvalid && !stall_latch;
  send_tready = out_tready  && !stall_latch;
  out_tdata   = out_tvalid ? send_tdata : {DATA_BITS{1'bx}};
end

`ifdef FORMAL

// Track when $past is valid. Operation must start with reset.
bit past_valid = 0;
always @(posedge clk) past_valid <= 1;
always @(posedge clk) if (!past_valid) assume (rst);

// TVALID deasserts after reset
always @(posedge clk) begin
  if (past_valid && $past(rst)) assume (!in_tvalid);
  if (past_valid && $past(rst)) assert (!out_tvalid);
end

// Data is stable when TVALID & !TREADY
always @(posedge clk) if (past_valid && !rst && $past(!rst)) begin
  if ($past(in_tvalid  &&  !in_tready)) assume (in_tvalid  && $stable(in_tdata));
  if ($past(out_tvalid && !out_tready)) assert (out_tvalid && $stable(out_tdata));
end

// Assume correctness of the skid buffer to ensure proper data ordering.
// Assume also that any errors in the 'x'-ing of the data bus will show up very quickly in dependent modules' tests.

`endif

endmodule

module skidbuf_formal #(
  parameter BITS            = 32,
  parameter REGISTER_OUTPUT = 1
) (
  input  logic            clk,
  input  logic            rst,

  input  logic            recv_tvalid,
  output logic            recv_tready,
  input  logic [BITS-1:0] recv_tdata,

  output logic            send_tvalid,
  input  logic            send_tready,
  output logic [BITS-1:0] send_tdata
);

skidbuf #(.BITS(BITS), .REGISTER_OUTPUT(REGISTER_OUTPUT)) DUT (.*);

reg past_valid = 0;
always @(posedge clk) past_valid <= 1;
always @(posedge clk) if (!past_valid) assume(rst);

// Assume the input obeys handshake rules
always @(posedge clk) if (past_valid) begin
  if ($past(rst)) assume(!recv_tvalid);
  if (!rst && !$past(rst) && $past(recv_tvalid && !recv_tready))
      assume(recv_tvalid && $stable(recv_tdata));
end

// Assert the output obeys handshake rules
always @(posedge clk) if (past_valid) begin
  if ($past(rst)) assert(!send_tvalid);
  if (!rst && !$past(rst) && $past(send_tvalid && !send_tready))
      assert(send_tvalid && $stable(send_tdata));
end

// TODO: properties showing that data going in is the same as data going out

endmodule

`timescale 1ns/1ps

module axi_stream_random_stall_tb #(
  parameter DATA_BITS = 32,
  parameter COUNT_BITS = 32,
  parameter STALL_1_PERCENT = 25,
  parameter BLOCK_1_PERCENT = 25,
  parameter STALL_2_PERCENT = 25,
  parameter BLOCK_2_PERCENT = 25
);

bit clk = 1; always #0.5 clk = !clk;
bit rst = 1; initial #4 rst = 0;
int tick = 0; always @(posedge clk) tick <= tick + 1;

logic                 in1_tvalid;
logic                 in1_tready;
logic [DATA_BITS-1:0] in1_tdata;
logic                 in1_stall; always @(posedge clk) in1_stall = $urandom_range(0, 99) < STALL_1_PERCENT;
logic                 in1_block; always @(posedge clk) in1_block = $urandom_range(0, 99) < BLOCK_1_PERCENT;

logic                 in2_tvalid;
logic                 in2_tready;
logic [DATA_BITS-1:0] in2_tdata;
logic                 in2_stall; always @(posedge clk) in2_stall = $urandom_range(0, 99) < STALL_2_PERCENT;
logic                 in2_block; always @(posedge clk) in2_block = $urandom_range(0, 99) < BLOCK_2_PERCENT;

logic                 out1_tvalid;
logic                 out1_tready;
logic [DATA_BITS-1:0] out1_tdata;

logic                 out2_tvalid;
logic                 out2_tready;
logic [DATA_BITS-1:0] out2_tdata;

axi_stream_counter #(.DATA_BITS(DATA_BITS)) COUNTER_1 (
  .clk, .rst,
  .tvalid(in1_tvalid), .tready(in1_tready), .tdata(in1_tdata));

axi_stream_random_stall #(.DATA_BITS(DATA_BITS)) STALL_1 (
  .clk, .rst,
  .in_tvalid(in1_tvalid), .in_tready(in1_tready), .in_tdata(in1_tdata),
  .out_tvalid(out1_tvalid), .out_tready(out1_tready), .out_tdata(out1_tdata),
  .stall(in1_stall), .block(in1_block));

axi_stream_counter #(.DATA_BITS(DATA_BITS)) COUNTER_2 (
  .clk, .rst,
  .tvalid(in2_tvalid), .tready(in2_tready), .tdata(in2_tdata));

axi_stream_random_stall #(.DATA_BITS(DATA_BITS)) STALL_2 (
  .clk, .rst,
  .in_tvalid(in2_tvalid), .in_tready(in2_tready), .in_tdata(in2_tdata),
  .out_tvalid(out2_tvalid), .out_tready(out2_tready), .out_tdata(out2_tdata),
  .stall(in2_stall), .block(in2_block));

logic                  transfer;
logic [COUNT_BITS-1:0] transfer_count;
logic                  transfer_mismatch;
logic                  transfer_mismatch_latch;
logic [DATA_BITS-1:0]  mismatch_tdata1;
logic [DATA_BITS-1:0]  mismatch_tdata2;
axi_stream_comparator #(.DATA_BITS(DATA_BITS), .COUNT_BITS(COUNT_BITS)) COMPARE (
  .clk, .rst,
  .in1_tvalid(out1_tvalid), .in1_tready(out1_tready), .in1_tdata(out1_tdata),
  .in2_tvalid(out2_tvalid), .in2_tready(out2_tready), .in2_tdata(out2_tdata),
  .transfer, .transfer_count, .transfer_mismatch, .transfer_mismatch_latch,
  .mismatch_tdata1, .mismatch_tdata2);

always @(posedge clk) if (transfer_mismatch) begin
  $error(1, "[tick %d, transfer %d] MISMATCH (%d != %d)", tick, transfer_count, mismatch_tdata1, mismatch_tdata2);
end

initial #10000  begin
  if (transfer_count < 100) $error(2, "Not enough transfers (%d)", transfer_count);
  assert(!transfer_mismatch_latch);
  $display("%d transfers OK", transfer_count);
  $finish;
end

endmodule

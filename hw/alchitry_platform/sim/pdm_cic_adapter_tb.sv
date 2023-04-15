module pdm_cic_adapter_tb;

localparam NUM_MICS = 5;
localparam CIC_BYTES = 1;
localparam CIC_BITS = CIC_BYTES * 8;

localparam SRC_STALL_PERCENT = 80;
localparam OUT_BLOCK_PERCENT = 20;
logic src_stall; always @(posedge clk) src_stall <= $urandom_range(0, 99) < SRC_STALL_PERCENT;
logic out_block; always @(posedge clk) out_block <= $urandom_range(0, 99) < OUT_BLOCK_PERCENT;

bit clk = 1; always #0.5 clk = !clk;
bit rst = 1; initial #4 rst = 0;
int tick = 0; always @(posedge clk) tick += 1;

logic src_valid, src_ready;
logic [NUM_MICS-1:0] src_data;
axi_stream_counter #(.DATA_BITS(NUM_MICS)) SRC
    (.clk, .rst, .tvalid(src_valid), .tready(src_ready), .tdata(src_data));

logic src_stall_valid, src_stall_ready;
logic [NUM_MICS-1:0] src_stall_data;

axi_stream_random_stall #(.DATA_BITS(NUM_MICS)) SRC_STALL (
    .clk, .rst,
    .in_tvalid(src_valid), .in_tready(src_ready), .in_tdata(src_data),
    .out_tvalid(src_stall_valid), .out_tready(src_stall_ready), .out_tdata(src_stall_data),
    .block(0), .stall(src_stall));

logic                dut_out_valid;
logic                dut_out_ready;
logic [CIC_BITS-1:0] dut_out_data;
logic                dut_out_last;

pdm_cic_adapter #(
    .NUM_MICS(NUM_MICS),
    .CIC_BYTES(CIC_BYTES),
    .CIC_BITS(CIC_BITS))
DUT (
    .clk, .rst,
    .s_axis_tvalid(src_stall_valid), .s_axis_tready(src_stall_ready), .s_axis_tdata(src_stall_data),
    .m_axis_tvalid(dut_out_valid), .m_axis_tready(dut_out_ready), .m_axis_tdata(dut_out_data), .m_axis_tlast(dut_out_last));

logic                dut_out_valid;
logic                dut_out_ready;
logic [CIC_BITS-1:0] dut_out_data;
logic                dut_out_last;

logic                out_valid;
logic                out_ready;
logic [CIC_BITS-1:0] out_data;
logic                out_last;

axi_stream_random_stall #(.DATA_BITS(1+CIC_BITS)) OUT_BLOCK (
    .clk, .rst,
    .in_tvalid(dut_out_valid), .in_tready(dut_out_ready), .in_tdata({dut_out_last, dut_out_data}),
    .out_tvalid(out_valid), .out_tready(out_ready), .out_tdata({out_last, out_data}),
    .block(out_block), .stall(0));

assign out_ready = 1;

int i = 0;

bit expected_tlast;
bit [NUM_MICS-1:0] expected_pdm;
bit expected_cic_bit;
bit [CIC_BITS-1:0] expected_tdata;

always @(posedge clk) if (out_valid && out_ready) begin
    expected_tlast = ((i % NUM_MICS) == (NUM_MICS-1));
    expected_pdm = i / NUM_MICS;
    expected_cic_bit = (expected_pdm[i % NUM_MICS] != 0);
    expected_tdata = expected_cic_bit ? 1 : -1;

    i <= i + 1;
    if (out_last != expected_tlast) $fatal(1, "TLAST wrong");
    if (out_data != expected_tdata) $fatal(1, "TDATA wrong (%d != %d)", out_data, expected_tdata);
    $display("[%5d] OUT: %2h, LAST: %d", tick, out_data, out_last);
end

initial #1000 $finish;

endmodule
module skidbuf #(
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

logic [BITS-1:0]  skid_tdata  = '0;
logic             skid_tvalid = '0;
always_comb recv_tready = !skid_tvalid;

always_ff @(posedge clk) begin
  if (rst) begin
    skid_tvalid <= 0;
    skid_tdata  <= {BITS{1'bx}};
  end else begin
    if ((recv_tvalid && recv_tready) && (send_tvalid && !send_tready)) begin
      skid_tvalid <= 1;
      skid_tdata  <= recv_tdata;
    end else if (send_tready) begin
      skid_tvalid <= 0;
      skid_tdata  <= {BITS{1'bx}};
    end
  end
end

logic            send_tvalid_comb;
logic [BITS-1:0] send_tdata_comb;

always_comb begin
  if (rst) begin
    send_tvalid_comb = '0;
    send_tdata_comb  = {BITS{1'bx}};
  end else if (skid_tvalid) begin
    send_tvalid_comb = '1;
    send_tdata_comb  = skid_tdata;
  end else begin
    send_tvalid_comb = recv_tvalid;
    send_tdata_comb  = recv_tvalid ? recv_tdata : {BITS{1'bx}};
  end
end

generate if (REGISTER_OUTPUT) begin
  always_ff @(posedge clk) begin
    if (rst) begin
      send_tvalid <= '0;
      send_tdata  <= {BITS{1'bx}};
    end else if (!send_tvalid || send_tready) begin
      if (skid_tvalid) begin
        send_tvalid <= '1;
        send_tdata  <= skid_tdata;
      end else begin
        send_tvalid <= recv_tvalid;
        send_tdata  <= recv_tvalid ? recv_tdata : {BITS{1'bx}};
      end
    end
  end
end else begin
  always_comb begin
    if (rst) begin
      send_tvalid = '0;
      send_tdata  = {BITS{1'bx}};
    end else if (skid_tvalid) begin
      send_tvalid = '1;
      send_tdata  = skid_tdata;
    end else begin
      send_tvalid = recv_tvalid;
      send_tdata  = recv_tvalid ? recv_tdata : {BITS{1'bx}};
    end
  end
end endgenerate

endmodule

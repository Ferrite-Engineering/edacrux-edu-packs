module mem_ctrl (
    input        clk,
    input        rst_n,
    input        we,
    input  [7:0] addr,
    input  [7:0] wdata,
    output [7:0] rdata
);
    wire sel_ctrl, sel_status, sel_data0, sel_data1;
    wire [7:0] ctrl, data0, data1;

    addr_decoder u_dec (
        .addr(addr), .sel_ctrl(sel_ctrl), .sel_status(sel_status),
        .sel_data0(sel_data0), .sel_data1(sel_data1)
    );

    regfile u_rf (
        .clk(clk), .rst_n(rst_n), .we(we),
        .sel_ctrl(sel_ctrl), .sel_data0(sel_data0), .sel_data1(sel_data1),
        .wdata(wdata), .ctrl(ctrl), .data0(data0), .data1(data1)
    );

    // Read mux. WIDTH ISSUE: status is only 4 meaningful bits but compared/packed
    // against an 8-bit constant expression below.
    wire [3:0] status4 = {2'b00, sel_data1, sel_data0};
    assign rdata = sel_ctrl   ? ctrl   :
                   sel_status ? {4'h0, status4} :
                   sel_data0  ? data0  :
                   sel_data1  ? data1  : 8'h00;
endmodule

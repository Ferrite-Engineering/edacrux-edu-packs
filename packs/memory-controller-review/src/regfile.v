module regfile (
    input            clk,
    input            rst_n,
    input            we,
    input            sel_ctrl,
    input            sel_data0,
    input            sel_data1,
    input      [7:0] wdata,
    output reg [7:0] ctrl,
    output reg [7:0] data0,
    output reg [7:0] data1
);
    reg [7:0] shadow;   // UNUSED — a dead scratch register (lint: UNUSEDSIGNAL)

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            ctrl  <= 8'h00;
            data0 <= 8'h00;
            data1 <= 8'h00;
        end else if (we) begin
            if (sel_ctrl)  ctrl  <= wdata;
            if (sel_data0) data0 <= wdata;
            if (sel_data1) data1 <= wdata;
        end
endmodule


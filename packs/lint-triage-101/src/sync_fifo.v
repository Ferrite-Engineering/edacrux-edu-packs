// A small sync FIFO, deliberately seeded with lint issues a triage lab needs:
//  - an unused signal
//  - a width mismatch on an assignment
//  - a case that isn't full (missing default)
//  - a signal read before it's fully driven in one path
module sync_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 4
)(
    input                  clk,
    input                  rst_n,
    input                  wr_en,
    input                  rd_en,
    input  [WIDTH-1:0]     wdata,
    output [WIDTH-1:0]     rdata,
    output                 full,
    output                 empty
);
    localparam AW = 2;               // log2(DEPTH) — but DEPTH is a param; not derived (lint: could mismatch)
    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [AW:0]      wptr, rptr;      // one extra bit for full/empty distinction
    reg [7:0]       debug_count;     // UNUSED — classic dead signal

    wire [AW-1:0] waddr = wptr[AW-1:0];
    wire [AW-1:0] raddr = rptr[AW-1:0];

    assign full  = (wptr[AW] != rptr[AW]) && (waddr == raddr);
    assign empty = (wptr == rptr);
    assign rdata = mem[raddr];

    // WIDTH MISMATCH: assigning a 4-bit expression's low bits — verilator WIDTH
    wire [3:0] level = wptr - rptr;
    wire       almost = level > 3'd2;   // width mismatch 4 vs 3

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
            rptr <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[waddr] <= wdata;
                wptr <= wptr + 1'b1;
            end
            if (rd_en && !empty)
                rptr <= rptr + 1'b1;
        end
    end
endmodule

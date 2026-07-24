`timescale 1ns/1ns
// UART transmitter, 8N1. Deliberately correct — this pack is about verification
// flow (a failing test that leads to a waveform), so the "bug" lives in the
// testbench's expectation on one case, mirroring a real spec-vs-impl mismatch.
module uart_tx #(parameter CLKS_PER_BIT = 4) (
    input        clk, rst_n, start,
    input  [7:0] data,
    output reg   tx, busy
);
    localparam IDLE=0, STARTB=1, DATA=2, STOPB=3;
    reg [1:0] state; reg [2:0] bitc; reg [$clog2(CLKS_PER_BIT):0] clkc; reg [7:0] sh;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state<=IDLE; tx<=1'b1; busy<=1'b0; clkc<=0; bitc<=0; sh<=0; end
        else case (state)
            IDLE:   begin tx<=1'b1; busy<=1'b0; clkc<=0; bitc<=0;
                          if (start) begin sh<=data; busy<=1'b1; state<=STARTB; end end
            STARTB: begin tx<=1'b0;
                          if (clkc==CLKS_PER_BIT-1) begin clkc<=0; state<=DATA; end else clkc<=clkc+1; end
            DATA:   begin tx<=sh[0];
                          if (clkc==CLKS_PER_BIT-1) begin clkc<=0; sh<=sh>>1;
                              if (bitc==3'd7) state<=STOPB; else bitc<=bitc+1; end else clkc<=clkc+1; end
            STOPB:  begin tx<=1'b1;
                          if (clkc==CLKS_PER_BIT-1) begin clkc<=0; state<=IDLE; end else clkc<=clkc+1; end
        endcase
    end
endmodule

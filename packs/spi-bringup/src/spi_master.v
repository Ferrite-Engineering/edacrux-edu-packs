`timescale 1ns/1ns
// SPI mode-0 master (CPOL=0, CPHA=0): sample on rising SCLK, shift on falling.
// Sub-module shift_reg makes the datapath navigable in NetCrux.
module shift_reg (
    input clk, load, shift, input [7:0] din, input msb_in,
    output [7:0] dout, output msb
);
    reg [7:0] q;
    always @(posedge clk) if (load) q <= din; else if (shift) q <= {q[6:0], msb_in};
    assign dout = q; assign msb = q[7];
endmodule

module spi_master #(parameter DIV = 2) (
    input clk, rst_n, start, input [7:0] tx_byte, input miso,
    output reg sclk, output reg cs_n, output mosi, output reg done, output [7:0] rx_byte
);
    localparam IDLE=0, RUN=1;
    reg state; reg [3:0] cnt; reg [$clog2(DIV):0] dv; reg sclk_en;
    wire [7:0] txq, rxq;
    wire rise = (state==RUN) && (dv==0) && (sclk==1'b0);
    wire fall = (state==RUN) && (dv==0) && (sclk==1'b1);
    shift_reg u_tx (.clk(clk), .load(start & (state==IDLE)), .shift(fall), .din(tx_byte), .msb_in(1'b0), .dout(txq), .msb(mosi));
    shift_reg u_rx (.clk(clk), .load(1'b0), .shift(rise), .din(8'h00), .msb_in(miso), .dout(rxq), .msb());
    assign rx_byte = rxq;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin state<=IDLE; sclk<=0; cs_n<=1; done<=0; cnt<=0; dv<=0; end
        else begin done<=0;
            case (state)
                IDLE: begin sclk<=0; cs_n<=1; if (start) begin cs_n<=0; cnt<=0; dv<=DIV-1; state<=RUN; end end
                RUN:  if (dv==0) begin dv<=DIV-1; sclk<=~sclk;
                          if (sclk==1'b1) begin if (cnt==4'd8) begin state<=IDLE; cs_n<=1; done<=1; end else cnt<=cnt+1; end
                      end else dv<=dv-1;
            endcase
        end
    end
endmodule

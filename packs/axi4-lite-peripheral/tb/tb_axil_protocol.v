// SPDX-License-Identifier: CC-BY-4.0
// Copyright (c) 2026 Ferrite Engineering
//
// Self-checking handshake testbench for axil_register_peripheral.
//
// The reference testbench (tb_axil.v) drives the slave with a master that
// always presents AW and W together and waits for B before the next write.
// AXI4-Lite allows more than that, so this bench drives the slave directly
// and checks that every write the slave accepts is committed and answered
// with exactly one B response:
//
//   1. AW and W in the same cycle
//   2. AW first, W three cycles later
//   3. W first, AW three cycles later
//   4. Back-to-back writes with BREADY held low (AW and W together)
//   5. Back-to-back writes with BREADY held low (second write AW first)
//   6. Unmapped address: SLVERR on B
//
// Each register is read back afterwards. It writes no waveform; build.sh
// runs it as a gate and fails if any check fails.

`timescale 1ns / 1ns

module tb_axil_protocol;
    reg         aclk;
    reg         aresetn;

    reg  [31:0] awaddr;
    reg         awvalid;
    wire        awready;
    reg  [31:0] wdata;
    reg  [ 3:0] wstrb;
    reg         wvalid;
    wire        wready;
    wire [ 1:0] bresp;
    wire        bvalid;
    reg         bready;
    reg  [31:0] araddr;
    reg         arvalid;
    wire        arready;
    wire [31:0] rdata;
    wire [ 1:0] rresp;
    wire        rvalid;
    reg         rready;

    axil_register_peripheral u_slave (
        .aclk   (aclk),
        .aresetn(aresetn),
        .awaddr (awaddr),
        .awvalid(awvalid),
        .awready(awready),
        .wdata  (wdata),
        .wstrb  (wstrb),
        .wvalid (wvalid),
        .wready (wready),
        .bresp  (bresp),
        .bvalid (bvalid),
        .bready (bready),
        .araddr (araddr),
        .arvalid(arvalid),
        .arready(arready),
        .rdata  (rdata),
        .rresp  (rresp),
        .rvalid (rvalid),
        .rready (rready)
    );

    initial aclk = 1'b1;
    always #5 aclk = ~aclk;

    // ── channel monitors ──────────────────────────────────────────────────
    integer aw_count = 0;
    integer w_count  = 0;
    integer b_count  = 0;
    integer errors   = 0;
    reg [1:0] last_bresp;

    always @(posedge aclk) begin
        if (aresetn) begin
            if (awvalid && awready) aw_count = aw_count + 1;
            if (wvalid  && wready)  w_count  = w_count + 1;
            if (bvalid  && bready) begin
                b_count    = b_count + 1;
                last_bresp = bresp;
            end
        end
    end

    // AXI rule: once VALID is high it stays high, with the payload stable,
    // until the handshake. Checked for the slave's B and R channels.
    reg       bvalid_q, rvalid_q;
    reg       bhs_q, rhs_q;
    reg [1:0] bresp_q;
    always @(posedge aclk) begin
        if (aresetn && bvalid_q && !bhs_q && (!bvalid || bresp != bresp_q)) begin
            $display("FAIL: BVALID or BRESP changed before BREADY at %0t", $time);
            errors = errors + 1;
        end
        if (aresetn && rvalid_q && !rhs_q && !rvalid) begin
            $display("FAIL: RVALID dropped before RREADY at %0t", $time);
            errors = errors + 1;
        end
        bvalid_q <= bvalid;
        bhs_q    <= bvalid & bready;
        bresp_q  <= bresp;
        rvalid_q <= rvalid;
        rhs_q    <= rvalid & rready;
    end

    // ── master-side drivers ───────────────────────────────────────────────
    // Inputs change on the falling edge; the slave samples on the rising
    // edge, so READY read at a falling edge is what the next rising edge
    // will see.
    task send_aw(input [31:0] addr, input integer gap);
        begin
            repeat (gap) @(negedge aclk);
            awaddr  = addr;
            awvalid = 1'b1;
            while (!awready) @(negedge aclk);
            @(negedge aclk);
            awvalid = 1'b0;
            awaddr  = 32'hXXXX_XXXX;
        end
    endtask

    task send_w(input [31:0] data, input integer gap);
        begin
            repeat (gap) @(negedge aclk);
            wdata  = data;
            wstrb  = 4'hF;
            wvalid = 1'b1;
            while (!wready) @(negedge aclk);
            @(negedge aclk);
            wvalid = 1'b0;
            wdata  = 32'hXXXX_XXXX;
        end
    endtask

    task wait_b_count(input integer n);
        integer guard;
        begin
            guard = 0;
            while (b_count < n && guard < 50) begin
                @(negedge aclk);
                guard = guard + 1;
            end
            if (b_count < n) begin
                $display("FAIL: waited for B response %0d, saw %0d", n, b_count);
                errors = errors + 1;
            end
        end
    endtask

    task check(input [255:0] what, input [31:0] got, input [31:0] want);
        begin
            if (got !== want) begin
                $display("FAIL: %0s: got 0x%08h, want 0x%08h", what, got, want);
                errors = errors + 1;
            end
        end
    endtask

    task read_check(input [31:0] addr, input [31:0] want, input [1:0] want_resp);
        begin
            @(negedge aclk);
            araddr  = addr;
            arvalid = 1'b1;
            while (!arready) @(negedge aclk);
            @(negedge aclk);
            arvalid = 1'b0;
            rready  = 1'b1;
            while (!rvalid) @(negedge aclk);
            check("read data", rdata, want);
            check("read resp", {30'b0, rresp}, {30'b0, want_resp});
            @(negedge aclk);
            rready = 1'b0;
            $display("  read  0x%02h = 0x%08h resp=%0d", addr[7:0], rdata, rresp);
        end
    endtask

    integer writes;

    initial begin
        aresetn = 1'b0;
        awvalid = 1'b0;
        wvalid  = 1'b0;
        arvalid = 1'b0;
        bready  = 1'b1;
        rready  = 1'b0;
        awaddr  = 32'h0;
        wdata   = 32'h0;
        wstrb   = 4'h0;
        araddr  = 32'h0;
        bvalid_q = 1'b0; rvalid_q = 1'b0; bhs_q = 1'b0; rhs_q = 1'b0;
        bresp_q  = 2'b00;
        writes  = 0;
        repeat (3) @(negedge aclk);
        aresetn = 1'b1;
        @(negedge aclk);

        // 1. AW and W together
        $display("case 1: AW and W in the same cycle");
        fork
            send_aw(32'h00, 0);
            send_w (32'h1111_1111, 0);
        join
        writes = writes + 1;
        wait_b_count(writes);
        check("case 1 bresp", {30'b0, last_bresp}, 32'd0);

        // 2. AW first
        $display("case 2: AW three cycles before W");
        fork
            send_aw(32'h04, 0);
            send_w (32'h2222_2222, 3);
        join
        writes = writes + 1;
        wait_b_count(writes);
        check("case 2 bresp", {30'b0, last_bresp}, 32'd0);

        // 3. W first
        $display("case 3: W three cycles before AW");
        fork
            send_aw(32'h08, 3);
            send_w (32'h3333_3333, 0);
        join
        writes = writes + 1;
        wait_b_count(writes);
        check("case 3 bresp", {30'b0, last_bresp}, 32'd0);

        // 4. Back-to-back, BREADY low, AW+W together each time
        $display("case 4: back-to-back writes with BREADY held low");
        bready = 1'b0;
        fork
            begin
                fork
                    send_aw(32'h0C, 0);
                    send_w (32'h4444_4444, 0);
                join
                fork
                    send_aw(32'h10, 0);
                    send_w (32'h5555_5555, 0);
                join
            end
            begin
                // Hold BREADY low long enough that the second write is
                // presented while the first response is still pending.
                repeat (6) @(negedge aclk);
                if (awready || wready) begin
                    $display("FAIL: slave ready for a new write while B is pending");
                    errors = errors + 1;
                end
                bready = 1'b1;
            end
        join
        writes = writes + 2;
        wait_b_count(writes);

        // 5. Back-to-back, BREADY low, second write AW first
        $display("case 5: back-to-back with BREADY low, second write AW first");
        bready = 1'b0;
        fork
            begin
                fork
                    send_aw(32'h14, 0);
                    send_w (32'h6666_6666, 0);
                join
                fork
                    send_aw(32'h18, 0);
                    send_w (32'h7777_7777, 4);
                join
            end
            begin
                repeat (5) @(negedge aclk);
                bready = 1'b1;
            end
        join
        writes = writes + 2;
        wait_b_count(writes);

        // 6. Unmapped address
        $display("case 6: unmapped address returns SLVERR");
        fork
            send_aw(32'hFC, 2);
            send_w (32'hDEAD_C0DE, 0);
        join
        writes = writes + 1;
        wait_b_count(writes);
        check("case 6 bresp", {30'b0, last_bresp}, 32'd2);

        repeat (3) @(negedge aclk);
        check("AW handshakes", aw_count, writes);
        check("W handshakes",  w_count,  writes);
        check("B responses",   b_count,  writes);
        $display("  %0d writes: %0d AW, %0d W, %0d B handshakes",
                 writes, aw_count, w_count, b_count);

        read_check(32'h00, 32'h1111_1111, 2'b00);
        read_check(32'h04, 32'h2222_2222, 2'b00);
        read_check(32'h08, 32'h3333_3333, 2'b00);
        read_check(32'h0C, 32'h4444_4444, 2'b00);
        read_check(32'h10, 32'h5555_5555, 2'b00);
        read_check(32'h14, 32'h6666_6666, 2'b00);
        read_check(32'h18, 32'h7777_7777, 2'b00);
        read_check(32'hFC, 32'hDEAD_BEEF, 2'b10);

        if (errors == 0) begin
            $display("PASS: tb_axil_protocol, %0d writes all completed", writes);
            $finish;
        end else begin
            $display("FAIL: tb_axil_protocol, %0d error(s)", errors);
            $fatal(1, "handshake checks failed");
        end
    end

    // Watchdog: a dropped write leaves the bench waiting forever.
    initial begin
        #20000;
        $display("FAIL: timeout, a write never completed (B count %0d)", b_count);
        $fatal(1, "timeout");
    end
endmodule

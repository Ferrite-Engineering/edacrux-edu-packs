// A small register-mapped memory controller: an address decoder selects one of
// four control/status registers. Two modules (decoder + regfile) so NetCrux
// shows real hierarchy, and seeded with lint findings so LintCrux has something
// to triage — the point of the pair pack is going from a lint hit to the
// structure around it.

module addr_decoder (
    input  [7:0] addr,
    output       sel_ctrl,
    output       sel_status,
    output       sel_data0,
    output       sel_data1
);
    // Decode the top address nibble to one-hot register selects.
    assign sel_ctrl   = (addr[7:4] == 4'h0);
    assign sel_status = (addr[7:4] == 4'h1);
    assign sel_data0  = (addr[7:4] == 4'h2);
    assign sel_data1  = (addr[7:4] == 4'h3);
endmodule


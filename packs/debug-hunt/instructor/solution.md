# debug-hunt — solution

**Bug location:** [`../src/counter_buggy.v`](../src/counter_buggy.v) line 22.

**The bug:**

```verilog
else if (~enable)  count <= count + 8'd1;
```

`~enable` is the bitwise complement of the enable signal. The counter
therefore increments when `enable = 0` and freezes when `enable = 1`
— the *inverse* of what an enable-gated counter should do.

**The fix:**

```verilog
else if (enable)  count <= count + 8'd1;
```

Drop the `~` operator. (`!enable` would have the same wrong meaning;
`enable` is correct.)

**Why students should find this without reading the golden source:**

The waveform diff between buggy and golden shows two distinctive
features:

1. A long divergence region between t = 30 ns and t = 200 ns where
   golden is counting and buggy is at 0.
2. A *mirror-image* divergence region between t = 200 ns and t = 300
   ns where buggy is counting and golden is paused.

The mirror-image pattern is the smoking gun: whatever logic gates
the counter is doing the opposite of what's intended. The only
gating expression in the source is the `else if (...)` predicate.
The only one-character change that inverts the predicate is removing
or adding a `~`. From there, it's clear: the buggy line has an extra
`~`.

**Verification that the fix is correct:**

After applying the fix, regenerate the buggy VCD. The buggy and
golden traces should become byte-identical. (`diff fixtures/buggy.vcd
fixtures/golden.vcd` would still differ in headers / dump dates,
but the value-change segments should match.)

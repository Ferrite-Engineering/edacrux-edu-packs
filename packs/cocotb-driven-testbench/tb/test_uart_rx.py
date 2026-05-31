# SPDX-License-Identifier: CC-BY-4.0
# Copyright (c) 2026 Ferrite Engineering
#
# Cocotb testbench for the uart_rx design. This file is the
# *documented* test (what the cocotb log was generated from in
# principle); the *actual* fixtures/reference.vcd is produced by the
# pure-Verilog tb/tb_uart_rx.v so the build pipeline does not require
# cocotb to be installed.
#
# To run with cocotb 2.0+ and Icarus Verilog:
#   python -m pip install cocotb==2.0.1
#   cocotb-runner --hdl=verilog --simulator=icarus \
#       --verilog-sources=src/uart_rx.v --tests=tb/test_uart_rx.py \
#       --topmodule=uart_rx
#
# The structured log messages emitted by the dut.* handles below
# carry inline simulation-time markers (e.g. "@<8680 ns>") that
# WaveCrux's cocotb-log-correlation feature parses.

import logging

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, Timer


CYCLES_PER_BIT = 434


def _bits_lsb_first(byte: int):
    return [(byte >> i) & 1 for i in range(8)]


async def _send_byte(dut, byte: int):
    # Start bit
    dut.rx.value = 0
    await Timer(8680, units="ns")
    # 8 data bits LSB-first
    for bit in _bits_lsb_first(byte):
        dut.rx.value = bit
        await Timer(8680, units="ns")
    # Stop bit
    dut.rx.value = 1
    await Timer(8680, units="ns")


@cocotb.test()
async def uart_rx_receives_four_bytes(dut):
    """Drive 0x55, 0xAA, 0x55, 0xAA into the UART RX and check rx_data."""
    log = logging.getLogger("UartRxTest")
    log.info("Starting UART RX test at 115_207 baud (CYCLES_PER_BIT=%d)", CYCLES_PER_BIT)

    # 50 MHz clock
    cocotb.start_soon(Clock(dut.clk, 20, units="ns").start())

    # Reset
    dut.rst_n.value = 0
    dut.rx.value = 1
    await Timer(45, units="ns")
    dut.rst_n.value = 1
    log.info("Reset released; entering 100 ns idle window")

    await Timer(100, units="ns")

    for expected in (0x55, 0xAA, 0x55, 0xAA):
        log.info("Sending byte 0x%02X", expected)
        await _send_byte(dut, expected)
        # Wait for receiver to assert rx_valid
        await RisingEdge(dut.rx_valid)
        rx = int(dut.rx_data.value)
        log.info("Received byte 0x%02X (expected 0x%02X)", rx, expected)
        assert rx == expected, f"UART RX mismatch: got 0x{rx:02X}, want 0x{expected:02X}"
        await Timer(1000, units="ns")

    log.info("All four bytes received correctly. Test PASSED.")

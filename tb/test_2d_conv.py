
import cocotb
import logging
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
import random

import cocotb_test.simulator
import pytest

# from cocotb.result import TestFailure, ReturnValue


class TB:
    def __init__(self, dut):
        self.dut = dut

        ports = 2
 
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        cocotb.start_soon(Clock(dut.clk_i, 2, units="ns").start())

    async def reset(self):
        self.dut.reset_i.setimmediatevalue(0)
        await RisingEdge(self.dut.clk_i)
        await RisingEdge(self.dut.clk_i)
        self.dut.reset_i.value = 1
        await RisingEdge(self.dut.clk_i)
        await RisingEdge(self.dut.clk_i)
        self.dut.reset_i.value = 0
        await RisingEdge(self.dut.clk_i)
        await RisingEdge(self.dut.clk_i)
        
        
@cocotb.coroutine
def write_ram(dut, address, value):
    """This coroutine performs a write of the RAM"""
    yield RisingEdge(dut.clk_i)              # Synchronise to the read clock
    dut.actv_in_ram_addr.value = address                  # Drive the values
    dut.actv_in_ram_din.value  = value
    dut.actv_in_ram_we.value  = 1
    yield RisingEdge(dut.clk_i)              # Wait 1 clock cycle
    dut.actv_in_ram_we.value  = 0                        # Disable write

@cocotb.coroutine
def read_ram(dut, address):
    """This coroutine performs a read of the RAM and returns a value"""
    yield RisingEdge(dut.clk_i)               # Synchronise to the read clock
    dut.actv_in_ram_addr = address                   # Drive the value onto the signal
    yield RisingEdge(dut.clk_i)               # Wait for 1 clock cycle
    #yield ReadOnly()                             # Wait until all events have executed for this timestep
    raise ReturnValue(int(dut.actv_in_ram_dout.value))  # Read back the value


@cocotb.coroutine
def write_ram_wgt(dut, address, value):
    """This coroutine performs a write of the RAM"""
    yield RisingEdge(dut.clk_i)              # Synchronise to the read clock
    dut.wgt_in_ram_addr.value = address                  # Drive the values
    dut.wgt_in_ram_din.value  = value
    dut.wgt_in_ram_we.value  = 1
    yield RisingEdge(dut.clk_i)              # Wait 1 clock cycle
    dut.wgt_in_ram_we.value  = 0                        # Disable write

@cocotb.coroutine
def read_ram_wgt(dut, address):
    """This coroutine performs a read of the RAM and returns a value"""
    yield RisingEdge(dut.clk_i)               # Synchronise to the read clock
    dut.wgt_in_ram_addr = address                   # Drive the value onto the signal
    yield RisingEdge(dut.clk_i)               # Wait for 1 clock cycle
    #yield ReadOnly()                             # Wait until all events have executed for this timestep
    raise ReturnValue(int(dut.actv_in_ram_dout.value))  # Read back the value




@cocotb.test()
async def run_test(dut):
  
  tb = TB(dut)

  dut.req_i = 0
  # dut.actv_in_ram_we = 0
  # dut.actv_in_ram_addr = 0
  # dut.actv_in_ram_dout = 0
  # dut.wgt_in_ram_addr = 0
  # dut.wgt_in_ram_we = 0
  # dut.wgt_in_ram_dout = 0
  dut.ready_i = 1
  dut.ack_i.value = 0
  dut.in_actv_grant_i.value = 1
  dut.out_actv_grant_i.value = 1
  dut.wgt_grant_i.value = 1
  dut.mult_grant_i.value = 1
  dut.mult_done_i.value = 1
  dut.mult_result_i = 0x50
  # dut.ram_addr_o = 0
  # dut.ram_we_o = 0
  # dut.ram_dout_o = 0    

  await tb.reset()



  ack_o = dut.ack_o.value
  dut.actv_in_ram_din.value = int(random.getrandbits(8))
  dut.wgt_in_ram_din.value = int(random.getrandbits(8))
  # ram_din_i = dut.ram_din_i.value


  # dut.clk_i = 0
  # dut.reset_i = 0
  # dut.req_i = 0
  # dut.actv_in_ram_we = 0
  # dut.actv_in_ram_addr = 0
  # dut.actv_in_ram_dout = 0
  # dut.wgt_in_ram_addr = 0
  # dut.wgt_in_ram_we = 0
  # dut.wgt_in_ram_dout = 0
  # dut.ram_index = 0
  # dut.ram_addr_o = 0
  # dut.ram_we_o = 0
  # dut.ram_dout_o = 0

  # ack_o = dut.ack_o.value
  # actv_in_ram_din = dut.actv_in_ram_din.value
  # wgt_in_ram_din = dut.wgt_in_ram_din.value
  # ram_din_i = dut.ram_din_i.value
  
  # for i in range(dut.InputWidth.value):
  #   await write_ram(dut, i, int(random.getrandbits(8)))
    
  
  # for i in range(dut.InputWgtWidth.value):
  #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
    
  # dut.ram_index_i.value = 1
  # for i in range(dut.InputWgtWidth.value):
  #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
  #   await RisingEdge(dut.clk_i)
    
    
  # dut.ram_index_i.value = 2
  # for i in range(dut.InputWgtWidth.value):
  #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
  #   await RisingEdge(dut.clk_i)
    
    
  # for i in range(10):
  #   await RisingEdge(dut.clk_i)    

  # # while(dut.ready_o.value == 0):
  # #   await RisingEdge(dut.clk_i)
  
  dut.req_i.value = 1
  await RisingEdge(dut.clk_i)
  
  # while(dut.ack_o.value == 0):
  #   await RisingEdge(dut.clk_i)
  dut.req_i.value = 0
  
  
  
  # while(dut.req_o.value == 0):
  #   await RisingEdge(dut.clk_i)
  for i in range(8000):
    await RisingEdge(dut.clk_i)     


# Register the test.
# factory = TestFactory(run_test)
# factory.generate_tests()
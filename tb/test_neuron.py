
import cocotb
import logging
import random
from cocotb.clock import Clock
from cocotb.triggers import Timer,FallingEdge, RisingEdge
from cocotb.regression import TestFactory
from cocotb.binary import BinaryRepresentation, BinaryValue


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
        
        

@cocotb.test()
async def run_test(dut):
  
  tb = TB(dut)
  
  dut.shift_i = 0
  dut.scan_di = 0
  dut.actv_i = 0
  dut.back_prop_req_i = 0
  dut.back_prop_ack_i = 0
  dut.result_i = 0
  
  await tb.reset()

  scan_do = dut.scan_do.value
  actv_o = dut.actv_o.value
  back_prop_ack_o = dut.back_prop_ack_o.value
  back_prop_req_o = dut.back_prop_req_o.value
  result_o = dut.result_o.value

  for i in range(2):
    await RisingEdge(dut.clk_i)
  dut.shift_i = 1
  await RisingEdge(dut.clk_i)

  for i in range(50):
    dut.scan_di.value = random.randint(-128,128)
    await RisingEdge(dut.clk_i)
        
  dut.shift_i = 0
  
  await RisingEdge(dut.clk_i)
  
  
  for i in range(dut.NumInputs.value-1):
    dut.actv_i.value[(dut.DataWidth.value)*i : ((dut.DataWidth.value)*i)+(dut.DataWidth.value)] = 0xFA  #random.randint(50,255)
  
  dut.actv_i = BinaryValue(value=bytes([random.randrange(0, 256) for _ in range(0, int(len(dut.actv_i)/8))]), n_bits=int(len(dut.actv_i)), bigEndian=False)
  # dut.scan_di = 0
  # dut.actv_i = 0
  # dut.back_prop_req_i = 0
  # dut.back_prop_ack_i = 0
  # dut.result_i = 0


  # scan_do = dut.scan_do.value
  # actv_o = dut.actv_o.value
  # back_prop_ack_o = dut.back_prop_ack_o.value
  # back_prop_req_o = dut.back_prop_req_o.value
  # result_o = dut.result_o.value
  
  for i in range(10):
    await RisingEdge(dut.clk_i)


# Register the test.
# factory = TestFactory(run_test)
# factory.generate_tests()
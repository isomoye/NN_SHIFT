import itertools
import logging
import os
import random
import subprocess
import sys

import cocotb_test.simulator
import pytest
import zlib, binascii, struct
from crc import Calculator, Configuration,Crc32

import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotbext.axi import AxiStreamFrame, AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor
from cocotbext.pcie.core import RootComplex, MemoryEndpoint, Device, Switch
from cocotbext.pcie.core.caps import MsiCapability
from cocotbext.pcie.core.utils import PcieId
from cocotbext.pcie.core.tlp import Tlp, TlpType



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
    
    for i in range(len(dut.req_i)):
        dut.req_i[i].value = 0
        
    for i in range(len(dut.req_i)):
        dut.ack_i[i].value = 1

    await tb.reset()
    
    
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)


    dut.shift_i.value = 1
    dut.actv_i.value = 0
    
    for i in range(100):
        dut.weights_i.value = random.randint(-265,256)
        await RisingEdge(dut.clk_i)
        
    await RisingEdge(dut.clk_i)
    dut.shift_i.value  = 0
    actv = 0
    await RisingEdge(dut.clk_i)
    for i in range(int(len(dut.actv_i)/32)):
        actv += random.randint(-265,256)
    dut.actv_i.value = actv
        # dut._id("actv_i[]", extended=False).value= random.randint(-265,256)
        
    # dut.actv_i.value = random.randint(-265,256)+random.randint(-265,256)+random.randint(-265,256)
    for i in range(len(dut.req_i)):
        dut.req_i[i].value = 1
    count = 0
    
    while(count < 5):
        if(dut.req_o.value != 0):
            for i in range(int(len(dut.actv_i)/32)):
                actv += random.randint(-265,256)
            dut.actv_i.value = actv
            for i in range(len(dut.req_i)):
                dut.req_i[i].value = 1
            count+= 1
        await RisingEdge(dut.clk_i)
        dut.req_i.value = 0
        
            
    for i in range(100):
        await RisingEdge(dut.clk_i)
        
    
    
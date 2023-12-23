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
from cocotb.types import Bit,Logic, LogicArray
from cocotb.types.range import Range
from bitarray import bitarray
from cocotb.binary import BinaryRepresentation, BinaryValue

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
    

    await tb.reset()
    
    
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)
    await RisingEdge(dut.clk_i)


    dut.shift_i.value = 1
    weights_out = dut.weights_o

    for i in range(dut.TotalWeights.value + dut.InputLayerWeights.value):
        dut.weights_i.value = random.randint(-128,128)
        await RisingEdge(dut.clk_i)
        
    await RisingEdge(dut.clk_i)
    dut.shift_i.value  = 0
    dut.actv_i.value = 0 

    # await RisingEdge(dut.clk_i)
    # for i in range(int(len(dut.actv_i)/8)-1):
    #     dut.actv_i.value[8*i : (8*i)+8] = random.randint(0,255)
    # dut.actv_i.value = 0xFFCADDAAEADFAD
    dut.actv_i.value = BinaryValue(value=bytes([random.randrange(0, 256) for _ in range(0, int(len(dut.actv_i)/8))]), n_bits=int(len(dut.actv_i)), bigEndian=False)
    # for i in range(int(len(dut.actv_i)/32)):
    #     dut.actv_i.value.bit_slice(i*32,(i*32) + 32) = random.randint(-265,256)
    #     # dut._id("actv_i[]", extended=False).value= random.randint(-265,256)
 
    # dut.actv_i.value = random.randint(-265,256)+random.randint(-265,256)+random.randint(-265,256)
    # for i in range(len(dut.req_i)):
    #     dut.req_i[i].value = 1

    # count = 0
    # while(1):
    #     await RisingEdge(dut.clk_i)
    #     flag = 1
    #     for i in range (int(len(dut.ack_o))):
    #         if dut.ack_o.value[i] == 0:
    #             flag = 0
    #     if flag == 1:
    #         dut.req_i = 0
    #         break
    # await RisingEdge(dut.clk_i)
    # await RisingEdge(dut.clk_i)
    # dut.actv_i.value = BinaryValue(value=bytes([random.randrange(0, 256) for _ in range(0, int(len(dut.actv_i)/8))]), n_bits=int(len(dut.actv_i)), bigEndian=False)
    # for i in range(len(dut.req_i)):
    #     dut.req_i[i].value = 1
    await RisingEdge(dut.clk_i)
    # sdut.req_i.value = 0
    # flag = 0
    # while(1):
    #     flag = 1
    #     for i in range (int(len(dut.ack_o))):
    #         if dut.ack_o.value[i] == 0:
    #             flag = 0
    #     if flag == 1:
    #         dut.req_i = 0
    #         break
    #     await RisingEdge(dut.clk_i)
    for i in range (10):
        dut.actv_i.value = BinaryValue(value=bytes([random.randrange(0, 256) for _ in range(0, int(len(dut.actv_i)/8))]), n_bits=int(len(dut.actv_i)), bigEndian=False)
        await RisingEdge(dut.clk_i)
     # while(count < 0):
    #     if(dut.req_o.value != 0):
    #         dut.actv_i.value = BinaryValue(value=bytes([random.randrange(0, 256) for _ in range(0, int(len(dut.actv_i)/8))]), n_bits=int(len(dut.actv_i)), bigEndian=False)
    #         for i in range(len(dut.req_i)):
    #             dut.req_i[i].value = 1
    #         count+= 1
    #     await RisingEdge(dut.clk_i)
    #     while(1):
    #         flag = 1
    #         for i in range (int(len(dut.ack_o))):
    #             if dut.ack_o.value[i] == 0:
    #                 flag = 0
    #         if flag == 1:
    #             dut.req_i = 0
    #             break
        
    for i in range(10):
        await RisingEdge(dut.clk_i)
    
    
           
    # for i in range(10000):
    #     await RisingEdge(dut.clk_i)
        
    
    
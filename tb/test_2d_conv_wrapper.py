
import cocotb
import logging
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
from matplotlib import pyplot
from cocotb.clock import Clock
from cocotb.binary import BinaryRepresentation, BinaryValue
from cocotb.triggers import FallingEdge, RisingEdge, Timer
import random
from fxpmath import Fxp

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
        cocotb.start_soon(Clock(dut.actv_in_ram_clk, 2, units="ns").start())
        cocotb.start_soon(Clock(dut.wgt_in_ram_clk, 2, units="ns").start())

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


def flatten(xss):
    return [x for xs in xss for x in xs]


# def convolution2d(image, kernel, bias):
#     m, n = kernel.shape
#     if (m == n):
#         y, x = image.shape
#         y = y - m + 1
#         x = x - m + 1
#         new_image = np.zeros((y,x))
#         for i in range(y):
#             for j in range(x):
#                 new_image[i][j] = np.sum(image[i:i+m, j:j+m]*kernel) + bias
#     return new_image
  
  
# def convolve(image, kernel):
#   # We start off by defining some constants, which are required for this code
#   kernelH, kernelW = kernel.shape
#   imageH, imageW = kernel.shape
#   h, w = imageH + 1 - kernelH, imageW + 1 - kernelW
  
#   # filter1 creates an index system that calculates the sum of the x and y indices at each point
#   # Shape of filter1 is h x kernelW
#   filter1 = np.arange(kernelW) + np.arange(h)[:, np.newaxis]
  
#   # intermediate is the stepped data, which has the shape h x kernelW x imageH
#   intermediate = image[filter1]
  
#   # transpose the inner dimensions of the intermediate so as to enact another filter
#   # shape is now h x imageH x kernelW
#   intermediate = np.transpose(intermediate, (0, 2, 1))
  
#   # filter2 similarly creates an index system
#   # Shape of filter2 is w * kernelH
#   filter2 = np.arange(kernelH) + np.arange(w)[:, np.newaxis]
  
#   # Apply filter2 on the inner data piecewise, resultant shape is h x w x kernelW x kernelH
#   intermediate = intermediate[:, filter2]
  
#   # transpose inwards again to get a resultant shape of h x w x kernelH x kernelW
#   intermediate = np.transpose(intermediate, (0, 1, 3, 2))
  
#   # piecewise multiplication with kernel
#   product = intermediate * kernel
  
#   # find the sum of each piecewise product, shape is now h x w
#   convolved = product.sum(axis = (2,3))
  
#   return convolved

@cocotb.test()
async def run_test(dut):
  
  tb = TB(dut)

  dut.req_i.value = 0
  dut.actv_in_ram_we.value = 0
  dut.actv_in_ram_addr.value = 0
  dut.actv_in_ram_dout.value = 0
  dut.wgt_in_ram_addr.value = 0
  dut.wgt_in_ram_we.value = 0
  dut.wgt_in_ram_dout.value = 0
  dut.ready_i.value = 1
  dut.ack_i.value = 0
  # dut.ram_addr_o = 0
  # dut.ram_we_o = 0
  # dut.ram_dout_o = 0   
  
  convolution_kernel = np.array([[0, 1, 0], 
                               [1, 1.5, 1], 
                               [0, 1, 0]])
  
  sharpen = np.array([[0, -1, 0], 
                    [-1, 5, -1], 
                    [0, -1, 0]])
  
  laplacian = np.array([[0, 1, 0], 
                      [1, -4, 1], 
                      [0, 1, 0]])
  
#   (train_X, train_y), (test_X, test_y) = mnist.load_data()
#   
#   for i in range(9):  
    # pyplot.subplot(330 + 1 + i)
    # pyplot.imshow(train_X[i], cmap=pyplot.get_cmap('gray'))
#   pyplot.show()

  basewidth = 28
  img = Image.open('sample_image.png')
  wpercent = (basewidth / float(img.size[0]))
  hsize = int((float(img.size[1]) * float(wpercent)))
  img = img.resize((basewidth, basewidth))
  img.save('resized_image.png')
  
  
#   pyplot.imshow(img)
#   pyplot.show()

#   im = plt.imread('sample_image.png')
#   print(im.shape)
#   pyplot.imshow(im)
#   pyplot.show()
#   
#   im.resize(28,28)
#   print(im.shape)
#   pyplot.imshow(im)
#   pyplot.show()
  images = np.array(img)
  convo = convolution2d(images,convolution_kernel,0)
  # convo = np.convolve(images,convolution_kernel)
#   images = flatten(images)
#   convolution_kernel_flat = flatten(convolution_kernel)
  
#   # convolve(img,convolution_kernel)
# #   for i in range (len(images)):
#     # print(images[i])

#   await tb.reset()
  
     
#   for i in range(10):
#     await RisingEdge(dut.clk_i)    

#   for i in range(dut.NumWeights.value):
#     data = Fxp(convolution_kernel_flat[i], signed=True, n_word=8, n_frac=4)
#     # print(data.bin(frac_dot=False))
#     await write_ram_wgt(dut, i,  BinaryValue(data.bin(frac_dot=False),n_bits=int(len(dut.wgt_in_ram_din)), bigEndian=False))
#     # BinaryValue(hex(data.get_val()),n_bits=int(len(dut.actv_in_ram_din)), bigEndian=False))
    
#   for i in range(len(images)):
#     data = Fxp(images[i], signed=True, n_word=8, n_frac=4)
#     # print(data)
#     await write_ram(dut, i,  BinaryValue(data.bin(frac_dot=False),n_bits=int(len(dut.actv_in_ram_din)), bigEndian=False))
#     #await write_ram(dut, i, int(random.getrandbits(8)))   
    
#   dut.req_i.value = 1
#   await RisingEdge(dut.clk_i)
  
#   while(dut.ack_o.value == 0):
#     await RisingEdge(dut.clk_i)
#   dut.req_i.value = 0
#   count = 0
#   while(dut.req_o.value == 0):
#     await RisingEdge(dut.clk_i)
#     count += 1
    
#   print('num clocks:' + str(count))
    
  for i in range(900):
    await RisingEdge(dut.clk_i) 


# #   ack_o = dut.ack_o.value
# #   dut.actv_in_ram_din.value = int(random.getrandbits(8))
# #   dut.wgt_in_ram_din.value = int(random.getrandbits(8))
#   # ram_din_i = dut.ram_din_i.value


#   # dut.clk_i = 0
#   # dut.reset_i = 0
#   # dut.req_i = 0
#   # dut.actv_in_ram_we = 0
#   # dut.actv_in_ram_addr = 0
#   # dut.actv_in_ram_dout = 0
#   # dut.wgt_in_ram_addr = 0
#   # dut.wgt_in_ram_we = 0
#   # dut.wgt_in_ram_dout = 0
#   # dut.ram_index = 0
#   # dut.ram_addr_o = 0
#   # dut.ram_we_o = 0
#   # dut.ram_dout_o = 0

#   # ack_o = dut.ack_o.value
#   # actv_in_ram_din = dut.actv_in_ram_din.value
#   # wgt_in_ram_din = dut.wgt_in_ram_din.value
#   # ram_din_i = dut.ram_din_i.value
  
    
  
#   # for i in range(dut.InputWgtWidth.value):
#   #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
    
#   # dut.ram_index_i.value = 1
#   # for i in range(dut.InputWgtWidth.value):
#   #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
#   #   await RisingEdge(dut.clk_i)
    
    
#   # dut.ram_index_i.value = 2
#   # for i in range(dut.InputWgtWidth.value):
#   #   await write_ram_wgt(dut, i, int(random.getrandbits(8)))
#   #   await RisingEdge(dut.clk_i)
    
    
#   # for i in range(10):
#   #   await RisingEdge(dut.clk_i)    

#   # # while(dut.ready_o.value == 0):
#   # #   await RisingEdge(dut.clk_i)
  
# #   dut.req_i.value = 1
# #   await RisingEdge(dut.clk_i)
  
# #   # while(dut.ack_o.value == 0):
# #   #   await RisingEdge(dut.clk_i)
# #   dut.req_i.value = 0
  
  
  
#   # while(dut.req_o.value == 0):
#   #   await RisingEdge(dut.clk_i)
# #   for i in range(8000):
# #     await RisingEdge(dut.clk_i)     


# # Register the test.
# # factory = TestFactory(run_test)
# # factory.generate_tests()
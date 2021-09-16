---
layout: post
title:  "FINN Matrix Vector RTL Backend"
author: "Syed Asad Alam"
---

*The matrix vector RTL backend is not part of FINN but stands independently. However, it is functionally same as the 
FINN matrix vector backend generated using HLS

The FINN matrix vector RTL backend is now released. It implements the matrix vector product operation and supports the AXI 
stream interface. It can be found [here](https://github.com/asadalam/FINN_MatrixVector_RTL), with a brief explanation of how
to implement and test it. This RTL backend was developed as part of Industry Secondment of the author who is a Research Fellow
at the School of Computer Science and Statistics, Trinity College Dublin, the University of Dublin.

The matrix vector unit (MVU) sits at the heart of the FINN architecture to implement the convolution for a neural network.
In principle, a 2D convolution can be implemented by lowering it to a matrix matrix multiplication of weight matrix and input activation.
In FINN, the matrix vector unit performs this multiplication of the weight matrix with one input image vector. Each input 
image vector is streamed into this unit to be multiplied with the weight matrix. The unit itself is built as a data flow
architecture.

There are two variants of the MVU. One is where the input activation is streamed in with burned-in weights (Batch MVU), the other where both 
weights and input activation is streamed in (Stream MVU). The FINN framework implements these units using HLS and the goal of this work was to
implement a generic and modular hand-written RTL to analyze the differences between RTL and HLS performance.

Essentially, the stream MVU is a subset of batch MVU. The stream MVU consists of a control unit and a number of processing elements (PEs). Each PE
is made up of a number of SIMD units. The degree of parallelism in the MVU is determined by the number of PEs and SIMDs/PE. Consider the 4x8 weight matrix
and a 8x1 input activation shown in Fig. 1

| <img src="https://xilinx.github.io/finn/img/QuartzNet.jpg" alt="QuartzNet Structure" title="QuartzNet Structure" width="450" height="500" align="center"/>|
| :---:|
| *Fig. 1 QuartzNet Model, [source](https://arxiv.org/abs/1910.10261)* |

In order to implement a fully generic RTL,

# AIC2021 Project1 - TPU - N26091411
###### tags: `aic2021` 

## Student ID 
N26091411

## Project Description
This project use weight stationary method.
Design a Tensor Processing Unit(TPU) which has **4x4** Processing elements(PEs) that is capable to calculate ```(4*K)*(K*4)``` 8-bit integer matrix muplication. (Where is ```K``` is limited by the size of input global buffer)

## Project directory hierachy
```
AIC2021_TPU/
    +-- tb/
    |   +-- matmul.py
    |   +-- top_tb.v
    +-- src/
    |   +-- define.v
    |   +-- global_buffer.v
    |   +-- top.v
	|   +-- pe.v
	|   +-- TPU.v	
    |
    Makefile
```
![](./img/slide1.PNG)
![](./img/slide2.PNG)
![](./img/slide3.PNG)
![](./img/slide4.PNG)
![](./img/slide5.PNG)
![](./img/slide6.PNG)
![](./img/slide7.PNG)
![](./img/slide8.PNG)
![](./img/slide9.PNG)
![](./img/slide10.PNG)
![](./img/slide11.PNG)
![](./img/slide12.PNG)
![](./img/slide13.PNG)
![](./img/slide14.PNG)
![](./img/slide15.PNG)
![](./img/slide16.PNG)
![](./img/slide17.PNG)
![](./img/slide18.PNG)
![](./img/slide19.PNG)
![](./img/slide20.PNG)
![](./img/slide21.PNG)
![](./img/slide22.PNG)
![](./img/slide23.PNG)
![](./img/slide24.PNG)
![](./img/slide25.PNG)
![](./img/slide26.PNG)
![](./img/slide27.PNG)
![](./img/slide28.PNG)
![](./img/slide29.PNG)
![](./img/slide30.PNG)
![](./img/slide31.PNG)
![](./img/slide32.PNG)
![](./img/slide33.PNG)
![](./img/slide34.PNG)
![](./img/slide35.PNG)
![](./img/slide36.PNG)
![](./img/slide37.PNG)
![](./img/slide38.PNG)
![](./img/slide39.PNG)
![](./img/slide40.PNG)
![](./img/slide41.PNG)
![](./img/slide42.PNG)
![](./img/slide43.PNG)
![](./img/slide44.PNG)
![](./img/slide45.PNG)
![](./img/slide46.PNG)
![](./img/slide47.PNG)
![](./img/slide48.PNG)
![](./img/slide49.PNG)
![](./img/slide50.PNG)
![](./img/slide51.PNG)
![](./img/slide52.PNG)
![](./img/slide53.PNG)
![](./img/slide54.PNG)
![](./img/slide55.PNG)

## TOP Simulation Achitecture
![](./img/top.png)

* Your TPU design should be under the top module which provided by TA.
* TOP module includes three global buffers prepared for your TPU. Each of the global buffers has its own read write port, ```256x32bit=1KiBytes``` size and result in total ```3KiBytes``` of global buffer.
* Although the global buffer is provided by TA, you are free to design your own global buffer's behavior, except the **name of the global buffers** which already defined in testbench in order to load the data & check the correctness of the output.


## Testbench
![](./img/testbench.png)
* At the start of the simulation, tb will load the global buffer A & B, which assume that CPU or DMA has already prepared the data for TPU in global buffer. When signal ```start==1```, the size of the two matrices will be available for TPU (```m```, ```n```, ```k```).
    * ```A(M*K)*B(K*N)```
* You should implement your own data loader, process elements(PEs), and controller which schedules the data in global buffer A & B to be calculated in the systolic array.
* Testbench will compare your output global buffer with golden, when you finish the calculation(```done==1```).

**Prerequisite**
* python3 with numpy library installed
* iverilog, ncverilog (or any other verilog compiler)

**Makefile**
* ```make test1```
    * ```A(2*2)*B(2*2)```
* ```make test2```
    * ```A(4*4)*B(4*4)```
* ```make test3```
    * ```A(4*K)*B(K*4)```, where ```K=9```
* ```make monster``` (extra)
    * ```A(M*K)*B(K*N)```, where ```K<10```, ```M<10```, ```N<10```
    * Although our target is ```(4*K)*(K*4)``` matrix multiplication, when ```M``` & ```N``` is small enough to fit in the input global buffers, give a solution for that size of input matrices. :smile:
* ```make clean```
    * This will remove the ```build/``` folder 

**Global buffer mapping**
```
build/
    +-- matrix_a.bin
    +-- matrix_b.bin
    +-- golden.bin
```
* Memory Mapping - Type A (with transpose)
![](./img/matrix_a.png)
* Memory Mapping - Type B (Without transpose)
![](./img/matrix_b.png)
* As shown in the figure above, two figures give an example of ```A(6*6)*B(6*6)```, how is the memory mapping of 8-bit matrix data into 32-bit global buffer. Your output global buffer should follow the memory mapping - type B.

## Grading Scores
* Testbench1~3 (70%)
    * Designs of dataflow in TPU
    * Execution time ranking in class
    * Data reuse method 
    * Pass atleast test1~3
* Readme (20%)
    * **Members' Student ID**
    * TPU achitecture graph
    * Explain your dataflow in TPU
    * Pls descript as much as you can
    * ...
* Extra (10%)
    * Support ```(M*K)*(K*N)```
    * or other features
        * please provided you own testbench for the extra features
    * Good coding style
    * Plagiarizing(copy-&-paste) others code is probihited
        * Dont try to do that :smile:, warning from TAs -100%


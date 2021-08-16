`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2021 04:09:40 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    
    input clk,  //
    input CS1,  //
    //Slave-Master connections
    input MISO, //
    output MOSI, //
    output spi_clk, //
    output CS,
    
    //input [7:0] Parallel_In, //
    input Test_Switch,
    input read,
    
    //Display outputs
    output [7:1] C,
    output [3:0] AN,
    
    //Output LEDs
    output FIFO_EMPTY, //
    output FIFO_FULL, //
    output [7:0] Parallel_Out
    );
    
    wire [7:0] Rx_DataOut;
    wire [7:0] MISO_Data;
    wire read_ready;
    wire write_ready;
    
    SPI_Master Accel(.clk(clk), .CS1(Load), .Test_Switch(Test_Switch), .byte_write(write_ready),
    .byte_read(read_ready), .MISO(MISO), .MOSI(MOSI), .MISO_Data(MISO_Data),  .spi_clk(spi_clk),
    .CS(CS));
    
    Sw_Debug Data_In_LEDs (.switch(Parallel_In), .clk(clk), .LED(Parallel_Out));
    
    //SPI_FIFO FIFO(.Master_clk(Master_clk), .write_ready(write_ready), .read_ready(read_pulse), 
    //.Rx_dataIn(MISO_Data), .Rx_DataOut(Rx_DataOut), .EMPTY(FIFO_EMPTY), .FULL(FIFO_FULL));
     
     Byte_Display_Selector AN_Select(clk, Array);
     Byte_Display MISO_Display(.Rx_Data(MISO_Data), .Array(Array), .C(C), .AN(AN));
     Debounce Command (.switch_in(CS1), .clk(clk), .switch_out(Load));//switch to see next word stored in FIFO
     Debounce_Pulse Read_request (.switch_in(read), .clk(clk), .pulse_out(read_pulse));
    
endmodule

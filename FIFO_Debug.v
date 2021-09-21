`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 03:01:47 PM
// Design Name: 
// Module Name: FIFO_Debug
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


module FIFO_Debug();
    
    reg clk = 0;
    reg write_ready = 0;
    reg read_ready = 0;
    reg [15:0] Rx_dataIn = 0;
    
    wire [7:0] Rx_DataOut1;
    wire [7:0] Rx_DataOut2;
    wire EMPTY;
    wire FULL;
    
    SPI_FIFO TB(.clk(clk), .write_ready(write_ready), .read_ready(read_ready), .Rx_dataIn(Rx_dataIn), .Rx_DataOut1(Rx_DataOut1), .Rx_DataOut2(Rx_DataOut2), .EMPTY(EMPTY), .FULL(FULL));
    
    integer i = 0;
    
    initial
    begin
        forever #1 clk = ~clk;
    end
    
    initial
    begin
        Rx_dataIn = 16'b0110011001100101;
        for (i = 0; i < 5; i = i + 1)
        begin
            write_ready = 1;
            #2
            write_ready = 0;
            #2;
            Rx_dataIn = Rx_dataIn + 1;
        end
        //read_ready = 1;
        #2;
        //read_ready = 0;
        #2;
       // read_ready = 1;
        #2;
        //read_ready = 0;
        #2;
        //read_ready = 1;
        #2;
        //read_ready = 0;
        #2;
        //read_ready = 1;
        #2;
        //read_ready = 0;
        $finish;
    end
endmodule

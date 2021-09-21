`timescale 1ns / 1ps
/*
This module is a wrapper for 3 FIFOs: each accelerometer axis has its own FIFO, used to store acceleration data for transmission via UART.
Manages data from SPI master, and stores it in proper FIFOs

i_Byte_Count -> used to load correct axis data to correct FIFO. 
When i_Byte_Count transitions from 0 to 1, X data has been read.
When i_Byte_Count transitions from 1 to 2, Y data has been read.
When i_Byte_Count transitions from 2 to 0, Z data has been read.
Load goes high on each transition and loads the most recent data.
*/

module Accel_FIFO_Management(
    input clk,
    input wire [15:0] Accel_Data,                   //Data from SPI master. New value on every MI_Byte_Complete (Load) pulse
    input wire [1:0] i_Byte_Count,                  //Number of bytes received by SPI master during current transaction (purpose detailed above)
    input wire wordComplete,                        //High for 1 clock cycle once UART finishes transmitting a full word (2 bytes). Signals reading the next FIFO
    input wire Load,                                //Loads data into FIFO defined by i_Byte_Count
    
    output reg [15:0] DataOut,                      //Output data stream. Flips through FIFO outputs (X -> Y -> Z -> X)
    output reg [1:0] Axis_Counter = 0               //Determines which data is to be transmitted (X, Y, Z, or 16'hFFFF)
    );
    
    reg X_Data_Ready;                               //Signals write of current X_Data to X_Data FIFO 
    reg Y_Data_Ready;                               //Signals write of current Y_Data to Y_Data FIFO 
    reg Z_Data_Ready;                               //Signals write of current Z_Data to Z_Data FIFO 
    
    reg [15:0] X_Data;                              //X_Data data line
    reg [15:0] Y_Data;                              //Y_Data data line
    reg [15:0] Z_Data;                              //Z_Data data line

    wire [15:0] X_DataOut;                          //Data output from X FIFO
    wire [15:0] Y_DataOut;                          //Data output from Y FIFO
    wire [15:0] Z_DataOut;                          //Data output from Z FIFO
    
    reg X_read_ready;                               //Signals a pop from the X FIFO
    reg Y_read_ready;                               //Signals a pop from the Y FIFO
    reg Z_read_ready;                               //Signals a pop from the Z FIFO

    always@(posedge clk)                           
    begin
        if (i_Byte_Count == 2 && Load == 1)         //If Y data registers were just read by SPI master, store data input in Y_Data, load to Y FIFO
        begin
            Y_Data              <= Accel_Data;                   
            Y_Data_Ready        <= 1;
        end
        else if (i_Byte_Count == 1 && Load == 1)    //If X data registers were just read by SPI master, store data input in Y_Data, load to Y FIFO
        begin
            X_Data_Ready        <= 1;
            X_Data              <= Accel_Data;
        end
        else if (i_Byte_Count == 0 && Load == 1)    //If Z data registers were just read by SPI master, store data input in Y_Data, load to Y FIFO
        begin
            Z_Data              <= Accel_Data;
            Z_Data_Ready        <= 1;
        end
        else
        begin
            X_Data_Ready        <= 0;
            Y_Data_Ready        <= 0;
            Z_Data_Ready        <= 0;
        end
    end
    
    always@(posedge clk)                
    begin
        X_read_ready <= 0;
        Y_read_ready <= 0;
        Z_read_ready <= 0;
        if (Axis_Counter == 3)                             //After Z data has been transmitted, transmit 16'hFF for data alignment in MATLAB
        begin
            DataOut                 <= 16'b1111111111111111;
            if (wordComplete)
            begin
                Axis_Counter        <= Axis_Counter + 1;   //Proceed to transmit X data
            end
        end
        if (Axis_Counter == 2)                             //Transmit Z data from Z FIFO
        begin
            DataOut <= Z_DataOut;                          //Load data to transmit with Z FIFO output
            if (wordComplete)                              //If UART Tx complete
            begin
                Axis_Counter        <= Axis_Counter + 1;   //Proceed to transmit 16'hFF
                Z_read_ready        <= 1;                  //Pop Z FIFO
            end 
        end
        if (Axis_Counter == 1)
        begin
            DataOut                 <= Y_DataOut;          //Load data to transmit with Y FIFO output
            if (wordComplete)                              //If UART Tx complete
            begin
                Axis_Counter        <= Axis_Counter + 1;   //Proceed to transmit Z data
                Y_read_ready        <= 1;                  //Pop Y FIFO
            end
        end
        if (Axis_Counter == 0)
        begin
            DataOut                 <= X_DataOut;           //Load data to transmit with X FIFO output
            if (wordComplete)                               //If UART Tx complete
            begin
               Axis_Counter         <= Axis_Counter + 1;    //Proceed to transmit Y data
               X_read_ready         <= 1;                   //Pop X FIFO
            end
        end     
    end

    SPI_FIFO X_Data_FIFO(.clk(clk), .write_ready(X_Data_Ready), .read_ready(X_read_ready), .Rx_DataIn(X_Data), .Rx_DataOut(X_DataOut));
    
    SPI_FIFO Y_Data_FIFO(.clk(clk), .write_ready(Y_Data_Ready), .read_ready(Y_read_ready), .Rx_DataIn(Y_Data), .Rx_DataOut(Y_DataOut));
    
    SPI_FIFO Z_Data_FIFO(.clk(clk), .write_ready(Z_Data_Ready), .read_ready(Z_read_ready), .Rx_DataIn(Z_Data), .Rx_DataOut(Z_DataOut));
    

    
endmodule

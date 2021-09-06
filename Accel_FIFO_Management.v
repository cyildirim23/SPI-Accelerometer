`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/31/2021 02:56:45 PM
// Design Name: 
// Module Name: Accel_FIFO_Management
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


module Accel_FIFO_Management(
    input clk,
    input wire [15:0] Accel_Data,
    input wire [1:0] i_Byte_Count,
    input wire wordComplete,        //High for 1 duty cycle once UART finishes transmitting a full word (2 bytes). Signals reading the next FIFO
    input wire Load,
    
    output reg [15:0] DataOut,
    output wire [1:0] X_SM,
    output wire [1:0] Y_SM,
    output wire [1:0] Z_SM,
    output reg [1:0] Axis_Counter = 0,
    output reg X_Data_Ready,
    output reg Y_Data_Ready,
    output reg Z_Data_Ready,
    output reg [15:0] X_Data,
    output reg [15:0] Y_Data,
    output reg [15:0] Z_Data,
    
    output wire FULL_Z
   
    );
    
    wire [15:0] X_DataOut;
    wire [15:0] Y_DataOut;
    wire [15:0] Z_DataOut;

    /*reg [15:0] X_Data;
    reg [15:0] Y_Data;
    reg [15:0] Z_Data;
    */
    /*reg X_Data_Ready;
    reg Y_Data_Ready;
    reg Z_Data_Ready;*/
    
    reg X_read_ready;
    reg Y_read_ready;
    reg Z_read_ready;
    
    //reg [1:0] Axis_Counter = 0;

    always@(posedge clk)                            //Once a 16-bit word is read from MISO, store in the appropriate axis register and write in corresponding FIFO
    begin
        if (i_Byte_Count == 2 && Load == 1)
        begin
            X_Data_Ready <= 1;
            X_Data <= Accel_Data;
        end
        else if (i_Byte_Count == 1 && Load == 1)
        begin
            Y_Data <= Accel_Data;
            Y_Data_Ready <= 1;
        end
        else if (i_Byte_Count == 0 && Load == 1)
        begin
            Z_Data <= Accel_Data;
            Z_Data_Ready <= 1;
        end
        else
        begin
            X_Data_Ready <= 0;
            Y_Data_Ready <= 0;
            Z_Data_Ready <= 0;
        end
    end
    
    always@(posedge clk)                //Transmit data from axis FIFO through UART, go to next when finished. Pop corresponding FIFO.
    begin
        X_read_ready <= 0;
        Y_read_ready <= 0;
        Z_read_ready <= 0;
        if (Axis_Counter == 3)
        begin
            DataOut <= 16'b1111111111111111;
            if (wordComplete)
            begin
                Axis_Counter <= Axis_Counter + 1;
            end
        end
        if (Axis_Counter == 2)
        begin
            DataOut <= Z_DataOut;
            if (wordComplete)
            begin
                Axis_Counter <= Axis_Counter + 1;
                Z_read_ready <= 1;
            end
        end
        if (Axis_Counter == 1)
        begin
            DataOut <= Y_DataOut;
            if (wordComplete)
            begin
                Axis_Counter <= Axis_Counter + 1;
                Y_read_ready <= 1;
            end
        end
        if (Axis_Counter == 0)
        begin
            DataOut <= X_DataOut;
            if (wordComplete)
            begin
               Axis_Counter <= Axis_Counter + 1;
               X_read_ready <= 1;  //Shifts next word into DataOut
            end
        end     
    end

    SPI_FIFO X_Data_FIFO(.clk(clk), .write_ready(X_Data_Ready), .read_ready(X_read_ready), .Rx_DataIn(X_Data), .Rx_DataOut(X_DataOut),
    .EMPTY(EMPTY_X), .FULL(FULL_X), .SM(X_SM));
    
    SPI_FIFO Y_Data_FIFO(.clk(clk), .write_ready(Y_Data_Ready), .read_ready(Y_read_ready), .Rx_DataIn(Y_Data), .Rx_DataOut(Y_DataOut),
    .EMPTY(EMPTY_Y), .FULL(FULL_Y), .SM(Y_SM));
    
    SPI_FIFO Z_Data_FIFO(.clk(clk), .write_ready(Z_Data_Ready), .read_ready(Z_read_ready), .Rx_DataIn(Z_Data), .Rx_DataOut(Z_DataOut),
    .EMPTY(EMPTY_Z), .FULL(FULL_Z), .SM(Z_SM));
    

    
endmodule

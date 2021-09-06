`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 04:12:53 PM
// Design Name: 
// Module Name: Axis_Data_Router
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


module Axis_Data_Router(  //FIFO to UART Tx

    input clk,
    input show_X,
    input show_Y,
    input show_Z,
    input Load,
    input wire [15:0] DataIn,
    
    input [1:0] i_Byte_Count,
    output reg [15:0] DataOut,
    output reg [15:0] X_Data,
    output reg [15:0] Y_Data,
    output reg [15:0] Z_Data,
    output reg Data_Ready
    );
      
    reg [1:0] axis_number;
    
  
    always@(posedge clk)
    begin
        if (i_Byte_Count == 2 && Load == 1)
        begin
            Data_Ready <= 1;
            X_Data <= DataIn;
        end
        else if (i_Byte_Count == 1 && Load == 1)
        begin
            Y_Data <= DataIn;
            Data_Ready <= 1;
        end
        else if (i_Byte_Count == 0 && Load == 1)
        begin
            Z_Data <= DataIn;
            Data_Ready <= 1;
        end
        else
            Data_Ready <= 0;
    end
    
    always@(posedge clk)
    begin
        if (show_X)
            DataOut <= X_Data;
        else if (show_Y)
            DataOut <= Y_Data;
        else if (show_Z)
            DataOut <= Z_Data;
        else
            DataOut <= 0;
    end

endmodule
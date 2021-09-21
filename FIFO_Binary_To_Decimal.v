`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/02/2021 10:39:54 PM
// Design Name: 
// Module Name: FIFO_Binary_To_Decimal
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


module FIFO_Binary_To_Decimal(      //Rearranges raw axis data into 10-bit binary, with bits in correct order
    
    input [15:0] Accel_Data,
    output wire [15:0] Tx_Data

    );

    wire [9:0] Decimal_Data;
    wire [2:0] reg0_practical;
    wire [7:0] reg1_practical;
    wire [7:0] reg0;
    wire [7:0] reg1;
    
    assign reg0 = Accel_Data [15:8];
    assign reg1 = Accel_Data [7:0];
    
    assign reg0_practical[2:0] = reg0[7:5];
    assign reg1_practical = reg1[6:0];
    
    assign Decimal_Data [9:3] = reg1_practical;
    assign Decimal_Data [2:0] = reg0_practical;
    
    assign Tx_Data [15:10] = 6'b000000;
    assign Tx_Data [9:0] = Decimal_Data;

endmodule

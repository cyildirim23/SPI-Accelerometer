`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2021 10:10:23 AM
// Design Name: 
// Module Name: Binary_to_Decimal
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


module Binary_to_Decimal(
    
    input [15:0] Accel_Data,
    input clk,
    input Load,
    
    output wire [9:0] Decimal_Data
    
    );
    
    reg SM;
    
    parameter IDLE = 0;
    parameter LOAD = 1;
    
    wire [7:0] reg0;
    wire [7:0] reg1;
    
    assign reg0 = Accel_Data [15:8];
    assign reg1 = Accel_Data [7:0];
    
    wire [1:0] reg0_practical;
    wire [7:0] reg1_practical;
    
    assign reg0_practical = reg0 [15:14];
    assign reg1_practical = reg1 [0:7];
    
    assign Decimal_Data [9:2] = reg0_practical;
    assign Decimal_Data [1:0] = reg1_practical;
    
endmodule

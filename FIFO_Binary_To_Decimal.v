`timescale 1ns / 1ps
/*
This module does the first part of the Binary to Decimal module; it rearranges the 16-bit (10-bit usable) acceleration data into
the correct order. The module gets synthesized away (since it is only wire assignments), but it is used as a module for design readability.
See "Binary_to_Decimal.v" for details
*/


module FIFO_Binary_To_Decimal(      
    
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

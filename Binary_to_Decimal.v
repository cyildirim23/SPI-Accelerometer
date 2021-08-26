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
    
    output reg [3:0] ones,
    output reg [3:0] tens,
    output reg [3:0] hundreds,
    output reg [3:0] thousands,
    output wire [9:0] Decimal_Data,
    output wire [1:0] reg0_practical,
    output wire [7:0] reg1_practical
    );
    
    reg SM = 0;
    reg [9:0] binary;

    reg [3:0] counter;
    parameter IDLE = 0;
    parameter CONVERT = 1;
    
    wire [7:0] reg0;
    wire [7:0] reg1;
    
    assign reg0 = Accel_Data [15:8];
    assign reg1 = Accel_Data [7:0];
    
   
    
    assign reg0_practical[1] = reg0[6];
    assign reg0_practical[0] = reg0[7];
    
    assign reg1_practical = reg1;
    
    assign Decimal_Data [9:2] = reg1_practical;
    assign Decimal_Data [1:0] = reg0_practical;
    
    integer i;
    
    always@(Decimal_Data)
    begin
        ones = 4'd0;
        tens = 4'd0;
        hundreds = 4'd0;
        thousands = 4'd0;
        for(i = 9; i>=0; i = i-1)
        begin
            if (ones >= 5)
                ones = ones + 3;
            if (tens >= 5)
                tens = tens + 3;
            if (hundreds >= 5)
                hundreds = hundreds + 3;
            if (thousands >= 5)
                thousands = thousands + 3;
                
            thousands = thousands << 1;
            thousands[0] = hundreds[3];
                
            hundreds = hundreds << 1;
            hundreds[0] = tens[3];
            
            tens = tens << 1;
            tens[0] = ones[3];
            
            ones = ones << 1;
            ones[0] = Decimal_Data[i];
        end

    end

    
    /*
    always@(posedge clk)
    begin
        case (SM)
        0:
        begin
            if (Load)
            begin
                SM <= CONVERT;
                binary <= Decimal_Data;
            end
        end
        1:
        begin
            if (ones >= 5)
                ones <= ones + 3;
            if (tens >= 5)
                tens <= tens + 3;
            if (hundreds >= 5)
                hundreds <= hundreds + 3;
            if (thousands >= 5)
                thousands <= thousands + 3;
            binary[9:1] <= binary [8:0];
            ones[3:1] <= ones[2:0];
            ones[0] <= binary[9];
            tens[3:1] <= tens[2:0];
            tens[0] <= ones[3];
            hundreds[3:1] <= hundreds[2:0];
            hundreds[0] <= tens[3];
            thousands[3:1] <= thousands[2:0];
            thousands[0] <= hundreds[3];
            counter <= counter - 1;
            if (counter == 0)
            begin
                counter <= 9;
                SM <= IDLE;
            end
        end
        endcase
    end

    */
endmodule

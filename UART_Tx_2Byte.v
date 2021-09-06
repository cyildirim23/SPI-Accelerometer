`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2021 03:52:13 PM
// Design Name: 
// Module Name: UART_Tx_2Byte
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


module UART_Tx_2Byte(

    input clk,
    input [15:0] Accel_Data,
    input Load,
    input Enable_Pulse,
    
    output Tx_Serial,
    output wire [7:0] r_Tx_Parallel,
    output reg DataCount = 0,
    output reg [7:0] Byte = 0,
    output wire Tx_Complete,
    output wire [7:0] Byte1,
    output wire [7:0] Byte2,
    output wire [2:0] SM,
    output reg wordComplete = 0,
    output reg [1:0] Tx_Count = 0,
    output reg Enable,
    output wire Enable_Tx_Pulse
    );
    
    //output wire [7:0] Byte1;
    //output wire [7:0] Byte2;
    
    assign Byte1 = Accel_Data [15:8];
    assign Byte2 = Accel_Data [7:0];
    
    always@(posedge clk)
    begin
        if (Tx_Complete)
            Tx_Count <= Tx_Count + 1;
        if (Tx_Count == 2)
        begin
            wordComplete <= 1;
            Tx_Count <= 0;
        end
        else
            wordComplete <= 0;
    end
    
    always@(posedge clk)
    begin
        if ((Tx_Count ==  1) || (Enable_Pulse))
            Enable <= 1;
        else
            Enable <= 0;
    end
    
    always@(posedge clk)
    begin
        if (Tx_Count == 0)
        begin
            Byte <= Byte1;
        end
        else if (Tx_Count == 1)
        begin
            Byte <= Byte2;
        end
    end 
    
    //Pulse Tx_Enable (.switch(Enable), .clk(clk), .switch_out(Enable_Tx_Pulse));
    
    UART_Tx_Debug Accel_Data_Tx(.clk(clk), .Enable(Enable), .Tx_Serial(Tx_Serial), .Tx_Complete(Tx_Complete),
   .Tx_Parallel(Byte));
   
endmodule

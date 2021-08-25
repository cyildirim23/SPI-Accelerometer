`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2021 12:35:53 PM
// Design Name: 
// Module Name: Byte_Display
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


module Byte_Display(                     //This module is responsible for displaying the mode, last received byte
                                    //(in hex, if the device is in receive mode) and the next byte to send 
       
    input clk,                                //(if the device is in transmit mode) 
    input wire [15:0] Rx_Data,           //Array which holds the most recently stored word  (Displayed in Rx mode)          //Array which holds the next word to be sent (Displayed in Tx mode)
    input wire [1:0] Array,
    
    output reg [7:1] C,         //Array responsible for the lighting of each individual segment for a 7-seg display
    output reg [3:0] AN         //Array responsible for controlling which displays are in use 
    );                          //(displaying the current value of C)
    
    //for both Rx_Data and Tx_Data, each array is split in two. Each part is used to determine a hex digit
    
    wire [3:0] halfbyte_1;     
    wire [3:0] halfbyte_2; 
    wire [3:0] halfbyte_3;     
    wire [3:0] halfbyte_4;      

    
    assign halfbyte_1 = Rx_Data[3:0];
    assign halfbyte_2 = Rx_Data[7:4];
    assign halfbyte_3 = Rx_Data[11:8];
    assign halfbyte_4 = Rx_Data[15:12];
    

    
    parameter nine = 7'b0010000;                //Values of C corresponding to the different numbers and letters used
    parameter eight = 7'b0000000;               //in displaying hex values
    parameter seven = 7'b1111000;
    parameter six = 7'b0000010;
    parameter five = 7'b0010010;
    parameter four = 7'b0011001;
    parameter three = 7'b0110000;
    parameter two = 7'b0100100;
    parameter one = 7'b1111001;
    parameter zero = 7'b1000000;
    parameter A = 7'b0001000;
    parameter b = 7'b0000011;
    parameter c = 7'b1000110;
    parameter d = 7'b0100001;
    parameter E = 7'b0000110;
    parameter F = 7'b0001110;
    parameter S = 7'b0010010;
    parameter r = 7'b1001110;
    
    always@(Array)
    begin
        case(Array)                         //Displays the first hex character, then the second, then the "r" 
        0:                                  //while in receive mode. Happens fast enough for all to appear at once
        begin
            AN = 4'b0111;
            case(halfbyte_1)
               4'b0000:    C = zero;
                4'b0001:    C = one;
                4'b0010:    C = two;
                4'b0011:    C = three;
                4'b0100:    C = four;
                4'b0101:    C = five;
                4'b0110:    C = six;
                4'b0111:    C = seven;
                4'b1000:    C = eight;
                4'b1001:    C = nine;
                4'b1010:    C = A;  
                4'b1011:    C = b;
                4'b1100:    C = c;
                4'b1101:    C = d;
                4'b1110:    C = E;
                4'b1111:    C = F;
            endcase
        end  
        1:
        begin 
            AN = 4'b1011;
            case(halfbyte_2)
                4'b0000:    C = zero;
                4'b0001:    C = one;
                4'b0010:    C = two;
                4'b0011:    C = three;
                4'b0100:    C = four;
                4'b0101:    C = five;
                4'b0110:    C = six;
                4'b0111:    C = seven;
                4'b1000:    C = eight;
                4'b1001:    C = nine;
                4'b1010:    C = A;  
                4'b1011:    C = b;
                4'b1100:    C = c;
                4'b1101:    C = d;
                4'b1110:    C = E;
                4'b1111:    C = F;
            endcase
        end
        2:
        begin
            AN = 4'b1101;
            case(halfbyte_3)
                4'b0000:    C = zero;
                4'b0001:    C = one;
                4'b0010:    C = two;
                4'b0011:    C = three;
                4'b0100:    C = four;
                4'b0101:    C = five;
                4'b0110:    C = six;
                4'b0111:    C = seven;
                4'b1000:    C = eight;
                4'b1001:    C = nine;
                4'b1010:    C = A;  
                4'b1011:    C = b;
                4'b1100:    C = c;
                4'b1101:    C = d;
                4'b1110:    C = E;
                4'b1111:    C = F;
            endcase
        end
        3:
        begin
            AN = 4'b1110;
            case(halfbyte_4)
                4'b0000:    C = zero;
                4'b0001:    C = one;
                4'b0010:    C = two;
                4'b0011:    C = three;
                4'b0100:    C = four;
                4'b0101:    C = five;
                4'b0110:    C = six;
                4'b0111:    C = seven;
                4'b1000:    C = eight;
                4'b1001:    C = nine;
                4'b1010:    C = A;  
                4'b1011:    C = b;
                4'b1100:    C = c;
                4'b1101:    C = d;
                4'b1110:    C = E;
                4'b1111:    C = F;
            endcase
        end
        endcase     
    end
endmodule        

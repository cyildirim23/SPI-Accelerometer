`timescale 1ns / 1ps
/*
This module is responsible for driving the 7 seg display. On each refresh (signalled by the Byte_Display_selector), a 
new array is lit with the corresponding character. Due to the refresh rate, the 7 seg display appears to be displaying
all arrays with the proper character at the same time
*/

module Byte_Display(                    

    input [3:0] ones,                       //Ones input from B_t_D
    input [3:0] tens,                       //Tens input from B_t_D
    input [3:0] hundreds,                   //Hundreds input from B_t_D
    input [3:0] thousands,                  //Thousands input from B_t_D      
    input wire [1:0] Array,                 //Array input from display selector. Indicates which AN (7seg index) is lit

    output reg [7:1] C,                     //Array responsible for the lighting of each individual segment of the current 7-seg AN
    output reg [3:0] AN                     //Array responsible for controlling which AN value is lit 
    );                          
      
    wire [3:0] halfbyte_1;
    wire [3:0] halfbyte_2;
    wire [3:0] halfbyte_3;
    wire [3:0] halfbyte_4;
                                            //Each half-byte is assigned a power of 10 to display (from -2000mGs to 2000mGs)
    assign halfbyte_1 = thousands;
    assign halfbyte_2 = hundreds;
    assign halfbyte_3 = tens;
    assign halfbyte_4 = ones;
    
    parameter nine = 7'b0010000;                //Values of C corresponding to the different numbers and letters used
    parameter eight = 7'b0000000;                
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
    parameter minus = 7'b0111111;
    
    always@(Array)
    begin
        case(Array)                         
        0:                                      //When Array is 0, display the correct thousands digit in the leftmost array
        begin
            AN = 4'b0111;
            case(thousands)
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
        1:                                      //When Array is 1, display the correct hundreds digit in the second leftmost array
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
        2:                                      //When Array is 2, display the correct tens digit in the second rightmost array
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
        3:                                      //When Array is 3, display the correct ones digit in the rightmost array
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
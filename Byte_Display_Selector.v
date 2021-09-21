`timescale 1ns / 1ps
/*
This module is responsible for refreshing the 7 seg display. On each refresh, one of the 4 arrays is lit with a different
character (given by Byte_Display)
*/


module Byte_Display_Selector(   
    input clk,                  
    output reg [1:0] Array);    
                                
    reg [20:0] counter = 0;     
    
    always@(posedge clk)
    begin
        counter <= counter + 1;
        if (counter == 400_000)     //Every 400_000 clocks, increment Array
        begin
            counter <= 0;
            Array <= Array + 1;
        end
    end
endmodule
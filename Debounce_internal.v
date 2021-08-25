`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2021 09:41:14 PM
// Design Name: 
// Module Name: Debounce_internal
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


module Debounce_internal(
    input switch_in,
    input clk,
    output reg switch_out   //Debounced output
    );         
    
    reg [19:0] counter = 0;
    parameter debounce_limit = 40;
    
    
    always@(posedge clk)
    begin
       if (switch_in == 1)                  //if switch input is high, increment counter
           counter <= counter + 1;
       if (counter == debounce_limit)       //after 1_000_000 consecutive high input samples
       begin                                //(input is stable high), output is set to 1
           switch_out <= 1;
           counter <= 0;
       end
       else if (switch_in == 0)
       begin
           switch_out <= 0;
           counter <= 0;
       end
   end
endmodule

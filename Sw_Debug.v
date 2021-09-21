module Sw_Debug(                //This module lights up the LEDs corresponding to a user's input 
                                //(where the input is a byte to be stored in the FIFO)
    input  switch,         //Input byte (each switch represents a bit)
    input clk,
    output reg LED       //LEDs for each bit
);
    
    always@(posedge clk)
        LED <= switch;

    
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2021 12:01:00 PM
// Design Name: 
// Module Name: Fast_clk_slow_pulse
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


module Fast_clk_slow_pulse(input switch, clk, output reg switch_out); 
                                //This module creates a pulse from an input switch. If a switch is
                                //Turned on, the output stays on for 2 clock cycles, the returns to 0
    reg pulse = 0;              //Output
    reg [4:0] counter  = 0;            //Used to determine how long pulse lasts
    reg lock = 0;               //Used to keep the output at 0 after a pulse, if the input is still high
    
    parameter pulse_length = 25; // number of clock cycles the pulse will last
    
    always@(posedge clk)
    begin
        switch_out <= pulse;
        if (switch == 1 && lock == 0)
        begin
            pulse <= 1;
            counter <= counter + 1;
            if (counter == pulse_length)           //This condition is met one clock cycle after high input begins
            begin
                lock <= 1;
                pulse <= 0;
                counter <= 0;     
            end
        end
        else if (switch == 0)           //If input goes back to 0, turn lock off, output goes to 0.
        begin
            lock <= 0;
            pulse <= 0;
        end
    end
endmodule

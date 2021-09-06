`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/28/2021 01:05:30 AM
// Design Name: 
// Module Name: Enable_Pulse
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


module Enable_Pulse(
    input switch, 
    input clk, 
    output reg switch_out = 0,
    output reg [1:0] SM = 0                               //This module creates a pulse from an input switch. If a switch is
    );      
                                //Turned on, the output stays on for 2 clock cycles, the returns to 0
    reg [12:0] counter = 0;            //Used to determine how long pulse lasts
    //output reg [1:0] lock = 0;               //Used to keep the output at 0 after a pulse, if the input is still high
    
    
    
    
    parameter pulse_length = 875; //Sets pulse width (number of clock cycles for one pulse)
    
    always@(posedge clk)
    begin
        case (SM)
        0:
        begin
            if (switch == 1)
            begin
                switch_out <= 1;
                SM <= 1;
            end
            else
            begin
                SM <= 0;
            end
            counter <= 0;
        end
        1:
        begin
            counter <= counter + 1;
            if (counter == pulse_length / 2)
            begin
                switch_out <= 0;
                counter <= 0;
                SM <= 2;
            end
            else
            begin
                SM <= 1;
            end
        end
        2:
        begin
            switch_out <= 0;
            if (!switch)
            begin
                SM <= 0;
            end
            else
            begin
                SM <= 2;
            end
        end
        endcase
    end
endmodule

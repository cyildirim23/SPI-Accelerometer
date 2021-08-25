`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2021 01:30:02 AM
// Design Name: 
// Module Name: Byte_S_t_P
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


module Byte_S_t_P(                    //UART Receiver
    input clk,
    input MISO,                //Serial input 
    input CS,               
    output reg [7:0] Rx_Data,       //Parallel data output to FIFO
    
    output reg r_DV = 0             //Data valid ("receive complete" marker)
    );
    
    parameter clks_per_bit = 25;   //# of clocks per bit for a baud rate of 115200 on 
                                    //xc7a35t basys 3 FPGA (100 MHz clock)   set to 868 for 115200 Baud
    parameter IDLE = 3'b000;        //Different states                       
    parameter DATA = 3'b001;
       
   
    reg [9:0] clk_count = 0;
    reg [2:0] bitIndex = 0;     //Data is sent one byte at a time, calling for 8 indices (one index per bit)
    reg [7:0] r_Rx_Data = 0;    //Stores parallel data, shifted into parallel output if valid
    reg SM = IDLE;           //Holds the current state
    
    always@(posedge clk)
    begin
        if (r_DV == 1)                  //if r_DV is ever set to 1 (data has been received)
            Rx_Data = r_Rx_Data;        
        case(SM)
        IDLE:
        begin
            clk_count <= 0;
            bitIndex <= 0;
            r_DV <= 0;
            if (CS == 0) //If chip select enabled
                SM <= DATA;                   //Go to "DATA" state
            else
                SM <= IDLE;                     //Else, stay in idle
        end
        DATA:      //packages serial data into bytes
        begin
            if (clk_count < (clks_per_bit - 1)/ 2)      //If too early to sample bit
            begin                                   
                clk_count <= clk_count + 1;
                SM <= DATA;             
            end
            else                                //Increment clk_count until clks_per_bit / 2 is reached
            begin  
                r_Rx_Data[bitIndex] <=                              //and stay in current state (START)
                bitIndex <= bitIndex + 1;
                SM <= START;
            end
        end
        DATA:                                   //This state stores each bit in an internal reg
        begin                                   //Each full clks_per_bit cycle from here will end mid-bit
            if (clk_count < clks_per_bit)
            begin                               //Make clk_count == clks_per_bit
                clk_count <= clk_count + 1;     
                SM <= DATA;
            end
            else                                    //Once clk_count == clks_per_bit
            begin
                r_Rx_Data[bitIndex] <= Rx_Serial;   //Store the current serial value in the current index 
                clk_count <= 0;                     //of the internal reg
                if (bitIndex < 7)
                begin                               //While max bit index (7) hasn't been reached, repeat above
                    bitIndex = bitIndex + 1;        //with the next index of the internal reg
                    SM <= DATA;
                end
                else                                //Once internal reg is full, reset bitIndex, proceed
                begin                               //to "STOP" state
                    bitIndex <= 0;
                    SM <= STOP;
                end
            end
        end
        STOP:                               //Same idea as "START"; sample where the middle of the next bit would be
        begin
            if (clk_count < clks_per_bit)
            begin
                clk_count <= clk_count + 1;
                SM <= STOP;
            end
            else
            begin
                if(Rx_Serial == 1'b1)       //If the sampled value is 1, the stop bit has ben received
                begin                       //reset clk_count, set r_DV to 1, proceed to "CLEAN" state
                    clk_count <= 0;
                    r_DV = 1;
                    SM <= CLEAN;
                end
            end
        end
        CLEAN:                              //set r_DV back to 0, go to "IDLE"
        begin
           SM <= IDLE;
        end
       
       default : SM <= IDLE;
       
       endcase
    end
    
endmodule

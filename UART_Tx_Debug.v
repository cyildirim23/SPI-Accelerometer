`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/23/2021 02:58:15 PM
// Design Name: 
// Module Name: UART_Tx_Debug
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


module UART_Tx_Debug(            
    input clk,
    input Enable,            //Enable, when == 1, sends the current parallel input as a serial output         
    input [7:0] Tx_Parallel_1, //Parallel input, to be sent serially
    input [7:0] Tx_Parallel_2,
    output reg Tx_Serial,
    output reg [2:0] SM = 0,
    output reg [14:0] clk_count = 0,
    output reg [4:0] bitIndex = 0,
    output reg Data_Ready = 0,
    output reg DataCount = 0,
    output reg [7:0] r_Tx_Parallel_1 = 0,
    output reg pulseCounter);    //Serial output
    //output reg read_enable);  //Used by FIFO to clear a byte after the byte to be transmitted has
                              //been read and stored in the transmitter
    parameter clks_per_bit = 10416; 
    
    //reg DataCount = 0;
    
    parameter IDLE = 3'b000;
    parameter LOAD = 3'b001;
    parameter START = 3'b010;
    parameter DATA = 3'b011;
    parameter STOP = 3'b100;
    
    
            //used to count clock cycles, to output bits for the proper # of clock cycles
    //reg [2:0] bitIndex = 0;         //Bit index, used when serializing data
                   //Represents current state
    //reg [7:0] r_Tx_Parallel_1 = 0;    //Internal register. Holds parallel data when Enable is active
    
    //reg pulseCounter = 0;
    
    
    always@(posedge clk)
    begin
        case(SM)
            0:      //Waits for enable signal
            begin
                DataCount = 0;
                Tx_Serial <= 1;             //Serial output is driven high when not transmitting
                if(pulseCounter == 1)   
                    Data_Ready <= 1;
                if (Enable == 1)
                begin
                    pulseCounter <= 0;
                    Data_Ready <= 0;
                    //read_enable <= 1;   //Set read_enable to 1, proceed to "LOAD" state
                    SM <= LOAD;
                end
                else
                    SM <= IDLE;
            end
            1: //LOAD           loads input
            begin
                if (DataCount == 0)
                    r_Tx_Parallel_1 <= Tx_Parallel_1; //Parallel input is loaded to internal reg
                else
                    r_Tx_Parallel_1 <= Tx_Parallel_2;
                SM <= START;                 //Proceed to "START" state
            end
            2: //START     sends a start bit
            begin
                //read_enable <= 0;       
                Tx_Serial <= 0;                     //Serial out is driven low for for 868 clocks
                if (clk_count < clks_per_bit - 1)
                begin
                    clk_count <= clk_count + 1;
                    SM <= START;
                end
                else                                //After above is done, proceed to "DATA" state, reset clk count
                begin
                    SM <= DATA;
                    clk_count <= 0;
                end
            end
            3:      //Data      sends each bit of data
            begin
                Tx_Serial <= r_Tx_Parallel_1[bitIndex];
                if (clk_count < clks_per_bit - 1)              //for 868 clocks, drive the output with the current
                begin                                          //index of the internal reg
                    SM <= DATA;
                    clk_count <= clk_count + 1;
                end
                else                                            //After, increment the index and repeat until
                begin                                           //the last bit is transmitted
                    if (bitIndex < 7)
                    begin
                        bitIndex <= bitIndex + 1;
                        clk_count <= 0;
                        SM <= DATA;
                    end
                    else 
                    begin                                       //After all indices have been transmitted, 
                        bitIndex <= 0;                          //proceed to "STOP" state
                        clk_count <= 0;
                        SM <= STOP;
                    end
                end
            end  
           
            4:      //Sends a stop bit, then returns to IDLE
            begin
                Tx_Serial <= 1;
                if (clk_count < clks_per_bit - 1)
                begin
                    clk_count <= clk_count + 1;
                    SM <= STOP;
                end
                else
                begin
                    DataCount <= 1;
                    clk_count <= 0;
                    if (DataCount == 1)
                    begin
                        SM <= IDLE;
                        pulseCounter <= 1;
                    end
                    else
                        SM <= LOAD;
                    clk_count <= 0;
                   /*
                    case(Enable)        //This case statement ensures that the data is sent once. 
                    0:                  
                    begin               
                        clk_count <= 0;
                        SM <= IDLE;
                    end
                    1:
                        SM <= STOP;
                    endcase
                        */
                end
            end
   
            default: SM <= IDLE;
        endcase
    end
endmodule
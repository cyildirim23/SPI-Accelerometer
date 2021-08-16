`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2021 10:12:32 PM
// Design Name: 
// Module Name: SPI_FIFO
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
module SPI_FIFO(                   //This module is for a FIFO. It stores any words received by the receiver
                                    //or any user-inputted byte, and reads them oldest first                              
    input Master_clk,
    input wire write_ready, //Pulse sent once a byte is requested
    input wire read_ready, //Pulse sent once a full byte is received by MASTER
    input wire [7:0] Rx_dataIn,  
    output [7:0] Rx_DataOut,   //UART receiver input

    //output [7:0] r_Display_Data,    //Holds the most recently stored word for display purposes (displayed in Rx mode)
    output reg EMPTY = 1,           //Used to tell if FIFO is empty. Linked to an LED
    output reg FULL = 0);            //Used to tell if FIFO is full. Linked to an LED  //Used to update EMPTY and FULL flags
    
    reg [3:0] counter = 0;
    reg [1:0] SM = 0;
    reg [7:0] FIFO [3:0];   //FIFO is 8 bits deep, 4 words wide
    reg [2:0] readCount = 0;    //Keeps track of how many read processes 
    reg [2:0] writeCount = 0;   //Keeps track of how many write processes
    
    
    parameter IDLE = 2'b00;     //Different states
    parameter WRITE = 2'b01;
    parameter READ = 2'b10;
    
    integer i;
    
    assign Rx_DataOut = FIFO[0];  
    
    
    always@(posedge Master_clk)
    begin
        case(SM)
        0:              //IDLE
        begin
            if (write_ready == 1 && FULL != 1)
                                              //If in receive mode, and the FIFO isn't full, go to WRITE
                SM <= WRITE;
            else if (read_ready == 1 && EMPTY != 1)  //If in transmit mode, and the FIFO isn't empty, go to READ
                SM <= READ;
            else
                SM <= IDLE;
        end
        1:             //WRITE
        begin
            if(FULL)                            //If FIFO is full, go to IDLE, reset readCount, go to IDLE
            begin
                readCount <= 0;
                SM <= IDLE;
            end
            else
            begin
                FIFO[counter] <= Rx_dataIn;
                counter <= counter + 1;
                SM <= IDLE;    
            end                  
        end
        2:          //READ
        begin
            if(EMPTY)                   //If FIFO is empty, reset writeCount, go to IDLE
            begin
                writeCount <= 0;
                SM <= IDLE;
            end  
            else         
            begin
                for(i=0; i <= 2; i = i+1)
                begin  
                    FIFO[i] <= FIFO[i + 1]; 
                end
                if(counter == 1)
                    FIFO[0] <= 8'b00000000;                       
                counter <= counter - 1; //Decrement counter                     
                SM <= IDLE;      
           end                         //Go to IDLE
        end
        endcase
        
        case(counter)               //EMPTY/FULL flags updated according to counter
            0:
            begin
                EMPTY <= 1;
                FULL <= 0;
            end
            4:
            begin
                EMPTY <= 0;
                FULL <= 1;
            end
            default:
            begin
                EMPTY <= 0;
                FULL <= 0;
            end
        endcase
    end
endmodule
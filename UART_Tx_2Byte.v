`timescale 1ns / 1ps
/*
Wrapper for the UART Tx module. Controls what data is transmitted via UART. Since axis data is held in 16 bits, this
module is needed to send each 8-bit part of each axis data half-word
*/


module UART_Tx_2Byte(

    input clk,                  
    input [15:0] Accel_Data,                                //Axis data input. Holds two bytes to be sent via UART
    input DB_Enable_Switch,                                 //Debounced switch input. Enables UART stream
    
    output Tx_Serial,                                       //UART Tx output
    output reg wordComplete = 0                             //Signal telling FIFO management when to change output data to new axis
    );
    
    wire [7:0] Byte1;                                       //First byte of Accel_Data to send over UART
    wire [7:0] Byte2;                                       //Second byte of Accel_Data to send over UART
    
    wire Tx_Complete;                                       //Signal that gets pulsed once a trasmission is complete. Increments Tx_Count
    
    reg [7:0] Byte;                                         //Current byte being sent over UART
    reg [1:0] Tx_Count = 0;                                 //Number of transmissions completed. 2 means a full half-word of accel data has been transmitted
    reg Enable;                                             //Tx Enable
        
    assign Byte1 = Accel_Data [15:8];                       //Byte 1 and 2 are assigned different halves of currrent acceleration data 
    assign Byte2 = Accel_Data [7:0];
    
    always@(posedge clk)
    begin
        if (Tx_Complete)                                    //Tx counter is incremented when a Tx_Complete pulse is detected
            Tx_Count <= Tx_Count + 1;
        if (Tx_Count == 2)                                  //If 2 bytes have been sent by UART, pulse wordComplete to change axes in FIFO management
        begin
            wordComplete <= 1;
            Tx_Count <= 0;                                  //Reset Tx counter
        end
        else
            wordComplete <= 0;
    end
    
    always@(posedge clk)
    begin
        if ((Tx_Count ==  1) || (DB_Enable_Switch))         //If UART is in the middle of sending a half-word, or enable switch is high
            Enable <= 1;                                    //Continue transmitting data
        else
            Enable <= 0;
    end
    
    always@(posedge clk)
    begin
        if (Tx_Count == 0)                                  //If no bytes have been sent, send the first byte
        begin
            Byte <= Byte1;
        end
        else if (Tx_Count == 1)                             //If one byte has been sent, send the second
        begin
            Byte <= Byte2;
        end
    end 
    
    UART_Tx_Debug Accel_Data_Tx(.clk(clk), .Enable(Enable), .Tx_Serial(Tx_Serial), .Tx_Complete(Tx_Complete),
   .Tx_Parallel(Byte));
   
endmodule

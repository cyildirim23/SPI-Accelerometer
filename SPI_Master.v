`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2021 11:51:25 AM
// Design Name: 
// Module Name: SPI_Master
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

//8-20-2021
//Current setup is "ready" to deal with multi-byte transactions. The changes made in this regard are compatible with single-byte transactions (reading device ID)
//Functionality of multi-byte transactions is unknown.

module SPI_Master(

    input clk,  //(top in)
    input MISO, // MISO stream (top in) (slave out)
    input CS1, // chip select (top in)
    
    input wire [7:0] Byte_Command,
    input wire [3:0] bytes_to_read,
    input wire [3:0] bytes_to_write,
    input wire MB,
    input ten_bit, 
    output reg CMD_OUT = 0,
    
    output reg CS = 1, // chip select used by slave & master (top out)
    output reg MOSI, //MOSI stream (top out) 
    output reg spi_clk = 1,
    
    output reg [15:0] MISO_Data, //Parallelized MISO, to store in FIFO
  
    output reg [3:0] MI_bitIndex = 7,
    output reg [2:0] MO_bitIndex = 7,
    output reg [6:0] clk_count = 0,
    output reg [2:0] SM = 0,
    output reg MO_Byte_Complete,
    input wire [3:0] MI_IndexReset,
    output reg MI_Byte_Complete = 0,
    output reg [1:0] i_Byte_Count = 0,
    output reg [1:0] o_Byte_Count = 0,
    output wire Load,
    output reg [15:0] r_MISO_Data = 0
    );          
    
    assign Load = MI_Byte_Complete;

    reg [7:0] r_MOSI_Data;
    reg [1:0] BCcount = 0;
            
    //Configure CPOL and CPHA
    
    parameter clks_per_masterclk = 100; //4MHz master clk
    
    //reg [2:0] bitIndex = 0;
    //reg write_trigger = 0;
    //reg read_trigger = 0;
    
   
   
    
   reg off_after_complete = 0;
   //reg MI_Byte_Complete = 0;
   
   
   //reg [3:0] o_Byte_Count = 0;
   
    
    parameter t_delay = 2;
    parameter IDLE = 0;
    parameter CS_ASSERT = 1;
    parameter COMMUNICATION = 2;
    parameter CS_DEASSERT = 3;
    
    always@(posedge clk)
    begin
        if (BCcount == 1)
            MI_Byte_Complete <= 0;
        case(SM)
        IDLE:
        begin
            spi_clk <= 1;
            if (CS1 == 1)
            begin
                SM <= CS_ASSERT;
                clk_count <= 0;
            end
        end  
        CS_ASSERT:
        begin
            if (CS1 == 1)       //chip select enabled, begin communication needs 5ns before Master_clk toggles for first time          
            begin
                if (clk_count == t_delay)
                begin
                    clk_count <= ((clks_per_masterclk - 1)/2) - t_delay;
                    SM <= COMMUNICATION;
                    CS <= 0;
                    MI_bitIndex <= MI_IndexReset;
                    o_Byte_Count <= bytes_to_write;
                    i_Byte_Count <= bytes_to_read;
                    CMD_OUT <= 0;
                end
                else
                begin
                    clk_count <= clk_count + 1;   
                    SM <= CS_ASSERT;
                end
            end
            else
                SM <= CS_ASSERT;
        end     
        COMMUNICATION:
        begin
            if (MI_Byte_Complete)
            begin
                MISO_Data <= r_MISO_Data;
            end
            else if (!MI_Byte_Complete)
            if (o_Byte_Count == 0 && i_Byte_Count == 0)// || (!CS1 && o_Byte_Count == 0 && i_Byte_Count == 0))
            begin
                clk_count <= 0;
                SM <= CS_DEASSERT;
                spi_clk <= 1;
            end
            else //Just added
            begin
                if (clk_count == (clks_per_masterclk - 1)/ 2)     //Generate Master clock
                begin
                    clk_count <= 0;
                    spi_clk <= ~spi_clk;
                    if (spi_clk && !(o_Byte_Count == 0))    //negedge spi_clk, output next bit to MOSI
                    begin
                        MOSI <= Byte_Command[MO_bitIndex];
                        MO_bitIndex <= MO_bitIndex - 1;
                        if(MO_bitIndex > 0)
                        begin
                            MO_Byte_Complete <= 0;
                        end
                        else
                        begin
                            o_Byte_Count <= o_Byte_Count - 1;
                            MO_Byte_Complete <= 1;
                            if (bytes_to_write > 1)  
                                CMD_OUT <= ~CMD_OUT;
                        end         
                    end    
                    else if (!spi_clk && !(i_Byte_Count == 0) && o_Byte_Count == 0)//(posedge spi_clk, sample MISO
                    begin
                        r_MISO_Data[MI_bitIndex] <= MISO;
                        if (MI_bitIndex > 0)
                        begin
                            MI_bitIndex <= MI_bitIndex - 1;
                            MI_Byte_Complete <= 0;
                        end
                        else
                        begin
                            MI_bitIndex <= MI_IndexReset;
                            MI_Byte_Complete <= 1;
                            i_Byte_Count <= i_Byte_Count - 1;
                        end
                    end
                end
                else if (clk_count != (clks_per_masterclk - 1)/ 2)
                begin
                    clk_count <= clk_count + 1;
                end
            end
        end
        CS_DEASSERT:
        begin
            if (clk_count == t_delay)
            begin
                CMD_OUT <= 0;
                clk_count <= 0;
                CS <= 1;
                MISO_Data <= 0;
                r_MISO_Data = 0;
                MO_bitIndex <= 7;
                MI_bitIndex <= MI_IndexReset;
                MO_Byte_Complete <= 0;
                MI_Byte_Complete <= 0;
                off_after_complete <= 0;
                if (CS1)
                    SM <= CS_ASSERT;
                else 
                    SM <= IDLE;    
            end
            else
            begin
                SM <= CS_DEASSERT;
                clk_count <= clk_count + 1; 
            end  
        end     
        endcase
    end
    
    always@(posedge clk)
    begin
        if (MI_Byte_Complete || BCcount == 1)
            BCcount <= BCcount + 1;
        if (BCcount == 1)
            BCcount <= 0;
    end
        
endmodule

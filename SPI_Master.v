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


module SPI_Master(

    
    input clk,  //(top in)
    input MISO, // MISO stream (top in) (slave out)
    input CS1,
    
    output reg CS = 1, // chip select used by slave & master (top out)
    output reg MOSI, //MOSI stream (top out) 
    output reg spi_clk = 1,
    
    input [7:0] Byte_Command,
    input [3:0] bytes_to_read,
    input ten_bit,
    
    output reg [9:0] MISO_Data, //Parallelized MISO, to store in FIFO
    //output reg byte_write = 0, //ready to write MISO data to FIFO (FIFO in)
    //output reg byte_read = 0, //ready to read from FIFO (FIFO in)
    output reg [3:0] MI_bitIndex = 7,
    output reg [3:0] MO_bitIndex = 7,
    output reg [6:0] clk_count = 0,
    output reg [1:0] SM = 0,
    output reg [3:0] i_Byte_Count
    );          
            
    //Configure CPOL and CPHA
    reg [3:0] MI_reset;
    
    parameter clks_per_masterclk = 100; //4MHz master clk
    
    //reg [2:0] bitIndex = 0;
    //reg write_trigger = 0;
    //reg read_trigger = 0;
    
    //
    always@(ten_bit)
    begin
        if (ten_bit)
        begin
            MI_reset = 9;
        end
        else
        begin
            MI_reset = 7;
        end
    end
    
    reg [7:0] r_MOSI_Data;
    
    reg off_after_complete = 0;
    reg MO_Byte_Complete = 0;
    reg MI_Byte_Complete = 0;
    
    //reg [3:0] i_Byte_Count;
    reg [3:0] o_Byte_Count;
    parameter t_delay = 2;
    
    parameter IDLE = 0;
    parameter CS_ASSERT = 1;
    parameter COMMUNICATION = 2;
    parameter CS_DEASSERT = 3;
    
    reg CS_Reassert = 0;
    
    always@(Byte_Command)
    begin
        CS_Reassert = Byte_Command[1];
    end
    
   always@(posedge clk)
   begin
        if (!CS1)
        begin
            off_after_complete <= 1;
        end
        if (CS1)
        begin
            off_after_complete <= 0;
        end    
        case(SM)
        IDLE:
        begin
            spi_clk <= 1;
            if (CS1 == 1)
            begin
                i_Byte_Count <= bytes_to_read;
                o_Byte_Count <= bytes_to_read;
                SM <= CS_ASSERT;
                clk_count <= 0;
            end
        end  
        CS_ASSERT:
        begin
            if (clk_count == t_delay)
            begin
                clk_count <= ((clks_per_masterclk - 1)/2) - t_delay;
                SM <= COMMUNICATION;
                CS <= 0;
            end
            else
            begin
                clk_count <= clk_count + 1;   
            end
        end     
        COMMUNICATION:
        begin
            if (!CS1)
            begin
                
            end
            if (i_Byte_Count == 0)
            begin
                clk_count <= 0;
                i_Byte_Count <= bytes_to_read;
                SM <= CS_DEASSERT;
            end
            begin
                if (clk_count == (clks_per_masterclk - 1)/ 2)     //Generate Master clock
                begin
                    clk_count <= 0;
                    spi_clk <= ~spi_clk;
                    if (spi_clk)// && !(MO_Byte_Complete && !CS1))    //negedge spi_clk, output next bit to MOSI
                    begin
                        if (i_Byte_Count > 0)
                        begin
                            MO_bitIndex <= MO_bitIndex - 1;
                        end
                        if (i_Byte_Count <= o_Byte_Count - 1)
                        begin
                            MOSI <= 0;
                        end
                        if (i_Byte_Count > o_Byte_Count - 1)
                        begin
                            MOSI <= Byte_Command[MO_bitIndex];   
                        end
                        if (i_Byte_Count == 0)
                        begin
                            i_Byte_Count <= bytes_to_read;
                            if (off_after_complete)
                            begin
                                SM <= CS_DEASSERT;
                            end
                        end
                        if (MO_bitIndex == 0)
                        begin
                            MO_Byte_Complete <= 1;
                        end
                        if (MO_bitIndex != 0)
                        begin
                            MO_Byte_Complete <= 0;   
                        end      
                    end    
                    else if (!spi_clk) //&& !(i_byte_count == 0 && !CS1))//(posedge spi_clk, sample MISO
                    begin
                        MISO_Data[MI_bitIndex] <= MISO;
                        MI_bitIndex <= MI_bitIndex - 1;
                        if (MI_bitIndex > 0)
                        begin
                            MI_Byte_Complete <= 0;
                        end
                        else
                        begin
                            i_Byte_Count <= i_Byte_Count - 1;
                            MI_Byte_Complete <= 1;
                        end
                    end
                end
                else
                begin
                    clk_count <= clk_count + 1;
                end
            end
        end
        CS_DEASSERT:
        begin
            if (clk_count == t_delay)
            begin
                MO_bitIndex <= 7;
                MI_bitIndex <= MI_reset;
                clk_count <= ((clks_per_masterclk - 1)/2);
                CS <= 1;
                MISO_Data <= 0;
                MO_Byte_Complete <= 0;
                MI_Byte_Complete <= 0;
                i_Byte_Count <= bytes_to_read;
                o_Byte_Count <= bytes_to_read;
                if (CS_Reassert)
                begin
                    clk_count <= 0;
                    SM <= CS_ASSERT;
                end
                else 
                begin
                    clk_count <= 0;
                    SM <= IDLE;
                end
            end
            else
            begin
                clk_count <= clk_count + 1; 
            end  
        end     
        endcase
    end
    
endmodule

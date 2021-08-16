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
    input Test_Switch,  //Input to send to slave (top in)
    input MISO, // MISO stream (top in) (slave out)
    input CS1, // chip select (top in)
    
    output reg CS = 1, // chip select used by slave & master (top out)
    output reg MOSI, //MOSI stream (top out) 
    output reg spi_clk = 1,
    output reg old_spi_clk = 0, //(top out) (FIFO in) 
    
    output reg [7:0] MISO_Data, //Parallelized MISO, to store in FIFO
    output reg byte_write = 0, //ready to write MISO data to FIFO (FIFO in)
    output reg byte_read = 0, //ready to read from FIFO (FIFO in)
    output reg [3:0] MI_bitIndex = 7,
    output reg [3:0] MO_bitIndex = 7,
    output reg [6:0] clk_count = 0,
    output reg [1:0] SM = 0
    );          
    
    reg [7:0] Byte_Command = 0;
            
    //Configure CPOL and CPHA
    
    parameter clks_per_masterclk = 100; //4MHz master clk
    
    //reg [2:0] bitIndex = 0;
    //reg write_trigger = 0;
    //reg read_trigger = 0;
    
    
 /*   always@(old_spi_clk && !spi_clk)
    begin
        if(bitIndex > 0)
        begin
            byte_write <= 0;
            byte_read <= 0;
            MOSI <= Byte_Command[bitIndex];
            MISO_Data[bitIndex] <= MISO;
            bitIndex <= bitIndex - 1;
        end
        else
        begin
            byte_write <= 1;
            byte_read <= 1;
            MOSI <= Byte_Command[bitIndex];
            MISO_Data[bitIndex] <= MISO;
            bitIndex <= 7;  
        end         
    
    end
    
   */ 
   reg [7:0] r_MOSI_Data;
    
   reg off_after_complete = 0;
   reg MO_Byte_Complete = 0;
   reg MI_Byte_Complete = 0;
    
    parameter t_delay = 2;
    parameter CS_ASSERT = 0;
    parameter COMMUNICATION = 1;
    parameter CS_DEASSERT = 2;
    always@(posedge clk)
    begin
        if (Test_Switch)
            Byte_Command = 8'b00000001;
        if (!Test_Switch)
            Byte_Command = 8'b10000000;
        case(SM)
        CS_ASSERT:
        begin
            if (CS1 == 1)       //chip select enabled, begin communication needs 5ns before Master_clk toggles for first time          
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
                    SM <= CS_ASSERT;
                end
            end
            else
                SM <= CS_ASSERT;
        end     
        COMMUNICATION:
        begin
            if (!CS1)
            begin
                off_after_complete <= 1;
                if (MO_Byte_Complete && MI_Byte_Complete)
                begin
                    clk_count <= 0;
                    SM <= CS_DEASSERT;
                end
            end
            begin
                if (clk_count == (clks_per_masterclk - 1)/ 2)     //Generate Master clock
                begin
                    clk_count <= 0;
                    spi_clk <= ~spi_clk;
                    if (spi_clk && !(MO_Byte_Complete && !CS1))    //negedge spi_clk, output next bit to MOSI
                    begin
                        if(MO_bitIndex > 0)
                        begin
                            MOSI <= Byte_Command[MO_bitIndex];
                            MO_bitIndex <= MO_bitIndex - 1;
                            MO_Byte_Complete <= 0;
                        end
                        else
                        begin
                            MOSI <= Byte_Command[MO_bitIndex];
                            MO_bitIndex <= 7;
                            MO_Byte_Complete <= 1;  
                        end         
                    end    
                    else if (!spi_clk && !(MI_Byte_Complete && !CS1))//(posedge spi_clk, sample MISO
                    begin
                        if (MI_bitIndex > 0)
                        begin
                            MI_Byte_Complete <= 0;
                            byte_write <= 0;
                            MISO_Data[MI_bitIndex] <= MISO;
                            MI_bitIndex <= MI_bitIndex - 1;
                        end
                        else
                        begin
                            MI_Byte_Complete <= 1;
                            byte_write <= 1;
                            MISO_Data[MI_bitIndex] <= MISO;
                            MI_bitIndex <= 7;
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
                clk_count <= ((clks_per_masterclk - 1)/2);
                SM <= CS_ASSERT;
                CS <= 1;
                MISO_Data <= 0;
                MO_bitIndex <= 0;
                MI_bitIndex <= 0;
                MO_Byte_Complete <= 0;
                MI_Byte_Complete <= 0;
                off_after_complete <= 0;
            end
            else
            begin
                SM <= CS_DEASSERT;
                clk_count <= clk_count + 1; 
            end  
        end     
        endcase
    end
    
endmodule

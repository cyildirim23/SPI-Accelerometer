`timescale 1ns / 1ps
/*
This module is for the SPI Master. It handles writing data over MOSI at every negative edge of the SPI clock,
and saving data over MISO at every positive edge of the SPI clock.
*/

module SPI_Master(

    input clk,  
    input MISO,                             //MISO stream 
    input CS1,                              //chip select switch
    
    input wire [7:0] Byte_Command,          //Data to be transmitted to accelerometer
    input wire [3:0] bytes_to_read,         //half-words to be read after writing is complete
    input wire [3:0] bytes_to_write,        //bytes to read after CS is asserted
    
    output reg CMD_OUT = 0,                 //Toggles after a byte is sent to accelerometer. Tells wrapper to load next byte to write
    
    output reg CS = 1,                      //chip select used by slave & master
    output reg MOSI,                        //MOSI stream
    output reg spi_clk = 1,                 //SPI clock, used by slave & master
    
    output reg [15:0] MISO_Data,            //Parallelized MISO, to store in appropriate FIFO
    input wire [3:0] MI_IndexReset,         //Holds the first index number for MISO_Data to be reset to upon half-word read completion
    output reg [1:0] i_Byte_Count = 0,      //Holds the number of half-words (or bytes, depending on mode) that have been read during the current transaction. Used to
                                            //store received acceleration data in proper FIFO (see Accel_FIFO_Management)
    output wire Load                        //Sends a pulse to appropriate FIFO once a half-word or byte has been saved (synchronized with MI_Byte_Complete)
    
    );          
    
    reg [1:0] BCcount = 0;                  //MI_Byte_Complete counter. Used to generate a 2 clock cycle wide pulse
     
    reg [15:0] r_MISO_Data = 0;             //Holds MISO data as it is received
    reg [1:0] o_Byte_Count = 0;             //Holds number of bytes left to transmit
    
    reg MO_Byte_Complete = 0;               //Pulse signal, goes high once a full byte or half-word has been received from MISO
    reg MI_Byte_Complete = 0;               //Pulse signal, goes high once a byte has been written to MOSI
    
    reg [2:0] SM = 0;                       //Holds the current state
    reg [9:0] clk_count = 0;                //Holds number of clock cycles. Used to implement necessary delays, and generate SPI clock at correct frequency
    
    reg [2:0] MO_bitIndex = 7;              //Holds the current bit index of the byte being written to MOSI
    reg [3:0] MI_bitIndex = 7;              //Holds the current bit index of the byte/half-word being read from MISO
    
    parameter clks_per_masterclk = 1000;    //100KHz master clk
    parameter t_delay = 2;                  //Generates the correct delay for CS assertion and deassertion, outlined by ADXL345 documentation
                                            
    parameter IDLE = 0;                     //Different states
    parameter CS_ASSERT = 1;
    parameter COMMUNICATION = 2;
    parameter CS_DEASSERT = 3;
    
    assign Load = MI_Byte_Complete;         //Different name assignment used for output signal for clarity (designates when data is loaded in FIFO management)
    
    always@(posedge clk)
    begin
        
        if (MI_Byte_Complete)
            BCcount                     <= BCcount + 1;
        if (BCcount == 1)                                   //Can replace with a 2 clock cycle wide pulse for clarity
        begin
            BCcount                     <= 0;
            MI_Byte_Complete            <= 0;
        end
        
        case(SM)                    
        IDLE:                                                               //While in IDLE, drive spi_clk high (ADXL345 spec)
        begin
            spi_clk                     <= 1;
            if (CS1 == 1)
            begin
                SM                      <= CS_ASSERT;                       //Once CS1 switch is high, move to CS_ASSERT state
                clk_count               <= 0;
            end
        end  
        
        CS_ASSERT:                                                          //Applies a 5ns delay (ADXL345 spec) before asserting CS
        begin
            if (CS1 == 1)                                                   //chip select enabled, begin communication needs 5ns before Master_clk toggles for first time          
            begin
                if (clk_count == t_delay)                                   //Once delay is met, initialize registers and move to COMMUNICATION state
                begin
                    SM                  <= COMMUNICATION;
                    clk_count           <= ((clks_per_masterclk - 1)/2) - t_delay;
                    CS                  <= 0;                                      //Chip select active
                    MI_bitIndex         <= MI_IndexReset;                          //Load correct starting index
                    o_Byte_Count        <= bytes_to_write;                         //load # of bytes to write to slave from wrapper
                    i_Byte_Count        <= bytes_to_read;                          //load # of half-words/bytes to write to slave from wrapper
                    CMD_OUT             <= 0;                                      //Ensure byte of parameters is first message sent to slave
                end
                else                                                        //If delay isn't met, stay in current state, increment counter
                begin
                    clk_count           <= clk_count + 1;                         
                    SM                  <= CS_ASSERT;
                end
            end
        end     
        
        COMMUNICATION:                                                      //Drive SPI clock; communication between slave and master takes place
        begin
            if (MI_Byte_Complete)                                           //Once a full byte or half-word is received, load into MISO_Data register
            begin
                MISO_Data <= r_MISO_Data;
            end
            else                                                            //if byte isn't complete, continue sending/receiving data
            begin
                if (o_Byte_Count == 0 && i_Byte_Count == 0)                 //if all bytes to write are written, and all expected bytes/half-words are received,
                begin                                                       //deassert chip select
                    SM                  <= CS_DEASSERT;
                    clk_count           <= 0;
                    spi_clk             <= 1;
                end
                else 
                begin
                    if (clk_count == (clks_per_masterclk - 1)/ 2)                       //Generate Master clock. If # clock cycles passed, toggle clock, reset counter (Maybe use an actual clock?)
                    begin
                        clk_count               <= 0;
                        spi_clk                 <= ~spi_clk;
                        if (spi_clk && !(o_Byte_Count == 0))                            //negedge spi_clk, output next bit to MOSI
                        begin
                            MOSI                <= Byte_Command[MO_bitIndex];           //output current MOSI command bit to MOSI
                            MO_bitIndex         <= MO_bitIndex - 1;                     //Decrement bit index
                            if(MO_bitIndex > 0)
                            begin
                                MO_Byte_Complete <= 0;
                            end
                            else
                            begin
                                o_Byte_Count        <= o_Byte_Count - 1;
                                MO_Byte_Complete    <= 1;
                                
                                if (bytes_to_write > 1)                                 //If writing 2 bytes (writing to a reg on the accelerometer), send data to be written
                                    CMD_OUT         <= ~CMD_OUT;                        //Loads Byte_Command with data to write accelerometer register
                            end         
                        end    
                        else if (!spi_clk && !(i_Byte_Count == 0) && o_Byte_Count == 0) //posedge spi_clk, sample MISO
                        begin
                            r_MISO_Data[MI_bitIndex] <= MISO;                           //Store current value of MISO into MISO reg
                            if (MI_bitIndex > 0)
                            begin
                                MI_bitIndex          <= MI_bitIndex - 1;                //Decrement bit index
                                MI_Byte_Complete     <= 0;
                            end
                            else
                            begin
                                MI_bitIndex          <= MI_IndexReset;
                                MI_Byte_Complete     <= 1;                             //Mark byte as received, store byte in appropriate register, and load into appropriate FIFO
                                i_Byte_Count         <= i_Byte_Count - 1;
                            end
                        end
                    end
                    else if (clk_count != (clks_per_masterclk - 1)/ 2)                //If clks_per_masterclk isn't reached, increment clock count
                    begin
                        clk_count                    <= clk_count + 1;
                    end
                end
            end
        end
        
        CS_DEASSERT:                                //Deassert chip select
        begin
            if (clk_count == t_delay)               //If 5ns delay is met, reset signals and check CS switch for next state
            begin
                CMD_OUT                     <= 0;
                clk_count                   <= 0;
                CS                          <= 1;
                MISO_Data                   <= 0;
                r_MISO_Data                 <= 0;
                MO_bitIndex                 <= 7;
                MI_bitIndex                 <= MI_IndexReset;
                MO_Byte_Complete            <= 0;
                MI_Byte_Complete            <= 0;
                if (CS1)                                    //If switch is still on, repeat transaction
                    SM                      <= CS_ASSERT;
                else 
                    SM                      <= IDLE;        //If switch is off, return to IDLE
            end
            else
            begin
                SM                          <= CS_DEASSERT;
                clk_count                   <= clk_count + 1; 
            end  
        end     
        endcase
    end

endmodule

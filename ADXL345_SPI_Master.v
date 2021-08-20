`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2021 02:53:32 PM
// Design Name: 
// Module Name: ADXL345_SPI_Master
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


module ADXL345_SPI_Master(

    input format,
    input axis_data,    //top SPI
    input clk,  //(top in)
    input Test_Switch,  //Input to send to slave (top in) //top SPI
    input MISO, // MISO stream (top in) (slave out)
    input CS1, // chip select (top in)  top SPI
    
    output wire CS, // chip select used by slave & master (top out)
    output wire MOSI, //MOSI stream (top out) 
    output wire spi_clk,
    
    output wire [7:0] MISO_Data, //Parallelized MISO, to store in FIFO MAKE 9:0
    output wire [2:0] MI_bitIndex,
    output wire [2:0] MO_bitIndex,
    output wire [6:0] clk_count,
    output wire [1:0] SM,
    output wire [3:0] i_Byte_Count,
    output reg [3:0] bytes_to_read,
    output reg ten_bit = 0

    );
    
   // reg [3:0] bytes_to_read;
    reg [7:0] Byte_Command;
    
    always@(posedge clk)
    begin
        if (format)
        begin
            Byte_Command = 8'b00000100;
            bytes_to_read = 1;
            ten_bit = 0;
        end
        if (Test_Switch)
        begin
            Byte_Command = 8'b00000001;
            bytes_to_read = 1;   
            ten_bit = 0;      
        end
        else if (axis_data)
        begin
            Byte_Command = 8'b11110010; //SECOND TO RIGHTMOST BIT SHOULD BE 1
            bytes_to_read = 6;
            ten_bit = 1;
        end                     
    end
    
    SPI_Master Accel(.clk(clk), .CS1(CS1), .Byte_Command(Byte_Command), .bytes_to_read(bytes_to_read), .ten_bit(ten_bit),
    .MISO(MISO), .MOSI(MOSI), .MISO_Data(MISO_Data), .i_Byte_Count(i_Byte_Count), .spi_clk(spi_clk), .CS(CS),
    .MI_bitIndex(MI_bitIndex), .MO_bitIndex(MO_bitIndex), .clk_count(clk_count),
    .SM(SM));
    
endmodule

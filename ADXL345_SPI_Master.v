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
    input measure_mode,
    
    output wire CS, // chip select used by slave & master (top out)
    output wire MOSI, //MOSI stream (top out) 
    output wire spi_clk,
    
    output wire [15:0] MISO_Data, //Parallelized MISO, to store in FIFO MAKE 9:0
    output wire [3:0] MI_bitIndex,
    output wire [2:0] MO_bitIndex,
    output wire [6:0] clk_count,
    output wire [1:0] SM,
    output reg ten_bit = 0,
    output wire MO_Byte_Complete,
    output wire CMD_OUT,
    output wire MI_Byte_Complete,
    output reg [3:0] MI_IndexReset = 7,  
    output [1:0] i_Byte_Count,
    output Load,
    output wire [15:0] r_MISO_Data,
    output wire [1:0] o_Byte_Count,
    output reg [1:0] bytes_to_read,
    output reg [1:0] bytes_to_write
    );
    
   
    
   // reg [3:0] bytes_to_read;
    reg [7:0] Byte_Command; //Determines operation parameters: read/write, and address
    reg [7:0] w_Data;   //Determines the data to be written. Only used for write operations
    reg [7:0] Command_params;
    //reg [3:0] bytes_to_write;
    //reg [3:0] bytes_to_read;
    
    reg Byte_Out;
    
    
    always@(posedge clk)
    begin
        if (format)
        begin
            Command_params = 8'b00110001;
            w_Data = 8'b00000100;    
            bytes_to_read = 1;
            bytes_to_write = 2;
            ten_bit = 0;
        end
        else if (Test_Switch)    //read operation, no w_Data
        begin
            Command_params = 8'b10000000;
            w_Data = 8'b00000000;
            bytes_to_read = 1;
            bytes_to_write = 1;   
            ten_bit = 0;      
        end
        else if (axis_data)
        begin
            Command_params = 8'b11110010; //SECOND TO RIGHTMOST BIT SHOULD BE 1
            w_Data = 8'b00000000;
            bytes_to_read = 3;
            bytes_to_write = 1;
            ten_bit = 1;
        end
        else if (measure_mode)
        begin
            Command_params <= 8'b00101101;
            w_Data <= 8'b00001000;
            bytes_to_read <= 1;
            bytes_to_write <= 2;
            ten_bit <= 0;
        end
        else
        begin
            Command_params  = 8'b00000000;
            bytes_to_read = 1;
            ten_bit = 0;
        end                     
    end
    
    always@(posedge clk)
    begin
        if(ten_bit)
            MI_IndexReset = 15;
        else if(!ten_bit)
            MI_IndexReset = 7;
    end
    
    always@(posedge clk)
    begin
        if (!CMD_OUT && bytes_to_write > 1)
        begin
            Byte_Command <= Command_params;
        end
        else if (CMD_OUT && bytes_to_write > 1)
        begin
            Byte_Command <= w_Data;
        end
        else if (bytes_to_write == 1)
        begin
            Byte_Command <= Command_params;
        end
    end
    Debounce_internal Byte_Out_DB(.switch_in(Byte_Out), .clk(clk), .switch_out(Byte_Out_db));
    
    SPI_Master Accel(.clk(clk), .CS1(CS1), .Byte_Command(Byte_Command), .i_Byte_Count(i_Byte_Count), .bytes_to_read(bytes_to_read), .bytes_to_write(bytes_to_write),
    .ten_bit(ten_bit), .MISO(MISO), .MOSI(MOSI), .MISO_Data(MISO_Data), .spi_clk(spi_clk), .CS(CS), .CMD_OUT(CMD_OUT), .r_MISO_Data(r_MISO_Data), .o_Byte_Count(o_Byte_Count),
    .MI_bitIndex(MI_bitIndex), .MI_Byte_Complete(MI_Byte_Complete), .MO_bitIndex(MO_bitIndex), .clk_count(clk_count), .MO_Byte_Complete(MO_Byte_Complete), .MI_IndexReset(MI_IndexReset),
    .SM(SM), .Load(Load));
endmodule
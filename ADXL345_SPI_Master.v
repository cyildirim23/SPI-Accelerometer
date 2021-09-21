`timescale 1ns / 1ps
/*
This module is a control wrapper for the SPI master. It takes input switches to determine 
what data gets written to the accelerometer, how many bytes are read/written, and how MISO data is packed (16 bits for axis data reads)
(CS, MISO, MOSI, spi_clk, MISO_Data, i_Byte_Count are handled in SPI_Master module)
*/

/* READING AXIS DATA
When reading acceleration data from the accelerometer, the request has a "multi-byte" bit.
This bit makes the register address increment automatically after a register is read. The order of data registers is X0, X1, Y0, Y1, Z0, Z1. The first address
to be read from is the X0 address. After this address is read, the X1 address is read, then the Y0, and so on. After Z1 is read, if CS1 is still high, the same
process repeats after CS is reasserted. New acceleration values are read and stored in appropriate FIFOs.
*/


module ADXL345_SPI_Master(

    input clk,

    input format,                   //writes the data_format register
    input axis_data,                //reads from axis data registers
    input Test_Switch,              //Tells the accelerometer to send its device ID over MISO 
    input measure_mode,             //Sets accelerometer to active (measures and stores acceleration data)
    input rate_control,             //Sets accelerometer sampling rate
    
    input MISO,                     //MISO stream 
    input CS1,                      //chip select switch
    
    output wire CS,                 //chip select used by slave & master 
    output wire MOSI,               //MOSI stream 
    output wire spi_clk,            //net used for the SPI clock
    
    output wire [15:0] MISO_Data,   //Parallelized MISO, to store in FIFO
    output [1:0] i_Byte_Count,      //Specifies remaining number of words to read over MISO and 
                                    //Specifies which FIFO gets most recent axis data word, depending on value at Load pulse
                                        
    output wire Load                //Tells FIFO management when to load MISO_Data (single pulse)
    
    );
    
    wire CMD_OUT;                   //Determines which byte is sent: Command_params or w_Data
   
    reg [7:0] Byte_Command;         //Holds byte to be sent by SPI master
    reg [7:0] w_Data;               //Determines the data to be written. Only used for write operations
    reg [7:0] Command_params;       //Determines communication parameters (read/write, multi-byte, address)
    reg [3:0] bytes_to_write;       //Number of bytes the master will write
    reg [3:0] bytes_to_read;        //Number of bytes the master will read
    reg two_byte = 0;               //Tells the master to expect two bytes. When 0, master expects 1 byte
    reg [3:0] MI_IndexReset = 7;    //Determines the starting index of the r_MISO_Data register. 15 if "two_byte" is 1.
    
    always@(posedge clk)
    begin
        if (format)
        begin
            Command_params <= 8'b00110001;      //Specifies write to data format register
            w_Data <= 8'b00000100;              //Specifies left-justified data registers, +-2g accel mode
            bytes_to_read <= 1;                 //Master will read 1 word from slave after writing
            bytes_to_write <= 2;                //Master will write 2 bytes (Command_params, then w_Data) on CS assertion
            two_byte <= 0;                      //Master will expect 8-bit words
        end
        else if (Test_Switch)                   //If Device_ID switch is on
        begin
            Command_params <= 8'b10000000;      //Specifies read from Device ID register
            w_Data <= 8'b00000000;              //Writes nothing
            bytes_to_read <= 1;                 //Master will read 1 word from slave after writing
            bytes_to_write <= 1;                //Master will write 1 byte (Command_params)
            two_byte <= 0;                      //Master will expect 8-bit words  
        end
        else if (axis_data)                     //If axis_data switch is on
        begin
            Command_params <= 8'b11110010;      //Specifies multi-byte read (see "READING AXIS DATA" above) from first x-axis data register
            w_Data <= 8'b00000000;              //Writes nothing
            bytes_to_read <= 3;                 //Master will read 3 words from slave after writing
            bytes_to_write <= 1;                //Master will write 1 byte (Command_params)
            two_byte <= 1;                      //Master will expect 16-bit words
        end
        else if (measure_mode)                  //If measure_mode switch is on
        begin
            Command_params <= 8'b00101101;      //Specifies write to POWER_CTL register
            w_Data <= 8'b00001000;              //Sets measure bit of POWER_CTL register to 1, enabling measurements
            bytes_to_read <= 1;                 //Master will read 1 word from slave after writing
            bytes_to_write <= 2;                //Master will write 2 bytes (Command_params, then w_Data) on CS assertion
            two_byte <= 0;                      //Master will expect 8-bit words
        end
        else if (rate_control)                  //If rate_control switch is on
        begin
            Command_params <= 8'b00101100;      //Specifies write to BW_RATE register
            w_Data <= 8'b00001101;              //Writes a byte that sets sampling rate to 800Hz
            bytes_to_read <= 1;                 //Master will read 1 word from slave after writing
            bytes_to_write <= 2;                //Master will write 2 bytes (Command_params, then w_Data) on CS assertion
            two_byte <= 0;                      //Master will expect 8-bit words
        end
        else
        begin
            Command_params  <= 8'b00000000;
            bytes_to_read <= 1;
            two_byte <= 0;
        end                     
    end
    
    always@(posedge clk)                        //Makes sure to start writing at the appropriate index if reading axis data, or reading any other registers
    begin
        if(two_byte)                            //If reading axis data, both axis registers will be written to a 16-bit reg per axis. Start at index 15
            MI_IndexReset = 15;                 
        else                
            MI_IndexReset = 7;                  //Else, store MISO data 1 byte at a time
    end
    
    always@(posedge clk)
    begin
        if (!CMD_OUT)                           
        begin
            Byte_Command <= Command_params;     //Output byte is Command_params
        end
        else if (CMD_OUT)
        begin
            Byte_Command <= w_Data;             //Output byte is data to write to register
        end
    end
    
    SPI_Master Accel(.clk(clk), .CS1(CS1), .Byte_Command(Byte_Command), .i_Byte_Count(i_Byte_Count), .bytes_to_read(bytes_to_read), .bytes_to_write(bytes_to_write),
    .MISO(MISO), .MOSI(MOSI), .MISO_Data(MISO_Data), .spi_clk(spi_clk), .CS(CS), .CMD_OUT(CMD_OUT), 
    .MI_IndexReset(MI_IndexReset), .Load(Load));
    
endmodule
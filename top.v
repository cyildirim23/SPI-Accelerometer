`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2021 04:09:40 PM
// Design Name: 
// Module Name: top
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


module top(
    
    input clk,  //
    input CS1,  //
    
    //Slave-Master connections
     //
    output MOSI, //
    output spi_clk, //
    output CS,
    
    //input [7:0] Parallel_In, //
    input Test_Switch,
    input axis_data,
    input format,
    input measure_mode,
    
    output Test_SwitchLED,
    output axis_dataLED,
    output formatLED,
    output measure_modeLED,
    
    //Display outputs
    output [7:1] C,
    output [3:0] AN,
    
    input show_X,
    input show_Y,
    input show_Z,
    
    output show_XLED,
    output show_YLED,
    output show_ZLED,
    
    input Enable,
    output EnableLED,
    
    output Tx_Out,
    input read_ready,
    output read_readyLED,
    
    //Output LEDs
    input MISO
    
    );
    
    /*(* DONT_TOUCH = "TRUE" *) */ ADXL345_SPI_Master Accel(.clk(clk), .CS1(CS1), .Test_Switch(Test_Switch),
    .axis_data(axis_data), .measure_mode(measure_mode),
    .MISO(MISO), .MOSI(MOSI), .MISO_Data(SO_Data), .Load(Load_Data),
    .spi_clk(spi_clk), .CS(CS), .format(format), .i_Byte_Count(SI_Byte_Count));
    
    wire [7:0] Rx_DataOut1;
    wire [7:0] Rx_DataOut2;
    
    
    wire Load_Data;
    wire ten_bit;
    wire [1:0] Array;
    wire [3:0] i_Byte_Count;
    wire MI_Byte_Complete;
    wire read_pulse;
    wire write_pulse;
    
    wire [15:0] SO_Data;
    wire [15:0] Display_Data;
    
    wire [15:0] X_Data;
    wire [7:0] X_DataOut1;
    wire [7:0] X_DataOut2;
    
    wire [15:0] Y_Data;
    wire [7:0] Y_DataOut1;
    wire [7:0] Y_DataOut2;
    
    wire [15:0] Z_Data;
    wire [7:0] Z_DataOut1;
    wire [7:0] Z_DataOut2;
    
    wire Axis_Data_Increment;
    wire Axis_Change;
   
    wire [15:0] o_X_Disp; 
    wire [15:0] o_Y_Disp; 
    wire [15:0] o_Z_Disp; 
    wire Enable_pulse;
    
    wire [1:0] SI_Byte_Count;
    
    
   /**/  
    
  /*  Sw_Debug TS (.switch(Test_Switch), .clk(clk), .LED(Test_SwitchLED));
    Sw_Debug AD (.switch(axis_data), .clk(clk), .LED(axis_dataLED));
    Sw_Debug F (.switch(format), .clk(clk), .LED(formatLED));
    Sw_Debug MM (.switch(measure_mode), .clk(clk), .LED(measure_modeLED));
    Sw_Debug X (.switch(show_X), .clk(clk), .LED(show_XLED));
    Sw_Debug Y(.switch(show_Y), .clk(clk), .LED(show_YLED));
    Sw_Debug Z(.switch(show_Z), .clk(clk), .LED(show_ZLED));
    Sw_Debug EN (.switch(Enable), .clk(clk), .LED(EnableLED));
    Sw_Debug RR (.switch(read_ready), .clk(clk), .LED(read_readyLED));
    */
    Byte_Display_Selector AN_Select(clk, Array);
     
    Byte_Display MISO_Display(.Rx_Data(Display_Data), 
    .clk(clk), .Array(Array), .C(C), .AN(AN));
    
    Axis_Data_Router (.clk(clk), .i_Byte_Count(SI_Byte_Count), 
    .show_X(show_X), .show_Y(show_Y), .show_Z(show_Z),
    .DataIn(SO_Data), .DataOut(Display_Data), .Load(Load_Data));
    
     //Debounce Command (.switch_in(CS1), .clk(clk), .switch_out(Load));//switch to see next word stored in FIFO
     //Debounce_Pulse Read_request (.switch_in(read), .clk(clk), .pulse_out(read_pulse));
    
endmodule
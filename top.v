`timescale 1ns / 1ps

module top(
    
    input clk, 
    
    //SPI connections
    input CS1,
    output CS,
    output MOSI, 
    output spi_clk,
    input MISO,
    
    
    //Accelerometer control switches
    input Test_Switch,
    input axis_data,
    input format,
    input measure_mode,
    input rate_control,
    
    //Display outputs
    output [7:1] C,         //7seg array bits
    output [3:0] AN,        //7seg array select bits
    output sign,
    
    //Switches for displaying respective axis data on 7seg display
    input show_X,
    input show_Y,
    input show_Z,
    
    input Enable,
    
    output Tx_Out,
    
    //Output LEDs
    output EnableLED,
    output show_XLED,
    output show_YLED,
    output show_ZLED,
    output Test_SwitchLED,
    output axis_dataLED,
    output formatLED,
    output measure_modeLED

    );
    
    wire [1:0] Array;
    wire [1:0] i_Byte_Count;
    
    wire [15:0] MISO_Data;
    
    wire [15:0] Axis_Data;
    wire [15:0] FIFO_Axis_Data;
    wire [15:0] Tx_Data;
    
    wire [3:0] ones_data;
    wire [3:0] tens_data;
    wire [3:0] hundreds_data;
    wire [3:0] thousands_data;
    
    ADXL345_SPI_Master Accel(.clk(clk), .CS1(CS1), .Test_Switch(Test_Switch),
    .axis_data(axis_data), .measure_mode(measure_mode),
    .MISO(MISO), .MOSI(MOSI), .MISO_Data(MISO_Data), .Load(Load_Data),
    .spi_clk(spi_clk), .CS(CS), .format(format), .rate_control(rate_control), .i_Byte_Count(i_Byte_Count));
   
    Sw_Debug TS (.switch(Test_Switch),      .clk(clk),      .LED(Test_SwitchLED));
    Sw_Debug AD (.switch(axis_data),        .clk(clk),      .LED(axis_dataLED));
    Sw_Debug F (.switch(format),            .clk(clk),      .LED(formatLED));
    Sw_Debug MM (.switch(measure_mode),     .clk(clk),      .LED(measure_modeLED));
    Sw_Debug X (.switch(show_X),            .clk(clk),      .LED(show_XLED));
    Sw_Debug Y(.switch(show_Y),             .clk(clk),      .LED(show_YLED));
    Sw_Debug Z(.switch(show_Z),             .clk(clk),      .LED(show_ZLED));
    Sw_Debug EN (.switch(Enable),           .clk(clk),      .LED(EnableLED));
    
    Byte_Display_Selector AN_Select(clk, Array);

    Byte_Display MISO_Display
    (.ones(ones_data), .tens(tens_data), .hundreds(hundreds_data), .thousands(thousands_data),
    .Array(Array), .C(C), .AN(AN));
    
    Axis_Data_Router Router
    (.clk(clk), .i_Byte_Count(i_Byte_Count), .Load(Load_Data),
    .show_X(show_X), .show_Y(show_Y), .show_Z(show_Z), 
    .DataIn(MISO_Data), .DataOut(Axis_Data));
    
    Binary_to_Decimal BtD
    (.Accel_Data(Axis_Data), 
    .negative(sign), .ones(ones_data), .tens(tens_data), .hundreds(hundreds_data), .thousands(thousands_data));
     
    Accel_FIFO_Management Axis_Data_Unit
    (.clk(clk), .i_Byte_Count(i_Byte_Count),
     .Accel_Data(MISO_Data), .DataOut(FIFO_Axis_Data),
     .wordComplete(wordComplete), .Load(Load_Data));
    
    UART_Tx_2Byte Tx_Module
    (.clk(clk), .DB_Enable_Switch(DB_Enable_Switch), .Accel_Data(Tx_Data),
     .Tx_Serial(Tx_Out), .wordComplete(wordComplete)); 
    
    FIFO_Binary_To_Decimal Converter
    (.Accel_Data(FIFO_Axis_Data), .Tx_Data(Tx_Data));
    
    Debounce Tx_Enable (.switch_in(Enable), .clk(clk), .switch_out(DB_Enable_Switch));
    
endmodule
    
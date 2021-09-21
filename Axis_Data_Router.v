`timescale 1ns / 1ps
/*
This module stores the latest data for each axis (same method used in FIFO management, using i_Byte_Count) into its respective register
Depending on which switch is high (show_X, show_Y, show_Z), the data output is loaded with the corresponding axis data register.  
This data is now ready for conversion into decimal before being displayed
*/

module Axis_Data_Router(  

    input clk,
    input show_X,                                           //Input switch for loading data output with x data
    input show_Y,                                           //Input switch for loading data output with y data
    input show_Z,                                           //Input switch for loading data output with z data
    
    input [1:0] i_Byte_Count,                               //Input from SPI master, used for determining which axis the current input data belongs to
    input Load,                                             //Signals when to load input data to appropriate axis data register
    
    input wire [15:0] DataIn,                               //Input data stream (MISO)
    output reg [15:0] DataOut                               //Output data stream. Leads to B_t_D for conversion
    
    );
      
    reg [15:0] X_Data;                                      //Register for holding x data
    reg [15:0] Y_Data;                                      //Register for holding y data
    reg [15:0] Z_Data;                                      //Register for holding z data
    
    always@(posedge clk)
    begin
        if (i_Byte_Count == 2 && Load)                      //If most recent data read was y axis data, and byte is complete
            Y_Data              <= DataIn;                  //Store data input into y data register
        else if (i_Byte_Count == 1 && Load)                 //If most recent data read was x axis data, and byte is complete
            X_Data              <= DataIn;                  //Store data input into x data register
        else if (i_Byte_Count == 0 && Load)                 //If most recent data read was z axis data, and byte is complete
            Z_Data              <= DataIn;                  //Store data input into z data register
    end
    
    always@(posedge clk)
    begin
        if (show_X)                                         //If show_x switch is high, display x data
            DataOut <= X_Data;
        else if (show_Y)                                    //If show_y switch is high, display y data
            DataOut <= Y_Data;
        else if (show_Z)                                    //If show_z switch is high, display z data
            DataOut <= Z_Data;
        else
            DataOut <= 0;
    end

endmodule
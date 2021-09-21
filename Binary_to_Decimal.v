`timescale 1ns / 1ps
/*
This module takes 16-bit accelerometer data axis readings. It rearranges the bits to read MSB -> LSB,
then converts them from twos complement to decimal data, with 4 bits for each power of 10 that is used
*/


module Binary_to_Decimal(
    
    input [15:0] Accel_Data,                                                //Accelerometer axis data input
    
    output reg [3:0] ones,                                                  //Output half-byte, holding # of ones
    output reg [3:0] tens,                                                  //Output half-byte, holding # of tens
    output reg [3:0] hundreds,                                              //Output half-byte, holding # of hundreds
    output reg [3:0] thousands,                                             //Output half-byte, holding # of thousands
    output wire negative                                                    //Output negative boolean, assigned to MSB of rearranged 2's complement number    
    );
    
    wire [9:0] Decimal_Data;                                                //Reg holding ordered 10-bit 2's complement data. Used as a magnitude if MSb is 0
    wire [9:0] twos_complement;                                             //Reg holding a version of Decimal_Data, but with each bit flipped and 1'd1 added. Used as a magnitude if MSb is 1
    
    wire [7:0] reg0;                                                        //Reg holding most significant 8 bits of Accel_Data
    wire [7:0] reg1;                                                        //Reg holding least significant 8 bits of Accel_Data
    
    wire [2:0] reg0_practical;                                              //Section of reg0 with usable data (rest of bits are always 0 in +- 2G mode)
    wire [7:0] reg1_practical;                                              //Section of reg1 with usable data (reg1 will always contain 8 bits of acceleration data)
    
    wire [9:0] magnitude;                                                   //Holds the magnitude of the binary 2's complement number
    wire [11:0] acceleration;                                               //Holds the final decimal number, in mGs (magnitude multiplied by 4, since data is 3.9mGs/LSb
    
    integer i;                                                              //Integer used in for loop

    assign reg0 = Accel_Data [15:8];
    assign reg1 = Accel_Data [7:0];
    
    assign reg0_practical[2:0] = reg0[7:5];
    assign reg1_practical = reg1[6:0];
    
    assign Decimal_Data [9:3] = reg1_practical;
    assign Decimal_Data [2:0] = reg0_practical;
    
    assign negative = Decimal_Data[9];
    assign twos_complement = ~Decimal_Data + 1'd1;
    assign magnitude = negative ? twos_complement : Decimal_Data;
    assign acceleration = magnitude * 4;
    
    always@(acceleration)
    begin
                                                                            //Clear decimal output data
        ones = 4'd0;
        tens = 4'd0;
        hundreds = 4'd0;
        thousands = 4'd0;
        
        for(i = 9; i>=0; i = i-1)                                           //Binary to decimal algorithm
        begin
            if (ones >= 5)                                                  //If ones >= 5, add 3
                ones = ones + 3;
            if (tens >= 5)                                                  //If tens >= 5, add 3
                tens = tens + 3;
            if (hundreds >= 5)                                              //If hundreds >= 5, add 3
                hundreds = hundreds + 3;
            if (thousands >= 5)                                             //If thousands >= 5, add 3
                thousands = thousands + 3;
                
            thousands = thousands << 1;                                     //Shift thousands left one bit
            thousands[0] = hundreds[3];                                     //Shift MSb of hundreds into LSb of thousands
                
            hundreds = hundreds << 1;                                       //Shift hundreds left one bit
            hundreds[0] = tens[3];                                          //Shift MSb of tens into LSb of hundreds
            
            tens = tens << 1;                                               //Shift tens left one bit
            tens[0] = ones[3];                                              //Shift MSb of ones into LSb of tens
            
            ones = ones << 1;                                               //Shift ones left one bit
            ones[0] = acceleration[i];                                      //Shift MSb of acceleration into LSb of thousands
        end

    end
endmodule

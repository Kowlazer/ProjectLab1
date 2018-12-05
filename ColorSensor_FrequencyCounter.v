`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2018 04:36:20 PM
// Design Name: 
// Module Name: FrequencyCounter
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


module FrequencyCounter(
    input CLK100MHZ,
    input freq_on,
    input sensor,
    
    output reg [20:0] frequency = 21'b0,
    output reg freq_done = 0
    );
    
    reg[31:0] second = 32'b0;
    reg[20:0] counter = 21'b0;
    
    reg previous = 0;
    reg sensor1 = 0;
    reg sensor2 = 0;
    reg sensor3 = 0;
    
    parameter sixteenth = 6_250_000;
    
    always @ (posedge CLK100MHZ)  //flip flop to sync incoming signal with clock
    begin
        sensor1 <= sensor;
        sensor2 <= sensor1;
        sensor3 <= sensor2;
    end
    
    always @ (posedge CLK100MHZ)
        previous <= sensor3;
    
    always @ (posedge CLK100MHZ)
        if(~freq_on)  //reset when on signal is low
            begin
            frequency = 0;
            counter = 0;
            second = 0;
            freq_done = 0;
            end
        else
            begin
            if (second < sixteenth) //if 1/16th of a second has not yet passed
                begin
                second = second + 1;
                if ((previous == 0) && (sensor3 == 1)) //count high edges
                    begin
                    counter = counter + 1;
                    end
                end
            else 
                begin
                frequency = 0;
                frequency = counter * 16;  //multiply counted edges by 16 for actual frequency
                counter = 0;
                second = 0;
                freq_done = 1;
                end
            end
endmodule

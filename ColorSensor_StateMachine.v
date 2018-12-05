`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/18/2018 11:33:25 AM
// Design Name: 
// Module Name: StateMachine
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


module StateMachine(
    input CLK100MHZ,
    input sensor,
    input SW0,
    input SW1,
    input SW2,
    input SW3,
    input SW4,
    input SW5,
    input SW6,
    
    output reg LED0,
    output reg LED1,
    output reg LED2,
    output reg LED3,
    output reg LED4,
    output reg LED5,
    output reg JA0,
    output reg JA1
    
    //output reg [5:0] detected_color
);

    reg [5:0] detected_color;
    wire freq_done; //done flag inputs from modules
    wire per_done;
    
    reg reset;   //reset output to percent cal
    
    reg freq_on;  //on outputs to modules
    reg per_on;
    
    reg [20:0] dividend;   //output dividend and divisor
    reg [20:0] divisor;   // to the percent calculator
    
    wire [20:0] frequency;  //freq from freq cal
    wire [9:0] percentage;  //percentage from per cal

    reg [5:0] calibrating_color = 0;
    reg [5:0] consistency_counter = 0;
    reg [5:0] previous_color = 0;
    reg [5:0] sensed_color = 0;
    reg [5:0] consistent_color = 0;
    //1 = Red Washer
    //2 = Blue Washer
    //3 = Green Washer
    //4 = Yellow Washer
    //5 = Nothing
    
    reg [8:0] RW_RF = 'd34;
    reg [8:0] RW_GF = 'd26;
    reg [8:0] RW_BF = 'd37;
    
    reg [8:0] BW_RF = 'd25;
    reg [8:0] BW_GF = 'd29;
    reg [8:0] BW_BF = 'd44;
    
    reg [8:0] GW_RF = 'd29;
    reg [8:0] GW_GF = 'd28;
    reg [8:0] GW_BF = 'd39;
    
    reg [8:0] YW_RF = 'd33;
    reg [8:0] YW_GF = 'd30;
    reg [8:0] YW_BF = 'd29;
    
    
    reg [20:0] Clear_Freq = 0;
    reg [20:0] Red_Freq = 0;
    reg [20:0] Green_Freq = 0;
    reg [20:0] Blue_Freq = 0;
    
    reg [8:0] Red_Percent = 0;
    reg [8:0] Green_Percent = 0;
    reg [8:0] Blue_Percent = 0;
    
    reg signed [9:0] RW_Red_Diff = 0;
    reg signed [9:0] RW_Green_Diff = 0;
    reg signed [9:0] RW_Blue_Diff = 0;
    reg signed [9:0] RW_Total_Diff = 0;
    
    reg signed [9:0] BW_Red_Diff = 0;
    reg signed [9:0] BW_Green_Diff = 0;
    reg signed [9:0] BW_Blue_Diff = 0;
    reg signed [9:0] BW_Total_Diff = 0;
    
    reg signed [9:0] GW_Red_Diff = 0;
    reg signed [9:0] GW_Green_Diff = 0;
    reg signed [9:0] GW_Blue_Diff = 0;
    reg signed [9:0] GW_Total_Diff = 0;
    
    reg signed [9:0] YW_Red_Diff = 0;
    reg signed [9:0] YW_Green_Diff = 0;
    reg signed [9:0] YW_Blue_Diff = 0;
    reg signed [9:0] YW_Total_Diff = 0;
    
    reg [6:0] state = 1;
    
    reg dummy = 0;
    reg dummy2 = 0;
    reg working = 1;
    reg r_cal = 0;
    reg g_cal = 0;
    reg b_cal = 0;
    reg y_cal = 0;
    
    
    //Frequency Counter instantiation
    FrequencyCounter Freq_Count(
        .CLK100MHZ(CLK100MHZ), //input
        .freq_on(freq_on),  //input
        .sensor(sensor),   //input
        
        .frequency(frequency), //output
        .freq_done(freq_done) //output
        );
    
    //Percent Calculator instantiation  
    PercentCalculator Percent_Cal(
        .CLK100MHZ(CLK100MHZ),  //input
        .reset(reset),          //input
        .dividend(dividend),    //input
        .divisor(divisor),      //input
        .per_on(per_on),        //input
        
        .per_done(per_done),    //output
        .percentage(percentage) //output
        );
    
    parameter      calibrate  = 0,
                   clear_f    = 1,
                   red_f      = 2,
                   red_per    = 3,
                   green_f    = 4,
                   green_per  = 5,
                   blue_f     = 6,
                   blue_per   = 7,
                   compare    = 8,
                   consistent = 9;
    
    always @ (posedge CLK100MHZ)
        if(dummy)
            begin
            JA1 = SW1;
            JA0 = SW0;
            end
        else
        case(state)
            calibrate: //calibration state to record new frequency values for each washer
                begin
                LED5 = 1;
                if(SW2 == 1 && SW3 == 0 && SW4 == 0 && SW5 == 0 && SW6 == 0 && calibrating_color == 0)
                    begin
                    LED5 = 0;
                    calibrating_color = 1;
                    state = clear_f;
                    end
                else if(SW2 == 1 && SW3 == 1  && SW4 == 0 && SW5 == 0 && SW6 == 0 && calibrating_color == 1)
                    begin
                    LED5 = 0; 
                    calibrating_color = 2;
                    state = clear_f;
                    end
                else if(SW2 == 1 && SW3 == 1 && SW4 == 1 && SW5 == 0 && SW6 == 0 && calibrating_color == 2)
                    begin
                    LED5 = 0;
                    calibrating_color = 3;
                    state = clear_f;
                    end
                else if(SW2 == 1 && SW3 == 1 && SW4 == 1 && SW5 == 1 && SW6 == 0 && calibrating_color == 3)
                    begin
                    LED5 = 0;
                    calibrating_color = 4;
                    state = clear_f;
                    end
                else if(SW2 == 1 && SW3 == 1 && SW4 == 1 && SW5 == 1 && SW6 == 1 && calibrating_color == 4)
                    begin
                    LED5 = 0;
                    calibrating_color = 0;
                    state = clear_f;
                    end
                else
                    begin
                    state = calibrate;
                    end
                end
                
            clear_f: 
                begin
                JA0 = 0;
                JA1 = 1;
                freq_on = 1;
                    if(freq_done)
                        begin
                        Clear_Freq = frequency;
                        freq_on = 0;
                        state = red_f;
                        end
                end
                    
           red_f:
                begin
                JA0 = 0;
                JA1 = 0;
                freq_on = 1;
                     if(freq_done)
                         begin
                         Red_Freq = frequency;
                         freq_on = 0;
                         state = red_per;
                         end
                end
                
          red_per:
                begin
                dividend = Red_Freq;
                divisor = Clear_Freq;
                per_on = 1;
                     if(per_done)
                            begin
                            Red_Percent = percentage;
                            if(calibrating_color == 1) //replace hardcoded values with calibrated values when the calibration flag is up
                                begin
                                RW_RF = percentage;
                                end
                            if(calibrating_color == 2)
                                begin
                                BW_RF = percentage;
                                end
                            if(calibrating_color == 3)
                                begin
                                GW_RF = percentage;
                                end
                            if(calibrating_color == 4)
                                begin
                                YW_RF = percentage;
                                end
                            per_on = 0;
                            state = green_f;
                            end
               end
               
           green_f:
                    begin
                    JA0 = 1;
                    JA1 = 1;
                    freq_on = 1;
                         if(freq_done)
                             begin
                             Green_Freq = frequency;
                             freq_on = 0;
                             state = green_per;
                             end
                    end
                    
          green_per:
                    begin
                    dividend = Green_Freq;
                    divisor = Clear_Freq;
                    per_on = 1;
                         if(per_done)
                                begin
                                Green_Percent = percentage;
                                if(calibrating_color == 1)
                                    begin
                                    RW_GF = percentage;
                                    end
                                if(calibrating_color == 2)
                                    begin
                                    BW_GF = percentage;
                                    end
                                if(calibrating_color == 3)
                                    begin
                                    GW_GF = percentage;
                                    end
                                if(calibrating_color == 4)
                                    begin
                                    YW_GF = percentage;
                                    end
 
                                per_on = 0;
                                state = blue_f;
                                end
                   end
                   
           blue_f:
                   begin
                   JA0 = 1;
                   JA1 = 0;
                   freq_on = 1;
                           if(freq_done)
                                 begin
                                 Blue_Freq = frequency;
                                 freq_on = 0;
                                 state = blue_per;
                                 end
                    end
                            
          blue_per:
                     begin
                     dividend = Blue_Freq;
                     divisor = Clear_Freq;
                     per_on = 1;
                            if(per_done)
                                begin
                                Blue_Percent = percentage;
                                if(calibrating_color == 1)  //return to the calibrating state for the rest of the washers
                                    begin
                                    RW_BF = percentage;
                                    state = calibrate;
                                    end
                                if(calibrating_color == 2)
                                    begin
                                    BW_BF = percentage;
                                    state = calibrate;
                                    end
                                if(calibrating_color == 3)
                                    begin
                                    GW_BF = percentage;
                                    state = calibrate;
                                    end
                                if(calibrating_color == 4)
                                    begin
                                    YW_BF = percentage;
                                    state = calibrate;
                                    end
                                per_on = 0;
                                state = compare;
                                end
                     end
                     
           compare:  //find total distance from the hardcoded or calibrated percentages
                begin
                
                //Red Washer Check
                RW_Red_Diff = RW_RF - Red_Percent;
                    if(RW_Red_Diff < 0)
                        begin
                        RW_Red_Diff = -RW_Red_Diff;
                        end
                RW_Green_Diff = RW_GF - Green_Percent;
                    if(RW_Green_Diff < 0)
                        begin
                        RW_Green_Diff = -RW_Green_Diff;
                        end
                RW_Blue_Diff = RW_BF - Blue_Percent;
                    if(RW_Blue_Diff < 0)
                        begin
                        RW_Blue_Diff = -RW_Blue_Diff;
                        end
                RW_Total_Diff = RW_Red_Diff + RW_Green_Diff + RW_Blue_Diff;
                
                //Blue Washer Check
                BW_Red_Diff = BW_RF - Red_Percent;
                    if(BW_Red_Diff < 0)
                        begin
                        BW_Red_Diff = -BW_Red_Diff;
                        end
                BW_Green_Diff = BW_GF - Green_Percent;
                    if(BW_Green_Diff < 0)
                        begin
                        BW_Green_Diff = -BW_Green_Diff;
                        end
                BW_Blue_Diff = BW_BF - Blue_Percent;
                    if(BW_Blue_Diff < 0)
                        begin
                        BW_Blue_Diff = -BW_Blue_Diff;
                        end
                BW_Total_Diff = BW_Red_Diff + BW_Green_Diff + BW_Blue_Diff;
                
                //Green Washer Check
                GW_Red_Diff = GW_RF - Red_Percent;
                    if(GW_Red_Diff < 0)
                        begin
                        GW_Red_Diff = -GW_Red_Diff;
                        end
                GW_Green_Diff = GW_GF - Green_Percent;
                    if(GW_Green_Diff < 0)
                        begin
                        GW_Green_Diff = -GW_Green_Diff;
                        end
                GW_Blue_Diff = GW_BF - Blue_Percent;
                    if(GW_Blue_Diff < 0)
                        begin
                        GW_Blue_Diff = -GW_Blue_Diff;
                        end
                GW_Total_Diff = GW_Red_Diff + GW_Green_Diff + GW_Blue_Diff;
                
                //Yellow Washer Check
                YW_Red_Diff = YW_RF - Red_Percent;
                    if(YW_Red_Diff < 0)
                        begin
                        YW_Red_Diff = -YW_Red_Diff;
                        end
                YW_Green_Diff = YW_GF - Green_Percent;
                    if(YW_Green_Diff < 0)
                        begin
                        YW_Green_Diff = -YW_Green_Diff;
                        end
                YW_Blue_Diff = YW_BF - Blue_Percent;
                    if(YW_Blue_Diff < 0)
                        begin
                        YW_Blue_Diff = -YW_Blue_Diff;
                        end
                YW_Total_Diff = YW_Red_Diff + YW_Green_Diff + YW_Blue_Diff;
                
                //Decision
                if(RW_Total_Diff < BW_Total_Diff && RW_Total_Diff < GW_Total_Diff && RW_Total_Diff < YW_Total_Diff)
                    begin
                    sensed_color = 'd1;
                    end
                if(BW_Total_Diff < RW_Total_Diff && BW_Total_Diff < GW_Total_Diff && BW_Total_Diff < YW_Total_Diff)
                    begin
                    sensed_color = 'd2;
                    end
                if(GW_Total_Diff < RW_Total_Diff && GW_Total_Diff < BW_Total_Diff && GW_Total_Diff < YW_Total_Diff)
                    begin
                    sensed_color = 'd3;
                    end
                if(YW_Total_Diff < RW_Total_Diff && YW_Total_Diff < BW_Total_Diff && YW_Total_Diff < GW_Total_Diff)
                    begin
                    sensed_color = 'd4;
                    end
                    
                state = consistent;
                end
                
         consistent:  //consistency checl
                begin
                    if(previous_color == 0)
                        begin
                        previous_color = sensed_color;
                        end
                    else
                        begin
                        if(previous_color == sensed_color)
                            begin
                            consistency_counter = consistency_counter + 1;
                            previous_color = sensed_color;
                            end
                        if(previous_color != sensed_color)
                            begin
                            consistency_counter = 0;
                            previous_color = sensed_color;
                            end
                        if(consistency_counter == 4)
                            begin
                            consistency_counter = 0;
                            consistent_color = sensed_color;
                            detected_color = consistent_color;
                            end
                        end
                   //LIGHT UP LEDS (for debug)
                   if(detected_color == 1)
                        begin
                        LED0 = 1;
                        LED1 = 0;
                        LED2 = 0;
                        LED3 = 0;
                        end
                   if(detected_color == 2)
                        begin
                        LED0 = 0;
                        LED1 = 1;
                        LED2 = 0;
                        LED3 = 0;
                        end
                   if(detected_color == 3)
                        begin
                        LED0 = 0;
                        LED1 = 0;
                        LED2 = 1;
                        LED3 = 0;  
                        end
                   if(detected_color == 4)
                        begin
                        LED0 = 0;
                        LED1 = 0;
                        LED2 = 0;
                        LED3 = 1;  
                        end
      
                   state = clear_f;
               end
      endcase    
endmodule

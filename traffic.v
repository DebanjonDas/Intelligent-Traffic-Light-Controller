module timer(
    input clk,reset,start,
    input [7:0]duration,
    output reg done
);
reg [7:0] count;
always@(posedge clk) begin
if(reset) begin
 count <=8'b0;
 done <=1'b0;
 end else begin
    if(start) begin
            count <= 8'b1;
            done  <= (duration <= 8'd1);
    end else if(count!=8'b0) begin
       if (count >= duration) begin
            count <= 8'b0;
            done  <= 1'b1;
       end
       else begin
       count<=count+8'd1;
        done<=1'b0;
        end
    end
    else done<=1'b0;
end
end
endmodule

module Traffic_fsm(
    input clk,reset,done,emergency_present,ped_request,night_mode,
    input [7:0] green_time,
    output reg start,
    output reg[7:0] timer_duration,
    output reg[3:0] state
);
reg [3:0] next_state;
parameter NS_G=4'b0000,NS_Y=4'b0001,ALL_R1=4'b0010,EW_G=4'b0011,EW_Y=4'b0100,ALL_R2=4'b0101,PED_WALK=4'b0110,EMERGENCY=4'b0111,NIGHT=4'b1000;
always@(posedge clk) begin
     if(reset) state<=NS_G;
     else state<=next_state;
end
always@(*) begin
next_state = state;
start = 1'b0;
timer_duration = 8'd0;
if (night_mode) next_state = NIGHT;
else if (emergency_present && state != EMERGENCY) begin
    next_state  = EMERGENCY;
    start = 1'b1;
end else begin
case(state)
NS_G: begin
    timer_duration=green_time;
       if(done) begin
       next_state=NS_Y;
       start=1'b1;
       end 
       end
NS_Y: begin
    timer_duration=8'd5;
       if(done) begin
       next_state=ALL_R1;
       start=1'b1;
       end 
       end       
 ALL_R1: begin
    timer_duration=8'd2;
       if(done) begin
       next_state=EW_G;
       start=1'b1;
       end 
       end
EW_G: begin
    timer_duration=green_time;
       if(done) begin
       next_state=EW_Y;
       start=1'b1;
       end 
       end
EW_Y: begin
    timer_duration=8'd5;
       if(done) begin
       next_state=ALL_R2;
       start=1'b1;
       end 
       end
ALL_R2: begin
    timer_duration=8'd2;
       if(done) begin
          start=1'b1;
          if(ped_request) next_state=PED_WALK;
          else next_state=NS_G;
       end 
       end   
PED_WALK: begin
    timer_duration=8'd15;
       if(done) begin
          next_state=NS_G;
          start=1'b1;
       end 
       end                
EMERGENCY: begin
    timer_duration=8'b0;
      if(!emergency_present) begin
         next_state=ALL_R1;
         start=1'b1;
         end
         end
NIGHT: begin
    timer_duration = 8'b0;
       if (!night_mode) begin
         next_state = ALL_R1; 
        start = 1'b1;
        end 
        end         
default: next_state=NS_G;       
endcase 
end
end
endmodule

module light_output_decoder(
    input clk,reset,
    input [3:0] state,
    input [1:0] emergency_route,
    output reg NS_green,NS_yellow,NS_red,EW_green,EW_yellow,EW_red,ped_walk
);
parameter NS_G=4'b0000,NS_Y=4'b0001,ALL_R1=4'b0010,EW_G=4'b0011,EW_Y=4'b0100,ALL_R2=4'b0101,PED_WALK=4'b0110,EMERGENCY=4'b0111,NIGHT=4'b1000;
reg [24:0] blink_counter;
always @(posedge clk) begin
if(reset) blink_counter <= 0;
else blink_counter <= blink_counter + 1;
end
wire blink_pulse = blink_counter[3]; 
always@(*) begin
    NS_green      = 1'b0;
    NS_yellow     = 1'b0;
    NS_red        = 1'b0;
    EW_green      = 1'b0;
    EW_yellow     = 1'b0;
    EW_red        = 1'b0;
    ped_walk      = 1'b0;
case(state)
NS_G: begin
    NS_green = 1'b1;
    EW_red   = 1'b1;
       end
NS_Y: begin
    NS_yellow = 1'b1;
    EW_red    = 1'b1;
       end       
 ALL_R1: begin
    NS_red  = 1'b1;
    EW_red  = 1'b1;
       end
EW_G: begin
    NS_red   = 1'b1;
    EW_green = 1'b1;
       end
EW_Y: begin
    NS_red     = 1'b1;
    EW_yellow  = 1'b1;
       end
ALL_R2: begin
    NS_red  = 1'b1;
    EW_red  = 1'b1;
       end   
PED_WALK: begin
    NS_red   = 1'b1;
    EW_red   = 1'b1;
    ped_walk = 1'b1;
       end                
EMERGENCY: begin
   if (emergency_route == 2'b01) begin
    NS_green = 1'b1; 
    EW_red   = 1'b1;
    end else if (emergency_route == 2'b10) begin
    NS_red   = 1'b1;
    EW_green = 1'b1; 
    end else begin
    NS_red   = 1'b1;
    EW_red   = 1'b1;
    end  
    end
NIGHT: begin
    NS_yellow = blink_pulse; 
    EW_yellow = blink_pulse;  
    end       
endcase 
end
endmodule

module pedestrian_controller (
    input clk,reset,ped_button,
    input [3:0] state,
    output reg ped_request
);
parameter PED_WALK=4'b0110;
always@(posedge clk) begin
if(reset) ped_request<=1'b0;
else if(ped_button) ped_request<=1'b1;
else if(state==PED_WALK) ped_request<=1'b0;
end
endmodule


module emergency(
    input NS_emergency,EW_emergency,
    input [7:0] NS_density,EW_density,
    output reg emergency_present,
    output reg [1:0] emergency_route
);
parameter route_freeze=2'b00,route_NS=2'b01,route_EW=2'b10;
always@(*) begin
emergency_present=1'b0;
emergency_route=route_freeze;
if(NS_emergency || EW_emergency) begin
 emergency_present=1'b1;
  if(NS_emergency && EW_emergency) begin
    if(NS_density>=EW_density) emergency_route=route_NS;
    else emergency_route=route_EW;
 end
else if(NS_emergency) emergency_route = route_NS;
else emergency_route = route_EW;
end
end
endmodule

module density_processor(
    input [7:0] NS_density,EW_density,
    input [3:0] state,
    output reg[7:0] green_time
);
parameter NS_G=4'b0000, EW_G=4'b0011;
reg [7:0] active_density;
always@(*) begin
active_density = NS_density;
       if (state == EW_G) active_density = EW_density;
    else active_density = NS_density; 
end
always @(*) begin
        if (active_density <= 8'd5) green_time = 8'd10; 
        else if (active_density <= 8'd15) green_time = 8'd20; 
        else if (active_density <= 8'd30) green_time = 8'd40;  
        else green_time = 8'd60;  
    end
endmodule

module intelligent_traffic_controller(
    input clk,reset,ped_button,NS_emergency, EW_emergency,night_mode,
    input  [7:0] NS_density, EW_density,
    output NS_green, NS_yellow, NS_red,EW_green, EW_yellow, EW_red,ped_walk
);
wire w_timer_done,w_timer_start,w_emergency_present,w_ped_request;
wire [7:0] w_timer_duration,w_green_time;
wire [1:0] w_emergency_route;
wire [3:0] w_state;
timer t1(
    .clk(clk), .reset(reset), .start(w_timer_start),
    .duration(w_timer_duration),.done(w_timer_done)
);
density_processor d1(
    .NS_density(NS_density),.EW_density(EW_density),
    .state(w_state),.green_time(w_green_time)
);
emergency e1(
    .NS_emergency(NS_emergency),.EW_emergency(EW_emergency),
    .NS_density(NS_density),.EW_density(EW_density),
    .emergency_present(w_emergency_present),.emergency_route(w_emergency_route)
);
pedestrian_controller p1(
    .clk(clk),.reset(reset),.ped_button(ped_button),
    .state(w_state),.ped_request(w_ped_request)
);
light_output_decoder l1(
    .clk(clk),.reset(reset),.state(w_state),.emergency_route(w_emergency_route),
    .NS_green(NS_green),.NS_yellow(NS_yellow), .NS_red(NS_red),
    .EW_green(EW_green),.EW_yellow(EW_yellow), .EW_red(EW_red),.ped_walk(ped_walk)
);
Traffic_fsm tf(
    .clk(clk), .reset(reset),.done(w_timer_done),.emergency_present(w_emergency_present),
    .ped_request(w_ped_request),.night_mode(night_mode),.green_time(w_green_time),
    .start(w_timer_start),.timer_duration(w_timer_duration),.state(w_state)
);
endmodule


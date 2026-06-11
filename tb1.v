module tb();
reg clk,reset,ped_button,NS_emergency, EW_emergency,night_mode;
reg [7:0] NS_density, EW_density;
wire NS_green, NS_yellow, NS_red,EW_green, EW_yellow, EW_red,ped_walk;
intelligent_traffic_controller uut (
        .clk(clk),
        .reset(reset),
        .ped_button(ped_button),
        .NS_emergency(NS_emergency),
        .EW_emergency(EW_emergency),
        .night_mode(night_mode),
        .NS_density(NS_density),
        .EW_density(EW_density),
        .NS_green(NS_green),
        .NS_yellow(NS_yellow),
        .NS_red(NS_red),
        .EW_green(EW_green),
        .EW_yellow(EW_yellow),
        .EW_red(EW_red),
        .ped_walk(ped_walk)
    );
always #5 clk=~clk;

always @(NS_green or NS_yellow or NS_red or EW_green or EW_yellow or EW_red or ped_walk or reset) begin
if (reset) $display("Time: %t ns [SYSTEM RESET ACTIVE]", $time);
else begin
    $display("Time%t   NS_Light:%s   EW_Light:%s   Pedestrian_Walk:%b", 
        $time, NS_green  ? "GREEN":NS_yellow ?"YELLOW":"RED",EW_green ? "GREEN":EW_yellow ? "YELLOW":"RED",
        ped_walk);
        end
    end

initial
  begin
    $dumpfile("traffic.vcd");
    $dumpvars(0,tb);
        clk          = 1'b0;
        reset        = 1'b1;
        ped_button   = 1'b0;
        NS_emergency = 1'b0;
        EW_emergency = 1'b0;
        night_mode = 1'b0;
        NS_density   = 8'd2;  
        EW_density   = 8'd4;
  #20 reset = 1'b0;
#200;

// Pedestrian request
$display("\n=== Pedestrian Request ===");
ped_button = 1'b1;
#10;
ped_button = 1'b0;
#300;

// NS Emergency
$display("\n=== NS Emergency ===");
NS_emergency = 1'b1;
#100;
NS_emergency = 1'b0;
#200;

// EW Emergency
$display("\n=== EW Emergency ===");
EW_emergency = 1'b1;
#100;
EW_emergency = 1'b0;
#200;

// Both emergencies together
$display("\n=== Simultaneous Emergencies ===");
NS_density = 8'd30;
EW_density = 8'd10;
NS_emergency = 1'b1;
EW_emergency = 1'b1;
#100;
NS_emergency = 1'b0;
EW_emergency = 1'b0;
#200;

// High traffic density
$display("\n=== High Density Test ===");
NS_density = 8'd35;
EW_density = 8'd40;
#300;

// Night mode
$display("\n=== Night Mode ===");
night_mode = 1'b1;
#150;
night_mode = 1'b0;
#200;

// Density change while running
$display("\n=== Dynamic Density Change ===");
NS_density = 8'd5;
EW_density = 8'd25;
#200;
NS_density = 8'd40;
EW_density = 8'd3;
#300;

$display("\n=== TEST COMPLETED ===");

$finish;
end 
endmodule
`timescale 1ns / 1ps
//..............................................Program Counter..............................//
module program_counter(
input clk,
input rst,
input [31:0] pc_in,
output reg [31:0] pc_out
);
always @(posedge clk or posedge rst) begin
if (rst) begin
pc_out <= 32'b00;
end else begin
pc_out <= pc_in;
end
end
endmodule
//............................................PC Adder .......................................//
module pc_adder(
input [31:0] pc_in,
output reg [31:0] pc_next
);
always @(*) begin
pc_next = pc_in + 4;
end
endmodule
//...........................................PC Mux(2x1)..............9i.........................//
module pc_mux(
input [31:0] pc_in,
10input [31:0] pc_branch,
input pc_select,
output reg[31:0] pc_out
);
always @(*) begin
if (pc_select==1'b0) begin
pc_out = pc_in;
end else begin
pc_out = pc_branch;
end
end
endmodule

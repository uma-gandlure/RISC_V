//.........................................................ALU.............................................//
module ALU(
input [31:0] A,
input [31:0] B,
input [3:0] ALUcontrol_In,
output reg [31:0] Result,
output reg Zero
);
always @(A or B or ALUcontrol_In) begin
case (ALUcontrol_In)
4'b0000: Result = A + B;
// ADD
4'b0001: Result = A - B;
// SUB
4'b0010: Result = A & B;
// AND
4'b0011: Result = A | B;
// OR
4'b0100: Result = A ^ B;
// XOR
4'b0101: Result = A << B[4:0];
// SLL (Shift Left Logical)
4'b0110: Result = A >> B[4:0];
// SRL (Shift Right Logical)
4'b0111: Result = $signed(A) >>> B[4:0]; // SRA (Shift Right Arithmetic)
4'b1000: Result =($signed(A) < $signed(B)) ? 32'b1 : 32'b0;
default: Result = 32'b0;
endcase
Zero = (Result == 32'b0) ? 1 : 0;
end
endmodule
//..............................................ALU Control...................................................//
module ALU_Control(
input [2:0] funct3,
input [6:0]funct7,
input [1:0] ALUOp,
output reg [3:0] ALUcontrol_Out
);
always @(*) begin
case ({ALUOp, funct7, funct3})
12'b10_0000000_000 : ALUcontrol_Out <= 4'b0000; // ADD
12'b00_0000000_000 : ALUcontrol_Out <= 4'b0000; // ADD
12'b00_0000000_001 : ALUcontrol_Out <= 4'b0000; // ADD
12'b00_0000000_010 : ALUcontrol_Out <= 4'b0000; // ADD
12'b10_0100000_000 : ALUcontrol_Out <= 4'b0001; // SUB
12'b10_0000000_111 : ALUcontrol_Out <= 4'b0010; // AND
12'b10_0000000_110 : ALUcontrol_Out <= 4'b0011; // OR
12'b10_0000000_100 : ALUcontrol_Out <= 4'b0100; // XOR
12'b10_0000000_001 : ALUcontrol_Out <= 4'b0101; // SLL
12'b10_0000000_101 : ALUcontrol_Out <= 4'b0110; // SRL
12'b10_0100000_101 : ALUcontrol_Out <= 4'b0111; // SRA
12'b10_0000000_010 : ALUcontrol_Out <= 4'b1000; // SLT
default
: ALUcontrol_Out <= 4'b0000;
endcase
end
endmodule
//................................................ALU Mux(2x1)......................................//
module MUX2to1 (
input [31:0] input0,
input [31:0] input1,
input select,
output [31:0] out
);
assign out = (select) ? input1 : input0;
endmodule

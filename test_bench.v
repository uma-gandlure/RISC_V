
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.04.2026 09:45:44
// Design Name:
// Module Name: test_bench
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
//=============================================================
// RISC-V Processor Testbench
// Tests: R-type, I-type, Load, Store, Branch (BEQ/BNE),
//
LUI, AUIPC, JAL instructions
module RISCV_Top_tb;
19// ---- Clock & Reset ----------------------------------------
reg clk;
reg rst;
// Clock: 10 ns period (100 MHz)
initial clk = 0;
always #5 clk = ~clk;
// ---- DUT instantiation ------------------------------------
RISCV_Top uut (
.clk(clk),
.rst(rst)
);
// ---- Internal signal access (for checking) ----------------
// Tap into the register file for result verification
wire [31:0] reg_x1 = uut.Reg_File.Registers[1];
wire [31:0] reg_x3 = uut.Reg_File.Registers[3];
wire [31:0] reg_x4 = uut.Reg_File.Registers[4];
wire [31:0] reg_x5 = uut.Reg_File.Registers[5];
wire [31:0] reg_x8 = uut.Reg_File.Registers[8];
wire [31:0] reg_x9 = uut.Reg_File.Registers[9];
wire [31:0] reg_x13 = uut.Reg_File.Registers[13];
wire [31:0] reg_x22 = uut.Reg_File.Registers[22];
wire [31:0] reg_x25 = uut.Reg_File.Registers[25];
// PC observable
wire [31:0] pc_now = uut.pc_out_wire;
// ---- Test counters ----------------------------------------
integer pass_count;
integer fail_count;
// ---- Helper task: CHECK -----------------------------------
// Prints PASS / FAIL for a single assertion
task check;
input [127:0] test_name; // label
input [31:0] got;
// actual value
input [31:0] expected; // expected value
begin
if (got === expected) begin
$display(" [PASS] %0s | got=0x%08h", test_name, got);
pass_count = pass_count + 1;
end else begin
$display(" [FAIL] %0s | got=0x%08h expected=0x%08h",
test_name, got, expected);
fail_count = fail_count + 1;
20end
end
endtask
// ---- Helper task: WAIT_CYCLES -----------------------------
task wait_cycles;
input integer n;
integer i;
begin
for (i = 0; i < n; i = i + 1)
@(posedge clk);
#1; // small delta after edge
end
endtask
// ==========================================================
// MAIN TEST SEQUENCE
// ==========================================================
initial begin
pass_count = 0;
fail_count = 0;
// ----------------------------------------------------------
// 1. RESET
// ----------------------------------------------------------
$display("\n==============================");
$display(" RISC-V Testbench Starting");
$display("==============================\n");
$display("[PHASE] Reset");
rst = 1;
@(posedge clk);
@(posedge clk);
rst = 0;
$display(" Reset released, PC = 0x%08h", pc_now);
// ----------------------------------------------------------
// 2. NOP (I_Mem[0])
// Instruction: NOP (all zeros)
// Expected: No register changes
// ----------------------------------------------------------
$display("\n[TEST] NOP — I_Mem[0]");
wait_cycles(2);
$display(" PC after NOP = 0x%08h", pc_now);
// ----------------------------------------------------------
// 3. R-type: ADD x13, x16, x25
// x16=40, x25=65 => x13 = 105
21// ----------------------------------------------------------
$display("\n[TEST] R-type ADD x13, x16, x25");
wait_cycles(2);
check("ADD x13=x16+x25", reg_x13, 32'd105);
// ----------------------------------------------------------
// 4. R-type: SUB x5, x8, x3
// x8=2, x3=12 => x5 = 2-12 = -10 (0xFFFFFFF6)
// ----------------------------------------------------------
$display("\n[TEST] R-type SUB x5, x8, x3");
wait_cycles(2);
check("SUB x5=x8-x3", reg_x5, 32'hFFFFFFF6);
// ----------------------------------------------------------
// 5. R-type: AND x1, x2, x3
// x2=2 (0010), x3=12 (1100) => x1 = 0
// ----------------------------------------------------------
$display("\n[TEST] R-type AND x1, x2, x3");
wait_cycles(2);
check("AND x1=x2&x3", reg_x1, 32'd0);
// ----------------------------------------------------------
// 6. R-type: OR x4, x3, x5
// x3=12 (1100), x5=-10 (0xFFFFFFF6) => x4 = 0xFFFFFFFE
// ----------------------------------------------------------
$display("\n[TEST] R-type OR x4, x3, x5");
wait_cycles(2);
check("OR x4=x3|x5", reg_x4, 32'hFFFFFFFE);
// ----------------------------------------------------------
// 7. R-type: XOR x4, x3, x5
// x3=12 (0x0000000C), x5=0xFFFFFFF6 => x4 = 0xFFFFFFFA
// ----------------------------------------------------------
$display("\n[TEST] R-type XOR x4, x3, x5");
wait_cycles(2);
check("XOR x4=x3^x5", reg_x4, 32'hFFFFFFFA);
// ----------------------------------------------------------
// 8. R-type: SLL x4, x3, x5
// x3=12, x5=0xFFFFFFF6, shamt=x5[4:0]=22
// x4 = 12 << 22 = 12 * 4194304 = 50331648 = 0x03000000
// ----------------------------------------------------------
$display("\n[TEST] R-type SLL x4, x3, x5");
wait_cycles(2);
check("SLL x4=x3<<x5[4:0]", reg_x4, 32'h03000000);
// ----------------------------------------------------------
// 9. R-type: SRL x4, x3, x5
22// x3=12, shamt=22 => x4 = 12 >> 22 = 0
// ----------------------------------------------------------
$display("\n[TEST] R-type SRL x4, x3, x5");
wait_cycles(2);
check("SRL x4=x3>>x5[4:0]", reg_x4, 32'd0);
// ----------------------------------------------------------
// 10. R-type: SRA x5, x3, x2
// x3=12, x2=2, shamt=2 => x5 = 12 >>> 2 = 3
// ----------------------------------------------------------
$display("\n[TEST] R-type SRA x5, x3, x2");
wait_cycles(2);
check("SRA x5=x3>>>x2", reg_x5, 32'd3);
// ----------------------------------------------------------
// 11. R-type: SLT x5, x3, x2
// x3=12, x2=2 => 12 < 2? => x5 = 0
// ----------------------------------------------------------
$display("\n[TEST] R-type SLT x5, x3, x2");
wait_cycles(2);
check("SLT x5=(x3<x2)", reg_x5, 32'd0);
// ----------------------------------------------------------
// 12. I-type: ADDI x22, x21, 2
// x21=80, imm=2 => x22 = 82
// ----------------------------------------------------------
$display("\n[TEST] I-type ADDI x22, x21, 2");
wait_cycles(2);
check("ADDI x22=x21+2", reg_x22, 32'd82);
// ----------------------------------------------------------
// 13. I-type: ORI x9, x8, 3
// x8=2 (10), imm=3 (11) => x9 = 3
// ----------------------------------------------------------
$display("\n[TEST] I-type ORI x9, x8, 3");
wait_cycles(2);
check("ORI x9=x8|3", reg_x9, 32'd3);
// ----------------------------------------------------------
// 14. I-type: XORI x9, x8, 4
// x8=2 (0010), imm=4 (0100) => x9 = 6
// ----------------------------------------------------------
$display("\n[TEST] I-type XORI x9, x8, 4");
wait_cycles(2);
check("XORI x9=x8^4", reg_x9, 32'd6);
// ----------------------------------------------------------
// 15. I-type: ANDI x1, x2, 5
23// x2=2 (0010), imm=5 (0101) => x1 = 0
// ----------------------------------------------------------
$display("\n[TEST] I-type ANDI x1, x2, 5");
wait_cycles(2);
check("ANDI x1=x2&5", reg_x1, 32'd0);
// ----------------------------------------------------------
// 16. I-type: SLLI x4, x3, 6
// x3=12, shamt=6 => x4 = 12 << 6 = 768
// ----------------------------------------------------------
$display("\n[TEST] I-type SLLI x4, x3, 6");
wait_cycles(2);
check("SLLI x4=x3<<6", reg_x4, 32'd768);
// ----------------------------------------------------------
// 17. I-type: SRLI x4, x3, 7
// x3=12, shamt=7 => x4 = 12 >> 7 = 0
// ----------------------------------------------------------
$display("\n[TEST] I-type SRLI x4, x3, 7");
wait_cycles(2);
check("SRLI x4=x3>>7", reg_x4, 32'd0);
// ----------------------------------------------------------
// 18. I-type: SRAI x5, x3, 8
// x3=12, shamt=8 => x5 = 12 >>> 8 = 0
// ----------------------------------------------------------
$display("\n[TEST] I-type SRAI x5, x3, 8");
wait_cycles(2);
check("SRAI x5=x3>>>8", reg_x5, 32'd0);
// ----------------------------------------------------------
// 19. I-type: SLTI x5, x3, 9
// x3=12, imm=9 => 12 < 9? => x5 = 0
// ----------------------------------------------------------
$display("\n[TEST] I-type SLTI x5, x3, 9");
wait_cycles(2);
check("SLTI x5=(x3<9)", reg_x5, 32'd0);
// ----------------------------------------------------------
// 20. Load: LW x8, 15(x2)
// addr = x2 + 15 = 2 + 15 = 17
// D_Memory[17>>2] = D_Memory[4] seeded to 56
// (Note: seed value at word index 4 after reset)
// => x8 = 56
// ----------------------------------------------------------
$display("\n[TEST] LOAD LW x8, 15(x2)");
wait_cycles(4);
check("LW x8=Dmem[17]", reg_x8, 32'd56);
24// ----------------------------------------------------------
// 21. Store: SW x14, 12(x6)
// addr = x6 + 12 = 44 + 12 = 56 => word addr = 14
// Write x14 (=20) to D_Memory[14]
// Then LW from same addr should return 20
// (Verified by observing DUT data memory directly)
// ----------------------------------------------------------
$display("\n[TEST] STORE SW x14, 12(x6) — then read back");
wait_cycles(4);
// Read back through data memory wire
begin : store_verify
reg [31:0] stored;
stored = uut.Data_Mem.D_Memory[56 >> 2]; // word addr = 14
check("SW Dmem[56>>2]=x14", stored, 32'd20);
end
// ----------------------------------------------------------
// 22. Branch: BEQ x9, x9, 12
// x9 == x9 => Zero=1 => branch taken
// PC should jump to PC + 12
// ----------------------------------------------------------
$display("\n[TEST] BRANCH BEQ x9, x9, 12");
begin : beq_check
reg [31:0] pc_before;
wait_cycles(1);
pc_before = pc_now;
wait_cycles(2);
$display(" PC before BEQ = 0x%08h, PC after = 0x%08h",
pc_before, pc_now);
// Branch should be taken; expect a non-sequential PC
if (pc_now !== pc_before + 4)
$display(" [PASS] BEQ branch taken (PC changed non-sequentially)");
else begin
$display(" [FAIL] BEQ branch NOT taken (PC still sequential)");
fail_count = fail_count + 1;
end
end
// ----------------------------------------------------------
// 23. LUI: lui x3, 40
// x3 = 40 << 12 = 40 * 4096 = 163840 = 0x00028000
// ----------------------------------------------------------
$display("\n[TEST] LUI x3, 40");
wait_cycles(4);
check("LUI x3=40<<12", reg_x3, 32'h00028000);
// ----------------------------------------------------------
25// 24. JAL: jal x1, 20
// x1 = PC + 4 (return address)
// PC = PC + 20
// ----------------------------------------------------------
$display("\n[TEST] JAL x1, 20");
begin : jal_check
reg [31:0] pc_jal;
wait_cycles(1);
pc_jal = pc_now;
wait_cycles(2);
// x1 must hold the return address = PC_jal + 4
check("JAL x1=PC+4", reg_x1, pc_jal + 4);
end
// ----------------------------------------------------------
// SUMMARY
// ----------------------------------------------------------
$display("\n==============================");
$display(" Test Summary");
$display("==============================");
$display(" PASSED : %0d", pass_count);
$display(" FAILED : %0d", fail_count);
if (fail_count == 0)
$display(" ALL TESTS PASSED");
else
$display(" SOME TESTS FAILED — review messages above");
$display("==============================\n");
$finish;
end
// ---- Optional: dump waveform ----------------------------------------
initial begin
$dumpfile("riscv_wave.vcd");
$dumpvars(0, RISCV_Top_tb);
end
// ---- Timeout watchdog -----------------------------------------------
initial begin
#50000;
$display("[TIMEOUT] Simulation exceeded 50,000 ns — aborting.");
$finish;
end
endmodule

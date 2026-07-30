`timescale 1ns/1ps

module DUT_TB;
reg [15:0] A, B;
reg [3:0] ALU_FUN;
wire Arith_Flag;
wire Carry_Flag;
wire Logic_Flag;
wire CMP_Flag;
wire Shift_Flag;
wire [15:0] ALU_OUT;
//For Tasks
reg Arith_Flag_Golden;
reg Logic_Flag_Golden;
reg CMP_Flag_Golden;
reg Shift_Flag_Golden;
reg Carry_Flag_Golden;
reg [15:0] ALU_OUT_Golden;

integer test_count  = 0;
integer error_count = 0;

ALU_16B ALU_DUT (.A(A), .B(B), .ALU_FUN(ALU_FUN),
                 .Arith_Flag(Arith_Flag), .Carry_Flag(Carry_Flag),
                 .Logic_Flag(Logic_Flag), .CMP_Flag(CMP_Flag),
                 .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

//Never Called Explicitly -- Driven From Driving Task
task Genrator (output [15:0] A_Generated, B_Generated);
begin
  A_Generated = $random;
  B_Generated = $random;
end
endtask

task Driver (output [15:0] A_Driven, B_Driven);
begin
  Genrator(.A_Generated(A_Driven), .B_Generated(B_Driven));
end
endtask


task Monitor (
    input [15:0] A, B,
    input [3:0] ALU_FUN,
    input Arith_Flag,
    input Logic_Flag,
    input Carry_Flag,
    input CMP_Flag,
    input Shift_Flag,
    input [15:0] ALU_OUT
);
begin
    $display("---------------------Inputs-----------------------");
    $display("A = %d | B = %d | ALU_FUN  = %b",
              A,       B,       ALU_FUN);
    $display("---------------------Outputs----------------------");
    $display("ALU_OUT = %d",
              ALU_OUT);
    $display("Arith_Flag = %b | Carry_Flag = %b",
              Arith_Flag,       Carry_Flag);
    $display("Logic_Flag = %b | CMP_Flag = %b | Shift_Flag = %b",
              Logic_Flag,       CMP_Flag,       Shift_Flag);
    $display("----------------------------------------------------");
    end
endtask

task Predector (
    input [15:0] A_Golden, B_Golden,
    input [3:0] ALU_FUN_Golden,
    output reg Arith_Flag_Golden,
    output reg Logic_Flag_Golden,
    output reg CMP_Flag_Golden,
    output reg Shift_Flag_Golden,
    output reg Carry_Flag_Golden,
    output reg [15:0] ALU_OUT_Golden
);

begin
    Arith_Flag_Golden = 1'b0 ;
    Logic_Flag_Golden = 1'b0 ; 
    CMP_Flag_Golden   = 1'b0 ;
    Shift_Flag_Golden = 1'b0 ;
	Carry_Flag_Golden = 1'b0 ;
	ALU_OUT_Golden = 16'b0 ;
    case (ALU_FUN_Golden) 
    4'b0000: begin
               {Carry_Flag_Golden,ALU_OUT_Golden} = A_Golden + B_Golden;
			   Arith_Flag_Golden = 1'b1 ;
              end
    4'b0001: begin
               {Carry_Flag_Golden,ALU_OUT_Golden} = A_Golden - B_Golden;
			   Arith_Flag_Golden = 1'b1 ;
              end
    4'b0010: begin
               ALU_OUT_Golden = A_Golden * B_Golden;
			   Arith_Flag_Golden = 1'b1 ;
              end
    4'b0011: begin
               ALU_OUT_Golden = A_Golden / B_Golden;
			   Arith_Flag_Golden = 1'b1 ;
              end
    4'b0100: begin
               ALU_OUT_Golden = A_Golden & B_Golden;
			   Logic_Flag_Golden = 1'b1 ;
              end
    4'b0101: begin
               ALU_OUT_Golden = A_Golden | B_Golden;
			   Logic_Flag_Golden = 1'b1 ;
              end
    4'b0110: begin
               ALU_OUT_Golden = ~ (A_Golden & B_Golden);
			   Logic_Flag_Golden = 1'b1 ;
              end
    4'b0111: begin
               ALU_OUT_Golden = ~ (A_Golden | B_Golden);
			   Logic_Flag_Golden = 1'b1 ;
              end     
    4'b1000: begin
               ALU_OUT_Golden =  (A_Golden ^ B_Golden);
			   Logic_Flag_Golden = 1'b1 ;
              end
    4'b1001: begin
               ALU_OUT_Golden = ~ (A_Golden ^ B_Golden);
			   Logic_Flag_Golden = 1'b1 ;
              end           
    4'b1010: begin
	          CMP_Flag_Golden = 1'b1 ;
              if (A_Golden == B_Golden)                                   
                 ALU_OUT_Golden = 16'b1;
              else
                 ALU_OUT_Golden = 16'b0;
              end
    4'b1011: begin
	           CMP_Flag_Golden = 1'b1 ;
               if (A_Golden > B_Golden)
                 ALU_OUT_Golden = 16'b10;                  
               else
                 ALU_OUT_Golden = 16'b0;
              end 
    4'b1100: begin
	           CMP_Flag_Golden = 1'b1 ;
               if (A_Golden < B_Golden)  
                ALU_OUT_Golden = 16'b11;                                 
               else
                 ALU_OUT_Golden = 16'b0;
              end      
    4'b1101: begin
	          Shift_Flag_Golden = 1'b1 ;
              ALU_OUT_Golden = A_Golden >> 1;
             end
    4'b1110: begin 
	          Shift_Flag_Golden = 1'b1 ;
              ALU_OUT_Golden = A_Golden << 1;
             end
    default: begin
			   Carry_Flag_Golden = 1'b0 ;
	           Arith_Flag_Golden = 1'b0 ;
               Logic_Flag_Golden = 1'b0 ; 
               CMP_Flag_Golden   = 1'b0 ;
               Shift_Flag_Golden = 1'b0 ;
               ALU_OUT_Golden = 16'b0;
             end
    endcase
end
endtask

task Checker (
    input Arith_Flag_Golden, Arith_Flag_Expected,
    input Logic_Flag_Golden, Logic_Flag_Expected,
    input CMP_Flag_Golden, CMP_Flag_Expected,
    input Shift_Flag_Golden, Shift_Flag_Expected,
    input Carry_Flag_Golden, Carry_Flag_Expected,
    input [15:0] ALU_OUT_Golden, ALU_OUT_Expected
);
begin
test_count = test_count + 1;
if (
    (Arith_Flag_Golden == Arith_Flag_Expected)
                      &&
    (Logic_Flag_Golden == Logic_Flag_Expected)
                      &&
    (CMP_Flag_Golden  == CMP_Flag_Expected)
                      &&
    (Shift_Flag_Golden == Shift_Flag_Expected)
                      &&
    (Carry_Flag_Golden == Carry_Flag_Expected)
                      &&
    (ALU_OUT_Golden == ALU_OUT_Expected)  
) begin
  $display("--------------Sucessful_Check-----------------");
  $display("----Golden_Result (Matched) Expected Results----");
  $display("Arith_Flag_Golden = %b | Arith_Flag_Expected = %b",
            Arith_Flag_Golden,       Arith_Flag_Expected);
  $display("Logic_Flag_Golden = %b | Logic_Flag_Expected = %b",
            Logic_Flag_Golden,       Logic_Flag_Expected);
  $display("CMP_Flag_Golden = %b  | CMP_Flag_Expected = %b",
            CMP_Flag_Golden,        CMP_Flag_Expected);
  $display("Shift_Flag_Golden = %b | Shift_Flag_Expected = %b",
            Shift_Flag_Golden,       Shift_Flag_Expected);
  $display("Carry_Out_Golden = %b | Carry_Out_Expected = %b",
            Carry_Flag_Golden,      Carry_Flag_Expected);
  $display("ALU_OUT_Golden = %d | ALU_OUT_Expected = %d",
            ALU_OUT_Golden,       ALU_OUT_Expected);  
  $display("----------------------End----------------------");        
end
else begin
  error_count = error_count + 1;
  $display("--------------Failed_Check-----------------");
  $display("----Golden_Result (Didn't Matched) Expected Results----");
  $display("Arith_Flag_Golden = %b | Arith_Flag_Expected = %b",
            Arith_Flag_Golden,       Arith_Flag_Expected);
  $display("Logic_Flag_Golden = %b | Logic_Flag_Expected = %b",
            Logic_Flag_Golden,       Logic_Flag_Expected);
  $display("CMP_Flag_Golden = %b  | CMP_Flag_Expected = %b",
            CMP_Flag_Golden,        CMP_Flag_Expected);
  $display("Shift_Flag_Golden = %b | Shift_Flag_Expected = %b",
            Shift_Flag_Golden,       Shift_Flag_Expected);
  $display("Carry_Out_Golden = %b | Carry_Out_Expected = %b",
            Carry_Flag_Golden,      Carry_Flag_Expected);
  $display("ALU_OUT_Golden = %d | ALU_OUT_Expected = %d",
            ALU_OUT_Golden,       ALU_OUT_Expected);  
  $display("----------------------End----------------------");   
end
  
end
endtask


integer tests;

initial begin
$display("=================================================================================");
$display("---------------------------Addition_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0000;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");
 

$display("=====================================================================================");
$display("---------------------------Substrcation_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0001;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


$display("=====================================================================================");
$display("---------------------------Multplication_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0010;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");
  

  $display("=====================================================================================");
$display("---------------------------Division_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0011;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


  $display("=====================================================================================");
$display("---------------------------Anding_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0100;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

    $display("=====================================================================================");
$display("---------------------------Oring_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0101;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


$display("=====================================================================================");
$display("---------------------------Nanding_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0110;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


$display("=====================================================================================");
$display("---------------------------Noring_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b0111;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


$display("=====================================================================================");
$display("---------------------------xoring_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1000;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

  $display("=====================================================================================");
$display("---------------------------xnoring_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1001;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

    $display("=====================================================================================");
$display("---------------------------Equality_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1010;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

      $display("=====================================================================================");
$display("---------------------------Bigger_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1011;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

$display("=====================================================================================");
$display("---------------------------Less_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1100;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");


  $display("=====================================================================================");
$display("---------------------------ShiftRight_A_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1101;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

    $display("=====================================================================================");
$display("---------------------------ShiftLeft_A_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1110;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

      $display("=====================================================================================");
$display("---------------------------Default_Functionality_Check--------------------------");
$display("=====================================================================================");

  ALU_FUN = 4'b1111;

  for (tests = 0; tests < 20; tests = tests + 1) begin

    Driver(.A_Driven(A), .B_Driven(B));
#1;
    Monitor(.A(A), .B(B), .ALU_FUN(ALU_FUN),
            .Arith_Flag(Arith_Flag), .Logic_Flag(Logic_Flag),
            .Carry_Flag(Carry_Flag), .CMP_Flag(CMP_Flag),
            .Shift_Flag(Shift_Flag), .ALU_OUT(ALU_OUT));

    Predector(.A_Golden(A), .B_Golden(B), .ALU_FUN_Golden(ALU_FUN),
              .Arith_Flag_Golden(Arith_Flag_Golden), .Logic_Flag_Golden(Logic_Flag_Golden),
              .CMP_Flag_Golden(CMP_Flag_Golden), .Shift_Flag_Golden(Shift_Flag_Golden),
              .Carry_Flag_Golden(Carry_Flag_Golden) ,.ALU_OUT_Golden(ALU_OUT_Golden));

    Checker(.Arith_Flag_Golden(Arith_Flag_Golden), .Arith_Flag_Expected(Arith_Flag),
            .Logic_Flag_Golden(Logic_Flag_Golden), .Logic_Flag_Expected(Logic_Flag),
            .CMP_Flag_Golden(CMP_Flag_Golden), .CMP_Flag_Expected(CMP_Flag),
            .Shift_Flag_Golden(Shift_Flag_Golden), .Shift_Flag_Expected(Shift_Flag),
            .Carry_Flag_Golden(Carry_Flag_Golden), .Carry_Flag_Expected(Carry_Flag),
            .ALU_OUT_Golden(ALU_OUT_Golden), .ALU_OUT_Expected(ALU_OUT));

  end

  $display("=====================================================");
  $display("TOTAL TESTS = %0d | FAILED = %0d | PASSED = %0d",
             test_count,   error_count, test_count - error_count);
  $display("=====================================================");

  $stop;
end

endmodule
`timescale 1ns / 1ps

module ffamuldivinv(
       
 input              reset,
 input              clock,
 input      [7:0]   inp_operA,
 input      [7:0]   inp_operB,
 input      [2:0]   op_sel,
 output reg         busy,
 output reg [7:0]   oup_operC );
     
 reg                op_done;        // internal register variable
 reg                inv_op_start;
 reg        [8:0]   inv_oper1;
 reg        [8:0]   inv_oper2;
 reg        [8:0]   inv_oper3;
 reg        [8:0]   inv_oper4;
 reg        [8:0]   inv_rem;
 reg        [8:0]   inv_quot;
 reg        [8:0]   inv_mul;
 reg        [7:0]   inp_reg;

 always @(*)
 begin
    if(reset == 0)  // Asynchronous Reset & negative reset
    begin
        oup_operC = 0;
        busy      = 0;
        inp_reg   = 0;
    end
    else
    begin
        busy    =   0;
        inp_reg =   0;
        case(op_sel)
            0 : oup_operC = inp_operA ^ inp_operB;                      // Addition
            1 : oup_operC = inp_operA ^ inp_operB;                      // Subtraction
            2 : oup_operC = finitefieldarth_mul(inp_operA, inp_operB);  // Multiplication
            3 : oup_operC = finitefieldarth_div(inp_operA, inp_operB);  // Division
            4 :
            begin
                if(op_done == 1'b0)
                begin
                    busy      = 1'b1;
                    oup_operC = 8'h0;
                    inp_reg   = inp_operA;
                end
                else
                begin
                    busy      =   1'b0;
                    oup_operC =   inv_mul;
                    inp_reg   =   0;
                end
            end 
        default:oup_operC = inp_operA ^ inp_operB;                      // Addition/Subtraction as Default operation
        endcase
    end
 end

 always @(posedge clock or negedge reset)
 begin
    if(reset == 0)
    begin
        inv_oper1   =   0;
        inv_oper2   =   0;
        inv_oper3   =   0;
        inv_oper4   =   0;
        inv_op_start=   0;
        inv_quot    =  9'h0;
        inv_rem     =  9'h0;
        inv_mul     =  9'h0;    
        op_done     =   0;
    end
    else
    begin
        if((busy == 1'b1) & (op_done == 1'b0) & (inv_op_start == 1'b0))
        begin
            inv_oper1       =  9'b100011011;
            inv_oper2       =  {1'b0, inp_reg};
            inv_oper3       =  9'h0;
            inv_oper4       =  9'h1;
            inv_quot        =  9'h0;
            inv_rem         =  9'h0;
            inv_mul         =  9'h0;    
            inv_op_start    =  1'b1; 
        end
        else
        begin
            if(inv_oper2 != 0)
            begin
                {inv_quot, inv_rem} = finitefieldarth_div(inv_oper1, inv_oper2);   // Dividing the irreducible polynomial with the operand
                inv_oper1           = inv_oper2;
                inv_oper2           = inv_rem;
     
                if(inv_rem != 0)
                begin
                    inv_mul     = inv_oper3 ^ (finitefieldarth_mul(inv_oper4, inv_quot)); // Deriving the Multiplicative inverse in multiple steps.
                    inv_oper3   = inv_oper4;
                    inv_oper4   = inv_mul;
                end
            end
            else if(inv_op_start)
            begin
                inv_op_start    =   1'b0;
                op_done         =   1'b1;
            end
            else
                op_done         =   1'b0;
        end
    end
 end
 
 
 function [7:0] finitefieldarth_mul;
    input [7:0] operA;        // 8 bit Operands 
    input [7:0] operB;
  
    reg [8:0] mul_temp;
    reg [3:0] counter;
    reg [7:0] op_temp;

    begin
        mul_temp  = {1'b0, operA};                              // 9 bits are considered to take care of carry generated.
        op_temp   = 0;
  
        for(counter = 0; counter < 8; counter = counter + 1)    // Logic is generated for the multiplicand bits
        begin
            if(operB[counter])
                op_temp = op_temp ^ mul_temp[7:0];
            else
                op_temp = op_temp;
   
            mul_temp = mul_temp << 1;
    
            if(mul_temp[8])                                    // If the carry is generated Modulo GF(2pow8) is carried out.
                mul_temp = mul_temp ^ 9'h11B;
            else
                mul_temp = mul_temp;
        end
        finitefieldarth_mul = op_temp;
    end
 endfunction

 
 function [17:0] finitefieldarth_div;  // Division operation: Results both Quotient & Remainder
    input [8:0] operdA;
    input [8:0] operdB;
  
    reg  [8:0] quotient;
    reg  [8:0] remainder;
    reg  [8:0] temp_result;
    reg  [3:0] degA;
    reg  [3:0] degr;
  
    reg  [3:0] div_count;
    reg  [3:0] deg_count;
  
    begin
        quotient  = 8'h0;
        remainder = operdA;
   
        for(div_count = 0; div_count < 8 ; div_count = div_count + 1)           //logic generated for upto 8 cycles
        begin                                                                   // considering the worst operation
            deg_count = (polytoleadterm(remainder) - polytoleadterm(operdB));
            if(polytoleadterm(remainder) >= polytoleadterm(operdB))              // Checking whether rem > divisor
            begin
                temp_result  = leadtermtopoly(deg_count);
                quotient     = quotient ^ temp_result;
                remainder    = remainder ^ (operdB << deg_count);
            end
            else
            begin
                temp_result  = temp_result;
                quotient     = quotient;
                remainder    = remainder;
            end
        end
        finitefieldarth_div = {quotient, remainder}; // Quotient & Remainder;
    end
 endfunction


 
 function [3:0] polytoleadterm;  // Function to findout the leading term in the polynomial
    input [8:0] operlA;
    begin
        casez (operlA)
            9'b1???????? : polytoleadterm = 4'h9;
            9'b01??????? : polytoleadterm = 4'h8;
            9'b001?????? : polytoleadterm = 4'h7;
            9'b0001????? : polytoleadterm = 4'h6;
            9'b00001???? : polytoleadterm = 4'h5;
            9'b000001??? : polytoleadterm = 4'h4;
            9'b0000001?? : polytoleadterm = 4'h3;
            9'b00000001? : polytoleadterm = 4'h2;
            9'b000000001 : polytoleadterm = 4'h1;
            default      : polytoleadterm = 4'h0;
        endcase
    end
 endfunction
 
 function [8:0] leadtermtopoly; // Function to derive polynomial from leading term.
    input [3:0] operlA;
    begin
        case (operlA)
            4'h8 : leadtermtopoly = 9'b100000000;
            4'h7 : leadtermtopoly = 9'b010000000;
            4'h6 : leadtermtopoly = 9'b001000000;
            4'h5 : leadtermtopoly = 9'b000100000;
            4'h4 : leadtermtopoly = 9'b000010000;
            4'h3 : leadtermtopoly = 9'b000001000;
            4'h2 : leadtermtopoly = 9'b000000100;
            4'h1 : leadtermtopoly = 9'b000000010;
            4'h0 : leadtermtopoly = 9'b000000001;
            default : leadtermtopoly= 9'b000000000;
        endcase
    end
 endfunction
endmodule

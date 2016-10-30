`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:35:10 09/16/2015 
// Design Name: 
// Module Name:   serial_mul_4x4 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module serial_mul_4x4(
    input clock,
    input reset,
    input inp1,
    input [3:0] inp2,
    output outp
    );
	 
	 reg	inp1_regc1;
	 reg 	inp1_regc2;
	 reg  inp1_regc3;
	 
	 reg	carryin0;
	 reg	carryin1;
	 reg	carryin2;
	 
	 wire carryout0;
	 wire carryout1;
	 wire carryout2;
	 
	 wire sumout0;
	 wire sumout1;
	 wire sumout2;
	 
	 reg	[3:0]	par_prods;
	 
	 wire p0_rst	=	reset & inp2[0];
	 wire p1_rst	=	reset & inp2[1];
	 wire p2_rst	=	reset & inp2[2];
	 wire p3_rst	=	reset & inp2[3];
	 
	 always @(posedge clock or negedge p0_rst)
	 begin
		if(p0_rst == 0)
			par_prods[0]	<=	4'b0000;
		else
			par_prods[0]	<=	inp1;
	 end
	
	 always @(posedge clock or negedge p1_rst)
	 begin
		if(p1_rst == 0)
			par_prods[1]	<=	4'b0000;
		else
			par_prods[1]	<=	inp1_regc1;
	 end

	 always @(posedge clock or negedge p2_rst)
	 begin
		if(p2_rst == 0)
			par_prods[2]	<=	4'b0000;
		else
			par_prods[2]	<=	inp1_regc2;
	 end
	
	 always @(posedge clock or negedge p3_rst)
	 begin
		if(p3_rst == 0)
			par_prods[3]	<=	4'b0000;
		else
			par_prods[3]	<=	inp1_regc3;
	 end
	 
	 always @(posedge clock or negedge reset)
	 begin
		if(reset == 0)
		begin
			inp1_regc1	<=	0;
			inp1_regc2	<=	0;
			inp1_regc3	<=	0;
		end
		else
		begin
			inp1_regc1	<=	inp1;
			inp1_regc2	<=	inp1_regc1;
			inp1_regc3	<=	inp1_regc2;
		end
	 end
	 
	 full_adder fa0(par_prods[0], par_prods[1], carryin0, sumout0, carryout0);
	 full_adder fa1(par_prods[2], par_prods[3], carryin1, sumout1, carryout1);
	 full_adder fa2(sumout0, sumout1,           carryin2, sumout2, carryout2);
	 
	 assign outp	=	sumout2;
	 
	 always @(posedge clock or negedge reset)
	 begin
		if(reset == 0)
		begin
			carryin0	<=	0;
			carryin1	<=	0;
			carryin2	<=	0;
		end
		else
		begin
			carryin0	<= carryout0;
			carryin1	<= carryout1;
			carryin2	<= carryout2;
		end
	 end
endmodule


module full_adder( input a,
						 input b,
						 input cin,
						 output s,
						 output cout);
						 
	assign	s		=	a ^ b ^ cin;
	assign   cout	=	(a & b) | (b & cin) | (cin & a);
						 
endmodule

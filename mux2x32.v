mux2x32.v
/*32位二路选择器*/
/*输入决定选择哪一路的控制信号s，输入待选择的信号a0、a1*/
/*输出被选择的信号y*/
module mux2x32 (a0,a1,s,y);
	input [31:0] a0,a1;
	input s;
	output [31:0] y;
	assign y = s?a1:a0; // 如果s为1，选择a1，否则选择a0
endmodule

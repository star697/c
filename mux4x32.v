mux4x32.v
/*32位四路选择器*/
/*待选择的数是a0~a3，控制信号为s，选择结果为y*/
/*s如何控制，由case语句决定*/
module mux4x32 (a0,a1,a2,a3,s,y);
	input [31:0] a0,a1,a2,a3;
	input [1:0] s;
	output [31:0] y;
	function [31:0] select;
		input [31:0] a0,a1,a2,a3;
		input [1:0] s;

		case (s)
			2'b00: select = a0; //s为00时，选择a0
			2'b01: select = a1;
			2'b10: select = a2;
			2'b11: select = a3;
		endcase
	endfunction
	assign  y = select(a0,a1,a2,a3,s); // y为选择的结果
endmodule

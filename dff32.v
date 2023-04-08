dff32.v
/*将数据送入指定寄存器*/
/*输入待存数据d，待存寄存器q；时钟clk和clrn*/
/*没有输出*/
module dff32(d,clk,clrn,q);
	input [31:0] d;
	input 	clk,clrn;
	output [31:0] q;
	reg  [31:0] q; 
	/*时序逻辑，clk的上升沿降沿触发、clrn的下降沿触发*/
	always @ (negedge clrn or posedge clk)
		// clrn是清零时钟
		if (clrn == 0) begin // 当清零时钟到来时
			q <= 0; // 为q赋值0
		end else begin
			q <= d; // 否则赋值d
		end
endmodule

cpu

shift.v
/*移位*/
/*输入一个数，返回移位之后的结果*/
/*输入d(待移的数)、sa(移动的位数)、right(移动方向)、arith(空位补全方式)*/
/*输出sh(移位后的结果)*/
module shift (d,sa,right,arith,sh);
input  [31:0]  d;
input  [4:0]     sa;
input  right,arith;
output [31:0] sh;
reg  [31:0] sh;
    
// 组合逻辑
always  @*  begin
	if   (!right)  begin // right为逻辑0时，左移
		sh = d << sa;
	end else  if   (!arith)  begin // right为逻辑1，且arith为逻辑0时，右移、0补空
		sh =  d  >>  sa;
	end else begin // 右移、1补空                     
		sh =  $signed(d)  >>>  sa;
	end
end
endmodule

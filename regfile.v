regfile.v
/*读寄存器堆、写寄存器堆*/
/*输入将要读取哪一个寄存器rna、rnb；输出读出的内容qa、qb*/
/*输入写使能we、待写入的寄存器wn，待写入的数据d*/
/*输入时钟clk、clrn*/
module regfile  (rna, rnb, d, wn,we, clk, clrn, qa, qb);
input       [4:0]  rna,rnb,wn;
input     [31:0]  d;
input     we, clk, clrn;
output  [31:0]  qa,qb;
reg     [31:0]  register  [1:31];  // 定义32个32位寄存器

// 读寄存器
// 如果指定的是rna，即rna不为0，将rna寄存器中的内容放入qa
assign qa  =   (rna ==  0) ? 0 : register[rna]; 
// 如果指定的是rnb，即rnb不为0，将rnb寄存器中的内容放入qb
assign qb  =   (rnb ==  0) ? 0 : register[rnb];
 

// 写寄存器
// 时序逻辑，clk的上升沿或clrn的下降沿触发
always @(posedge clk or negedge clrn)
begin 
if  (clrn==0) // 当为清空时钟信号时
begin
	integer i;
	for(i=1;i<32;i=i+1)
		register[i] <= 0; // 清空所有寄存器
end 
else  if((wn!=0)&&we) // 当写使能为逻辑1，且wn不是0时
register[wn]  <= d; // 将d写入wn寄存器
end
endmodule

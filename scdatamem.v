# c
scdatamem.v
/*将数据写入RAM中（随机存取存储器）的指定位置*/
/*输入待写数据datain、目标地址addr；写使能信号we；时钟信号clk、inclk、outclk*/
/*输出将被覆盖的数据dataout*/
module scdatamem (clk,dataout,datain,addr,we,inclk,outclk);
input	[31:0]	datain;
input	[31:0]	addr ;
input		clk, we, inclk, outclk;
output	[31:0]	dataout;
reg [31:0] ram	[0:31]; // 定义32个32位RAM
// 把将被覆盖的数据放入dataout
assign	dataout	=ram[addr[6:2]];
// 时序逻辑，clk的上升沿触发
always @ (posedge clk) begin
	if (we) ram[addr[6:2]] = datain; // 如果写使能信号we为1，将数据写入目标地址
end
// 为RAM赋值，这一步不是必要的，只是欲运行的自定义程序的需要。
integer i;
initial begin
	for (i = 0;i < 32;i = i + 1)
		ram[i] = 0;
	ram[5'h14] = 32'h000000a3;
	ram[5'h15] = 32'h00000027;
	ram[5'h16] = 32'h00000079;
	ram[5'h17] = 32'h00000115;
end
endmodule

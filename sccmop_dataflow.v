sccmop_dataflow.v
/*最顶层的控制模块*/
/*输入时钟clock和resetn*/
/*输出 指令inst、PC的值pc、ALU的运算结果aluout、存储器的输出memout、时钟信号mem_clk*/
module  sccomp_dataflow(clock, resetn, inst, pc, aluout, memout,mem_clk);
input  clock, resetn,mem_clk;
output   [31:0]  inst,pc, aluout,memout;
wire [31:0]   data;
wire   wmem;
// 实例化一个cpu
sccpu_dataflow s (clock, resetn, inst,memout,pc, wmem, aluout, data);
// 实例化一个ROM
scinstmem imem (pc,inst);
// 实例化一个RAM
scdatamem dmem (clock, memout, data, aluout, wmem, mem_clk, mem_clk);
endmodule

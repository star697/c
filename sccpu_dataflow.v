sccpu_dataflow.v
/*cpu*/
/*输入时钟信号clock、是否进行清零的信号resetn*/
/*输入32位指令inst、以及其他值*/
module  sccpu_dataflow(clock, resetn, inst, mem, pc, wmem, alu, data);
input     [31:0]   inst,mem;
input         clock, resetn;
output   [31:0]  pc,alu,data;
 
output wmem;
wire  [31:0] p4 , bpc, npc, adr, ra, alua, alub, res, alu_mem;
wire  [3:0] aluc;
wire  [4:0] reg_dest, wn;
wire  [1:0] pcsource;
wire  zero, wmem, wreg, regrt, m2reg, shift, aluimm, jal, sext;
wire  [31:0]  sa  =  {27'b0,inst[10:6]};
wire  [31:0]  offset  =  {imm[13:0],inst[15:0],2'b00};

/*控制器*/
// 输入inst[31:26]即op字段、inst[5:0]即func字段、0标志位zero
// 输出wmem、wreg等控制信号
sccu_dataflow cu  (inst[31:26] , inst[5:0] , zero, wmem,wreg,regrt,m2reg, aluc, shift, aluimm,pcsource, jal, sext);

/*0拓展或符号拓展*/
wire   e  =  sext  &  inst[15]; // 取出0或者符号 
wire   [15:0]       imm =  {16{e}}; 
wire  [31:0]       immediate  =  {imm,inst[15:0]}; // 拼接、拓展

/*修改PC，使PC指向下一条地址*、
dff32  ip  (npc,clock,resetn,pc); // 将npc（即下一条指令的地址）写入寄存器pc

/*计算下地址*/
// 四路选择器的0路
cla32  pcplus4   (pc,32'h4,1'b0,p4); // pc和32位十六进制4相加，再加上进位0，结果放入p4
// 四路选择器的1路
cla32  br_adr     (p4,offset,1'b0, adr); // p4和拓展后的imm相加，再加上进位0，结果放入adr
// 四路选择器的3路
wire  [31:0]        jpc =  {p4[31:28],inst[25:0],2'b00}; // 如图

/*二路选择器*/
// ③号。在ra即q1、sa之间选择，控制信号是shift，选择结果为alua
mux2x32  alu_a  (ra,sa,shift,alua);
// ④号。在data即q2、immediate之间选择，控制信号是aluimm，选择结果为alub
mux2x32  alu_b  (data, immediate,aluimm, alub);
// ⑤号。在alu即r、mem即do之间选择，控制信号是m2reg,选择结果为alu_mem
mux2x32  result   (alu,mem,m2reg,alu_mem);
// ②号。在alu_mem、p4之间选择，控制信号是jal即call，选择结构是res
mux2x32  link (alu_mem,p4,jal,res);
// ①号。在inst[15:11]即rd，inst[20: 16]即rt之间选择，控制信号是regrt，选择结果是reg_dest
mux2x5  reg_wn   (inst[15:11], inst[20: 16] , regrt, reg_dest);
// 对应图中的①号后面的f器件（不知道做什么的...）
assign wn = reg_dest   |   {5{jal}}; 

/*四路选择器，计算下地址*/
// 在p4、adr即addr、ra即q1、jpc即p4+immidiate<<2，之间选择，控制信号是pcsource，选择结果是npc
mux4x32  nextpc  (p4,adr,ra, jpc,pcsource,npc);

/*寄存器组*/
// 定义一个寄存器，输入端口是inst[25:21]即rs(n1)、inst[20:16]即rt(n2)
// 输出端口是data即ra即q1、data即q2
// 输入写使能wreg、待写寄存器wn即n
// 输入时钟clock即clk、清零时钟resetn
regfile  rf   (inst[25:21] ,inst[20:16] ,res,wn,wreg,clock,resetn,ra,data);

/*alu*/
// 操作数是alua、alub，操作结果是aluu空r、标志位zero即z
// 控制信号是aluc
alu  al_unit   (alua,alub,aluc,alu, zero); 
endmodule

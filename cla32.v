cla32.v
/*下面所有程序都是为了实现一个东东：32位并行加法器*/
/*从最基本的加法进位模型add实现全加器cla_2，
  逐步集成为4位全加器cla_4、8位的全加器cla_8、
  16位全加器cla_16、32位全加器cla_32,
  最终实现32位并行加法器cla32
*/

/*加数是a、b，和是s*/
/*借位是ci，进位是co*/
module cla32 (a,b,ci,s,co);
	input   [31:0]  a,b;
	input  ci;
	output   [31:0]   s;
	output co;
	wire  g_out, p_out;
	cla_32  cla   (a,b, ci,g_out,p_out, s); // 向下调用
	assign  co  =  g_out| p_out &  ci;
endmodule




module add(a,b,c,g,p,s);
	input a,b,c;
	output g,p,s;
	assign s = a^b^c;
	assign g = a & b;
	assign p = a | b;
endmodule



module g_p  (g,p,c_in,g_out,p_out,c_out);
input  [1:0]  g,p;
input  c_in;
output g_out, p_out, c_out;
assign g_out = g[1]|p[1] & g[0];
assign p_out = p[1]  & p[0];
assign c_out = g[0]   |  p[0]  &  c_in;
endmodule



module cla_2 (a,b,c_in,g_out,p_out,s) ;
input  [1:0]  a,b;
input c_in;
output g_out, p_out;
output  [1:0]  s;
wire  [1:0]  g,p;
wire c_out;
add add0 (a[0],b[0],c_in, g[0],p[0],s[0]);
add add1 (a[1],b[1],c_out, g[1],p[1],s[1]);
g_p g_p0 (g,p,c_in,  g_out,p_out,c_out);
endmodule

module cla_4 (a,b, c_in,g_out,p_out,s);
input  [3:0]  a,b;
input  c_in;
output g_out, p_out;
output  [3:0]  s;
wire  [1:0]  g,p;
wire c_out;
cla_2 cla0 (a[1:0],b[1:0],c_in, g[0],p[0],s[1:0]);
cla_2 clal (a[3:2],b[3:2],c_out,g[1],p[1],s[3:2]);
g_p    g_p0  (g,p,c_in, g_out,p_out,c_out);
endmodule

module  cla_8   (a,b, c_in,g_out,p_out, s);
input   [7:0]  a,b;
input  c_in;
output  g_out, p_out;
output   [7:0]   s;
wire   [1:0]   g,p;
wire  c_out;
cla_4  cla0  (a[3:0],b[3:0],c_in, g[0],p[0],s[3:0]);
cla_4  c1a1  (a[7:4],b[7:4],c_out,g[1],p[1],s[7:4]);
g_p   g_p0  (g,p,c_in,  g_out,p_out,c_out);
endmodule


module cla_16 (a,b, c_in,g_out,p_out, s);
input   [15:0]  a,b;
input  c_in;
output  g_out, p_out;
output   [15:0]  s;
wire  [1:0]  g,p;
wire  c_out;
cla_8  cla0   (a[7:0],b[7:0],c_in,g[0],p[0],s[7:0]);
cla_8  cla1   (a[15:8],b[15:8],c_out,g[1],p[1],s[15:8]);
g_p    g_p0  (g,p,c_in,  g_out,p_out,c_out);
endmodule


module cla_32  (a,b,c_in,g_out,p_out, s);
input  [31:0]  a,b;
input c_in;
output  g_out, p_out;
output  [31:0]  s;
wire  [1:0]  g,p;
wire c_out;
cla_16 c1a0 (a[15:0],b[15:0],c_in,g[0],p[0],s[15:0]);
cla_16 c1a1 (a[31:16],b[31:16],c_out,g[1],p[1],s[31:16]);
g_p    g_p0  (g,p,c_in, g_out,p_out,c_out);
endmodule
addsub32.v
/*32位加减运算模块*/
/*调用32位加法模块*/
/*是加是减，取决于sub的取值*/
module addsub32(a,b,sub,s);
	input [31:0] a,b;
	input  		sub;
	output [31:0] s;
	cla32 as32 (a,b^{32{sub}},sub,s);
endmodule
alu.v
/*alu算数逻辑单元*/
/*输入操作数a、b，操作类型信号aluc*/
/*输出运算结果r；z是？*/
module alu (a,b,aluc,r,z);
input [31:0] a,b; 
// aluc是3位的，每一位都有作用，见下
input [3:0] aluc; 
output  [31:0]  r;  
output z;            
wire  [31:0]  d_and = a & b; // 求和
wire  [31:0] d_or = a | b; // 求或
wire  [31:0] d_xor = a ^ b; // 求异或
wire  [31:0]  d_lui = {b[15:0],16'h0}; // 拼接，低16位补0

wire  [31:0]  d_and_or = aluc[2]? d_or : d_and; // aluc[2]决定 与/或
wire  [31:0]  d_xor_1ui= aluc[2]? d_lui : d_xor;  // aluc[2]决定 异或/拼接

wire  [31:0]  d_as,d_sh; // 加减法结果保存到d_as中；移位结果存入d_sh中
// aluc[2]控制加减法
addsub32 as32  (a,b,aluc[2],d_as); 
// b为待移的数，a[4:0]为移动位数，aluc[2]决定左右移，aluc[3]决定补全方式，结果保存在d_sh中
shift shifter  (b,a[4:0],aluc[2],aluc[3],d_sh) ; 

// 四路选择，aluc[1:0]控制选择哪一路，r为选择结果
mux4x32 se1ect  (d_as,d_and_or, d_xor_1ui, d_sh, aluc[1:0],r);
assign z = ~|r;
endmodule    

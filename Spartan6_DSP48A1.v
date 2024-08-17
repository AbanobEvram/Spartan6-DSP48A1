 module Spartan6_DSP48A1
 #(
    parameter A0REG = 0,// if 1(register) ,0(no register)
              A1REG = 1, 
              B0REG = 0,
              B1REG = 1,
              CREG = 1, 
              DREG = 1, 
              MREG = 1,
              PREG = 1, 
              CARRYINREG = 1, 
              CARRYOUTREG = 1, 
              OPMODEREG = 1,
              CARRYINSEL = "OPMODE5",//CARRYIN or OPMODE5 else out=0
              B_INPUT = "DIRECT",//DIRECT or CASCADE
              RSTTYPE = "SYNC"//SYNC or ASYNC
 )
 (
 	input [17:0] A,B,D,BCIN,
 	input [47:0] C,PCIN,
 	input [7:0] OPMODE,
 	input CLK,CARRYIN,
 	input RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE,
 	input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE,
   output [17:0] BCOUT,
   output [47:0] PCOUT,P,
   output [35:0] M,
   output CARRYOUT, CARRYOUTF
 );
   wire [17:0] A0_m, A1_m, B0_m,B1_m,D_m,B0_in,B1_in,pre_adder_out;
   wire [47:0] C_m,Post_adder_out;
   wire [35:0] M_m,mult_out;
   wire [7:0] OPMODE_m;
   wire CYI_in,CYI_m,CYO_in;
   reg [47:0] X_m,Z_m;
    
   reg_mux #(18,RSTTYPE,A0REG)  A0_REG(A,RSTA,CEA,CLK,A0_m);
   reg_mux #(18,RSTTYPE,A1REG)  A1_REG(A0_m,RSTA,CEA,CLK,A1_m);
   reg_mux #(18,RSTTYPE,B0REG)  B0_REG(B0_in,RSTB,CEB,CLK,B0_m);
   reg_mux #(18,RSTTYPE,B1REG)  B1_REG(B1_in,RSTB,CEB,CLK,B1_m);
   reg_mux #(48,RSTTYPE,CREG)  C_REG(C,RSTC,CEC,CLK,C_m);
   reg_mux #(18,RSTTYPE,DREG)  D_REG(D,RSTD,CED,CLK,D_m);
   reg_mux #(36,RSTTYPE,MREG)  M_REG(mult_out,RSTM,CEM,CLK,M_m);
   reg_mux #(48,RSTTYPE,PREG)  P_REG(Post_adder_out,RSTP,CEP,CLK,P);
   reg_mux #(1,RSTTYPE,CARRYINREG)  CYI_REG(CYI_in,RSTCARRYIN,CECARRYIN,CLK,CYI_m);
   reg_mux #(1,RSTTYPE,CARRYOUTREG)  CYO_REG(CYO_in,RSTCARRYIN,CECARRYIN,CLK,CARRYOUT);
   reg_mux #(8,RSTTYPE,OPMODEREG)  OPMODE_REG(OPMODE,RSTOPMODE,CEOPMODE,CLK,OPMODE_m);

   assign CYI_in=(CARRYINSEL=="OPMODE5")?OPMODE_m[5]:(CARRYINSEL=="CARRYIN")?CARRYIN:0;

   assign B0_in=(B_INPUT=="DIRECT")?B:(B_INPUT=="CASCADE")?BCIN:0;

   assign  pre_adder_out=(OPMODE_m[6]==0)?(D_m+B0_m):(D_m-B0_m); 

   assign  B1_in=(OPMODE_m[4]==1)?pre_adder_out:B0_m ;

   assign BCOUT = B1_m;

   assign  mult_out=A1_m*B1_m;

   assign  M = M_m;


 always @(*) begin
   case(OPMODE_m[1:0])
      0:X_m=0;
      1:X_m=M_m;
      2:X_m=P;
      3:X_m={D_m[11:0],A1_m[17:0],B1_m[17:0]};
   endcase
 end
  always @(*) begin
   case(OPMODE_m[3:2])
      0:Z_m=0;
      1:Z_m=PCIN;
      2:Z_m=P;
      3:Z_m=C_m;
   endcase
 end
 assign {CYO_in,Post_adder_out}=(OPMODE_m[7]==0)?(X_m+Z_m+CYI_m):(Z_m-(X_m+CYI_m));
 assign CARRYOUTF = CARRYOUT ;
 assign PCOUT = P ;
endmodule 
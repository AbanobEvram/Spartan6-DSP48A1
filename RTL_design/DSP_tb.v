module DSP_tb();
 localparam A0REG = 0;// if 1(register) ,0(no register)
 localparam A1REG = 1; 
 localparam B0REG = 0;
 localparam B1REG = 1;
 localparam CREG = 1;
 localparam DREG = 1; 
 localparam MREG = 1;
 localparam PREG = 1; 
 localparam CARRYINREG = 1; 
 localparam CARRYOUTREG = 1; 
 localparam OPMODEREG = 1;
 localparam CARRYINSEL = "OPMODE5";//CARRYIN or OPMODE5 else out=0
 localparam B_INPUT = "DIRECT";//DIRECT or CASCADE
 localparam RSTTYPE = "SYNC";//SYNC or ASYNC
 
 reg [17:0] A,B,D,BCIN;
 reg [47:0] C,PCIN;
 reg [7:0] OPMODE;
 reg CLK,CARRYIN;
 reg RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE;
 reg CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE;
 wire [17:0] BCOUT;
 wire [47:0] PCOUT,P;
 wire [35:0] M;
 wire CARRYOUT,CARRYOUTF;

 Spartan6_DSP48A1 #(A0REG,A1REG,B0REG,B1REG,CREG,DREG,MREG,PREG,CARRYINREG,CARRYOUTREG,OPMODEREG,CARRYINSEL,B_INPUT,RSTTYPE) dut(
 	A,B,D,BCIN,C,PCIN,OPMODE,CLK,CARRYIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
 initial begin
 	CLK=0;
 	forever
 		#1 CLK=~CLK;
 end
integer i;
initial begin
// Initialize and reset signals
    RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
    CEA = 1; CEB = 1; CEM = 1; CEP = 1; CEC = 1; CED = 1; CECARRYIN = 1; CEOPMODE = 1;
    A = 0; B = 0; C = 0; D = 0; CARRYIN = 0; BCIN = 0; PCIN = 0;
    OPMODE = 8'b00000000;
    repeat(5)
     @(negedge CLK);
    
    // put reset signal =1
    RSTA = 0; RSTB = 0; RSTM = 0; RSTP = 0; RSTC = 0; RSTD = 0; RSTCARRYIN = 0; RSTOPMODE = 0;
    $display("Case : 1");
    //B*A+C+opmode[5] =(15*2)+10+1=41
    OPMODE=8'b01101101;
    A=15;B=2;C=10;
    repeat(5)
    @(negedge CLK);
    
    $display("Case : 2");
    //C-((D-B)*A)=1000-((13-3)*10)=900
    OPMODE=8'b11011101;
    D=13;B=3;A=10;C=1000;
    repeat(5)
    @(negedge CLK);

    $display("Case : 3");
    //X_m=P,Z_m=P:x+z=900+900=1800
    OPMODE=8'b01011010;
    repeat(2)
    @(negedge CLK);

    $display("Case : 4");
    //P=PCIN=12345;
    OPMODE=8'b01010100;
    PCIN=12345;
    repeat(2)
    @(negedge CLK);

    $display("Case : 5");
    //(D+B)*A=(3+2)*5=25
    OPMODE=8'b00010001;
    D=3;B=2;A=5;
    repeat(5)
    @(negedge CLK);

    $display("Case : 6");
    //Output equal the concatinated numbe
    //=10_1010_1010_0101_0101_1010_1010_1010_0101_0101_1010_1010_1010_0101_0101 
    OPMODE = 8'b00010011;
    D=18'b1010_1010_1010_0101_0101;
    B=0;
    A=18'b1010_1010_1010_0101_0101;
    repeat(5)
    @(negedge CLK);
    $display("P=%b",P);

    $display("Case : 7");
    //Note the output from subtracter will be N_num so the out will be big num
    OPMODE=8'b11011111;
    B=47;
    A=33;
    C=47;
    D=30;
    PCIN=7;
    repeat(5)
    @(negedge CLK);

    $display("PCIN+M_m+CIN,M_m=(D+B)*A ,so P=PCIN+(D+B)*A+CIN");
    OPMODE = 8'b00110101;
    for(i=0;i<5;i=i+1) begin
        $display("iteration : %d",i);
        A=$urandom_range(1,50);
        B=$urandom_range(1,50);
        D=$urandom_range(1,50);
        PCIN=$urandom_range(1,50);
        repeat(5)
        @(negedge CLK);           
    end
    
    $display("Randomize cases");
    for(i=0;i<1000;i=i+1) begin
        A = $urandom_range(1, 50);
        B = $urandom_range(1, 50);
        D = $urandom_range(1, 50);
        C = $urandom_range(1, 50);
        PCIN = $urandom_range(1, 50);
        OPMODE = $random;
        repeat(5)
        @(negedge CLK);           

    end

    $stop;
end

initial begin
    $monitor("A=%d, B=%d, C=%d, D=%d, CARRYIN=%d ,PCIN=%d , OPMODE=%b, P=%d,BCOUT=%d ,M=%d ,CARRYOUT=%d", A, B, C, D,CARRYIN ,PCIN , OPMODE, P,BCOUT ,M , CARRYOUT);
end
endmodule
module reg_mux(data,rst,ce,clk,out);
 parameter WIDTH=18;
 parameter RSTTYPE = "SYNC";//SYNC or ASYNC
 parameter REGISTER_ENABLE=1;//1 or 0
 input [WIDTH-1:0] data;
 input clk,rst,ce;
 output  [WIDTH-1:0] out;
 reg [WIDTH-1:0] out_sync,out_async;
 
 always @(posedge clk ) begin
 	if (RSTTYPE!="ASYNC") begin //default SYNC
 		if(rst)
 			out_sync<=0;
 		else if(ce)	
 			out_sync<=data;
 	end
 end
 always @(posedge clk or posedge rst) begin
 	if (RSTTYPE=="ASYNC") begin 
 		if(rst)
 			out_async<=0;
 		else if(ce)	
 			out_async<=data;
 	end
 end
assign out =(REGISTER_ENABLE&&RSTTYPE=="ASYNC")?out_async:(REGISTER_ENABLE&&RSTTYPE!="ASYNC")?out_sync:data ;
endmodule
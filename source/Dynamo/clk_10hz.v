module clk_10hz (clk_50m ,clk_10hz ,rst);
input clk_50m,rst;
output clk_10hz;
reg clk_10hz;
reg [26:0]div_cnt;
always @ (posedge clk_50m or negedge rst)begin
if(!rst)
div_cnt<=27'b0;
else if(div_cnt==2499999)
div_cnt<=27'b0;
else
div_cnt<=div_cnt+1'b1;
end
always @ (posedge clk_50m or negedge rst)begin
if(!rst)
clk_10hz<=1'b0;
else if (div_cnt==2499999)
clk_10hz<=~clk_10hz;
else
clk_10hz<=clk_10hz;
end
endmodule
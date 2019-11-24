module clk_5hz (clk_50m ,clk_5hz ,rst);
input clk_50m,rst;
output clk_5hz;
reg clk_5hz;
reg [26:0]div_cnt;
always @ (posedge clk_50m or negedge rst)begin
if(!rst)
div_cnt<=27'b0;
else if(div_cnt==24999999)
div_cnt<=27'b0;
else
div_cnt<=div_cnt+1'b1;
end
always @ (posedge clk_50m or negedge rst)begin
if(!rst)
clk_5hz<=1'b0;
else if (div_cnt==24999999)
clk_5hz<=~clk_5hz;
else
clk_5hz<=clk_5hz;
end
endmodule
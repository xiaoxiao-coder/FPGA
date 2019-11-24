module Frequency_divider_dynamic_scanning( clk_50m,clk_d,rst  );


input clk_50m,rst;

output reg clk_d;



reg [20:0]div_cnt2;


always @ (posedge clk_50m or negedge rst)begin
if(!rst)
div_cnt2<=21'b0;
else if(div_cnt2==125000)
div_cnt2<=21'b0;
else
div_cnt2<=div_cnt2+1'b1;
end


always @ (posedge clk_50m or negedge rst)begin
if(!rst)
clk_d<=1'b0;
else if (div_cnt2==125000)
clk_d<=~clk_d;
else
clk_d<=clk_d;
end
endmodule
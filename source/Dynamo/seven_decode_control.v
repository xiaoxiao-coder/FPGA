module seven_decode_control(

     //input

     clk_50m,

     rst,
 
     reg1,

     reg2,

     reg3,

     reg4,

     //output

     d1_out,            //duanxuan 

     d1_wx              //pianxuan

);

//input

input clk_50m;

input rst;

input [3:0] reg1 , reg2 , reg3 , reg4 ;

//output

output reg [3:0] d1_wx;

output wire [7:0] d1_out;

//..

reg [7:0] d_tmp_num;

wire clk_d;


always @ (posedge clk_d or negedge rst) begin       
if(!rst)begin

d1_wx <= 4'b1110;


end

else begin
  case(d1_wx)
    4'b1110:begin
               d_tmp_num <= reg2;
               d1_wx <= 4'b1101;
             end
    4'b1101:begin
               d_tmp_num <= reg3;
               d1_wx <= 4'b1011;
             end
    4'b1011:begin
               d_tmp_num <= reg4;
               d1_wx <= 4'b0111;
              end
    4'b0111:begin
               d_tmp_num <= reg1;
               d1_wx <= 4'b1110;
             end
    default:begin
              d1_wx <= 4'b1110;
            end
  endcase
end
end
Frequency_divider_dynamic_scanning U1(.clk_50m(clk_50m),.clk_d(clk_d),.rst(rst));

//Frequency_divider_1 U2(.clk_50m(clk_50m),.clk_1(clk_1),.rst(rst));

Nixie_Light_Display U3(.q_num(d_tmp_num),.q_out(d1_out));

endmodule
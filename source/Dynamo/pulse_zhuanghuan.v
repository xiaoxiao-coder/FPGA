module pulse_zhuanghuan(

     //input

     clk_50m,

     pulse,

     //output

     pulse_zh

);

//
input clk_50m;

input pulse;

//

output pulse_zh;

//

reg pulse_reg;

always @ (posedge clk_50m )begin

pulse_reg <= pulse;

end

assign pulse_zh = pulse & (!pulse_reg);

endmodule












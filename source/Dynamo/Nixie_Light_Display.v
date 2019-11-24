module Nixie_Light_Display(q_num, q_out);
input[3:0] q_num;
output[7:0] q_out;
reg[7:0] q_out;
always @(q_num) begin
    case(q_num)		
    4'b0000:q_out = 8'b00111111;
    4'b0001:q_out = 8'b00000110;
    4'b0010:q_out = 8'b01011011;
    4'b0011:q_out = 8'b01001111;
    4'b0100:q_out = 8'b01100110;
    4'b0101:q_out = 8'b01101101;
    4'b0110:q_out = 8'b01111101;
    4'b0111:q_out = 8'b00000111;
    4'b1000:q_out = 8'b01111111;
    4'b1001:q_out = 8'b01101111;
    4'b1010:q_out = 8'b01110111;
    4'b1011:q_out = 8'b01111100;
    4'b1100:q_out = 8'b00111001;
    4'b1101:q_out = 8'b01011110;
    4'b1110:q_out = 8'b01111001;
    4'b1111:q_out = 8'b01110001;
    
    endcase
end
endmodule
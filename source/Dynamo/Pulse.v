module Pulse (

     //input

     clk_50m ,      //system clock;

     counter,       //
     
     rst,           //system reset, low is active

     en,

     //output

     pulse_out,     //????━?o?3???3?

   );

//parameter define

parameter WIDTH1 = 20;

parameter WIDTH2 = 27;


//input ports


input clk_50m;

input rst;

input en;


input [WIDTH1-1:0]counter;       


//output ports


output wire pulse_out;

//?D??????′????━??━?????━????：?|?


reg pulse;

reg [WIDTH2-1:0]div_cnt;

wire [WIDTH1-1:0]counter1;


//

assign counter1 = counter;

always @ (posedge clk_50m or negedge rst)begin

       if(!rst)

           div_cnt<=27'b0;

       else if(div_cnt==counter1)

           div_cnt<=27'b0;

       else

           div_cnt<=div_cnt+1'b1;

end


always @ (posedge clk_50m or negedge rst)begin

       if(!rst)

           pulse<=1'b0;

       else begin

           if(en==1)begin

              pulse<=1'b0;
           end

           else begin

              if (div_cnt==counter1)

                  pulse<=~pulse;

              else
                  pulse<=pulse;
              end
       end

end

assign pulse_out = pulse;

endmodule
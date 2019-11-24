module Count_pulse(

     //input

     pulse_in,        //pulse input 

     clk_50m,         //system_clk

     rst,             //fuwei

     //output


     speed            //0.1S de mai chong shumu cheng 10 cheng guiyihua can shu
      
     );


//input ports

input pulse_in;

input clk_50m;

input rst;

//output ports

output [23:0]speed;

//reg or wire

reg [23:0] count_speed;

reg [23:0] count_speed1;

reg [23:0] count_speed2;

wire [0:0] clk_10hz;

wire [0:0] clk_5hz;

//...................................................

clk_10hz clk1 (

     //input

     .clk_50m(clk_50m),
     
     .rst(rst),

     //output

     .clk_10hz(clk_10hz)

     );

//.......................................................

clk_5hz clk2 (

     //input

     .clk_50m(clk_50m),
     
     .rst(rst),

     //output

     .clk_5hz(clk_5hz)

     );

//............................................................

always @ (posedge pulse_in or negedge rst)begin

     if (!rst)begin

        count_speed2 <= 0;
 
        count_speed1 <= 0;

     end

     else begin
        
        if(clk_5hz==1)begin

        count_speed1 <= count_speed1 + 256;

        count_speed2 <= 0;

        end

        else begin

        count_speed2 <= count_speed2 + 256;

        count_speed1 <= 0;

        end       

     end
end

always @ (posedge clk_10hz or negedge rst)begin

     if(!rst)begin

        count_speed <= 0;

     end

     else begin

        count_speed <= count_speed1 + count_speed2 ;

     end

end

assign speed = count_speed ;

endmodule
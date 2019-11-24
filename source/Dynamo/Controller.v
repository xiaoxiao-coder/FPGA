module Controller(

     //input 

     clk_50m,             //system colck

     rst,

     x_pulse_in,            //pulse input

     y_pulse_in,

     kind,                // operation kind
  
    // xspeed_en,

    // xplace_en,

    // yspeed_en,

    // yplace_en,

     //output

     dirc_x,               //x operate direction

     dirc_y,               //y operate direction

     en_x,                //x en

     en_y,                //y en

     xcount,

     ycount,

     reg1,

     reg2,

     reg3,

     reg4

);

//x he y de wei zhi

parameter xx1 = 384000;         //1500

parameter yy1 = 332800;         //1300

parameter yy2 = 1459200;         //5700

parameter yy3 = 2252800;        //8800

// wucha
parameter Error1 = 3840;   //zhongjianwucha  //15

parameter Error2 = 78592;  //cengwucha          //307

parameter Error3 = 3840;   //shijiweizhi wucha    //15

parameter EC1 = 786432 ;       //3072

parameter EC2 = 524288;        //2048

parameter EC3 = 262144;      //1024

parameter EC4 = 65536;          //256

//pulse
parameter PL0 = 200000;

parameter PL1 = 200000;

parameter PL2 = 200000;

parameter PL3 = 200000;

parameter PL4 = 200000;

//jianxiao wucha

parameter xwc = 256;

parameter xwc1 = 375 ;

parameter ywc = 256;

parameter ywc1 = 256 ;


//input   

input clk_50m;

input rst;

input x_pulse_in;

input y_pulse_in;

input  [3:0] kind;

//input xspeed_en , xplace_en , yspeed_en , yplace_en ;


//output

output reg dirc_x;

output reg dirc_y;

output reg en_x;

output reg en_y;

output reg [20:0] xcount;

output reg [20:0] ycount;

output reg [3:0] reg1 , reg2 , reg3 , reg4 ;

//reg or wire

wire [23:0] xspeed , yspeed ;

reg [23:0] x , y ;

reg [23:0] xa , ya ;

reg [23:0] xplace1 , xplace2 ;  

reg [1:0] xdirc;   //shiji de fangwei

reg [1:0] xdirc1;  //yaoqiu de fangwei

reg [0:0] dirc;    //x zai zhonghian  shi de fangwei 

reg [0:0] dirc1;

reg [23:0] xc;

reg [23:0] yc;

reg [23:0] xe1 ;     //x zhou yun xu de wu cha  

wire [23:0] xe2;

wire[23:0] ye1 , ye2 ;     //y zhou yun xu de wu cha

wire[23:0] yee1 , yee2;    //y zhou de ke tiao wu cha ji zai tong yi ceng

wire [23:0] xze;            //x zhou zai zhong jian shi de yun xu wu cha 

//wire [3:0] kind1;

//wire [3:0] kind2;

reg xspeed_en , xplace_en , yspeed_en , yplace_en ;




//.......................................................................................................


//assign xe = Error1 ;

//assign ye = Error1 ;

//assign yee = Error2 ;

//assign kind1 = kind ;

//assign kind2 = 4'b0000;

assign xze = Error3 ;

assign yee1 = y - Error2 ;

assign yee2 = y + Error2 ;

//assign xe1 = x  ;

assign xe2 = x + Error1 ;

assign ye1 = y - Error1 ;

assign ye2 = y + Error1 ;

//.....................................................................................................

always @ (posedge clk_50m)begin

     if (x>=Error1)begin

         xe1 <= x - Error1;

     end

     else begin

        xe1 <= x;

     end





end


//................     moshi duiying de zhi de sheding     ...........................................


always @ (posedge clk_50m )begin


        case(kind)

           4'b0000:begin xdirc1<=2'b10; x<=0;  y<=yy1;  xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ; end     //0

           4'b0001:begin xdirc1<=2'b00; x<=xx1; y<=yy1;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //1

           4'b0010:begin xdirc1<=2'b01; x<=xx1; y<=yy1;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //2

           4'b0011:begin xdirc1<=2'b00; x<=xx1; y<=yy2;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //3

           4'b0100:begin xdirc1<=2'b01; x<=xx1; y<=yy2;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //4

           4'b0101:begin xdirc1<=2'b00; x<=xx1; y<=yy3;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //5

           4'b0110:begin xdirc1<=2'b01; x<=xx1; y<=yy3;xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end     //6

           4'b0111:begin xdirc1<=2'b10; x<=0;  y<=yy3; xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ; end     //7
           
           4'b1000:begin xdirc1<=xdirc1; x<=x;  y<=y; xspeed_en<=1 ; xplace_en<=0 ; yspeed_en<=0 ; yplace_en<=0 ; end //8

           4'b1001:begin xdirc1<=xdirc1; x<=x;  y<=y; xspeed_en<=0 ; xplace_en<=1 ; yspeed_en<=0 ; yplace_en<=0 ;end//9

           4'b1010:begin xdirc1<=xdirc1; x<=x;  y<=y; xspeed_en<=0 ; xplace_en<=0 ; yspeed_en<=1 ; yplace_en<=0 ;end//10

           4'b1011:begin xdirc1<=xdirc1; x<=x;  y<=y; xspeed_en<=0 ; xplace_en<=0 ; yspeed_en<=0 ; yplace_en<=1 ; end //11

           default:begin xdirc1<=xdirc1;x<=x;  y<=y; xspeed_en<=xspeed_en ; xplace_en<=xplace_en ; yspeed_en<=yspeed_en ; yplace_en<=yplace_en ;  end

           //4'b0000:begin xdirc1<=2'b10; x<=16'b0000000000000000; y<=16'b0000000000110101;  end     //0

           //4'b0001:begin xdirc1<=2'b00; x<=16'b0000000000101011; y<=16'b0000000000110101;  end     //1

           //4'b0010:begin xdirc1<=2'b01; x<=16'b0000000000101011; y<=16'b0000000000110101;  end     //2

           //4'b0011:begin xdirc1<=2'b00; x<=16'b0000000000101011; y<=16'b0000000001110111;  end     //3

           //4'b0100:begin xdirc1<=2'b01; x<=16'b0000000000101011; y<=16'b0000000001110111;  end     //4

           //4'b0101:begin xdirc1<=2'b00; x<=16'b0000000000101011; y<=16'b0000000010110111;  end     //5

           //4'b0110:begin xdirc1<=2'b01; x<=16'b0000000000101011; y<=16'b0000000010110111;  end     //6

           //4'b0111:begin xdirc1<=2'b10; x<=16'b0000000000000000; y<=16'b0000000010110111;  end     //7
     
        endcase    

end


//........................zai x zhou zhongjian shi de xdirc zhi duiying de yunxing fangxiang .................................


always @ (posedge clk_50m or negedge rst)begin

     if(!rst)begin

        dirc <= dirc ;

     end

     else begin

        if (xdirc1 == 2'b00)begin                  //yao qiu zai zuo ce

           dirc <= 1'b1 ;    
      
        end

        else if (xdirc1 == 2'b01)begin

           dirc <= 1'b0 ;

        end

        else begin

           dirc <= dirc1 ;

        end

     end

        


end



//.......................zai xzhou shang zuoyi he youyi de jishu .............................................


always @ (posedge x_pulse_in or negedge rst)begin

     if(!rst)begin

        xplace1 <= 0 ;

        xplace2 <= 0 ;
//
        //xplace1 <= 16'b0000000000000000 ;

        //xplace2 <= 16'b0000000000000000 ;

     end

     else begin

     if(en_x == 0)begin
    
        if(dirc_x==1)begin
     
           xplace1 <= xplace1 + xwc ; 

           xplace2 <= xplace2 ;
   
        end
  
        else begin

           xplace2 <= xplace2 + xwc1 ;

           xplace1 <= xplace1 ;

        end 

     end
     
     else begin

           xplace1 <= xplace1 ;
   
           xplace2 <= xplace2 ;

     end  

     end

end


//......................jisuan xa he xdirc..................................................


always @ (posedge clk_50m or negedge rst)begin

  if (!rst)begin

     xa <=0 ;

  end
  else begin

     if(xplace1 > xplace2)begin

        xa <= xplace1 - xplace2 ;
 
        xdirc <= 2'b00 ;

     end

     else if (xplace1 < xplace2)begin

        xa <= xplace2 - xplace1 ;

        xdirc <= 2'b01 ;

     end

     else begin

        xa <= 0;

        xdirc <= 2'b10;

     end
  end

end

//...........................................................................................................


always @ (posedge clk_50m )begin

     if(xdirc == xdirc1)begin

       if(x>=xa)begin

          xc <= x - xa;

       end

       else begin

          xc <= xa - x ;
       
       end

     end

     else begin

        xc <= x + xa;

     end

end

//............................................................................................................
always @(posedge clk_50m )begin

     if( y >= ya )begin

        yc <= y - ya ;

     end

     else begin

        yc <= ya - y;

     end

end

//............................................................................................................

always @ (posedge clk_50m or negedge rst)begin

     if(!rst)begin

        xcount <= PL0;

        //xcount <= 21'b000111101000010010000;      //250000//100hz
 
     end

     else begin

        if( xc > EC1)begin

           xcount <= PL4; 

           //xcount <= 21'b000001100001101010000;       //50000//500hz

        end

        else if ( (EC2 < xc) && (xc <= EC1)) begin

           xcount <= PL3; 

           //xcount <= 21'b000011000011010100000;         //100000//400hz

        end

        else if ( (EC3 < xc) && (xc <= EC2)) begin

           xcount <= PL2;

           //xcount <= 21'b000100100100111110000;         //150000//300hz

        end

        else if ( (EC4 < xc) && (xc <= EC3)) begin

           xcount <= PL1;

           //xcount <= 21'b000110000110101000000;        //200000//200hz

        end

        else begin

           xcount <= PL0;

           //xcount <= 21'b000111101000010010000;        //250000//100hz

        end     

     end

end

//............................................................................................................


always @ (posedge clk_50m or negedge rst)begin

     if(!rst)begin

        ycount <= PL0;

        //ycount <= 21'b000111101000010010000;      //250000//100hz 

     end
     
     else begin
        if( yc > EC1)begin

           ycount <= PL4; 

           //ycount <= 21'b000001100001101010000;       //50000//500hz

        end

        else if ( (EC2 < yc) && (yc <= EC1)) begin

           ycount <= PL3; 

           //ycount <= 21'b000011000011010100000;         //100000//400hz

        end

        else if ( (EC3 < yc) && (yc <= EC2)) begin

           ycount <= PL2; 

           //ycount <= 21'b000100100100111110000;         //150000//300hz

        end

        else if ( (EC4 < yc) && (yc <= EC3)) begin

           ycount <= PL1; 

           //ycount <= 21'b000110000110101000000;        //200000//200hz

        end

        else begin

           ycount <= PL0; 

           //ycount <= 21'b000111101000010010000;        //250000//100hz

        end     

     end
end

//...............................cishi de x zhou fangwei duiyin de x zhou yi dong ............................


always @ (posedge clk_50m)begin

     if(xdirc == 2'b00)begin

        dirc1 <= 1'b0;

     end

     else if (xdirc == 2'b01)begin

        dirc1 <= 1'b1;

     end
     
     else begin

        dirc1 <= dirc1 ;

     end


end


//.............................zai yzhou shangyi he xia yi de jishu ....................


always @ (posedge y_pulse_in or negedge rst)begin

     if(!rst)begin

        ya <= 0 ;

        //ya <= 16'b0000000000000000 ;

     end

     else begin

     if (en_y == 0)begin

        if(dirc_y == 1'b0)begin           //shangyi

           ya <= ya + ywc ;    

        end

        else begin

           ya <= ya - ywc1;                 //xiayi

        end
 
     end

     else begin

        ya <= ya ;

     end

     end

end


//................................zhuangtaiji kongzhi  ..................................



always @ (posedge clk_50m or negedge rst)begin

     if(!rst)begin

        en_x <= 1'b1;

        en_y <= 1'b1;

     end

     else begin

        if( (yee1 <= ya) && (ya <= yee2))begin                       //tongceng

           if((ye1 <= ya) && (ya <= ye2))begin                       //yzhou zai zhiding weizhi

              en_y <= 1'b1; 

              if(xa <= xze)begin      //zai xzhou zhongjian

                 if(x==0)begin 

                 //if(x==16'b0000000000000000)begin            //yunxu wuchafanwei nei ji xzai zhiding weizhi 

                    en_x <= 1'b1;

                 end

                 else begin

                    dirc_x <= dirc;
                    
                    en_x <= 1'b0;

                 end
              
              end

              else begin

                 if(xdirc == xdirc1)begin         //tong fang wei zhi
 
                    if((xe1 <= xa) && (xa <= xe2))begin     //xzhou zai zhiding weizhi 

                       en_x <= 1'b1;

                    end

                    else if (xa <= xe1)begin    //tongfangxiang weiyi bugou
            
                       en_x <= 1'b0;
                       
                       dirc_x <= dirc;        
                        
                    end

                    else begin                //tongfangxiang weiyi guotou 

                       en_x <= 1'b0;
                   
                       dirc_x <= !dirc;
 
                    end

                 end

                 else begin                     //buzai tongfangxiang de weizi

                    en_x <= 1'b0;
 
                    dirc_x <= dirc; 

                 end

              end

           end

           else if (ya > ye2) begin
   
              dirc_y <= 1'b1;
    
              en_y <= 1'b0;

           end
 
           else begin

               dirc_y <= 1'b0;
      
               en_y <= 1'b0;

           end

        end

        else begin                  //bu tong ceng

           if(xa <= xze)begin        //pan duan ci shi x shifou zai zhong jian //zai zhongjian 
 
              en_x <= 1'b1;

              if(ya > y)begin              //pandan y zhou shi pianshang haishi piania //pianshangqiangkuang

                 dirc_y <= 1'b1 ;          //xiangxiayi

                 en_y <= 1'b0;


              end   
              
              else begin

                 dirc_y <= 1'b0;

                 en_y <= 1'b0;
               
              end         

           end

           else begin

              dirc_x <= dirc1;
              
              en_x <= 1'b0;

           end

        end

     end

end


always @ (posedge clk_50m or negedge rst)begin

     if(!rst)begin

        reg1 <= 0;
 
        reg2 <= 0;

        reg3 <= 0;

        reg4 <= 0;

     end

     else begin

        if(xspeed_en==1)begin

           reg1 <= xspeed[11:8] ;

           reg2 <= xspeed[15:12] ;

           reg3 <= xspeed[19:16];

           reg4 <= xspeed[23:20];

        end

        else if(xplace_en==1)begin

           reg1 <= xa[11:8] ;

           reg2 <= xa[15:12] ;

           reg3 <= xa[19:16];

           reg4 <= xa[23:20];

        end

        else if(yspeed_en==1)begin

           reg1 <= yspeed[11:8] ;

           reg2 <= yspeed[15:12] ;

           reg3 <= yspeed[19:16];

           reg4 <= yspeed[23:20];

        end

        else if(yplace_en==1)begin

           reg1 <= ya[11:8] ;

           reg2 <= ya[15:12] ;

           reg3 <= ya[19:16];

           reg4 <= ya[23:20];

        end
        else begin

           reg1 <= 0 ;

           reg2 <= 0 ;

           reg3 <= 0;

           reg4 <= 0;     

        end

     end

end

 
Count_pulse X1(

     //input

     .pulse_in(x_pulse_in),        //pulse input 

     .clk_50m(clk_50m),         //system_clk

     .rst(rst),             //fuwei

     //output


     .speed(xspeed)            //0.1S de mai chong shumu cheng 10 cheng guiyihua can shu
      
     );

 Count_pulse Y1(

     //input

     .pulse_in(y_pulse_in),        //pulse input 

     .clk_50m(clk_50m),         //system_clk

     .rst(rst),             //fuwei

     //output


     .speed(yspeed)            //0.1S de mai chong shumu cheng 10 cheng guiyihua can shu
      
     );


endmodule


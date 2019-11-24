module keyboard_buffer(
    input clk,
    input reset,
    input wire [3:0]row,
    //output wire [7:0]keystrokes,
    output wire [3:0]col,
    //output reg xspeed_en,
    //output reg xplace_en,
    //output reg yspeed_en,
    //output reg yplace_en,
    output reg [3:0]data
    );
    wire [7:0]keystrokes;
    wire [3:0]key_value;
    reg [7:0]keystrokes_1=0;
    
    keyboard_encoder u_keyboard_encoder_0( //????¡ì?1????¡ì?????¡§???¡ì?¡ì???¡ì????¨¬??¨¬?????
            .clk(clk),
            .reset(reset),
            .row(row),
            .col(col),
            .key_value(key_value),
            .keystrokes(keystrokes)
            );
    
    always@(posedge clk or negedge reset)
        begin
            if(!reset)
                begin
                    data <=0 ;
                    //xspeed_en <=0 ;
                    //xplace_en <=0 ;
                    //yspeed_en <=0 ;
                    //yplace_en <=0 ;
                          
                end
            else if(keystrokes_1!=keystrokes)
                begin
                    keystrokes_1<=keystrokes;
                    //if((key_value>=0)&&(key_value<=7))//??????0-7
                       // begin
                     data<=key_value;
                         //   xspeed_en <= xspeed_en;
                    //        xplace_en <= xplace_en;
                    //        yspeed_en <= yspeed_en;
                    //        yplace_en <= yplace_en;
                   //     end
                   // else if (key_value == 8)
                     //   begin
                   //         data <= key_value;
                    //        xspeed_en <= 1;
                    //        xplace_en <= 0;
                     //       yspeed_en <= 0;
                     //       yplace_en <= 0;
                    //    end
                   // else if (key_value == 9)
                    //    begin
                    //        data <= key_value;
                     //       xspeed_en <= 0;
                       //     xplace_en <= 1;
                      //      yspeed_en <= 0;
                      //      yplace_en <= 0;
                     //   end
                 //   else if (key_value == 10)
                     //   begin
                     ///       data <= key_value;
                      //      xspeed_en <= 0;
                     //       xplace_en <= 0;
                     //       yspeed_en <= 1;
                    //        yplace_en <= 0;
                    //    end
                  //  else if (key_value == 11)
                      //  begin
                       //     data <= key_value;
                      //      xspeed_en <= 0;
                       //     xplace_en <= 0;
                        //    yspeed_en <= 0;
                       //     yplace_en <= 1;
                       // end

                    //else
                       // begin
                          //  data <= key_value ;
                          //  xspeed_en <= xspeed_en;
                          //  xplace_en <= xplace_en;
                           // yspeed_en <= yspeed_en;
                           // yplace_en <= yplace_en;
                       // end
                end
            else
                begin
                      data = data ;
                      //xspeed_en <= 0;
                      //xplace_en <= 0;
                      //yspeed_en <= 0;
                      //yplace_en <= 0;
                end
        end
endmodule
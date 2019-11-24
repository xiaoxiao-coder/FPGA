module keyboard_encoder(
    input clk,
    input reset,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg [7:0] keystrokes
    );
    reg [19:0] count;//50hz  count=5,000,00  2^20=1,048,576
    reg [2:0] state;  //?¡§¡é???¡ì???¡§¡è?¡ìo??
    reg key_flag;   //??????¡ì1?¡§¡è?¡ìo????
    reg clk_50hz;  //50HZ?¡ìo?¡§¡è??¡ì?D?o?
    
    reg [3:0] col_reg;  //??????¡ì|??¨¬??¡ì?¡ì3?|¡§???¡ì?¨¦D?|¡§?
    reg [3:0] row_reg;  //??????¡ì|??¨¬??¡ì?¡ì3?|¡§??DD?|¡§?
    
    always @(posedge clk or negedge reset)
    if(!reset)
        begin
            clk_50hz<=0;
            count<=0;
        end
    else
        begin
        if(count>=500000)
            begin
                clk_50hz<=~clk_50hz;
                count<=0;
            end
        else count<=count+1;
        end

    always @(posedge clk_50hz or negedge reset)
    if(!reset)
        begin
            col<=4'b0000;
            state<=0;
        end
    else
    begin
        case (state)
            0: 
                begin
                    col[3:0]<=4'b0000;
                    key_flag<=1'b0;
                    if(row[3:0]!=4'b1111)
                        begin
                            state<=1;
                            col[3:0]<=4'b1110;
                        end //?¡ì?D??¡ì1???????¡§o??¡ì|??¨¬??¡ì?¡ì|¡§??¡ì2?¡ì???DD
                    else state<=0;
                end
            1:
                begin
                if(row[3:0]!=4'b1111)
                    state<=5;   //?D???¡ìo???¨¨??¡ìo?|¡§??¡ì2?¡ì???DD
                else
                    begin
                        state<=2;
                        col[3:0]<=4'b1101;
                    end  //?¡ì|??¨¬??¡ì?¡ì|¡§??¡ì2?tDD
                end 
            2:
                begin    
                if(row[3:0]!=4'b1111)
                    state<=5;//?D???¡ìo???¨¨??¡ìo?|¡§??¡ì2?tDD
                else
                    begin
                        state<=3;
                        col[3:0]<=4'b1011;
                    end  //?¡ì|??¨¬??¡ì?¡ì|¡§??¡ì2?¡ì?¡ìyDD
                end
            3:
                begin    
                    if(row[3:0]!=4'b1111)
                        state<=5;//?D???¡ìo???¨¨??¡ìo?|¡§??¡ì2?¡ì?¡ìyDD
                    else
                        begin
                            state<=4;
                            col[3:0]<=4'b0111;
                        end  //?¡ì|??¨¬??¡ì?¡ì|¡§??¡ì2??DD
                end
            4:
                begin    
                    if(row[3:0]!=4'b1111)
                        state<=5;//?D???¡ìo???¨¨??¡ìo?|¡§??¡ì2??DD
                    else  state<=0;
                end
        
            5:
                begin  
                    if(row[3:0]!=4'b1111) 
                        begin
                            col_reg<=col;  //?¡§¡è?¡§o????¡ì|??¨¬??¡ì?¡ì?¡ì?¨¦D?|¡§?
                            row_reg<=row;  //?¡§¡è?¡§o????¡ì|??¨¬??¡ì?¡ìDD?|¡§?
                            state<=5;
                            key_flag<=1'b1;  //?¡ì?D??¡ì1??????
                        end
                    else
                        state<=0;
                end
        endcase
    end

    always @(clk_50hz or col_reg or row_reg or key_flag)
        begin
           if(key_flag==1'b1) 
                   begin
                        case ({col_reg,row_reg})
                             8'b1110_1110:key_value<=0; //1
                             8'b1110_1101:key_value<=1;  //2
                             8'b1110_1011:key_value<=2;  //3
                             8'b1110_0111:key_value<=3;  //10
                          
                             8'b1101_1110:key_value<=4;  //4
                             8'b1101_1101:key_value<=5;  //5
                             8'b1101_1011:key_value<=6;   //6
                             8'b1101_0111:key_value<=7;  //11
        
                             8'b1011_1110:key_value<=8;  //7
                             8'b1011_1101:key_value<=9;  //8
                             8'b1011_1011:key_value<=10;  //9
                             8'b1011_0111:key_value<=11;  //12
        
                             8'b0111_1110:key_value<=12;  //14
                             8'b0111_1101:key_value<=13;  //0
                             8'b0111_1011:key_value<=14;  //15
                             8'b0111_0111:key_value<=15;  //13
                             default:     key_value<=0;
                        endcase 
                 end   
      end  
    always@(posedge key_flag or negedge reset)
        if(!reset)
            keystrokes<=0;
        else
            begin
                keystrokes<=keystrokes+1;
            end
endmodule
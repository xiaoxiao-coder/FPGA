//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           i2c_ov5640_rgb565_cfg
// Last modified Date:  2018/3/21 14:26:05
// Last Version:        V1.0
// Descriptions:        i2c配置
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/21 14:26:05
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module i2c_ov5640_rgb565_cfg
  #(
    parameter CMOS_H_PIXEL = 24'd1024,//CMOS水平方向像素个数
    parameter CMOS_V_PIXEL = 24'd768  //CMOS垂直方向像素个数
    )
   (  
    input                clk      ,   //时钟信号
    input                rst_n    ,   //复位信号，低电平有效
    
    input                i2c_done ,   //I2C寄存器配置完成信号
    output  reg          i2c_exec ,   //I2C触发执行信号   
    output  reg  [23:0]  lut_data ,   //I2C要配置的地址与数据(高16位地址,低8位数据)
    output  reg          init_done    //初始化完成信号
    );

//parameter define
localparam  REG_NUM = 8'd248  ;       //总共需要配置的寄存器个数
localparam  TOTAL_H_PIXEL = CMOS_H_PIXEL + 13'd1216;  //水平总像素大小
localparam  TOTAL_V_PIXEL = CMOS_V_PIXEL + 13'd504;   //垂直总像素大小

//reg define
reg   [14:0]   start_init_cnt;        //等待延时计数器
reg    [7:0]   init_reg_cnt  ;        //寄存器配置个数计数器

//*****************************************************
//**                    main code
//*****************************************************

//cam_scl配置成250khz,输入的clk为1Mhz,周期为1us,20000*1us = 20ms
//OV5640上电到开始配置IIC至少等待20ms
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        start_init_cnt <= 15'd0;
    else if(start_init_cnt < 15'd20000)
        start_init_cnt <= start_init_cnt + 1'b1;                    
end

//寄存器配置个数计数    
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        init_reg_cnt <= 8'd0;
    else if(i2c_exec)   
        init_reg_cnt <= init_reg_cnt + 8'b1;
end

//i2c触发执行信号   
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        i2c_exec <= 1'b0;
    else if(start_init_cnt == 15'd19999)
        i2c_exec <= 1'b1;
    else if(i2c_done && (init_reg_cnt < REG_NUM))
        i2c_exec <= 1'b1;
    else
        i2c_exec <= 1'b0;
end 

//初始化完成信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        init_done <= 1'b0;
    else if((init_reg_cnt == REG_NUM) && i2c_done)  
        init_done <= 1'b1;  
end

//配置寄存器地址与数据
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        lut_data <= 24'd0;
    else begin
        case(init_reg_cnt)
            //先对寄存器进行软件复位，使寄存器恢复初始值
            8'd0  : lut_data <= {8'h78,16'h3008,8'h82}; //Bit[7]:复位 Bit[6]:电源休眠
            8'd1  : lut_data <= {8'h78,16'h3008,8'h02}; //正常工作模式
            8'd2  : lut_data <= {8'h78,16'h3103,8'h02}; //Bit[1]:1 PLL Clock
            //引脚输入/输出控制 FREX/VSYNC/HREF/PCLK/D[9:6]
            8'd3  : lut_data <= {8'h78,8'h30,8'h17,8'hff};
            //引脚输入/输出控制 D[5:0]/GPIO1/GPIO0 
            8'd4  : lut_data <= {8'h78,16'h3018,8'hff};
            8'd5  : lut_data <= {8'h78,16'h3037,8'h13}; //PLL分频控制
            8'd6  : lut_data <= {8'h78,16'h3108,8'h01}; //系统根分频器
            8'd7  : lut_data <= {8'h78,16'h3630,8'h36};
            8'd8  : lut_data <= {8'h78,16'h3631,8'h0e};
            8'd9  : lut_data <= {8'h78,16'h3632,8'he2};
            8'd10 : lut_data <= {8'h78,16'h3633,8'h12};
            8'd11 : lut_data <= {8'h78,16'h3621,8'he0};
            8'd12 : lut_data <= {8'h78,16'h3704,8'ha0};
            8'd13 : lut_data <= {8'h78,16'h3703,8'h5a};
            8'd14 : lut_data <= {8'h78,16'h3715,8'h78};
            8'd15 : lut_data <= {8'h78,16'h3717,8'h01};
            8'd16 : lut_data <= {8'h78,16'h370b,8'h60};
            8'd17 : lut_data <= {8'h78,16'h3705,8'h1a};
            8'd18 : lut_data <= {8'h78,16'h3905,8'h02};
            8'd19 : lut_data <= {8'h78,16'h3906,8'h10};
            8'd20 : lut_data <= {8'h78,16'h3901,8'h0a};
            8'd21 : lut_data <= {8'h78,16'h3731,8'h12};
            8'd22 : lut_data <= {8'h78,16'h3600,8'h08}; //VCM控制,用于自动聚焦
            8'd23 : lut_data <= {8'h78,16'h3601,8'h33}; //VCM控制,用于自动聚焦
            8'd24 : lut_data <= {8'h78,16'h302d,8'h60}; //系统控制
            8'd25 : lut_data <= {8'h78,16'h3620,8'h52};
            8'd26 : lut_data <= {8'h78,16'h371b,8'h20};
            8'd27 : lut_data <= {8'h78,16'h471c,8'h50};
            8'd28 : lut_data <= {8'h78,16'h3a13,8'h43}; //AEC(自动曝光控制)
            8'd29 : lut_data <= {8'h78,16'h3a18,8'h00}; //AEC 增益上限
            8'd30 : lut_data <= {8'h78,16'h3a19,8'hf8}; //AEC 增益上限
            8'd31 : lut_data <= {8'h78,16'h3635,8'h13};
            8'd32 : lut_data <= {8'h78,16'h3636,8'h03};
            8'd33 : lut_data <= {8'h78,16'h3634,8'h40};
            8'd34 : lut_data <= {8'h78,16'h3622,8'h01};
            8'd35 : lut_data <= {8'h78,16'h3c01,8'h34};
            8'd36 : lut_data <= {8'h78,16'h3c04,8'h28};
            8'd37 : lut_data <= {8'h78,16'h3c05,8'h98};
            8'd38 : lut_data <= {8'h78,16'h3c06,8'h00}; //light meter 1 阈值[15:8]
            8'd39 : lut_data <= {8'h78,16'h3c07,8'h08}; //light meter 1 阈值[7:0]
            8'd40 : lut_data <= {8'h78,16'h3c08,8'h00}; //light meter 2 阈值[15:8]
            8'd41 : lut_data <= {8'h78,16'h3c09,8'h1c}; //light meter 2 阈值[7:0]
            8'd42 : lut_data <= {8'h78,16'h3c0a,8'h9c}; //sample number[15:8]
            8'd43 : lut_data <= {8'h78,16'h3c0b,8'h40}; //sample number[7:0]
            8'd44 : lut_data <= {8'h78,16'h3810,8'h00}; //Timing Hoffset[11:8]
            8'd45 : lut_data <= {8'h78,16'h3811,8'h10}; //Timing Hoffset[7:0]
            8'd46 : lut_data <= {8'h78,16'h3812,8'h00}; //Timing Voffset[10:8]
            8'd47 : lut_data <= {8'h78,16'h3708,8'h64};
            8'd48 : lut_data <= {8'h78,16'h4001,8'h02}; //BLC(黑电平校准)补偿起始行号
            8'd49 : lut_data <= {8'h78,16'h4005,8'h1a}; //BLC(黑电平校准)补偿始终更新
            8'd50 : lut_data <= {8'h78,16'h3000,8'h00}; //系统块复位控制
            8'd51 : lut_data <= {8'h78,16'h3004,8'hff}; //时钟使能控制
            8'd52 : lut_data <= {8'h78,16'h4300,8'h61}; //格式控制 RGB565
            8'd53 : lut_data <= {8'h78,16'h501f,8'h01}; //ISP RGB
            8'd54 : lut_data <= {8'h78,16'h440e,8'h00};
            8'd55 : lut_data <= {8'h78,16'h5000,8'ha7}; //ISP控制
            8'd56 : lut_data <= {8'h78,16'h3a0f,8'h30}; //AEC控制;stable range in high
            8'd57 : lut_data <= {8'h78,16'h3a10,8'h28}; //AEC控制;stable range in low
            8'd58 : lut_data <= {8'h78,16'h3a1b,8'h30}; //AEC控制;stable range out high
            8'd59 : lut_data <= {8'h78,16'h3a1e,8'h26}; //AEC控制;stable range out low
            8'd60 : lut_data <= {8'h78,16'h3a11,8'h60}; //AEC控制; fast zone high
            8'd61 : lut_data <= {8'h78,16'h3a1f,8'h14}; //AEC控制; fast zone low
            //LENC(镜头校正)控制 16'h5800~16'h583d
            8'd62 : lut_data <= {8'h78,16'h5800,8'h23}; 
            8'd63 : lut_data <= {8'h78,16'h5801,8'h14};
            8'd64 : lut_data <= {8'h78,16'h5802,8'h0f};
            8'd65 : lut_data <= {8'h78,16'h5803,8'h0f};
            8'd66 : lut_data <= {8'h78,16'h5804,8'h12};
            8'd67 : lut_data <= {8'h78,16'h5805,8'h26};
            8'd68 : lut_data <= {8'h78,16'h5806,8'h0c};
            8'd69 : lut_data <= {8'h78,16'h5807,8'h08};
            8'd70 : lut_data <= {8'h78,16'h5808,8'h05};
            8'd71 : lut_data <= {8'h78,16'h5809,8'h05};
            8'd72 : lut_data <= {8'h78,16'h580a,8'h08};
            8'd73 : lut_data <= {8'h78,16'h580b,8'h0d};
            8'd74 : lut_data <= {8'h78,16'h580c,8'h08};
            8'd75 : lut_data <= {8'h78,16'h580d,8'h03};
            8'd76 : lut_data <= {8'h78,16'h580e,8'h00};
            8'd77 : lut_data <= {8'h78,16'h580f,8'h00};
            8'd78 : lut_data <= {8'h78,16'h5810,8'h03};
            8'd79 : lut_data <= {8'h78,16'h5811,8'h09};
            8'd80 : lut_data <= {8'h78,16'h5812,8'h07};
            8'd81 : lut_data <= {8'h78,16'h5813,8'h03};
            8'd82 : lut_data <= {8'h78,16'h5814,8'h00};
            8'd83 : lut_data <= {8'h78,16'h5815,8'h01};
            8'd84 : lut_data <= {8'h78,16'h5816,8'h03};
            8'd85 : lut_data <= {8'h78,16'h5817,8'h08};
            8'd86 : lut_data <= {8'h78,16'h5818,8'h0d};
            8'd87 : lut_data <= {8'h78,16'h5819,8'h08};
            8'd88 : lut_data <= {8'h78,16'h581a,8'h05};
            8'd89 : lut_data <= {8'h78,16'h581b,8'h06};
            8'd90 : lut_data <= {8'h78,16'h581c,8'h08};
            8'd91 : lut_data <= {8'h78,16'h581d,8'h0e};
            8'd92 : lut_data <= {8'h78,16'h581e,8'h29};
            8'd93 : lut_data <= {8'h78,16'h581f,8'h17};
            8'd94 : lut_data <= {8'h78,16'h5820,8'h11};
            8'd95 : lut_data <= {8'h78,16'h5821,8'h11};
            8'd96 : lut_data <= {8'h78,16'h5822,8'h15};
            8'd97 : lut_data <= {8'h78,16'h5823,8'h28};
            8'd98 : lut_data <= {8'h78,16'h5824,8'h46};
            8'd99 : lut_data <= {8'h78,16'h5825,8'h26};
            8'd100: lut_data <= {8'h78,16'h5826,8'h08};
            8'd101: lut_data <= {8'h78,16'h5827,8'h26};
            8'd102: lut_data <= {8'h78,16'h5828,8'h64};
            8'd103: lut_data <= {8'h78,16'h5829,8'h26};
            8'd104: lut_data <= {8'h78,16'h582a,8'h24};
            8'd105: lut_data <= {8'h78,16'h582b,8'h22};
            8'd106: lut_data <= {8'h78,16'h582c,8'h24};
            8'd107: lut_data <= {8'h78,16'h582d,8'h24};
            8'd108: lut_data <= {8'h78,16'h582e,8'h06};
            8'd109: lut_data <= {8'h78,16'h582f,8'h22};
            8'd110: lut_data <= {8'h78,16'h5830,8'h40};
            8'd111: lut_data <= {8'h78,16'h5831,8'h42};
            8'd112: lut_data <= {8'h78,16'h5832,8'h24};
            8'd113: lut_data <= {8'h78,16'h5833,8'h26};
            8'd114: lut_data <= {8'h78,16'h5834,8'h24};
            8'd115: lut_data <= {8'h78,16'h5835,8'h22};
            8'd116: lut_data <= {8'h78,16'h5836,8'h22};
            8'd117: lut_data <= {8'h78,16'h5837,8'h26};
            8'd118: lut_data <= {8'h78,16'h5838,8'h44};
            8'd119: lut_data <= {8'h78,16'h5839,8'h24};
            8'd120: lut_data <= {8'h78,16'h583a,8'h26};
            8'd121: lut_data <= {8'h78,16'h583b,8'h28};
            8'd122: lut_data <= {8'h78,16'h583c,8'h42};
            8'd123: lut_data <= {8'h78,16'h583d,8'hce};
            //AWB(自动白平衡控制) 16'h5180~16'h519e
            8'd124: lut_data <= {8'h78,16'h5180,8'hff};
            8'd125: lut_data <= {8'h78,16'h5181,8'hf2};
            8'd126: lut_data <= {8'h78,16'h5182,8'h00};
            8'd127: lut_data <= {8'h78,16'h5183,8'h14};
            8'd128: lut_data <= {8'h78,16'h5184,8'h25};
            8'd129: lut_data <= {8'h78,16'h5185,8'h24};
            8'd130: lut_data <= {8'h78,16'h5186,8'h09};
            8'd131: lut_data <= {8'h78,16'h5187,8'h09};
            8'd132: lut_data <= {8'h78,16'h5188,8'h09};
            8'd133: lut_data <= {8'h78,16'h5189,8'h75};
            8'd134: lut_data <= {8'h78,16'h518a,8'h54};
            8'd135: lut_data <= {8'h78,16'h518b,8'he0};
            8'd136: lut_data <= {8'h78,16'h518c,8'hb2};
            8'd137: lut_data <= {8'h78,16'h518d,8'h42};
            8'd138: lut_data <= {8'h78,16'h518e,8'h3d};
            8'd139: lut_data <= {8'h78,16'h518f,8'h56};
            8'd140: lut_data <= {8'h78,16'h5190,8'h46};
            8'd141: lut_data <= {8'h78,16'h5191,8'hf8};
            8'd142: lut_data <= {8'h78,16'h5192,8'h04};
            8'd143: lut_data <= {8'h78,16'h5193,8'h70};
            8'd144: lut_data <= {8'h78,16'h5194,8'hf0};
            8'd145: lut_data <= {8'h78,16'h5195,8'hf0};
            8'd146: lut_data <= {8'h78,16'h5196,8'h03};
            8'd147: lut_data <= {8'h78,16'h5197,8'h01};
            8'd148: lut_data <= {8'h78,16'h5198,8'h04};
            8'd149: lut_data <= {8'h78,16'h5199,8'h12};
            8'd150: lut_data <= {8'h78,16'h519a,8'h04};
            8'd151: lut_data <= {8'h78,16'h519b,8'h00};
            8'd152: lut_data <= {8'h78,16'h519c,8'h06};
            8'd153: lut_data <= {8'h78,16'h519d,8'h82};
            8'd154: lut_data <= {8'h78,16'h519e,8'h38};
            //Gamma(伽马)控制 16'8'h78,h5480~16'h5490
            8'd155: lut_data <= {8'h78,16'h5480,8'h01}; 
            8'd156: lut_data <= {8'h78,16'h5481,8'h08};
            8'd157: lut_data <= {8'h78,16'h5482,8'h14};
            8'd158: lut_data <= {8'h78,16'h5483,8'h28};
            8'd159: lut_data <= {8'h78,16'h5484,8'h51};
            8'd160: lut_data <= {8'h78,16'h5485,8'h65};
            8'd161: lut_data <= {8'h78,16'h5486,8'h71};
            8'd162: lut_data <= {8'h78,16'h5487,8'h7d};
            8'd163: lut_data <= {8'h78,16'h5488,8'h87};
            8'd164: lut_data <= {8'h78,16'h5489,8'h91};
            8'd165: lut_data <= {8'h78,16'h548a,8'h9a};
            8'd166: lut_data <= {8'h78,16'h548b,8'haa};
            8'd167: lut_data <= {8'h78,16'h548c,8'hb8};
            8'd168: lut_data <= {8'h78,16'h548d,8'hcd};
            8'd169: lut_data <= {8'h78,16'h548e,8'hdd};
            8'd170: lut_data <= {8'h78,16'h548f,8'hea};
            8'd171: lut_data <= {8'h78,16'h5490,8'h1d};
            //CMX(彩色矩阵控制) 18'h78,6'h5381~16'h538b
            8'd172: lut_data <= {8'h78,16'h5381,8'h1e};
            8'd173: lut_data <= {8'h78,16'h5382,8'h5b};
            8'd174: lut_data <= {8'h78,16'h5383,8'h08};
            8'd175: lut_data <= {8'h78,16'h5384,8'h0a};
            8'd176: lut_data <= {8'h78,16'h5385,8'h7e};
            8'd177: lut_data <= {8'h78,16'h5386,8'h88};
            8'd178: lut_data <= {8'h78,16'h5387,8'h7c};
            8'd179: lut_data <= {8'h78,16'h5388,8'h6c};
            8'd180: lut_data <= {8'h78,16'h5389,8'h10};
            8'd181: lut_data <= {8'h78,16'h538a,8'h01};
            8'd182: lut_data <= {8'h78,16'h538b,8'h98};
            //SDE(特殊数码效果)控制 16'h5580~16'h558b
            8'd183: lut_data <= {8'h78,16'h5580,8'h06};
            8'd184: lut_data <= {8'h78,16'h5583,8'h40};
            8'd185: lut_data <= {8'h78,16'h5584,8'h10};
            8'd186: lut_data <= {8'h78,16'h5589,8'h10};
            8'd187: lut_data <= {8'h78,16'h558a,8'h00};
            8'd188: lut_data <= {8'h78,16'h558b,8'hf8};
            8'd189: lut_data <= {8'h78,16'h501d,8'h40}; //ISP MISC
            //CIP(颜色插值)控制 (16'h5300~16'h530c)
            8'd190: lut_data <= {8'h78,16'h5300,8'h08};
            8'd191: lut_data <= {8'h78,16'h5301,8'h30};
            8'd192: lut_data <= {8'h78,16'h5302,8'h10};
            8'd193: lut_data <= {8'h78,16'h5303,8'h00};
            8'd194: lut_data <= {8'h78,16'h5304,8'h08};
            8'd195: lut_data <= {8'h78,16'h5305,8'h30};
            8'd196: lut_data <= {8'h78,16'h5306,8'h08};
            8'd197: lut_data <= {8'h78,16'h5307,8'h16};
            8'd198: lut_data <= {8'h78,16'h5309,8'h08};
            8'd199: lut_data <= {8'h78,16'h530a,8'h30};
            8'd200: lut_data <= {8'h78,16'h530b,8'h04};
            8'd201: lut_data <= {8'h78,16'h530c,8'h06};
            8'd202: lut_data <= {8'h78,16'h5025,8'h00};
            //系统时钟分频 Bit[7:4]:系统时钟分频 input clock =24Mhz, PCLK = 48Mhz
            8'd203: lut_data <= {8'h78,16'h3035,8'h11}; 
            8'd204: lut_data <= {8'h78,16'h3036,8'h3c}; //PLL倍频
            8'd205: lut_data <= {8'h78,16'h3c07,8'h08};
            //时序控制 16'h3800~16'h3821
            8'd206: lut_data <= {8'h78,16'h3820,8'h46};
            8'd207: lut_data <= {8'h78,16'h3821,8'h01};
            8'd208: lut_data <= {8'h78,16'h3814,8'h31};
            8'd209: lut_data <= {8'h78,16'h3815,8'h31};
            8'd210: lut_data <= {8'h78,16'h3800,8'h00};
            8'd211: lut_data <= {8'h78,16'h3801,8'h00};
            8'd212: lut_data <= {8'h78,16'h3802,8'h00};
            8'd213: lut_data <= {8'h78,16'h3803,8'h04};
            8'd214: lut_data <= {8'h78,16'h3804,8'h0a};
            8'd215: lut_data <= {8'h78,16'h3805,8'h3f};
            8'd216: lut_data <= {8'h78,16'h3806,8'h07};
            8'd217: lut_data <= {8'h78,16'h3807,8'h9b};

            //设置输出像素个数
            //DVP 输出水平像素点数高4位
            8'd218: lut_data <= {8'h78,16'h3808,{4'd0,CMOS_H_PIXEL[11:8]}};
            //DVP 输出水平像素点数低8位
            8'd219: lut_data <= {8'h78,16'h3809,CMOS_H_PIXEL[7:0]};
            //DVP 输出垂直像素点数高3位
            8'd220: lut_data <= {8'h78,16'h380a,{5'd0,CMOS_V_PIXEL[10:8]}};
            //DVP 输出垂直像素点数低8位
            8'd221: lut_data <= {8'h78,16'h380b,CMOS_V_PIXEL[7:0]};
            //水平总像素大小高5位
            8'd222: lut_data <= {8'h78,16'h380c,{3'd0,TOTAL_H_PIXEL[12:8]}};
            //水平总像素大小低8位 
            8'd223: lut_data <= {8'h78,16'h380d,TOTAL_H_PIXEL[7:0]};
            //垂直总像素大小高5位 
            8'd224: lut_data <= {8'h78,16'h380e,{3'd0,TOTAL_V_PIXEL[12:8]}};
            //垂直总像素大小低8位     
            8'd225: lut_data <= {8'h78,16'h380f,TOTAL_V_PIXEL[7:0]};

            8'd226: lut_data <= {8'h78,16'h3813,8'h06};
            8'd227: lut_data <= {8'h78,16'h3618,8'h00};
            8'd228: lut_data <= {8'h78,16'h3612,8'h29};
            8'd229: lut_data <= {8'h78,16'h3709,8'h52};
            8'd230: lut_data <= {8'h78,16'h370c,8'h03};
            8'd231: lut_data <= {8'h78,16'h3a02,8'h17}; //60Hz max exposure
            8'd232: lut_data <= {8'h78,16'h3a03,8'h10}; //60Hz max exposure
            8'd233: lut_data <= {8'h78,16'h3a14,8'h17}; //50Hz max exposure
            8'd234: lut_data <= {8'h78,16'h3a15,8'h10}; //50Hz max exposure
            8'd235: lut_data <= {8'h78,16'h4004,8'h02}; //BLC(背光) 2 lines
            8'd236: lut_data <= {8'h78,16'h4713,8'h03}; //JPEG mode 3
            8'd237: lut_data <= {8'h78,16'h4407,8'h04}; //量化标度
            8'd238: lut_data <= {8'h78,16'h460c,8'h22};     
            8'd239: lut_data <= {8'h78,16'h4837,8'h22}; //DVP CLK divider
            8'd240: lut_data <= {8'h78,16'h3824,8'h02}; //DVP CLK divider
            8'd241: lut_data <= {8'h78,16'h5001,8'ha3}; //ISP 控制
            8'd242: lut_data <= {8'h78,16'h3b07,8'h0a}; //帧曝光模式  
            //彩条测试使能 
            8'd243: lut_data <= {8'h78,16'h503d,8'h00}; //8'h00:正常模式 8'h80:彩条显示
            //测试闪光灯功能
            8'd244: lut_data <= {8'h78,16'h3016,8'h02};
            8'd245: lut_data <= {8'h78,16'h301c,8'h02};
            8'd246: lut_data <= {8'h78,16'h3019,8'h02}; //打开闪光灯
            8'd247: lut_data <= {8'h78,16'h3019,8'h00}; //关闭闪光灯
            //只读存储器,防止在case中没有列举的情况，之前的寄存器被重复改写
            default : lut_data <= {8'h78,16'h300a,8'h00}; //器件ID高8位
        endcase
    end
end

endmodule
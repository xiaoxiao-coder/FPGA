//////////////////////////////////////////////////////////////////////////////////
//  ov5640 lcd display                                                          //
//                                                                              //
//  Author: lhj                                                                 //
//                                                                              //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2018/01/11     lhj          1.0         Original
//*******************************************************************************/

module top(

input x_pulse_in_1,

input y_pulse_in_1,

input [3:0] row,

//output

output dirc_x,

output dirc_y,

output en_x,

output en_y,

output x_pulse_out,

output y_pulse_out,

output [3:0] col,

output [3:0] d1_wx ,

output [7:0] d1_out,

output [3:0] data_led,
input                       sys_clk,
input                       rst_n,
inout                       cmos_scl,         
inout                       cmos_sda,         
input                       cmos_vsync,       
input                       cmos_href,        
input                       cmos_pclk,         
output                      cmos_xclk,         
input[7:0]                  cmos_db,
//ddr                                                           
//output reg                           clk_led                ,
//output                               pll_lock               ,
//output                               ddr_init_done          ,
//output                               ddrphy_rst_done        ,                                                                                                                          
input                                pad_loop_in            ,
input                                pad_loop_in_h          ,
output                               pad_rstn_ch0           ,
output                               pad_ddr_clk_w          ,
output                               pad_ddr_clkn_w         ,
output                               pad_csn_ch0            ,
output [15:0]                        pad_addr_ch0           ,
inout  [16-1:0]                      pad_dq_ch0             ,
inout  [16/8-1:0]                    pad_dqs_ch0            ,
inout  [16/8-1:0]                    pad_dqsn_ch0           ,
output [16/8-1:0]                    pad_dm_rdqs_ch0        ,
output                               pad_cke_ch0            ,
output                               pad_odt_ch0            ,
output                               pad_rasn_ch0           ,
output                               pad_casn_ch0           ,
output                               pad_wen_ch0            ,
output [2:0]                         pad_ba_ch0             ,
output                               pad_loop_out           ,
output                               pad_loop_out_h         ,
//output                               err_flag,   
//hdmi output        
output                             tmds_clk_p,
output                             tmds_clk_n,
output[2:0]                        tmds_data_p,       
output[2:0]                        tmds_data_n                       
);

parameter MEM_DATA_BITS          = 64;             //external memory user interface data width
parameter ADDR_BITS              = 25;             //external memory user interface address width
parameter BUSRT_BITS             = 10;             //external memory user interface burst width
/*
parameter  SLAVE_ADDR = 7'h3c         ;  //OV5640的器件地址7'h3c
parameter  BIT_CTRL   = 1'b1          ;  //OV5640的字节地址为16位  0:8位 1:16位
parameter  CLK_FREQ   = 26'd65_000_000;  //i2c_dri模块的驱动时钟频率 65MHz
parameter  I2C_FREQ   = 18'd250_000   ;  //I2C的SCL时钟频率,不超过400KHz
parameter  CMOS_H_PIXEL = 24'd1024    ;  //CMOS水平方向像素个数,用于设置SDRAM缓存大小
parameter  CMOS_V_PIXEL = 24'd768     ;  //CMOS垂直方向像素个数,用于设置SDRAM缓存大小
*/
wire                            wr_burst_data_req;
wire                            wr_burst_finish;
wire                            rd_burst_finish;
wire                            rd_burst_req;
wire                            wr_burst_req;
wire[BUSRT_BITS - 1:0]          rd_burst_len;
wire[BUSRT_BITS - 1:0]          wr_burst_len;
wire[ADDR_BITS - 1:0]           rd_burst_addr;
wire[ADDR_BITS - 1:0]           wr_burst_addr;
wire                            rd_burst_data_valid;
wire[MEM_DATA_BITS - 1 : 0]     rd_burst_data;
wire[MEM_DATA_BITS - 1 : 0]     wr_burst_data;
wire                            read_req;
wire                            read_req_ack;
wire                            read_en;
wire[15:0]                      read_data;
wire                            write_en;
wire[15:0]                      write_data;
wire                            write_req;
wire                            write_req_ack;
wire                            video_clk;         //video pixel clock
wire                            video_clk5x;
wire                            hs;
wire                            vs;
wire                            de;
wire[15:0]                      vout_data;
wire[15:0]                      cmos_16bit_data;
wire                            cmos_16bit_wr;
wire[1:0]                       write_addr_index;
wire[1:0]                       read_addr_index;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;

wire                            ui_clk;
wire                            ui_clk_sync_rst;
wire                            init_calib_complete;
// Master Write Address
wire [3:0]                      s00_axi_awid;
wire [63:0]                     s00_axi_awaddr;
wire [7:0]                      s00_axi_awlen;    // burst length: 0-255
wire [2:0]                      s00_axi_awsize;   // burst size: fixed 2'b011
wire [1:0]                      s00_axi_awburst;  // burst type: fixed 2'b01(incremental burst)
wire                            s00_axi_awlock;   // lock: fixed 2'b00
wire [3:0]                      s00_axi_awcache;  // cache: fiex 2'b0011
wire [2:0]                      s00_axi_awprot;   // protect: fixed 2'b000
wire [3:0]                      s00_axi_awqos;    // qos: fixed 2'b0000
wire [0:0]                      s00_axi_awuser;   // user: fixed 32'd0
wire                            s00_axi_awvalid;
wire                            s00_axi_awready;
// master write data
wire [63:0]                     s00_axi_wdata;
wire [7:0]                      s00_axi_wstrb;
wire                            s00_axi_wlast;
wire [0:0]                      s00_axi_wuser;
wire                            s00_axi_wvalid;
wire                            s00_axi_wready;
// master write response
wire [3:0]                      s00_axi_bid;
wire [1:0]                      s00_axi_bresp;
wire [0:0]                      s00_axi_buser;
wire                            s00_axi_bvalid;
wire                            s00_axi_bready;
// master read address
wire [3:0]                      s00_axi_arid;
wire [63:0]                     s00_axi_araddr;
wire [7:0]                      s00_axi_arlen;
wire [2:0]                      s00_axi_arsize;
wire [1:0]                      s00_axi_arburst;
wire [1:0]                      s00_axi_arlock;
wire [3:0]                      s00_axi_arcache;
wire [2:0]                      s00_axi_arprot;
wire [3:0]                      s00_axi_arqos;
wire [0:0]                      s00_axi_aruser;
wire                            s00_axi_arvalid;
wire                            s00_axi_arready;
// master read data
wire [3:0]                      s00_axi_rid;
wire [63:0]                     s00_axi_rdata;
wire [1:0]                      s00_axi_rresp;
wire                            s00_axi_rlast;
wire [0:0]                      s00_axi_ruser;
wire                            s00_axi_rvalid;
wire                            s00_axi_rready;
wire                            clk_200MHz;

wire                            hdmi_hs;
wire                            hdmi_vs;
wire                            hdmi_de;
wire[7:0]                       hdmi_r;
wire[7:0]                       hdmi_g;
wire[7:0]                       hdmi_b;

//reg or wire

wire [0:0] en_y1;

wire [0:0] en_x1;

wire [3:0] kind;

wire [20:0] xcount;

wire [20:0] ycount;

//wire xspeed_en;

//wire xplace_en;

//wire yspeed_en;

//wire yplace_en;

wire [3:0] reg1 , reg2 , reg3 , reg4 ;

wire x_pulse_in;

wire y_pulse_in;

assign data_led = ~kind;

assign en_x = 1'b0;

assign en_y = 1'b0;


/*
wire                  i2c_exec        ;  //I2C触发执行信号          
wire                  cam_init_done   ;  //摄像头初始化完成
wire                  i2c_done        ;  //I2C寄存器配置完成信号
wire                  i2c_dri_clk     ;  //I2C操作时钟
*/

assign  hdmi_hs    = hs;
assign  hdmi_vs     = vs;
assign  hdmi_de    = de;
assign hdmi_r      = {vout_data[15:11],vout_data[13:11]};
assign hdmi_g      = {vout_data[10:5],vout_data[6:5]};
assign hdmi_b      = {vout_data[4:0],vout_data[2:0]};

assign write_en = cmos_16bit_wr;
assign write_data = {cmos_16bit_data[4:0],cmos_16bit_data[10:5],cmos_16bit_data[15:11]};


/* clk_200M clk_ref_m0
(
.pll_rst(1'b0),
.clkin1(sys_clk),
.pll_lock(),
.clkout0(clk_200MHz),
.clkout1(cmos_xclk)
);*/

video_pll video_pll_m0
(
  .clkin1                    (sys_clk                  ),
  .clkout0                   (video_clk                ),
  .clkout1                   (video_clk5x              ),
  .clkout2                   (cmos_xclk                ),
  .pll_rst                   (1'b0                     ),
  .pll_lock                  (                         )
);

dvi_encoder dvi_encoder_m0
(
	.pixelclk      (video_clk          ),// system clock
	.pixelclk5x    (video_clk5x        ),// system clock x5
	.rstin         (~rst_n             ),// reset
	.blue_din      (hdmi_b            ),// Blue data in
	.green_din     (hdmi_g            ),// Green data in
	.red_din       (hdmi_r            ),// Red data in
	.hsync         (hdmi_hs           ),// hsync data
	.vsync         (hdmi_vs           ),// vsync data
	.de            (hdmi_de         ),// data enable
	.tmds_clk_p    (tmds_clk_p         ),
	.tmds_clk_n    (tmds_clk_n         ),
	.tmds_data_p   (tmds_data_p        ),//rgb
	.tmds_data_n   (tmds_data_n        ) //rgb
);

i2c_config i2c_config_m0(
	.rst                        (~rst_n                   ),
	.clk                        (sys_clk                  ),
	.clk_div_cnt                (16'd500                  ),
	.i2c_addr_2byte             (1'b1                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (cmos_scl                 ),
	.i2c_sda                    (cmos_sda                 )
);
//configure look-up table
lut_ov5640_rgb565_1024_768 lut_ov5640_rgb565_1024_768_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
);

//CMOS sensor 8bit data is converted to 16bit data
cmos_8_16bit cmos_8_16bit_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.pdata_i                    (cmos_db                  ),
	.de_i                       (cmos_href                ),
	.pdata_o                    (cmos_16bit_data          ),
	.hblank                     (                         ),
	.de_o                       (cmos_16bit_wr            )
);
//CMOS sensor writes the request and generates the read and write address index
cmos_write_req_gen cmos_write_req_gen_m0(
	.rst                        (~rst_n                   ),
	.pclk                       (cmos_pclk                ),
	.cmos_vsync                 (cmos_vsync               ),
	.write_req                  (write_req                ),
	.write_addr_index           (write_addr_index         ),
	.read_addr_index            (read_addr_index          ),
	.write_req_ack              (write_req_ack            )
);

//The video output timing generator and generate a frame read data request
video_timing_data video_timing_data_m0
(
	.video_clk                  (video_clk                ),
	.rst                        (~rst_n                   ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),
	.hs                         (hs                       ),
	.vs                         (vs                       ),
	.de                         (de                       ),
	.vout_data                  (vout_data                )
);
//video frame data read-write control
frame_read_write frame_read_write_m0
(
	.rst                        (~rst_n                   ),
	.mem_clk                    (ui_clk                   ),
	.rd_burst_req               (rd_burst_req             ),
	.rd_burst_len               (rd_burst_len             ),
	.rd_burst_addr              (rd_burst_addr            ),
	.rd_burst_data_valid        (rd_burst_data_valid      ),
	.rd_burst_data              (rd_burst_data            ),
	.rd_burst_finish            (rd_burst_finish          ),
	.read_clk                   (video_clk                ),
	.read_req                   (read_req                 ),
	.read_req_ack               (read_req_ack             ),
	.read_finish                (                         ),
	.read_addr_0                (24'd0                    ), //The first frame address is 0
	.read_addr_1                (24'd2073600              ), //The second frame address is 24'd2073600 ,large enough address space for one frame of video
	.read_addr_2                (24'd4147200              ),
	.read_addr_3                (24'd6220800              ),
	.read_addr_index            (read_addr_index          ),
	.read_len                   (24'd196608               ),//frame size 
	.read_en                    (read_en                  ),
	.read_data                  (read_data                ),

	.wr_burst_req               (wr_burst_req             ),
	.wr_burst_len               (wr_burst_len             ),
	.wr_burst_addr              (wr_burst_addr            ),
	.wr_burst_data_req          (wr_burst_data_req        ),
	.wr_burst_data              (wr_burst_data            ),
	.wr_burst_finish            (wr_burst_finish          ),
	.write_clk                  (cmos_pclk                ),
	.write_req                  (write_req                ),
	.write_req_ack              (write_req_ack            ),
	.write_finish               (                         ),
	.write_addr_0               (24'd0                    ),
	.write_addr_1               (24'd2073600              ),
	.write_addr_2               (24'd4147200              ),
	.write_addr_3               (24'd6220800              ),
	.write_addr_index           (write_addr_index         ),
	.write_len                  (24'd196608               ), //frame size  
	.write_en                   (write_en                 ),
	.write_data                 (write_data               )
);
ddr3 u_ipsl_hmemc_top (
    .pll_refclk_in        (sys_clk        ),
    .ddr_rstn_key         (rst_n          ),   
    .pll_aclk_0           (              ),
    .pll_aclk_1           (ui_clk       ),
    .pll_aclk_2           (              ),
    .pll_lock             (      ),
    .ddrphy_rst_done      (),
 
    .ddrc_init_done       ( ),
   // .pll_lock             (pll_lock      ),
   // .ddrphy_rst_done      (ddrphy_rst_done),
  //  .ddrphy_rst_done      (ui_clk_sync_rst),
   // .ddrc_init_done       (ddr_init_done ),
    .ddrc_rst         (0),    
      
    .areset_1         (0),               
    .aclk_1           (ui_clk),                                                        
    .awid_1           (s00_axi_awid),       
    .awaddr_1         (s00_axi_awaddr),     
    .awlen_1          (s00_axi_awlen),      
    .awsize_1         (s00_axi_awsize),     
    .awburst_1        (s00_axi_awburst),    
    .awlock_1         (s00_axi_awlock),                       
    .awvalid_1        (s00_axi_awvalid),    
    .awready_1        (s00_axi_awready),    
  //  .awurgent_1       (axi_awurgent),  //? 
  //  .awpoison_1       (axi_awpoison),   //?     
    .awurgent_1       (1'b0),  //? 
    .awpoison_1       (1'b0),   //?                 
    .wdata_1          (s00_axi_wdata),      
    .wstrb_1          (s00_axi_wstrb),      
    .wlast_1          (s00_axi_wlast),      
    .wvalid_1         (s00_axi_wvalid),     
    .wready_1         (s00_axi_wready),                       
    .bid_1            (s00_axi_bid),        
    .bresp_1          (s00_axi_bresp),      
    .bvalid_1         (s00_axi_bvalid),     
    .bready_1         (s00_axi_bready),                                    
    .arid_1           (s00_axi_arid     ),  
    .araddr_1         (s00_axi_araddr   ),  
    .arlen_1          (s00_axi_arlen    ),  
    .arsize_1         (s00_axi_arsize   ),  
    .arburst_1        (s00_axi_arburst  ),  
    .arlock_1         (s00_axi_arlock   ),                      
    .arvalid_1        (s00_axi_arvalid  ),  
    .arready_1        (s00_axi_arready  ),  
   // .arpoison_1       (s00_axi_arqos ),   //?   
    .arpoison_1       (1'b0 ),   //?                  
    .rid_1            (s00_axi_rid      ),  
    .rdata_1          (s00_axi_rdata    ),  
    .rresp_1          (s00_axi_rresp    ),  
    .rlast_1          (s00_axi_rlast    ),  
    .rvalid_1         (s00_axi_rvalid   ),  
    .rready_1         (s00_axi_rready   ),  
   // .arurgent_1       (axi_arurgent ),    //?    
    .arurgent_1       (1'b0),    //?        
    .csysreq_1        (1'b1),               
    .csysack_1        (),           
    .cactive_1        (), 
          
    .csysreq_ddrc     (1'b1),
    .csysack_ddrc     (),
    .cactive_ddrc     (),
             
    .pad_loop_in           (pad_loop_in),
    .pad_loop_in_h         (pad_loop_in_h),
    .pad_rstn_ch0          (pad_rstn_ch0),
    .pad_ddr_clk_w         (pad_ddr_clk_w),
    .pad_ddr_clkn_w        (pad_ddr_clkn_w),
    .pad_csn_ch0           (pad_csn_ch0),
    .pad_addr_ch0          (pad_addr_ch0),
    .pad_dq_ch0            (pad_dq_ch0),
    .pad_dqs_ch0           (pad_dqs_ch0),
    .pad_dqsn_ch0          (pad_dqsn_ch0),
    .pad_dm_rdqs_ch0       (pad_dm_rdqs_ch0),
    .pad_cke_ch0           (pad_cke_ch0),
    .pad_odt_ch0           (pad_odt_ch0),
    .pad_rasn_ch0          (pad_rasn_ch0),
    .pad_casn_ch0          (pad_casn_ch0),
    .pad_wen_ch0           (pad_wen_ch0),
    .pad_ba_ch0            (pad_ba_ch0),
    .pad_loop_out          (pad_loop_out),
    .pad_loop_out_h        (pad_loop_out_h)                                
);   
aq_axi_master u_aq_axi_master
	(
      .ARESETN                     (rst_n                                     ),
	 // .ARESETN                     (~ui_clk_sync_rst                          ),
	  .ACLK                        (ui_clk                                    ),
	  .M_AXI_AWID                  (s00_axi_awid                              ),
	  .M_AXI_AWADDR                (s00_axi_awaddr                            ),
	  .M_AXI_AWLEN                 (s00_axi_awlen                             ),
	  .M_AXI_AWSIZE                (s00_axi_awsize                            ),
	  .M_AXI_AWBURST               (s00_axi_awburst                           ),
	  .M_AXI_AWLOCK                (s00_axi_awlock                            ),
	  .M_AXI_AWCACHE               (s00_axi_awcache                           ),
	  .M_AXI_AWPROT                (s00_axi_awprot                            ),
	  .M_AXI_AWQOS                 (s00_axi_awqos                             ),
	  .M_AXI_AWUSER                (s00_axi_awuser                            ),
	  .M_AXI_AWVALID               (s00_axi_awvalid                           ),
	  .M_AXI_AWREADY               (s00_axi_awready                           ),
	  .M_AXI_WDATA                 (s00_axi_wdata                             ),
	  .M_AXI_WSTRB                 (s00_axi_wstrb                             ),
	  .M_AXI_WLAST                 (s00_axi_wlast                             ),
	  .M_AXI_WUSER                 (s00_axi_wuser                             ),
	  .M_AXI_WVALID                (s00_axi_wvalid                            ),
	  .M_AXI_WREADY                (s00_axi_wready                            ),
	  .M_AXI_BID                   (s00_axi_bid                               ),
	  .M_AXI_BRESP                 (s00_axi_bresp                             ),
	  .M_AXI_BUSER                 (s00_axi_buser                             ),
	  .M_AXI_BVALID                (s00_axi_bvalid                            ),
	  .M_AXI_BREADY                (s00_axi_bready                            ),
	  .M_AXI_ARID                  (s00_axi_arid                              ),
	  .M_AXI_ARADDR                (s00_axi_araddr                            ),
	  .M_AXI_ARLEN                 (s00_axi_arlen                             ),
	  .M_AXI_ARSIZE                (s00_axi_arsize                            ),
	  .M_AXI_ARBURST               (s00_axi_arburst                           ),
	  .M_AXI_ARLOCK                (s00_axi_arlock                            ),
	  .M_AXI_ARCACHE               (s00_axi_arcache                           ),
	  .M_AXI_ARPROT                (s00_axi_arprot                            ),
	  .M_AXI_ARQOS                 (s00_axi_arqos                             ),
	  .M_AXI_ARUSER                (s00_axi_aruser                            ),
	  .M_AXI_ARVALID               (s00_axi_arvalid                           ),
	  .M_AXI_ARREADY               (s00_axi_arready                           ),
	  .M_AXI_RID                   (s00_axi_rid                               ),
	  .M_AXI_RDATA                 (s00_axi_rdata                             ),
	  .M_AXI_RRESP                 (s00_axi_rresp                             ),
	  .M_AXI_RLAST                 (s00_axi_rlast                             ),
	  .M_AXI_RUSER                 (s00_axi_ruser                             ),
	  .M_AXI_RVALID                (s00_axi_rvalid                            ),
	  .M_AXI_RREADY                (s00_axi_rready                            ),
	  .MASTER_RST                  (1'b0                                     ),
	  .WR_START                    (wr_burst_req                             ),
	  .WR_ADRS                     ({wr_burst_addr,3'd0}                     ),
	  .WR_LEN                      ({wr_burst_len,3'd0}                      ),
	  .WR_READY                    (                                         ),
	  .WR_FIFO_RE                  (wr_burst_data_req                        ),
	  .WR_FIFO_EMPTY               (1'b0                                     ),
	  .WR_FIFO_AEMPTY              (1'b0                                     ),
	  .WR_FIFO_DATA                (wr_burst_data                            ),
	  .WR_DONE                     (wr_burst_finish                          ),
	  .RD_START                    (rd_burst_req                             ),
	  .RD_ADRS                     ({rd_burst_addr,3'd0}                     ),
	  .RD_LEN                      ({rd_burst_len,3'd0}                      ),
	  .RD_READY                    (                                         ),
	  .RD_FIFO_WE                  (rd_burst_data_valid                      ),
	  .RD_FIFO_FULL                (1'b0                                     ),
	  .RD_FIFO_AFULL               (1'b0                                     ),
	  .RD_FIFO_DATA                (rd_burst_data                            ),
	  .RD_DONE                     (rd_burst_finish                          ),
	  .DEBUG                       (                                         )
);

//...................................................

pulse_zhuanghuan Z1(

     //input

     .clk_50m(sys_clk),

     .pulse(x_pulse_in_1),

     //output

     .pulse_zh(x_pulse_in)

);

//.....................................................

pulse_zhuanghuan Z2(

     //input

     .clk_50m(sys_clk),

     .pulse(y_pulse_in_1),

     //output

     .pulse_zh(y_pulse_in)

);

//...................................................

Controller M1(

     //input 

     .clk_50m(sys_clk),             //system colck

     .rst(rst_n),

     .x_pulse_in(x_pulse_in),            //pulse input

     .y_pulse_in(y_pulse_in),

     .kind(kind),                // operation kind

     //.xspeed_en(xspeed_en),

     //.xplace_en(xplace_en),

     //.yspeed_en(yspeed_en),
  
     //.yplace_en(yplace_en),     

     //output

     .dirc_x(dirc_x),               //x operate direction

     .dirc_y(dirc_y),               //y operate direction

     .en_x(en_x1),                //x en

     .en_y(en_y1),                //y en

     .xcount(xcount),

     .ycount(ycount),

     .reg1(reg1),

     .reg2(reg2),

     .reg3(reg3),

     .reg4(reg4)

);

//..................................................................................

 Pulse M2(

     //input

     .clk_50m(sys_clk),      //system clock;

     .counter(xcount),       //
     
     .rst(rst_n),           //system reset, low is active
 
     .en(en_x1),

     //output

     .pulse_out(x_pulse_out)     //??????ì??o?3???3?

   );

//..................................................................................

 Pulse M3(

     //input

     .clk_50m(sys_clk),      //system clock;

     .counter(ycount),       //
     
     .rst(rst_n),           //system reset, low is active

     .en(en_y1),

     //output

     .pulse_out(y_pulse_out)     //

   );

//.....................................................................................

keyboard_buffer M4(
    //input 
    .clk(sys_clk),

    .reset(rst_n),

    .row(row),

    //output 

    .col(col),

    //.xspeed_en(xspeed_en),

    //.xplace_en(xplace_en),

   // .yspeed_en(yspeed_en),

   // .yplace_en(yplace_en),

    .data(kind)
    );

//.........................................................................................

seven_decode_control M5 (

     //input

     .clk_50m(sys_clk),

     .rst(rst_n),
 
     .reg1(reg1),

     .reg2(reg2),

     .reg3(reg3),

     .reg4(reg4),

     //output

     .d1_out(d1_out),             //duanxuan   

     .d1_wx(d1_wx)              //pianxuan

);

endmodule
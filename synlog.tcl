history clear
set wid1 [get_window_id]
set wid2 [open_file D:/astudy/FPGA_ziguang/CD/demo/13_ddr3_ov5640_hdmi/synthesize/synplify_impl/synplify.srs]
win_activate $wid2
run_tcl -fg D:/astudy/FPGA_ziguang/CD/demo/13_ddr3_ov5640_hdmi/top_rtl.tcl
project -close D:/astudy/FPGA_ziguang/CD/demo/13_ddr3_ov5640_hdmi/synthesize/synplify_impl/../synplify_pro.prj

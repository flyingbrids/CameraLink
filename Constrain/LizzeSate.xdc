## LVDS cameralink
set_property PACKAGE_PIN R19  [get_ports xclk_p]
set_property PACKAGE_PIN T19  [get_ports xclk_n]
create_clock -period 14.286 -name clk_1 [get_ports xclk_p]

set_property PACKAGE_PIN R16 [get_ports {x_p[3]}]
set_property PACKAGE_PIN T16 [get_ports {x_n[3]}]

set_property PACKAGE_PIN N21 [get_ports {x_p[2]}]
set_property PACKAGE_PIN N22 [get_ports {x_n[2]}]

set_property PACKAGE_PIN T20 [get_ports {x_p[1]}]
set_property PACKAGE_PIN U20 [get_ports {x_n[1]}]

set_property PACKAGE_PIN P21 [get_ports {x_p[0]}]
set_property PACKAGE_PIN R21 [get_ports {x_n[0]}]

set_property PACKAGE_PIN T17 [get_ports yclk_p]
set_property PACKAGE_PIN U17 [get_ports yclk_n]
create_clock -period 14.286 -name clk_2 [get_ports yclk_p]

set_property PACKAGE_PIN R17 [get_ports {y_p[3]}]
set_property PACKAGE_PIN R18 [get_ports {y_n[3]}]

set_property PACKAGE_PIN N20 [get_ports {y_p[2]}]
set_property PACKAGE_PIN P20 [get_ports {y_n[2]}]

set_property PACKAGE_PIN W19 [get_ports {y_p[1]}]
set_property PACKAGE_PIN W20 [get_ports {y_n[1]}]

set_property PACKAGE_PIN V21 [get_ports {y_p[0]}]
set_property PACKAGE_PIN V22 [get_ports {y_n[0]}]

set_property IOSTANDARD LVDS_25 [get_ports xclk_p]
set_property IOSTANDARD LVDS_25 [get_ports xclk_n]
set_property IOSTANDARD LVDS_25 [get_ports {x_p[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_n[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_p[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_n[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_p[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_n[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {x_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports yclk_p]
set_property IOSTANDARD LVDS_25 [get_ports yclk_n]
set_property IOSTANDARD LVDS_25 [get_ports {y_p[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_n[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_p[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_n[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_p[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_n[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_p[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {y_n[0]}]

#UART
set_property PACKAGE_PIN R22 [get_ports SerTFG_p]
set_property PACKAGE_PIN T22 [get_ports SerTFG_n]
set_property PACKAGE_PIN T21 [get_ports SerTC_p]
set_property PACKAGE_PIN U22 [get_ports SerTC_n]
set_property IOSTANDARD LVDS_25 [get_ports SerTFG_p]
set_property IOSTANDARD LVDS_25 [get_ports SerTFG_n]
set_property IOSTANDARD LVDS_25 [get_ports SerTC_p]
set_property IOSTANDARD LVDS_25 [get_ports SerTC_n]

#LVDS XBAND
set_property PACKAGE_PIN Y21  [get_ports tx1_clk_p]
set_property PACKAGE_PIN AA21 [get_ports tx1_clk_n]
set_property PACKAGE_PIN AA22 [get_ports tx1_data_p]
set_property PACKAGE_PIN AB22 [get_ports tx1_data_n]
set_property PACKAGE_PIN W21  [get_ports tx2_clk_p]
set_property PACKAGE_PIN Y22  [get_ports tx2_clk_n]
set_property PACKAGE_PIN AA20 [get_ports tx2_data_p]
set_property PACKAGE_PIN AB20 [get_ports tx2_data_n]

set_property IOSTANDARD LVDS_25 [get_ports tx1_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports tx1_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports tx1_data_p]
set_property IOSTANDARD LVDS_25 [get_ports tx1_data_n]
set_property IOSTANDARD LVDS_25 [get_ports tx2_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports tx2_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports tx2_data_p]
set_property IOSTANDARD LVDS_25 [get_ports tx2_data_n]

#clock
set_clock_groups -asynchronous -group [get_clocks clk_1] -group *
set_clock_groups -asynchronous -group [get_clocks clk_2] -group *

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins camera_receiver/camera_link/rx2/u0_cam_pll/mmcm_adv_inst/CLKOUT3]] -group *
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins camera_receiver/camera_link/rx1/u0_cam_pll/mmcm_adv_inst/CLKOUT3]] -group *

set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group *

#misc
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

set_operating_conditions -grade extended
set_operating_conditions -airflow 0
set_operating_conditions -board_layers 8to11
set_operating_conditions -board small
set_operating_conditions -heatsink none

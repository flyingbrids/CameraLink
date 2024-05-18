## LVDS cameralink
set_property PACKAGE_PIN AA22 [get_ports clk_p_hawk]
set_property PACKAGE_PIN AB22 [get_ports clk_n_hawk]
create_clock -period 13.468 -name clk_hawk [get_ports clk_p_hawk]

set_property PACKAGE_PIN Y21 [get_ports x_0_p_hawk]
set_property PACKAGE_PIN AA21 [get_ports x_0_n_hawk]
set_property PACKAGE_PIN AA20 [get_ports x_1_p_hawk]
set_property PACKAGE_PIN AB20 [get_ports x_1_n_hawk]
set_property PACKAGE_PIN W21 [get_ports x_2_p_hawk]
set_property PACKAGE_PIN Y22 [get_ports x_2_n_hawk]
set_property PACKAGE_PIN V21 [get_ports x_3_p_hawk]
set_property PACKAGE_PIN V22 [get_ports x_3_n_hawk]

set_property IOSTANDARD LVDS_25 [get_ports x_0_p_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_0_n_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_1_p_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_1_n_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_2_p_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_2_n_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_3_p_hawk]
set_property IOSTANDARD LVDS_25 [get_ports x_3_n_hawk]
set_property IOSTANDARD LVDS_25 [get_ports clk_p_hawk]
set_property IOSTANDARD LVDS_25 [get_ports clk_n_hawk]

set_clock_groups -asynchronous -group [get_clocks clk_hawk] -group *

set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group *

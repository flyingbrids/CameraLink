## LVDS cameralink
set_property PACKAGE_PIN AA22 [get_ports hawk_clk_p]
set_property PACKAGE_PIN AB22 [get_ports hawk_clk_n]
create_clock -period 13.468 -name clk_hawk [get_ports clk_p_hawk]

set_property PACKAGE_PIN Y21 [get_ports data_hawk_p[3]]
set_property PACKAGE_PIN AA21[get_ports data_hawk_n[3]]

set_property PACKAGE_PIN AA20 [get_ports data_hawk_p[2]]
set_property PACKAGE_PIN AB20[get_ports data_hawk_n[2]]

set_property PACKAGE_PIN W21 [get_ports data_hawk_p[1]]
set_property PACKAGE_PIN Y22[get_ports data_hawk_n[1]]

set_property PACKAGE_PIN V21 [get_ports data_hawk_p[0]]
set_property PACKAGE_PIN V22[get_ports data_hawk_n[0]]

set_property PACKAGE_PIN W19 [get_ports owl_clk_1_p]
set_property PACKAGE_PIN W20 [get_ports owl_clk_1_n]
create_clock -period 14.286 -name clk_owl_1 [get_ports owl_clk_1_p]

set_property PACKAGE_PIN R22 [get_ports data_owl_p[3]]
set_property PACKAGE_PIN T22 [get_ports data_owl_n[3]]

set_property PACKAGE_PIN T21 [get_ports data_owl_p[2]]
set_property PACKAGE_PIN Y22 [get_ports data_owl_n[2]]

set_property PACKAGE_PIN P21 [get_ports data_owl_p[1]]
set_property PACKAGE_PIN R21 [get_ports data_owl_n[1]]

set_property PACKAGE_PIN T20 [get_ports data_owl_p[0]]
set_property PACKAGE_PIN U20 [get_ports data_owl_n[0]]

set_property PACKAGE_PIN R19 [get_ports owl_clk_2_p]
set_property PACKAGE_PIN T19 [get_ports owl_clk_2_n]
create_clock -period 14.286 -name clk_owl_2 [get_ports owl_clk_2_p]

set_property PACKAGE_PIN N21 [get_ports data_owl_p[4]]
set_property PACKAGE_PIN N22[get_ports data_owl_n[4]]

set_property PACKAGE_PIN T17 [get_ports data_owl_p[7]]
set_property PACKAGE_PIN U17 [get_ports data_owl_n[7]]

set_property PACKAGE_PIN R17 [get_ports data_owl_p[6]]
set_property PACKAGE_PIN R18 [get_ports data_owl_n[6]]

set_property PACKAGE_PIN R16 [get_ports data_owl_p[5]]
set_property PACKAGE_PIN T16 [get_ports data_owl_n[5]]

set_property IOSTANDARD LVDS_25 [get_ports hawk_clk_p]
set_property IOSTANDARD LVDS_25 [get_ports hawk_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_p[3]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_n[3]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_p[2]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_n[2]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_p[1]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_n[1]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_p[0]]
set_property IOSTANDARD LVDS_25 [get_ports data_hawk_n[0]]
set_property IOSTANDARD LVDS_25 [get_ports owl_clk_1_p]
set_property IOSTANDARD LVDS_25 [get_ports owl_clk_1_n]
set_property IOSTANDARD LVDS_25 [get_ports owl_clk_2_p]
set_property IOSTANDARD LVDS_25 [get_ports owl_clk_2_n]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[7]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[7]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[6]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[6]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[5]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[5]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[4]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[4]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[3]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[3]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[2]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[2]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[1]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[1]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_p[0]]
set_property IOSTANDARD LVDS_25 [get_ports data_owl_n[0]]

set_clock_groups -asynchronous -group [get_clocks clk_hawk] -group *
set_clock_groups -asynchronous -group [get_clocks clk_owl_1] -group *
set_clock_groups -asynchronous -group [get_clocks clk_owl_2] -group *
set_clock_groups -asynchronous -group [get_clocks clk_fpga_0] -group *

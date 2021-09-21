set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

set_property PACKAGE_PIN R2 [get_ports CS1]
set_property IOSTANDARD LVCMOS33 [get_ports CS1]

set_property PACKAGE_PIN L1 [get_ports sign]
set_property IOSTANDARD LVCMOS33 [get_ports sign]

set_property PACKAGE_PIN T1 [get_ports Test_Switch]
set_property IOSTANDARD LVCMOS33 [get_ports Test_Switch]

set_property PACKAGE_PIN U1 [get_ports axis_data]
set_property IOSTANDARD LVCMOS33 [get_ports axis_data]

set_property PACKAGE_PIN W2 [get_ports format]
set_property IOSTANDARD LVCMOS33 [get_ports format]

set_property PACKAGE_PIN R3 [get_ports measure_mode]
set_property IOSTANDARD LVCMOS33 [get_ports measure_mode]

set_property PACKAGE_PIN T2 [get_ports rate_control]
set_property IOSTANDARD LVCMOS33 [get_ports rate_control]

set_property PACKAGE_PIN P1 [get_ports Test_SwitchLED]
set_property IOSTANDARD LVCMOS33 [get_ports Test_SwitchLED]

set_property PACKAGE_PIN N3 [get_ports axis_dataLED]
set_property IOSTANDARD LVCMOS33 [get_ports axis_dataLED]

set_property PACKAGE_PIN P3 [get_ports formatLED]
set_property IOSTANDARD LVCMOS33 [get_ports formatLED]

set_property PACKAGE_PIN U3 [get_ports measure_modeLED]
set_property IOSTANDARD LVCMOS33 [get_ports measure_modeLED]

set_property PACKAGE_PIN W14 [get_ports read_ready]
set_property IOSTANDARD LVCMOS33 [get_ports read_ready]
set_property PACKAGE_PIN U14 [get_ports read_readyLED]
set_property IOSTANDARD LVCMOS33 [get_ports read_readyLED]

set_property PACKAGE_PIN V15 [get_ports Enable]
set_property IOSTANDARD LVCMOS33 [get_ports Enable]
set_property PACKAGE_PIN U15 [get_ports EnableLED]
set_property IOSTANDARD LVCMOS33 [get_ports EnableLED]

set_property PACKAGE_PIN A18 [get_ports Tx_Out]
set_property IOSTANDARD LVCMOS33 [get_ports Tx_Out]

set_property PACKAGE_PIN W16 [get_ports show_X]
set_property IOSTANDARD LVCMOS33 [get_ports show_X]
set_property PACKAGE_PIN V16 [get_ports show_Y]
set_property IOSTANDARD LVCMOS33 [get_ports show_Y]
set_property PACKAGE_PIN V17 [get_ports show_Z]
set_property IOSTANDARD LVCMOS33 [get_ports show_Z]
set_property PACKAGE_PIN U19 [get_ports show_XLED]
set_property IOSTANDARD LVCMOS33 [get_ports show_XLED]
set_property PACKAGE_PIN E19 [get_ports show_YLED]
set_property IOSTANDARD LVCMOS33 [get_ports show_YLED]
set_property PACKAGE_PIN U16 [get_ports show_ZLED]
set_property IOSTANDARD LVCMOS33 [get_ports show_ZLED]

set_property PACKAGE_PIN W7 [get_ports {C[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[1]}]
set_property PACKAGE_PIN W6 [get_ports {C[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[2]}]
set_property PACKAGE_PIN U8 [get_ports {C[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[3]}]
set_property PACKAGE_PIN V8 [get_ports {C[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[4]}]
set_property PACKAGE_PIN U5 [get_ports {C[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[5]}]
set_property PACKAGE_PIN V5 [get_ports {C[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[6]}]
set_property PACKAGE_PIN U7 [get_ports {C[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {C[7]}]

set_property PACKAGE_PIN U2 [get_ports {AN[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[0]}]
set_property PACKAGE_PIN U4 [get_ports {AN[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[1]}]
set_property PACKAGE_PIN V4 [get_ports {AN[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[2]}]
set_property PACKAGE_PIN W4 [get_ports {AN[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {AN[3]}]

set_property PACKAGE_PIN K17 [get_ports MISO]
set_property IOSTANDARD LVCMOS33 [get_ports MISO]
##Sch name = JC2
set_property PACKAGE_PIN M18 [get_ports CS]
set_property IOSTANDARD LVCMOS33 [get_ports CS]
##Sch name = JC3
set_property PACKAGE_PIN N17 [get_ports MOSI]
set_property IOSTANDARD LVCMOS33 [get_ports MOSI]
##Sch name = JC4
set_property PACKAGE_PIN P18 [get_ports spi_clk]
set_property IOSTANDARD LVCMOS33 [get_ports spi_clk]




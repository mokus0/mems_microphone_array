# general system and bitstream properties
set_property BITSTREAM.GENERAL.COMPRESS       TRUE  [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE      33    [current_design]
set_property CONFIG_VOLTAGE                   3.3   [current_design]
set_property CFGBVS                           VCCO  [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR  NO    [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH    1     [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE   YES   [current_design]

# Baseboard pin assignments
# clk => 100000000Hz
create_clock -period 10.0 -name clk_0 -waveform {0.000 5.000} [get_ports clk]

set_property PACKAGE_PIN  N14       [get_ports {clk}]
set_property IOSTANDARD   LVCMOS33  [get_ports {clk}]
set_property PACKAGE_PIN  P6        [get_ports {rst_n}]
set_property IOSTANDARD   LVCMOS33  [get_ports {rst_n}]

set_property PACKAGE_PIN  K13       [get_ports {base_board_led[0]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[0]}]
set_property PACKAGE_PIN  K12       [get_ports {base_board_led[1]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[1]}]
set_property PACKAGE_PIN  L14       [get_ports {base_board_led[2]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[2]}]
set_property PACKAGE_PIN  L13       [get_ports {base_board_led[3]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[3]}]
set_property PACKAGE_PIN  M16       [get_ports {base_board_led[4]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[4]}]
set_property PACKAGE_PIN  M14       [get_ports {base_board_led[5]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[5]}]
set_property PACKAGE_PIN  M12       [get_ports {base_board_led[6]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[6]}]
set_property PACKAGE_PIN  N16       [get_ports {base_board_led[7]}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_led[7]}]

set_property PACKAGE_PIN  P15       [get_ports {base_board_uart_rxd}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_uart_rxd}]
set_property PACKAGE_PIN  P16       [get_ports {base_board_uart_txd}]
set_property IOSTANDARD   LVCMOS33  [get_ports {base_board_uart_txd}]

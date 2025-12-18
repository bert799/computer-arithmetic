create_clock -period 2.000 -name clk -waveform {0.000 0.500} [get_ports clk]

reset_switching_activity -all 

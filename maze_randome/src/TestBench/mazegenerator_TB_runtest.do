SetActiveLib -work
comp -include "$dsn\src\maze.vhd" 
comp -include "$dsn\src\TestBench\mazegenerator_TB.vhd" 
asim +access +r TESTBENCH_FOR_mazegenerator 
wave 
wave -noreg clk
wave -noreg reset
wave -noreg done_maze
wave -noreg maze_out
# The following lines can be used for timing simulation
# acom <backannotated_vhdl_file_name>
# comp -include "$dsn\src\TestBench\mazegenerator_TB_tim_cfg.vhd" 
# asim +access +r TIMING_FOR_mazegenerator 

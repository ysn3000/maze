library ieee;
use ieee.std_logic_1164.all;

package maze_package is	
	
	type cell is record
		right_wall, down_wall, left_wall, up_wall : std_logic ; 
		visited :std_logic;	
	end record;
	
	type co_ro is record
		row , col : integer;
	end record;
	
	type stack_arr is array (natural range<>) of co_ro;
	
	
	type maze_array is array (natural range <>, natural range <>) of cell;
end package;

package body maze_package is
end package body;
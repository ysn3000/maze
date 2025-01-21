library ieee;
use ieee.NUMERIC_STD.all; 
use IEEE.std_logic_1164.all;
library maze_randome;
use maze_randome.maze_package.all;

	-- Add your library and packages declaration here ...

entity mazegenerator_tb is
	-- Generic declarations of the tested unit
		generic(
		rows : INTEGER := 9;
		cols : INTEGER := 9 );
end mazegenerator_tb;

architecture TB_ARCHITECTURE of mazegenerator_tb is
	-- Component declaration of the tested unit
	component mazegenerator
		generic(
		rows : INTEGER := 9;
		cols : INTEGER := 9 );
	port(
		clk : in STD_LOGIC ;
		reset : in STD_LOGIC;
		done_maze : out STD_LOGIC;
		maze_out : out maze_array(0 to rows-1,0 to cols-1) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal done_maze : STD_LOGIC;
	signal maze_out : maze_array(0 to rows-1,0 to cols-1);

	-- Add your code here ... 
	
    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

	-- Unit Under Test port map
	UUT : mazegenerator
		generic map (
			rows => rows,
			cols => cols
		)

		port map (
			clk => clk,
			reset => reset,
			done_maze => done_maze,
			maze_out => maze_out
		);

	-- Add your stimulus here ...
	 -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process clk_process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Step 1: Apply reset
        reset <= '1';
        wait for 2 * clk_period;
        reset <= '0';

        -- Step 2: Wait for maze generation to complete
        wait until done_maze = '1';

        -- Step 3: Optional checks or display
        -- Add assertions or waveform inspection to validate maze_out contents
        wait for 10 * clk_period;
        assert false report "Testbench finished: Maze generation complete!" severity note;

        -- Stop simulation
        wait;
    end process stimulus_process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_mazegenerator of mazegenerator_tb is
	for TB_ARCHITECTURE
		for UUT : mazegenerator
			use entity work.mazegenerator(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_mazegenerator;


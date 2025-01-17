library ieee;
use ieee.NUMERIC_STD.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity mazegenerator_tb is
	-- Generic declarations of the tested unit
		generic(
		rows : INTEGER := 9;
		cols : INTEGER := 9 );
end mazegenerator_tb;

architecture TB_ARCHITECTURE of mazegenerator_tb is
-- Component declaration of the tested unit	  
	 constant clk_period : time := 10 ns;
	
	component mazegenerator
		generic(
		rows : INTEGER := 9;
		cols : INTEGER := 9 );
	port(
		clk : in STD_LOGIC;
		reset : in STD_LOGIC;
		done_maze : out STD_LOGIC;
		maze_out : out STD_LOGIC_VECTOR(rows*cols-1 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal clk : STD_LOGIC;
	signal reset : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal done_maze : STD_LOGIC;
	signal maze_out : STD_LOGIC_VECTOR(rows*cols-1 downto 0);

	-- Add your code here ...

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
	-- Clock process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test process
    stim_process: process
    begin
        -- Initialize signals
        reset <= '1';
        wait for clk_period * 2;
        reset <= '0';

        -- Wait for the maze generation to complete
        wait until done_maze = '1';

        -- Add any additional test cases or checks here
        assert false report "Test completed successfully." severity note;

        wait;
	end process;	
		

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_mazegenerator of mazegenerator_tb is
	for TB_ARCHITECTURE
		for UUT : mazegenerator
			use entity work.mazegenerator(behavioral);
		end for;
	end for;
end TESTBENCH_FOR_mazegenerator;


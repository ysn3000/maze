library IEEE;		   
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;	
use work.maze_package.all;


entity MazeGenerator is
	generic (
	rows : integer := 9;
	cols : integer := 9
		);	
	port (
	clk,reset : in std_logic;	 
	done_maze : out std_logic;
	maze_out : out maze_array(0 to rows-1, 0 to cols-1)
		);
end MazeGenerator;

architecture Behavioral of MazeGenerator is	


	--maze arrays
	signal maze :  maze_array(0 to rows-1, 0 to cols-1) := (others	=> (others =>(
						visited => '0',
						right_wall => '1' ,
						down_wall  => '1',
						left_wall  => '1',
						up_wall	   => '1'))); 
	
	--stack
	signal stack :stack_arr(0 to rows * cols - 1) := (others => (
														row => 0,
														col => 0));
	signal stack_pointer : integer range 0 to cols*rows := 0;
	
	--cols and rows
	signal next_cols, current_cols : integer range 0 to cols -1 := 0;
	signal next_rows, current_rows : integer range 0 to rows -1 := 0;
	
	--dfs fsm 
	type dfs_states is (INIT, VISITED, CHECK_NEIGHBORS, MOVE, BACKTRACK, DONE);
	signal current_state : dfs_states := INIT;
	
	--direction fsm
	type  direction_states is (RIGHT, DOWN, LEFT, UP);
	signal next_direction : direction_states;
	
	--neighbors
	type neighbors_array is array(0 to 3 ) of integer range 0 to 3;	
	signal neighbors : neighbors_array :=( others => 0);  
	signal neighbors_count : integer range 0 to 4 := 0; 
	signal m_done :std_logic := '0';
	
	-- Pseudo-random number generator
	signal pseudo_rand : std_logic_vector(31 downto 0) := (others => '0');

	
begin  
	
	
	process(clk)
		-- maximal length 32-bit xnor LFSR
		function lfsr32(x : std_logic_vector(31 downto 0)) return std_logic_vector is
		begin
			return x(30 downto 0) & (x(0) xnor x(1) xnor x(21) xnor x(31));
		end function;
	begin
		if rising_edge(clk) then
			if reset='1' then
				pseudo_rand <= (others => '0');
			else
				pseudo_rand <= lfsr32(pseudo_rand);
			end if;
		end if;
	end process;
		
		
	
	process(clk, reset)
	begin
		
		if reset = '1' then
			current_state <=	INIT;
			stack_pointer <= 0;		 
			m_done <= '0';
		elsif rising_edge(clk) then
			
			case current_state is 
				when INIT =>
					maze <=(others	=> (others =>(
						visited => '0',
						right_wall => '1' ,
						down_wall  => '1',
						left_wall  => '1',
						up_wall	   => '1')));
					current_state <= VISITED; 	
				when VISITED => 
					maze(current_rows, current_cols).visited <= '1';
					stack(stack_pointer).row <=  current_rows ;
					stack(stack_pointer).col <= current_cols ;
					
					stack_pointer <= stack_pointer + 1;
					current_state <= CHECK_NEIGHBORS; 
					
				when CHECK_NEIGHBORS =>	  
					neighbors_count <= 0; -- Reset count at the beginning  
				
					if current_cols > 0 and maze(current_rows, current_cols - 1).visited = '0' and neighbors_count <= 3then
						--left
						neighbors(neighbors_count) <= 2;
						neighbors_count <= neighbors_count + 1;
					end if;
					
					if	current_rows > 0 and maze(current_rows - 1, current_cols).visited = '0' and neighbors_count <= 3then	
						--up
						neighbors(neighbors_count) <= 3;
						neighbors_count <= neighbors_count + 1;
					end if;
					
					if  current_cols < cols - 1 and  maze(current_rows, current_cols + 1).visited = '0' and neighbors_count <= 3 then	
						--right
						neighbors(neighbors_count) <= 0;
						neighbors_count <= neighbors_count + 1;
					end if;			  
					
					if   current_rows < rows -1 and maze(current_rows + 1, current_cols).visited = '0' and neighbors_count <= 3 then	
						--down
						neighbors(neighbors_count) <= 1;
						neighbors_count <= neighbors_count + 1;	
					
					end if;	 
					
					if 	neighbors_count > 0 then
						
						case neighbors(to_integer(unsigned(pseudo_rand(1 downto 0)))mod neighbors_count) is
							when 0 => next_direction <= RIGHT;
							when 1 => next_direction <= DOWN;
							when 2 => next_direction <= LEFT;
							when 3 => next_direction <= UP;
							when others => null;
						end case;
						current_state <= MOVE;	
						
					else 
						current_state <= BACKTRACK;
					end if;	
					
				when MOVE =>  
					case  next_direction is 
						when RIGHT => 	--right break wall 
							 if current_cols < cols - 1 and  maze(current_rows, current_cols + 1).visited = '0' then
								maze(current_rows, current_cols).right_wall <= '0';
								maze(current_rows, current_cols + 1).left_wall <= '0';
								current_cols <= current_cols + 1;					  
							 end if;	 
						when DOWN =>   --down break wall   
							if 	 current_rows < rows -1 and maze(current_rows + 1, current_cols).visited = '0' then 
								maze(current_rows, current_cols).down_wall <= '0';
								maze(current_rows + 1, current_cols).up_wall <= '0';
								current_rows <= current_rows + 1;
							
							end if;	
						when LEFT =>   --left break wall	  
							if current_cols > 0 and maze(current_rows, current_cols - 1).visited = '0'then 
								maze(current_rows, current_cols).left_wall <= '0';
								maze(current_rows, current_cols - 1).right_wall <= '0';
								current_cols <= current_cols - 1;
							
							end if;	
						when UP =>	   --up break wall
							if 	current_rows > 0 and maze(current_rows - 1, current_cols).visited = '0' then
								maze(current_rows, current_cols).up_wall <= '0';
								maze(current_rows - 1, current_cols).down_wall <= '0';
								current_rows <= current_rows - 1;
							
							end if;	
						 when others =>	 null;
					end case;
					current_state <= VISITED;  
					
				when BACKTRACK =>
					if stack_pointer > 0 then 
					  
					
						stack_pointer <= stack_pointer - 1;
						current_rows <= stack(stack_pointer).row;
						current_cols <= stack(stack_pointer).col;
						current_state <= CHECK_NEIGHBORS;
					else
						current_state <= DONE;
					end if;	
				when DONE => 
					m_done <= '1';
				
				when others  =>
					current_state <= DONE;	
					
			end case;
		end if;	
			
	end process;			
	
		done_maze <= m_done;
		maze_out <= maze;

	
end Behavioral;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_func_math.all; 

entity DPRAM is
    generic
    (
    data_size   : positive;                  -- Width of the data to store
    dpram_depth : positive                 -- Depth of the DPRAM
    );
	port 
	(	
		data_a	: in std_logic_vector(data_size-1 downto 0);               -- Data input for port A
		data_b	: in std_logic_vector(data_size-1 downto 0);               -- Data input for port B
		addr_a	: in std_logic_vector(log2_ceil(dpram_depth)-1 downto 0);  -- Adress for port A
		addr_b	: in std_logic_vector(log2_ceil(dpram_depth)-1 downto 0);  -- Adress for port B
		we_a	: in std_logic := '1';                                     -- Write/Read mode for port A ( '1'  =  Write , '0' = Read )
		we_b	: in std_logic := '1';                                     -- Write/Read mode for port B ( '1'  =  Write , '0' = Read )
		clk		: in std_logic;                                            -- Clock for both ports 
		q_a		: out std_logic_vector(data_size-1 downto 0);                        -- Data output for port A
		q_b		: out std_logic_vector(data_size-1 downto 0)                         -- Data output for port B
	);
end DPRAM;

architecture rtl of DPRAM is
	
	-- Build a 2-D array type for the RAM
	subtype word_t is std_logic_vector(data_size-1 downto 0);
	type memory_t is array(dpram_depth-1 downto 0) of word_t;
	
	-- Declare the RAM
	shared variable ram : memory_t;

begin

	-- Port A
	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we_a = '1') then
				ram(to_integer(unsigned(addr_a))) := data_a;
			end if;
			q_a <= ram(to_integer(unsigned(addr_a)));
		end if;
	end process;
	
	-- Port B
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(we_b = '1') then
				ram(to_integer(unsigned(addr_b))) := data_b;
			end if;
			q_b <= ram(to_integer(unsigned(addr_b)));
		end if;
	end process;
end rtl;

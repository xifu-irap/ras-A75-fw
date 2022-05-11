library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_func_math.all; 
use work.pkg_project.all;

entity delay_mgt is
    generic
    (
    data_size   : positive := 1;                  -- Width of the data to store
    dpram_depth : positive := 256               -- Depth of the DPRAM ! Must be > or = 64 !
	);
	port 
	(	
		data_a  	: in std_logic_vector(data_size-1 downto 0);               -- Data input for port A
		data_b	    : in std_logic_vector(data_size-1 downto 0);               -- Data input for port B
		clk  		: in std_logic;                                            -- Clock for both ports 
		rst         : in std_logic;                                            -- Reset to get the valid data
		delay_value : in std_logic_vector(7 downto 0);                         -- Delay value
		q_a	        : out std_logic_vector(data_size-1 downto 0);                        -- Data output for port A
		q_b		    : out std_logic_vector(data_size-1 downto 0);                        -- Data output for port B
		data_valid  : out std_logic
	);
end delay_mgt;

architecture rtl of delay_mgt is
	
signal cpt_valid : std_logic_vector(7 downto 0);
signal addr_a : std_logic_vector(log2_ceil(dpram_depth)-1 downto 0); -- Adress for port A
signal addr_b : std_logic_vector(log2_ceil(dpram_depth)-1 downto 0); -- Adress for port B

begin



	process(clk, rst)
	begin
		if rst = '1' then
			data_valid <= '0' ; 
			cpt_valid <= (others => '0');
			addr_a <= (others => '0');
			addr_b <= ( 0 => '1', others => '0');
		elsif rising_edge(clk) then
			addr_a <= std_logic_vector(unsigned(addr_a) + 1);
			addr_b <= std_logic_vector(unsigned(addr_b) + 1);
			if cpt_valid = delay_value
			then 
				data_valid <= '1' ;
			else
				cpt_valid <= std_logic_vector(unsigned(cpt_valid)+ 1) ;
				data_valid <= '0' ;	
			end if;
			if addr_a = delay_value
			then
				addr_a <= (others => '0');
			end if;
			if addr_b = delay_value
			then
				addr_b <= (others => '0');
			end if;
		end if;
	end process ;

	DPRAM_test : entity work.DPRAM 
	generic map 
	(
		data_size => data_size,                 -- Width of the data to store
		dpram_depth => dpram_depth               -- Depth of the DPRAM ! Must be > or = 64 !	
	)
	port map 
	(	
		data_a	=> data_a,               -- Data input for port A
		data_b	=> data_b,               -- Data input for port B
		addr_a	=> addr_a,               -- Adress for port A
		addr_b	=> addr_b,               -- Adress for port B
		we_a	=> '1',                 -- Write/Read mode for port A ( '1'  =  Write , '0' = Read )
		we_b	=> '0',                 -- Write/Read mode for port B ( '1'  =  Write , '0' = Read )
		clk		=> clk,                  -- Clock for both ports 
		q_a		=> q_a,                  -- Data output for port A
		q_b		=> q_b                   -- Data output for port B
	);

end rtl;
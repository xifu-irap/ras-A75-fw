library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pkg_func_math.all; 
use work.pkg_project.all;

entity delay_mgt is
	port 
	(	
		data_in  	: in std_logic;
		clk  		: in std_logic;
		i_rst_n     : in std_logic;
		delay_value : in std_logic_vector(7 downto 0);
		data_out	: out std_logic
	);
end delay_mgt;

architecture rtl of delay_mgt is
	
constant depth := 256;
signal shift_register	: std_logic_vector(depth-1 downto 0);

begin

	P_delay : process(clk, rst)
	begin
		if i_rst_n = '0' then
			shift_register <= (others => '0');
		elsif rising_edge(clk) then
			shift_register <= shift_register(depth-2 downto 0) & data_in;
			data_out <= shift_register(delay_value);
		end if;
	end process ;

end rtl;
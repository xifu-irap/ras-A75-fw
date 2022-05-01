----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.04.2021 15:51:40
-- Design Name: 
-- Module Name: clock_gen_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity clock_gen_tb is
--  Port ( );
end clock_gen_tb;

architecture Behavioral of clock_gen_tb is

     component clock_gen
		Port ( i_clk : in STD_LOGIC;
		clk_62MHz : out STD_LOGIC;
		o_rst : out std_logic
		);
    end component;

signal s_i_clk : STD_LOGIC := '0';
signal s_clk_62MHz : STD_LOGIC := '0';
signal s_o_rst : STD_LOGIC := '0';
signal endsim : boolean   := false  ; 

begin 

	clk_gen_200 : process 
	begin 
        if endsim = false 
		then
			wait for 5 ns;
			s_i_clk <= not s_i_clk ;
		else 
			wait;
		end if ;
	end process clk_gen_200;

	stimulus : process 
	begin
        wait for 1000 ms;
        endsim <= true;
	end process stimulus ;

	clk_gen : clock_gen port map
		(
			i_clk => s_i_clk,
			clk_62MHz => s_clk_62MHz,
			o_rst => s_o_rst
		);

end ;
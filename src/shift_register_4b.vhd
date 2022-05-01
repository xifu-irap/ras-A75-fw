----------------------------------------------------------------------------------
-- Company: IRAP
-- Engineer: Noémie Rolland
-- 
-- Create Date: 04.01.2021 15:27:26
-- Design Name: 
-- Module Name: shift_register_4b - Behavioral
-- Project Name:row-addressing-command
-- Target Devices: Opal Kelly XEM7310 - Artix7 XC7A75T - 1FGG 484
-- Tool Versions: 
-- Description: This module reads the value of the sequence every 10 ns and then creates a delay of 1, 2 or 3 clock periods
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_register_4b is
    Port ( i_clk : in STD_LOGIC;
           i_rst_n : in STD_LOGIC;
           i_seq_5MHz : in STD_LOGIC; -- value of the sequence
           o_late : out STD_LOGIC_VECTOR (3 downto 0)); -- vector with different delay, bit0 no delay, bit1 1 clock period of delay, bit2 2 clock periods of delay, bit3 3 clock periods of delay
end shift_register_4b;

architecture Behavioral of shift_register_4b is

signal late_int : std_logic_vector(3 downto 0); --intern signal

begin

P_retard : process(i_clk,i_rst_n)
begin
   if (i_rst_n = '0') then
   -- initialisation of the signal
	   late_int <= (others => '0');		
	elsif (rising_edge(i_clk)) then
		late_int <= late_int(2 downto 0) & i_seq_5MHz; --shift every 10 ns which creates a delay of the input signal i_seq_5MHz
	end if;
end process;

o_late <= late_int; --the output signal takes the value of the intern signal

end Behavioral;

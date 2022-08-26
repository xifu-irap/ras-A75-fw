----------------------------------------------------------------------------------
-- Company: IRAP
-- Engineer: Noémie Rolland
-- 
-- Create Date: 04.01.2021 11:14:31
-- Design Name: 
-- Module Name: div_freq_5MHz - Behavioral
-- Project Name: row-addressing-command
-- Target Devices: Opal Kelly XEM7310 - Artix7 XC7A75T - 1FGG 484
-- Tool Versions: 
-- Description: This module divides the master clock (100MHz) to obtain a clock at 5MHz.
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity div_freq_5MHz is
    Port ( i_clk : in STD_LOGIC; -- 100MHz
           i_rst_n : in STD_LOGIC; -- Active low 
           o_clk_en_5M : out STD_LOGIC); -- clk enable 5MHz
end div_freq_5MHz;

architecture Behavioral of div_freq_5MHz is
signal cmp : unsigned(4 downto 0); -- counter

begin

P_div_clk : process(i_clk, i_rst_n)
begin
   if (i_rst_n = '0') then
   -- intitialisation of the signals during the reset
      cmp <= (others => '0');
      o_clk_en_5M <= '0';
   elsif (rising_edge(i_clk)) then
      if (cmp = 19) then
      -- when the counter has detected 20 rising edge
         o_clk_en_5M <= '1'; 
         cmp <= (others => '0'); -- reset of the counter
      else 
         cmp <= cmp + 1; -- incrementation of the counter
         o_clk_en_5M <= '0';
      end if;
   end if;
 end process;

end Behavioral;

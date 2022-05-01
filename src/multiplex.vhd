----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.01.2021 16:15:02
-- Design Name: 
-- Module Name: multiplex - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplex is
    Port ( i_late0 : in STD_LOGIC; --sequence with no delay
           i_late1 : in STD_LOGIC; --sequence with a delay of 1 clock period
           i_late2 : in STD_LOGIC; --sequence with a delay of 2 clock periods
           i_late3 : in STD_LOGIC; --sequence with a delay of 3 clock periods
           i_REV : in STD_LOGIC_VECTOR (3 downto 0); -- value of the required delay
           o_late_sig : out STD_LOGIC);
end multiplex;

architecture Behavioral of multiplex is

begin

P_mux : process(i_REV, i_late0,i_late1, i_late2, i_late3)
begin
   -- choice of the delay signal according to the value of REV
   if i_REV = "0000" then 
	   o_late_sig <= i_late0;
	elsif i_REV = "0001" then
	   o_late_sig <= i_late1;
	elsif i_REV = "0010" then
	   o_late_sig <= i_late2;
	else 
	   o_late_sig <= i_late3;
	end if;
end process;

end Behavioral;

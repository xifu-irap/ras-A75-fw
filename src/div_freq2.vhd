----------------------------------------------------------------------------------
--Copyright (C) 2021-2030 Noémie ROLLAND, IRAP Toulouse.

--This file is part of the ATHENA X-IFU DRE RAS.

--ras-a75-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
--License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
--later version.

--This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
--implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
--more details.You should have received a copy of the GNU General Public Licensealong with this program.  

--If not, see <https://www.gnu.org/licenses/>.

--noemie.rolland@irap.omp.eu
--div_freq2.vhd

-- Company: IRAP
-- Engineer: Noémie Rolland
-- 
-- Create Date: 10.02.2021 09:30:27
-- Design Name: 
-- Module Name: div_freq2 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module is a clock divider. It divides the clock frequency by 2.
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

entity div_freq2 is
    Port ( sys_clk : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           clk100M : out STD_LOGIC);
end div_freq2;

architecture Behavioral of div_freq2 is

signal cmp : unsigned(1 downto 0);

begin

P_div_freq : process(sys_clk, i_rst)
begin
    if i_rst = '1' then
        cmp <= (others => '0');
        clk100M <= '0';
    elsif (rising_edge(sys_clk)) then
        if cmp = 1 then
            cmp <= (others => '0');
            clk100M <= '1';
        else
            cmp <= cmp + 1;
            clk100M <= '0';
        end if;
    end if;
end process;
            

end Behavioral;

----------------------------------------------------------------------------------
--Copyright (C) 2021-2030 No�mie ROLLAND, IRAP Toulouse.

--This file is part of the ATHENA X-IFU DRE RAS.

--ras-a75-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
--License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
--later version.

--This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
--implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
--more details.You should have received a copy of the GNU General Public Licensealong with this program.  

--If not, see <https://www.gnu.org/licenses/>.

--noemie.rolland@irap.omp.eu
--read_5MHz.vhd

-- Company: IRAP
-- Engineer: 
-- 
-- Create Date: 04.01.2021 14:44:32
-- Design Name: 
-- Module Name: read_5MHz - Behavioral
-- Project Name: RAS_simu
-- Target Devices: Opal Kelly XEM7310 - Artix7 XC7A75T - 1FGG 484
-- Tool Versions: 
-- Description: This module reads bit by bit the input command every 200 ns.
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

entity read_5MHz_slave is
    Port 
        ( 
        i_clk : in STD_LOGIC;                       -- system clock
        i_clk_row_enable : in STD_LOGIC;            -- clk row
        i_sync_lasting_row : in STD_LOGIC;          -- Sync (during Trow)
        i_rst_n : in STD_LOGIC;
        i_cmd : in STD_LOGIC_VECTOR (39 downto 0);
        i_NRO : in STD_LOGIC_VECTOR (5 downto 0);
        o_seq_5MHz : out STD_LOGIC
        );
end read_5MHz_slave;

architecture Behavioral of read_5MHz_slave is

signal counter : unsigned(5 downto 0);

begin

    P_counter : process(i_clk, i_rst_n)
    begin
        if (i_rst_n = '0') then
            counter <= "000000";
    
        elsif (rising_edge(i_clk)) then
            if (i_clk_row_enable = '1') then         
    
                if (i_sync_lasting_row = '0') then
                    counter <= counter + 1;
                elsif
                    counter <= "000000";
                end if;
    
        end if;
    
    end process;

    o_seq_5MHz <= i_cmd(counter);

end Behavioral;

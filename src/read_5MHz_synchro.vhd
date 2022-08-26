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
-- Engineer: No�mie Rolland
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

entity read_5MHz_synchro is
    Port 
        ( 
        i_clk : in STD_LOGIC;                       -- system clock
        i_clk_row_enable : in STD_LOGIC;                 -- gate at 5MHz for system clock
        i_rst_n : in STD_LOGIC;
        i_cmd : in STD_LOGIC_VECTOR (39 downto 0);
        i_NRO : in STD_LOGIC_VECTOR(5 downto 0);
        o_seq_5MHz : out STD_LOGIC
        );
end read_5MHz_synchro;

architecture Behavioral of read_5MHz_synchro is

signal cmd_int : std_logic_vector(39 downto 0);
signal counter : unsigned(5 downto 0);
signal clk_row_enable2 : STD_LOGIC;
signal clk_row_enable3 : STD_LOGIC;
signal clk_row_enable4 : STD_LOGIC;

begin

-- This delayed ghate is used to raz the synchronisation signal after few system clock periods
P_delay_row_gate : process(i_clk, i_rst_n)
begin
    if (i_rst_n = '0') then
        clk_row_enable2 <= '0';
        clk_row_enable3 <= '0';
        clk_row_enable4 <= '0';
    elsif (rising_edge(i_clk)) then 
        clk_row_enable4 <= clk_row_enable3;
        clk_row_enable3 <= clk_row_enable2;
        clk_row_enable2 <= i_clk_row_enable;
    end if;
end process;

P_read_process : process(i_clk, i_rst_n)
begin
    if (i_rst_n = '0') then
        o_seq_5MHz <= '0';
        cmd_int <= i_cmd; --the command sequence is stored in an intern signal
        counter <= "000000";

    elsif (rising_edge(i_clk)) then   
        if (i_clk_row_enable = '1') then         
            if i_NRO = "000000" then -- if the user doesn't want to read the sequence
                o_seq_5MHz <= '0'; -- all the output driving signals = 0
        
            elsif (counter < unsigned(i_NRO)-1 and counter < 39) then -- while counter < i_NRO or < 40 we read the sequence
                cmd_int <= cmd_int(0) & cmd_int(39 downto 1); --rotation of the vector every 200 ns
                o_seq_5MHz <= cmd_int(0); --reading of the bit 0 (this bit change every 200 ns because of the previous rotation)
                counter <= counter + 1;
                
            else -- when counter >= i_NRO or >= 40 we start the sequence from te beginning
                cmd_int <= i_cmd;
                o_seq_5MHz <= cmd_int(0); --reading of the bit 0 (this bit change every 200 ns because of the previous rotation)
                counter <= "000000";  
                
            end if;  
        
        end if;
 
        -- We want to raz the synchronization signal after few system clock periods       
        if (clk_row_enable4 = '1') then
            o_seq_5MHz <= '0';
        end if;

   end if;
end process;

end Behavioral;

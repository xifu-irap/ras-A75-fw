----------------------------------------------------------------------------------
--Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.

--This file is part of the ATHENA X-IFU DRE RAS.

--ras-a75-fw is free software: you can redistribute it and/or modifyit under the terms of the GNU General Public 
--License as published bythe Free Software Foundation, either version 3 of the License, or(at your option) any 
--later version.

--This program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the 
--implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See theGNU General Public License for 
--more details.You should have received a copy of the GNU General Public Licensealong with this program.  

--If not, see <https://www.gnu.org/licenses/>.

--paul.marbeau@alten.com
--sequence_treatment_synchro.vhd

-- Company: IRAP
-- Engineer: Paul Marbeau
-- 
-- Create Date: 09.05.2022 
-- Design Name: 
-- Module Name: sequence_treatment_synchro - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module instantiates the synchro signal
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sequence_treatment_synchro is
    Port (
    i_clk : in STD_LOGIC;
    i_clk_row_enable : in STD_LOGIC;
    i_rst_n : in STD_LOGIC;
    i_cmd : in STD_LOGIC_VECTOR(39 downto 0);
    i_NRO : in STD_LOGIC_VECTOR(5 downto 0);
    i_DEL : in std_logic_vector(7 downto 0);
    o_sig_late : out STD_LOGIC;
    o_long_sync : out STD_LOGIC
    );
end sequence_treatment_synchro;


architecture Behavioral of sequence_treatment_synchro is

COMPONENT read_5MHz
    PORT (
    i_clk : IN  std_logic;
    i_clk_row_enable : in STD_LOGIC;
    i_rst_n : IN  std_logic;
    i_cmd : IN  std_logic_vector(39 downto 0);
    i_NRO : IN std_logic_vector(5 downto 0);
    o_seq_5MHz : OUT  std_logic
    );
END COMPONENT;


----------- Intern signals -----------------
signal seq_5MHz         : std_logic;
signal seq_5MHz_long    : std_logic;
signal sig_late         : std_logic_vector(0 downto 0);
signal rst              : std_logic;
signal seq_early        : std_logic_vector(0 downto 0);
signal data_valid       : std_logic;
signal clk_row_enable   : std_logic_vector(4 downto 0);


begin

-- instantiation of the modules

uu0: read_5MHz PORT MAP
    (  -- Read of each bit of the sequence at Frow
    i_clk => i_clk,
    i_clk_row_enable => i_clk_row_enable,
    i_rst_n => i_rst_n,
    i_cmd => i_cmd,
    i_NRO => i_NRO,
    o_seq_5MHz => seq_5MHz_long
    );
o_long_sync <= seq_5MHz_long;

-- This process delays the clk_row_clock by 4 clock periods
-- This is to gate the synchronisation signal
P_clkrow_delay : process(i_clk, i_rst_n)
begin
    if (i_rst_n = '0') then
        clk_row_enable(4 downto 0) <= "00000";
    elsif (rising_edge(i_clk)) then 
        clk_row_enable(4 downto 0) <= clk_row_enable(3 downto 0) & i_clk_row_enable;
    end if;
end process;

-- This process gates the synchronisation signal (few clock periods only)
P_sync_duration : process(i_clk, i_rst_n)
begin
    if (i_rst_n = '0') then
        seq_5MHz <= '0';
    elsif (rising_edge(i_clk)) then
        if (i_clk_row_enable = '1') then
            seq_5MHz <= seq_5MHz_long;
        elsif (clk_row_enable(4) = '1') then
            seq_5MHz <= '0';
    end if;
end process;

delay_mgt : entity work.delay_mgt
    generic map 
        (
        data_size   => 1,                  -- Width of the data to store
        dpram_depth => 256                 -- Depth of the DPRAM ! Must be > or = 64 !
        )
    port map 
        (	
        data_a  	=> seq_early,
        data_b	    => seq_early,
        clk  		=> i_clk,                           -- Clock for both ports 
        rst         => rst,                             -- Reset to get the valid data
        delay_value => i_DEL,                           -- Delay value
        q_a	        => open,                            -- Data output for port A
        q_b		    => sig_late,                        -- Data output for port B
        data_valid  => data_valid
        );

seq_early(0) <= seq_5MHz; 	        
o_sig_late <= sig_late(0) and data_valid;
rst <= not(i_rst_n);

end Behavioral;

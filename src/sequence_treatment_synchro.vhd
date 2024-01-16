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

COMPONENT read_5MHz_master
    PORT (
        i_clk               : IN std_logic;
        i_clk_row_enable    : in std_logic;
        i_rst_n             : IN std_logic;
        i_cmd               : IN std_logic_vector(39 downto 0);
        i_NRO               : IN std_logic_vector(5 downto 0);
        o_seq_5MHz          : OUT std_logic
        );
END COMPONENT;

COMPONENT delay_mgt
    PORT (
		data_in  	: in std_logic;
		clk  		: in std_logic;
		i_rst_n     : in std_logic;
		delay_value : in std_logic_vector(7 downto 0);
		data_out	: out std_logic
        );
END COMPONENT;

----------- Intern signals -----------------
signal seq_5MHz         : std_logic;
signal seq_5MHz_long    : std_logic;
signal seq_5MHz_delayed : std_logic;
signal seq_early        : std_logic_vector(0 downto 0);
signal data_valid       : std_logic;
signal counter          : natural;


begin

-- instantiation of the modules

uu0: read_5MHz_master PORT MAP
    (  -- Read of each bit of the sequence at Frow
    i_clk => i_clk,
    i_clk_row_enable => i_clk_row_enable,
    i_rst_n => i_rst_n,
    i_cmd => i_cmd,
    i_NRO => i_NRO,
    o_seq_5MHz => seq_5MHz_long
    );
o_long_sync <= seq_5MHz_long;

-- This process gates the synchronisation signal (few clock periods only)
P_sync_duration: process(i_clk, i_rst_n)
begin
    if (i_rst_n = '0') then
        counter <= 0;
        seq_5MHz <= '0';
    elsif (rising_edge(i_clk)) then
        if (i_clk_row_enable = '1' and seq_5MHz_long = '1') then
            counter <= 0;
            seq_5MHz <= '1';
        elsif (counter > 4) then
            seq_5MHz <= '0';
        else 
           counter <= counter + 1;
        end if;
    end if;
end process;

delay_mgt: delay_mgt PORT MAP
    (	
    data_in  	=> seq_5MHz,
    clk  		=> i_clk,
    i_rst_n     => i_rst_n,
    delay_value => i_DEL,
    data_out    => seq_5MHz_delayed
    );

o_sig_late <= seq_5MHz_delayed;

end Behavioral;

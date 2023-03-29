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
--sequence_treatment.vhd

-- Company: IRAP
-- Engineer: No�mie Rolland
-- 
-- Create Date: 23.02.2021 12:00:40
-- Design Name: 
-- Module Name: sequence_treatment - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module instantiates all the modules that manage the switch control
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

entity sequence_treatment is
    Port (
        i_clk : in STD_LOGIC;
        i_clk_row_enable : in STD_LOGIC;
        i_rst_n : in STD_LOGIC;
        i_sync_lasting_row : in STD_LOGIC;          -- Sync (during Trow)
        i_cmd : in STD_LOGIC_VECTOR (39 downto 0);
        i_REV : in STD_LOGIC_VECTOR(3 downto 0);
        i_first_row : in STD_LOGIC; -- = Cmd_row.Row(0) 
        i_NRO : in STD_LOGIC_VECTOR(5 downto 0);
        o_sig_overlap : out STD_LOGIC;
        ); 
end sequence_treatment;

architecture Behavioral of sequence_treatment is

COMPONENT read_5MHz_slave
    PORT (
        i_clk : IN  std_logic;
        i_clk_row_enable : in STD_LOGIC;
        i_sync_lasting_row : in STD_LOGIC;          -- Sync (during Trow)
        i_rst_n : IN  std_logic;
        i_cmd : IN  std_logic_vector(39 downto 0);
        i_NRO : IN std_logic_vector(5 downto 0);
        o_seq_5MHz : OUT  std_logic
        );
END COMPONENT;

COMPONENT shift_register_15b
    PORT (
         i_clk : IN  std_logic;
         i_rst_n : IN  std_logic;
         i_seq_5MHz : IN  std_logic;
         o_sig_delayed : OUT  std_logic_vector(14 downto 0)
        );
END COMPONENT;
	     
component mux_overlap is
    Port (
        i_clk : in STD_LOGIC;
        i_rst_n : in STD_LOGIC;
        i_REV : in STD_LOGIC_VECTOR(3 downto 0);
        i_sig_delayed : in STD_LOGIC_VECTOR(14 downto 0);
        o_sig_overlap : out STD_LOGIC
        );
end component;


----------- Intern signals -----------------
--signal clk_en_5M : std_logic;
signal seq_5MHz : std_logic;
signal sig_delayed : std_logic_vector(14 downto 0);
   
begin

-- instantiation of the modules

uu0: read_5MHz_slave PORT MAP (  -- Read the bits of the sequence at Frow
    i_clk => i_clk,
    i_clk_row_enable => i_clk_row_enable,
    i_sync_lasting_row => i_sync_lasting_row,          -- Sync (during Trow)
    i_rst_n => i_rst_n,
    i_cmd => i_cmd,
    i_NRO => i_NRO,
    o_seq_5MHz => seq_5MHz
    );

uu1: shift_register_15b PORT MAP ( -- Creation of delays (for overlap)
    i_clk => i_clk,
    i_rst_n => i_rst_n,
    i_seq_5MHz => seq_5MHz,
    o_sig_delayed => sig_delayed
    );

uu2 : mux_overlap PORT MAP ( -- Select the positive or the negativ overlap according to REV
    i_clk => i_clk,
    i_rst_n => i_rst_n,
    i_REV => i_REV,
    i_sig_delayed => sig_delayed,
    o_sig_overlap => o_sig_overlap
    );

end Behavioral;

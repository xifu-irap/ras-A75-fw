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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sequence_treatment_synchro is
    Port ( i_clk : in STD_LOGIC;
           i_clk_en_5M : in STD_LOGIC;
           i_rst_n : in STD_LOGIC;
           i_cmd : in STD_LOGIC_VECTOR (39 downto 0);
           i_NRO : in STD_LOGIC_VECTOR(5 downto 0);
           i_DEL : in std_logic_vector(13 downto 0);
           o_sig_late : out STD_LOGIC);
end sequence_treatment_synchro;

architecture Behavioral of sequence_treatment_synchro is

COMPONENT read_5MHz
    PORT(
         i_clk : IN  std_logic;
         i_clk_en_5M : in STD_LOGIC;
         i_rst_n : IN  std_logic;
         i_cmd : IN  std_logic_vector(39 downto 0);
         i_NRO : IN std_logic_vector(5 downto 0);
         o_seq_5MHz : OUT  std_logic
        );
    END COMPONENT;

COMPONENT shift_register_15b
    PORT(
         i_clk : IN  std_logic;
         i_rst_n : IN  std_logic;
         i_seq_5MHz : IN  std_logic;
         o_sig_late : OUT  std_logic_vector(14 downto 0)
        );
    END COMPONENT;

----------- Intern signals -----------------
signal seq_5MHz : std_logic;
signal sig_late : std_logic_vector(14 downto 0);


   
begin

-- instantiation of the modules

uu0: read_5MHz PORT MAP (  -- Read of each bit of the sequence at 5 MHz
          i_clk => i_clk,
          i_clk_en_5M => i_clk_en_5M,
          i_rst_n => i_rst_n,
          i_cmd => i_cmd,
          i_NRO => i_NRO,
          o_seq_5MHz => seq_5MHz
        );


		        
o_sig_late <= sig_late;

end Behavioral;

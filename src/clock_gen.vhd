-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            This file is part of the ATHENA X-IFU DRE Telemetry and Telecommand Firmware.
--
--                            ras-a75-fw is free software: you can redistribute it and/or modify
--                            it under the terms of the GNU General Public License as published by
--                            the Free Software Foundation, either version 3 of the License, or
--                            (at your option) any later version.
--
--                            This program is distributed in the hope that it will be useful,
--                            but WITHOUT ANY WARRANTY; without even the implied warranty of
--                            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--                            GNU General Public License for more details.
--
--                            You should have received a copy of the GNU General Public License
--                            along with this program.  If not, see <https://www.gnu.org/licenses/>.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    email                   paul.marbeau@alten.com
--!   @file                   clock_gen.vhd
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--!   @details                Clock management
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity clock_gen is
    Port ( i_clk : in STD_LOGIC;
           clk_62MHz : out STD_LOGIC;
           o_rst : out std_logic
           );
end clock_gen;

architecture Behavioral of clock_gen is

signal LOCKED : std_logic := '0' ;
signal CLKFBOUT : std_logic ;
signal CLKOUT0 : std_logic ;
signal CLKOUT2 : std_logic ;
signal CLKOUT3 : std_logic ;
signal CLKOUT4 : std_logic ;
signal CLKOUT5 : std_logic ;
signal sync  : std_logic ;
signal rst_gen : std_logic_vector(7 downto 0) ;

begin

    reset_generator: process(LOCKED, i_clk)
    begin
      if (LOCKED = '0') then
        rst_gen <= (others => '1');
      elsif rising_edge(i_clk) then
        -- keep internal reset active for at least <rstn_gen'size> clock cycles --
        rst_gen <= rst_gen(rst_gen'left-1 downto 0) & '0';
      end if;
    end process reset_generator;

    o_rst <= rst_gen(rst_gen'left);

    MMCME2_BASE_inst : MMCME2_BASE
    generic map (
       BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
       CLKFBOUT_MULT_F => 5.0,    -- Multiply value for all CLKOUT (2.000-64.000).
       CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
       CLKIN1_PERIOD => 5.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
       CLKOUT1_DIVIDE => 16,
       CLKOUT2_DIVIDE => 1,
       CLKOUT3_DIVIDE => 1,
       CLKOUT4_DIVIDE => 1,
       CLKOUT5_DIVIDE => 1,
       CLKOUT6_DIVIDE => 1,
       CLKOUT0_DIVIDE_F => 1.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
       -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
       CLKOUT0_DUTY_CYCLE => 0.5,
       CLKOUT1_DUTY_CYCLE => 0.5,
       CLKOUT2_DUTY_CYCLE => 0.5,
       CLKOUT3_DUTY_CYCLE => 0.5,
       CLKOUT4_DUTY_CYCLE => 0.5,
       CLKOUT5_DUTY_CYCLE => 0.5,
       CLKOUT6_DUTY_CYCLE => 0.5,
       -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       CLKOUT0_PHASE => 0.0,
       CLKOUT1_PHASE => 0.0,
       CLKOUT2_PHASE => 0.0,
       CLKOUT3_PHASE => 0.0,
       CLKOUT4_PHASE => 0.0,
       CLKOUT5_PHASE => 0.0,
       CLKOUT6_PHASE => 0.0,
       CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
       DIVCLK_DIVIDE => 1,        -- Master division value (1-106)
       REF_JITTER1 => 0.0,        -- Reference input jitter in UI (0.000-0.999).
       STARTUP_WAIT => FALSE      -- Delays DONE until MMCM is locked (FALSE, TRUE)
    )
    port map (
       -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
       CLKOUT0 => open,     -- 1-bit output: CLKOUT0
       CLKOUT0B => open,   -- 1-bit output: Inverted CLKOUT0
       CLKOUT1 => clk_62MHz,     -- 1-bit output: CLKOUT1
       CLKOUT1B => open,   -- 1-bit output: Inverted CLKOUT1
       CLKOUT2 => open,     -- 1-bit output: CLKOUT2
       CLKOUT2B => open,   -- 1-bit output: Inverted CLKOUT2
       CLKOUT3 => open,     -- 1-bit output: CLKOUT3
       CLKOUT3B => open,   -- 1-bit output: Inverted CLKOUT3
       CLKOUT4 => open,     -- 1-bit output: CLKOUT4
       CLKOUT5 => open,     -- 1-bit output: CLKOUT5
       CLKOUT6 => open,     -- 1-bit output: CLKOUT6
       -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
       CLKFBOUT => CLKFBOUT,   -- 1-bit output: Feedback clock
       CLKFBOUTB => open, -- 1-bit output: Inverted CLKFBOUT
       -- Status Ports: 1-bit (each) output: MMCM status ports
       LOCKED => LOCKED,       -- 1-bit output: LOCK
       -- Clock Inputs: 1-bit (each) input: Clock input
       CLKIN1 => i_clk,       -- 1-bit input: Clock
       -- Control Ports: 1-bit (each) input: MMCM control ports
       PWRDWN => '0',       -- 1-bit input: Power-down
       RST => '0',             -- 1-bit input: Reset
       -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
       CLKFBIN => CLKFBOUT     -- 1-bit input: Feedback clock
    );
 
end Behavioral;

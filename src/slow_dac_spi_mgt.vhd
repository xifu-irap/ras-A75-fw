-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            Copyright (C) 2021-2030 Paul Marbeau, IRAP Toulouse.
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--                            This file is part of the ATHENA X-IFU DRE Time Domain Multiplexing Firmware.
--
--                            ras_a75_fw is free software: you can redistribute it and/or modify
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
--!   @file                   slow_dac_spi_mgt.vhd
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--    Automatic Generation    No
--    Code Rules Reference    SOC of design and VHDL handbook for VLSI development, CNES Edition (v2.1)
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--!   @details                Specific project constants
-- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

library work;
use     work.pkg_func_math.all;
use     work.pkg_project.all;

entity slow_dac_spi_mgt is port
   (     i_rst                : in     std_logic                                                            ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
         sys_clk              : in     std_logic                                                            ; --! System Clock
         Cmd_DAC_row          : in std_logic_vector (31 downto 0) ;
         Cmd_DAC_cluster      : in std_logic_vector (31 downto 0) ;
         Cmd_DAC_start        : in std_logic ;   

         o_adc_spi_mosi   : out    std_logic                                                                ; --! ADC - SPI Serial Data In Out
         o_adc_spi_sclk   : out    std_logic                                                                ; --! ADC - SPI Serial Clock (CPOL = ‘0’, CPHA = ’0’)
         o_adc_spi_cs_n   : out    std_logic                                                                ; --! ADC - SPI Chip Select ('0' = Active, '1' = Inactive)

         o_dac_data                   : out    std_logic                                                                  ;   --! DAC - Serial Data
         o_dac_sclk                   : out    std_logic                                                                  ;   --! DAC - Serial Clock
         o_dac_sync_row_high_n        : out    std_logic                                                                  ;   --! DAC - Frame Synchronization ('0' = Active, '1' = Inactive)
         o_dac_sync_row_low_n         : out    std_logic                                                                  ;   --! DAC - Frame Synchronization ('0' = Active, '1' = Inactive)
         o_dac_sync_cluster_high_n    : out    std_logic                                                                  ;   --! DAC - Frame Synchronization ('0' = Active, '1' = Inactive)
         o_dac_sync_cluster_low_n     : out    std_logic                                                                      --! DAC - Frame Synchronization ('0' = Active, '1' = Inactive)

   );
end entity slow_dac_spi_mgt;

architecture RTL of slow_dac_spi_mgt is
constant c_SPI_SER_WD_S_V_S   : integer := log2_ceil(c_DAC_SPI_SER_WD_S+1)                                  ; --! DAC SPI: Serial word size vector bus size
constant c_DAC_SPI_SER_WD_S_V : std_logic_vector(c_SPI_SER_WD_S_V_S-1 downto 0) :=
                                std_logic_vector(to_unsigned(c_DAC_SPI_SER_WD_S, c_SPI_SER_WD_S_V_S))       ; --! DAC SPI: Serial word size vector
signal   o_dac_sync_n         : std_logic                                                                   ; --! Chip Select of the spi_master block
signal   dac_spi_start        : std_logic                                                                   ; --! DAC SPI: Start transmit ('0' = Inactive, '1' = Active)
signal   dac_spi_data_tx      : std_logic_vector(c_DAC_SPI_SER_WD_S-1 downto 0)                             ; --! DAC SPI: Data to transmit (stall on MSB)
signal   dac_spi_tx_busy_n    : std_logic                                                                   ; --! DAC SPI: Transmit link busy ('0' = Busy, '1' = Not Busy)
signal   cnt_dac              : std_logic_vector(1 downto 0 )                                               ; --|
signal   cnt_en               : std_logic                                                                   ; -- |
signal   spi_free             : std_logic                                                                   ; --  } Management signals
signal   start                : std_logic                                                                   ; -- |
signal   flag                 : std_logic                                                                   ; --|
signal   o_dac_data_r         : std_logic                                                                   ; --! Registered signals for delay purposes                                                                
signal   o_dac_sclk_r         : std_logic                                                                   ; --! Registered signals for delay purposes

begin

   -- ------------------------------------------------------------------------------------------------------
   --!   ADC, static configuration without SPI
   -- ------------------------------------------------------------------------------------------------------
   o_adc_spi_mosi   <= '1';     -- Duty Cycle Stabilizer ('0' = Disable, '1' = Enable)
   o_adc_spi_sclk   <= '0';     -- Data format ('0' = Binary, '1' = Twos complement)
   o_adc_spi_cs_n   <= '1';     -- Static configuration ('0' = No, '1' = Yes)

   -- ------------------------------------------------------------------------------------------------------
   --!   SPI master
   --    @Req : 
   -- ------------------------------------------------------------------------------------------------------
   I_dac_spi_master : entity work.spi_master generic map
   (     g_CPOL               => c_DAC_SPI_CPOL       , -- std_logic                                        ; --! Clock polarity
         g_CPHA               => c_DAC_SPI_CPHA       , -- std_logic                                        ; --! Clock phase
         g_N_CLK_PER_SCLK_L   => c_DAC_SPI_SCLK_L     , -- integer                                          ; --! Number of clock period for elaborating SPI Serial Clock low  level
         g_N_CLK_PER_SCLK_H   => c_DAC_SPI_SCLK_H     , -- integer                                          ; --! Number of clock period for elaborating SPI Serial Clock high level
         g_N_CLK_PER_MISO_DEL => 0                    , -- integer                                          ; --! Number of clock period for miso signal delay from spi pin input to spi master input
         g_DATA_S             => c_DAC_SPI_SER_WD_S     -- integer                                            --! Data bus size
   ) port map
   (     i_rst                => i_rst                , -- in     std_logic                                 ; --! Reset asynchronous assertion, synchronous de-assertion ('0' = Inactive, '1' = Active)
         i_clk                => sys_clk              , -- in     std_logic                                 ; --! Clock

         i_start              => dac_spi_start        , -- in     std_logic                                 ; --! Start transmit ('0' = Inactive, '1' = Active)
         i_ser_wd_s           => c_DAC_SPI_SER_WD_S_V , -- in     slv(log2_ceil(g_DATA_S+1)-1 downto 0)     ; --! Serial word size
         i_data_tx            => dac_spi_data_tx      , -- in     std_logic_vector(g_DATA_S-1 downto 0)     ; --! Data to transmit (stall on MSB)
         o_tx_busy_n          => dac_spi_tx_busy_n    , -- out    std_logic                                 ; --! Transmit link busy ('0' = Busy, '1' = Not Busy)

         o_data_rx            => open                 , -- out    std_logic_vector(g_DATA_S-1 downto 0)     ; --! Receipted data (stall on LSB)
         o_data_rx_rdy        => open                 , -- out    std_logic                                 ; --! Receipted data ready ('0' = Not ready, '1' = Ready)

         i_miso               => '0'                  , -- in     std_logic                                 ; --! SPI Master Input Slave Output
         o_mosi               => o_dac_data_r         , -- out    std_logic                                 ; --! SPI Master Output Slave Input
         o_sclk               => o_dac_sclk_r         , -- out    std_logic                                 ; --! SPI Serial Clock
         o_cs_n               => o_dac_sync_n       -- out    std_logic                                   --! SPI Chip Select ('0' = Active, '1' = Inactive)
   );


  process (sys_clk, i_rst)
  begin
      if i_rst = '1'                   -- Initialisation 
      then 
           dac_spi_data_tx <= (others=>'0');
           cnt_dac <= "00";
           o_dac_data <= '0' ;
           o_dac_sync_row_high_n <= '1' ;
           o_dac_sync_row_low_n <= '1' ;
           o_dac_sync_cluster_high_n <= '1' ;
           o_dac_sync_cluster_low_n <= '1' ;
           flag <='1';
           start <= '0';
      elsif rising_edge(sys_clk)
      then
            if (Cmd_DAC_start ='1' or cnt_en = '1') and dac_spi_tx_busy_n ='1'  -- Assigns the value according to the DAC concerned
            then 
                  dac_spi_start <='0' ;
                  cnt_en <='1';
                  start <= '1' ;
                  if cnt_dac ="00" 
                  then 
                        dac_spi_data_tx   <= Cmd_DAC_row(15 downto 0);
                  elsif cnt_dac ="01" 
                  then 
                        dac_spi_data_tx   <= Cmd_DAC_row(31 downto 16);
                  elsif cnt_dac ="10" 
                  then 
                        dac_spi_data_tx   <= Cmd_DAC_cluster(15 downto 0);
                  elsif cnt_dac ="11" 
                  then
                        dac_spi_data_tx   <= Cmd_DAC_cluster(31 downto 16);
                  end if;
                  if flag ='0'
                  then 
                        cnt_dac <= std_logic_vector(unsigned(cnt_dac) + 1);
                  end if ;
            end if;
            flag <= dac_spi_tx_busy_n ;     --|
            o_dac_data <= o_dac_data_r;     -- } Delay the concerned signals 
            o_dac_sclk <= o_dac_sclk_r;     --|
            if start ='1'
            then
                  dac_spi_start <='1';
                  start <='0' ;
            else 
                  dac_spi_start <='0';
            end if ;
            if cnt_dac ="00"              -- Assign the Chip Select 
            then 
                  o_dac_sync_row_high_n <= '1' ;
                  o_dac_sync_row_low_n <= o_dac_sync_n ;
                  o_dac_sync_cluster_high_n <= '1' ;
                  o_dac_sync_cluster_low_n <= '1' ;
            elsif cnt_dac ="01" 
            then 
                  o_dac_sync_row_high_n <= o_dac_sync_n ;
                  o_dac_sync_row_low_n <= '1' ;
                  o_dac_sync_cluster_high_n <= '1' ;
                  o_dac_sync_cluster_low_n <= '1' ;
            elsif cnt_dac ="10" 
            then 
                  o_dac_sync_row_high_n <= '1' ;
                  o_dac_sync_row_low_n <= '1' ;
                  o_dac_sync_cluster_high_n <= '1' ;
                  o_dac_sync_cluster_low_n <= o_dac_sync_n ;
            elsif cnt_dac ="11" 
            then
                  o_dac_sync_row_high_n <= '1' ;
                  o_dac_sync_row_low_n <= '1' ;
                  o_dac_sync_cluster_high_n <= o_dac_sync_n ;
                  o_dac_sync_cluster_low_n <= '1' ;
            end if;
            if cnt_dac = "11" and Cmd_DAC_start ='0' and dac_spi_tx_busy_n ='0' and flag ='1'  -- Disable the loop if at least one cycle is done
            then
                  cnt_en <='0' ;
                  dac_spi_start <= '0' ; 
            end if ;
            if cnt_en ='0' and Cmd_DAC_start ='1'
            then 
                  cnt_dac <="00" ;
            end if;
     end if ;
end process ; 

end architecture RTL;

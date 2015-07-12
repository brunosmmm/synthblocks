----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:55:59 07/03/2015 
-- Design Name: 
-- Module Name:    synthblocks - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.NUMERIC_STD.ALL;
use work.Spar6_Parts.all;

use work.sb_common.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity synthblocks is
  generic(data_depth : integer := 24);
  port (ck : in std_logic;
        top_rst : in std_logic;
		switches : in std_logic_vector(7 downto 0);

   --ac97
        sdata_in : in std_logic;
        bit_clk : in std_logic;
        sync : out std_logic;
        sdata_out : out std_logic;
        ac97_nrst : out std_logic;
   --serial comm
        midi_rx : in std_logic;
        midi_tx : out std_logic);
  
end synthblocks;

architecture Behavioral of synthblocks is

  --general signals
  signal sysclk_10 : std_logic;
  signal sysclk_100 : std_logic;
  signal rst : std_logic;

  --voice group signals
  signal vgroup0_cmat1 : std_logic_vector(15 downto 0);
  signal vgroup0_cmat2 : std_logic_vector(15 downto 0);
  signal vgroup0_shamt_12 : std_logic_vector(15 downto 0);
  signal vgroup0_shamt_34 : std_logic_vector(15 downto 0);
  signal vgroup0_osc_sel : std_logic_vector(15 downto 0);
  signal vgroup0_op_sel : std_logic_vector(15 downto 0);
  signal vgroup0_pconf1 : std_logic_vector(15 downto 0);
  
  --voice signals
  signal voice_0_out : std_logic_vector(data_depth-1 downto 0);
  signal voice_0_pitch : std_logic_vector(6 downto 0);
  signal voice_0_vel : std_logic_vector(6 downto 0);
  signal voice_0_active : std_logic;
  
  signal voice_1_out : std_logic_vector(data_depth-1 downto 0);
  signal voice_1_pitch : std_logic_vector(6 downto 0);
  signal voice_1_vel : std_logic_vector(6 downto 0);
  signal voice_1_active : std_logic;

  signal voice_2_out : std_logic_vector(data_depth-1 downto 0);
  signal voice_2_pitch : std_logic_vector(6 downto 0);
  signal voice_2_vel : std_logic_vector(6 downto 0);  
  signal voice_2_active : std_logic;

  signal voice_3_out : std_logic_vector(data_depth-1 downto 0);
  signal voice_3_pitch : std_logic_vector(6 downto 0);
  signal voice_3_vel : std_logic_vector(6 downto 0);
  signal voice_3_active : std_logic;
  
  component clk_wiz_v3_6 is
    port
      (-- Clock in ports
        CLK_IN1           : in     std_logic;
        -- Clock out ports
        CLK_OUT1          : out    std_logic;
        CLK_OUT2          : out    std_logic;
        -- Status and control signals
        RESET             : in     std_logic;
        LOCKED            : out    std_logic
        );
  end component;

  --ac97 signals
  signal latching_cmd : std_logic;
  signal ready : std_logic;
  signal L_bus, R_bus, L_bus_out, R_bus_out : std_logic_vector(17 downto 0);
  signal cmd_addr : std_logic_vector(7 downto 0);
  signal cmd_data : std_logic_vector(15 downto 0);

  --control bus
  signal ctl_data_addr : std_logic_vector(15 downto 0);
  signal ctl_data_from : std_logic_vector(15 downto 0);
  signal ctl_data_to : std_logic_vector(15 downto 0);
  signal ctl_rd : std_logic;
  signal ctl_wr : std_logic;
  
  signal pitch_data_to_ctl : std_logic_vector(15 downto 0);
  signal voice_data_to_ctl : std_logic_vector(15 downto 0);

  --control registers
  
  
begin

  rst <= not top_rst;
  voice_0_pitch <= switches(5 downto 0) & '0';
  vgroup0_osc_sel <= "00000000000000" & switches(7 downto 6);
  vgroup0_cmat1 <= x"0001";
  vgroup0_cmat2 <= x"0002";
  vgroup0_op_sel <= x"0000";
  voice_0_active <= '1';
  voice_0_vel <= (others=>'1');
  
  --system clock
  pll: clk_wiz_v3_6 
	port map(clk_in1 => ck,
	         clk_out1 => sysclk_100,
             clk_out2 => sysclk_10,
             reset=> rst,
             locked=>open);

  --audio codec
  ac97_ctl : entity work.ac97(arch)
    port map(n_reset=>top_rst,
             clk=>sysclk_100,
             ac97_sdata_out=>sdata_out,
             ac97_sdata_in=>sdata_in,
             latching_cmd=>latching_cmd,
             ac97_sync=>sync,
             ac97_bitclk=>bit_clk,
             ac97_n_reset=>ac97_nrst,
             ac97_ready_sig=>ready,
             L_out=>L_bus,
             R_out=>R_bus,
             L_in=>L_bus_out,
             R_in=>R_bus_out,
             cmd_addr=>cmd_addr,
             cmd_data=>cmd_data);

  ac97cmd_ctl: entity work.ac97cmd(arch)
    port map(clk=>sysclk_100,
             ac97_ready_sig=>ready,
             cmd_addr=>cmd_addr,
             cmd_data=>cmd_data,
             volume=>"11111",
             source=>"000",
             latching_cmd=>latching_cmd);

  --voices
  voice0: entity work.voice(sound)
    generic map(data_depth=>data_depth,
                control_base=>voice_0_base)
    port map(data_out=>voice_0_out,
             pitch=>voice_0_pitch,
             velocity=>voice_0_vel,
             active=>voice_0_active,
             clk_100=>sysclk_100,
             rst=>rst,
             ctl_data_addr=>ctl_data_addr,
             ctl_data_in=>ctl_data_from,
             ctl_data_out=>open,
             ctl_rd=>ctl_rd,
             ctl_wr=>ctl_wr);

  voice1: entity work.voice(sound)
    generic map(data_depth=>data_depth,
                control_base=>voice_0_base)
    port map(data_out=>voice_1_out,
             pitch=>voice_1_pitch,
             velocity=>voice_1_vel,
             active=>voice_1_active,
             clk_100=>sysclk_100,
             rst=>rst,
             ctl_data_addr=>ctl_data_addr,
             ctl_data_in=>ctl_data_from,
             ctl_data_out=>open,
             ctl_rd=>ctl_rd,
             ctl_wr=>ctl_wr);

  voice2: entity work.voice(sound)
    generic map(data_depth=>data_depth,
                control_base=>voice_0_base)
    port map(data_out=>voice_2_out,
             pitch=>voice_2_pitch,
             velocity=>voice_2_vel,
             active=>voice_2_active,
             clk_100=>sysclk_100,
             rst=>rst,
             ctl_data_addr=>ctl_data_addr,
             ctl_data_in=>ctl_data_from,
             ctl_data_out=>open,
             ctl_rd=>ctl_rd,
             ctl_wr=>ctl_wr);

    voice3: entity work.voice(sound)
      generic map(data_depth=>data_depth,
                  control_base=>voice_0_base)
    port map(data_out=>voice_3_out,
             pitch=>voice_3_pitch,
             velocity=>voice_3_vel,
             active=>voice_3_active,
             clk_100=>sysclk_100,
             rst=>rst,
             ctl_data_addr=>ctl_data_addr,
             ctl_data_in=>ctl_data_from,
             ctl_data_out=>open,
             ctl_rd=>ctl_rd,
             ctl_wr=>ctl_wr);

  --communications unit
  comm_unit: entity work.serial_midi(comm)
    port map(clk=>sysclk_100,
             rst=>rst,
             ctl_addr=>ctl_data_addr,
             ctl_data_out=>ctl_data_from,
             pitch_data_in=>pitch_data_to_ctl,
				 voice_data_in=>voice_data_to_ctl,
             ctl_rd=>ctl_rd,
             ctl_wr=>ctl_wr,
             rx=>midi_rx,
             tx=>midi_tx);

  --pitch generation & control
  pitch_unit: entity work.pitch_gen(gen)
    port map(clk=>sysclk_100,
             rst=>rst,
             data_addr=>ctl_data_addr,
             data_in=>ctl_data_from,
             data_out=>pitch_data_to_ctl,
             rd_en=>ctl_rd,
             wr_en=>ctl_wr,
             v0_pitch=>open,--voice_0_pitch
             v0_vel=>open,
             v0_active=>open,
             v1_pitch=>voice_1_pitch,
             v1_vel=>voice_1_vel,
             v1_active=>voice_1_active,
             v2_pitch=>voice_2_pitch,
             v2_vel=>voice_2_vel,
             v2_active=>voice_2_active,
             v3_pitch=>voice_3_pitch,
             v3_vel=>voice_3_vel,
             v3_active=>voice_3_active
             );
    
  
  --sample oscillator data
  process (sysclk_100, rst)
  begin

    if rst = '1' then
      L_bus <= (others=>'0');
      R_bus <= (others=>'0');
    elsif rising_edge(sysclk_100) then
      if (ready = '1') then
        L_bus <= voice_0_out(data_depth-1 downto data_depth-18);
        R_bus <= voice_0_out(data_depth-1 downto data_depth-18);
      end if; 
    end if;
    
  end process;
  
    
end Behavioral;


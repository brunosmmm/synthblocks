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
		switches : in std_logic_vector(8 downto 0);

   --ac97
        sdata_in : in std_logic;
        bit_clk : in std_logic;
        sync : out std_logic;
        sdata_out : out std_logic;
        ac97_nrst : out std_logic);
  
end synthblocks;

architecture Behavioral of synthblocks is

  --general signals
  signal sysclk_10 : std_logic;
  signal sysclk_100 : std_logic;
  signal rst : std_logic;

  --osc1 signals
  signal osc1_sel : std_logic_vector(2 downto 0);
  signal osc1_out : std_logic_vector(data_depth-1 downto 0);
  signal osc1_pitch : std_logic_vector(6 downto 0);
  signal osc1_spitch : std_logic_vector(6 downto 0);
  signal osc1_shamt : std_logic_vector(7 downto 0);
  signal osc1_gain : std_logic_vector(15 downto 0);
  signal osc1_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc2 signals
  signal osc2_sel : std_logic_vector(2 downto 0);
  signal osc2_out : std_logic_vector(data_depth-1 downto 0);
  signal osc2_pitch : std_logic_vector(6 downto 0);
  signal osc2_spitch : std_logic_vector(6 downto 0);
  signal osc2_shamt : std_logic_vector(7 downto 0);
  signal osc2_gain : std_logic_vector(15 downto 0);
  signal osc2_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc3 signals
  signal osc3_sel : std_logic_vector(2 downto 0);
  signal osc3_out : std_logic_vector(data_depth-1 downto 0);
  signal osc3_pitch : std_logic_vector(6 downto 0);
  signal osc3_spitch : std_logic_vector(6 downto 0);
  signal osc3_shamt : std_logic_vector(7 downto 0);
  signal osc3_gain : std_logic_vector(15 downto 0);
  signal osc3_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc4 signals
  signal osc4_sel : std_logic_vector(2 downto 0);
  signal osc4_out : std_logic_vector(data_depth-1 downto 0);
  signal osc4_pitch : std_logic_vector(6 downto 0);
  signal osc4_spitch : std_logic_vector(6 downto 0);
  signal osc4_shamt : std_logic_vector(7 downto 0);
  signal osc4_gain : std_logic_vector(15 downto 0);
  signal osc4_post_gain : std_logic_vector(data_depth-1 downto 0);

  --operation matrix signals
  signal opmat_cmat1 : std_logic_vector(15 downto 0);
  signal opmat_cmat2 : std_logic_vector(15 downto 0);
  signal opmat_sel : std_logic_vector(15 downto 0);
  signal opmat_outa : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outb : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outc : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outd : std_logic_vector(data_depth-1 downto 0);

  --mixer signals
  signal gain_a : std_logic_vector(15 downto 0);
  signal gain_b : std_logic_vector(15 downto 0);
  signal gain_c : std_logic_vector(15 downto 0);
  signal gain_d : std_logic_vector(15 downto 0);
  signal mixer_out : std_logic_vector(data_depth-1 downto 0);
  
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
  
begin

  rst <= not top_rst;
  osc1_pitch <= switches(5 downto 0) & '0';
  osc1_sel <= '0' & switches(7 downto 6);
  osc2_sel <= (others=>'0');
  osc3_sel <= (others=>'0');
  osc4_sel <= (others=>'0');
  
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
  

  --oscillator instances and peripherals
  osc1_shamt <= (others=>'0');
  osc1_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc1_shamt,
             pitch_in=>osc1_pitch,
             pitch_out=>osc1_spitch);

  osc2_shamt <= (others=>'0');
  osc2_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc2_shamt,
             pitch_in=>osc2_pitch,
             pitch_out=>osc2_spitch);

  osc3_shamt <= (others=>'0');
  osc3_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc3_shamt,
             pitch_in=>osc3_pitch,
             pitch_out=>osc3_spitch);

  osc4_shamt <= (others=>'0');
  osc4_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc4_shamt,
             pitch_in=>osc4_pitch,
             pitch_out=>osc4_spitch);
  
  osc1: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth,
	             wt_size => 9)
    port map( sysclk_10=>sysclk_10,
              rst=>rst,
              sigout=>osc1_out,
              osc_sel=>osc1_sel,
              pitch=>osc1_spitch);

  osc1_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc1_out,
         gain_in=>osc1_gain,
         data_out=>osc1_post_gain);
  
  osc2: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>sysclk_10,
             rst=>rst,
             sigout=>osc2_out,
             osc_sel=>osc2_sel,
             pitch=>osc2_spitch);

  osc2_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc2_out,
         gain_in=>osc2_gain,
         data_out=>osc2_post_gain);
  
  osc3: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>sysclk_10,
             rst=>rst,
             sigout=>osc3_out,
             osc_sel=>osc3_sel,
             pitch=>osc3_spitch);

  osc3_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc3_out,
         gain_in=>osc3_gain,
         data_out=>osc3_post_gain);
  
  osc4: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>sysclk_10,
             rst=>rst,
             sigout=>osc4_out,
             osc_sel=>osc4_sel,
             pitch=>osc4_spitch);

  osc4_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc4_out,
         gain_in=>osc4_gain,
         data_out=>osc4_post_gain);
  
  --operation matrix
  opmat : entity work.op_matrix(operate)
    generic map(data_depth=>data_depth)
    port map(in_1=>osc1_post_gain,
             in_2=>osc2_post_gain,
             in_3=>osc3_post_gain,
             in_4=>osc4_post_gain,
             cmat_1=>opmat_cmat1,
             cmat_2=>opmat_cmat2,
             op_sel=>opmat_sel,
             out_a=>opmat_outa,
             out_b=>opmat_outb,
             out_c=>opmat_outc,
             out_d=>opmat_outd);

  --connect osc1 & osc2 to op_a
  opmat_cmat1 <= x"0001";
  opmat_cmat2 <= x"0002";
  opmat_sel <= x"0000"; --ch1 passthrough on all

  --mix oscillators
  mix0: entity work.4_to_1_mixer(mix)
    generic map(data_depth=>data_depth)
    port map(in_1=>opmat_outa,
             in_2=>opmat_outb,
             in_3=>opmat_outc,
             in_4=>opmat_outd,
             gain_1=>gain_a,
             gain_2=>gain_b,
             gain_3=>gain_c,
             gain_4=>gain_d,
             mix_out=>mixer_out
             );

  --sample oscillator data
  process (sysclk_100, rst, osc1_post_gain)
  begin

    if rst = '1' then
      L_bus <= (others=>'0');
      R_bus <= (others=>'0');
    elsif rising_edge(sysclk_100) then
      if (ready = '1') then
        L_bus <= mixer_out(data_depth-1 downto data_depth-18);
        R_bus <= mixer_out(data_depth-1 downto data_depth-18);
      end if; 
    end if;
    
  end process;
  
    
end Behavioral;


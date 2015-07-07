library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity voice is
  generic(data_depth : integer := 24);
  port(pitch : in std_logic_vector(6 downto 0);
       data_out : out std_logic_vector(data_depth-1 downto 0);
		 clk_100 : in std_logic;
		 rst : in std_logic;

       --configuration
       osc_sel : in std_logic_vector(15 downto 0);
       osc_1_2_shamt : in std_logic_vector(15 downto 0);
       osc_3_4_shamt : in std_logic_vector(15 downto 0);
       opmat_cmat1 : in std_logic_vector(15 downto 0);
       opmat_cmat2 : in std_logic_vector(15 downto 0);
       opmat_sel : in std_logic_vector(15 downto 0);
       active : in std_logic
       
       );

end entity;

architecture sound of voice is

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
  
begin

  --oscillator instances and peripherals
  osc1_shamt <= osc_1_2_shamt(7 downto 0);
  osc1_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc1_shamt,
             pitch_in=>osc1_pitch,
             pitch_out=>osc1_spitch);

  osc2_shamt <= osc_1_2_shamt(15 downto 8);
  osc2_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc2_shamt,
             pitch_in=>osc2_pitch,
             pitch_out=>osc2_spitch);

  osc3_shamt <= osc_3_4_shamt(7 downto 0);
  osc3_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc3_shamt,
             pitch_in=>osc3_pitch,
             pitch_out=>osc3_spitch);

  osc4_shamt <= osc_3_4_shamt(15 downto 8);
  osc4_shift: entity work.pitch_shifter(shift)
    port map(shamt=> osc4_shamt,
             pitch_in=>osc4_pitch,
             pitch_out=>osc4_spitch);
  
  osc1_sel <= osc_sel(2 downto 0);
  osc1: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth,
	             wt_size => 9)
    port map( sysclk_10=>clk_100,
              rst=>rst,
              sigout=>osc1_out,
              osc_sel=>osc1_sel,
              pitch=>osc1_spitch);

  osc1_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc1_out,
         gain_in=>osc1_gain,
         data_out=>osc1_post_gain);

  osc2_sel <= osc_sel(5 downto 3);
  osc2: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>clk_100,
             rst=>rst,
             sigout=>osc2_out,
             osc_sel=>osc2_sel,
             pitch=>osc2_spitch);

  osc2_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc2_out,
         gain_in=>osc2_gain,
         data_out=>osc2_post_gain);

  osc3_sel <= osc_sel(8 downto 6);
  osc3: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>clk_100,
             rst=>rst,
             sigout=>osc3_out,
             osc_sel=>osc3_sel,
             pitch=>osc3_spitch);

  osc3_gain_block : entity work.gain(modify)
    generic map(data_depth=>data_depth)
    port map(data_in=>osc3_out,
         gain_in=>osc3_gain,
         data_out=>osc3_post_gain);

  osc4_sel <= osc_sel(11 downto 9);
  osc4: entity work.osc(Behavioral)
    generic map(data_depth=>data_depth)
    port map(sysclk_10=>clk_100,
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

  --mix oscillators
  mix0: entity work.mix_4_to_1(mix)
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

  data_out <= mixer_out when active = '1' else
              (others=>'0');
  
end architecture;

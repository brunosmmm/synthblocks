library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee_proposed;
use ieee_proposed.fixed_pkg.all;

use work.sb_common.all;

entity voice is
  generic(data_depth : integer := 24;
          control_base : std_logic_vector(15 downto 0));
  port(pitch : in std_logic_vector(6 downto 0);
       velocity : in std_logic_vector(6 downto 0);
       data_out : out std_logic_vector(data_depth-1 downto 0);
       clk_100 : in std_logic;
       rst : in std_logic;

       active : in std_logic;

       --attack_in : in std_logic_vector(15 downto 0);
       --decay_in : in std_logic_vector(15 downto 0);
       --release_in : in std_logic_vector(15 downto 0);
       --sustain_in : in std_logic_vector(15 downto 0)

       --control bus
       ctl_data_addr : in std_logic_vector(15 downto 0);
       ctl_data_in : in std_logic_vector(15 downto 0);
       ctl_data_out : out std_logic_vector(15 downto 0);
       ctl_rd : in std_logic;
       ctl_wr : in std_logic
       );

end entity;

architecture sound of voice is

  --osc1 signals
  signal osc1_sel : std_logic_vector(2 downto 0);
  signal osc1_out : std_logic_vector(data_depth-1 downto 0);
  --signal osc1_pitch : std_logic_vector(6 downto 0);
  signal osc1_spitch : std_logic_vector(6 downto 0);
  signal osc1_shamt : std_logic_vector(7 downto 0);
  signal osc1_gain : std_logic_vector(6 downto 0);
  signal osc1_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc2 signals
  signal osc2_sel : std_logic_vector(2 downto 0);
  signal osc2_out : std_logic_vector(data_depth-1 downto 0);
  --signal osc2_pitch : std_logic_vector(6 downto 0);
  signal osc2_spitch : std_logic_vector(6 downto 0);
  signal osc2_shamt : std_logic_vector(7 downto 0);
  signal osc2_gain : std_logic_vector(6 downto 0);
  signal osc2_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc3 signals
  signal osc3_sel : std_logic_vector(2 downto 0);
  signal osc3_out : std_logic_vector(data_depth-1 downto 0);
  --signal osc3_pitch : std_logic_vector(6 downto 0);
  signal osc3_spitch : std_logic_vector(6 downto 0);
  signal osc3_shamt : std_logic_vector(7 downto 0);
  signal osc3_gain : std_logic_vector(6 downto 0);
  signal osc3_post_gain : std_logic_vector(data_depth-1 downto 0);

  --osc4 signals
  signal osc4_sel : std_logic_vector(2 downto 0);
  signal osc4_out : std_logic_vector(data_depth-1 downto 0);
  --signal osc4_pitch : std_logic_vector(6 downto 0);
  signal osc4_spitch : std_logic_vector(6 downto 0);
  signal osc4_shamt : std_logic_vector(7 downto 0);
  signal osc4_gain : std_logic_vector(6 downto 0);
  signal osc4_post_gain : std_logic_vector(data_depth-1 downto 0);

  --operation matrix signals
  signal opmat_outa : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outb : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outc : std_logic_vector(data_depth-1 downto 0);
  signal opmat_outd : std_logic_vector(data_depth-1 downto 0);

  --mixer signals
  signal gain_a : std_logic_vector(7 downto 0);
  signal gain_b : std_logic_vector(7 downto 0);
  signal gain_c : std_logic_vector(7 downto 0);
  signal gain_d : std_logic_vector(7 downto 0);
  signal mixer_out : std_logic_vector(data_depth-1 downto 0);

  --control unit signals
  signal osc_sel : std_logic_vector(15 downto 0);
  signal osc_1_2_shamt : std_logic_vector(15 downto 0);
  signal osc_3_4_shamt : std_logic_vector(15 downto 0);
  signal opmat_cmat1 : std_logic_vector(15 downto 0);
  signal opmat_cmat2 : std_logic_vector(15 downto 0);
  signal opmat_sel : std_logic_vector(15 downto 0);
  signal param_config1 : std_logic_vector(15 downto 0);
  signal attack_in : std_logic_vector(15 downto 0);
  signal decay_in : std_logic_vector(15 downto 0);
  signal release_in : std_logic_vector(15 downto 0);
  signal sustain_in : std_logic_vector(15 downto 0);
  
    --use velocity in the normal way, i.e. controlling oscillator
  --output amplitude
  alias param_velocity_gain : std_logic is param_config1(0);
  
    --ADSR envelope generator
  signal adsr_out : std_logic_vector(data_depth-1 downto 0);
  alias attack : std_logic_vector(7 downto 0) is attack_in(7 downto 0);
  alias decay : std_logic_vector(7 downto 0) is decay_in(7 downto 0);
  alias release : std_logic_vector(7 downto 0) is release_in(7 downto 0);
  alias sustain : std_logic_vector(7 downto 0) is sustain_in(7 downto 0);
  signal noteoff : std_logic;
  signal releasing : std_logic;

  --save pitch and velocity
  signal v_pitch : std_logic_vector(6 downto 0);
  signal v_vel : std_logic_vector(6 downto 0);

  type vp_save is (vp_idle, vp_active, vp_releasing);
  
begin

  --register pitch & velocity
  save: process(clk_100, rst, active)
    variable save_state : vp_save;
  begin

    if rst = '1' then
      save_state := vp_idle;
      v_pitch <= (others=>'0');
      v_vel <= (others=>'0');
    elsif rising_edge(clk_100) then
      case save_state is
        when vp_idle =>

          if active = '1' then
            v_vel <= velocity;
            v_pitch <= pitch;
            save_state := vp_active;
          end if;

        when vp_active =>

          --wait for release
          if releasing = '1' then
            save_state := vp_releasing;
          end if;

        when vp_releasing =>
          if releasing = '0' then
            --finished
            save_state := vp_idle;
          end if;
      end case;
      
    end if;

  end process;
  
  --velocity mode
  osc1_gain <= v_vel when param_velocity_gain = '1' else
               (others=>'1'); --maximum
  osc2_gain <= v_vel when param_velocity_gain = '1' else
               (others=>'1');
  osc3_gain <= v_vel when param_velocity_gain = '1' else
               (others=>'1');
  osc4_gain <= v_vel when param_velocity_gain = '1' else
               (others=>'1');

  --control unit
  control: entity work.control_unit(control)
    generic map(base_address=>control_base)
    port map(rst=>rst,
             clk=>clk_100,
             data_addr=>ctl_data_addr,
             data_in=>ctl_data_in,
             data_out=>ctl_data_out,
             rd_en=>ctl_rd,
             wr_en=>ctl_wr,
             v0_r0=>osc_1_2_shamt,
             v0_r1=>osc_3_4_shamt,
             v0_r2=>opmat_cmat1,
             v0_r3=>opmat_cmat2,
             v0_r4=>osc_sel,
             v0_r5=>opmat_sel,
             v0_r6=>param_config1,
             v0_r7=>attack_in,
             v0_r8=>decay_in,
             v0_r9=>sustain_in,
             v0_r10=>release_in
             );
  

  --oscillator instances and peripherals
  osc1_shamt <= osc_1_2_shamt(7 downto 0);
  osc1_shift: entity work.pitch_shifter(shift)
    port map(shamt=>osc1_shamt,
             pitch_in=>v_pitch,
             pitch_out=>osc1_spitch);

  osc2_shamt <= osc_1_2_shamt(15 downto 8);
  osc2_shift: entity work.pitch_shifter(shift)
    port map(shamt=>osc2_shamt,
             pitch_in=>v_pitch,
             pitch_out=>osc2_spitch);

  osc3_shamt <= osc_3_4_shamt(7 downto 0);
  osc3_shift: entity work.pitch_shifter(shift)
    port map(shamt=>osc3_shamt,
             pitch_in=>v_pitch,
             pitch_out=>osc3_spitch);

  osc4_shamt <= osc_3_4_shamt(15 downto 8);
  osc4_shift: entity work.pitch_shifter(shift)
    port map(shamt=>osc4_shamt,
             pitch_in=>v_pitch,
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
    generic map(data_depth=>data_depth,
                gain_res=>7,
                gain_mode=>gain_mode_velocity)
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
    generic map(data_depth=>data_depth,
                gain_res=>7,
                gain_mode=>gain_mode_velocity)
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
    generic map(data_depth=>data_depth,
                gain_res=>7,
                gain_mode=>gain_mode_velocity)
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
    generic map(data_depth=>data_depth,
                gain_res=>7,
                gain_mode=>gain_mode_velocity)
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


  gain_a <= to_slv(to_sfixed(0.5, 2, -5));
  gain_b <= to_slv(to_sfixed(0.5, 2, -5));
  gain_c <= (others=>'0');
  gain_d <= (others=>'0');
  
  --mix oscillators
  mix0: entity work.mix_4_to_1(mix)
    generic map(data_depth=>data_depth,
                gain_res=>8)
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
				 
				 
	--missing filter!

  noteoff <= not active;
  
	--envelope generator
  adsr0: entity work.adsr_gen(envelope)
    generic map(data_depth=>data_depth)
    port map(clk=>clk_100,
             rst=>rst,
             data_in=>mixer_out,
             data_out=>adsr_out,
             note_on=>active,
             note_off=>noteoff,
             attack_i=>attack,
             decay_d=>decay,
             release_d=>release,
             sustain_l=>sustain,
             releasing=>releasing);
  

  data_out <= adsr_out when active = '1' or releasing = '1' else
              (others=>'0');
  
end architecture;

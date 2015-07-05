----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:56:45 07/03/2015 
-- Design Name: 
-- Module Name:    osc - Behavioral 
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
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity osc is
  generic( wt_size : integer := 9;
           data_depth : integer := 24);
	port( sysclk_10: in std_logic;
			rst : in std_logic;
			osc_sel : in std_logic_vector(2 downto 0);
			pitch : in std_logic_vector(6 downto 0);
			
			sigout: out std_logic_vector(data_depth-1 downto 0));
			
end osc;

architecture Behavioral of osc is

  signal ck_div_by: unsigned(31 downto 0);
  signal sigout_16 : std_logic_vector(15 downto 0);
  signal phase_counter_32 : std_logic_vector(31 downto 0);
  signal square_wave_24 : std_logic_vector(23 downto 0);
  signal sawtooth_wave_24 : std_logic_vector(23 downto 0);
  signal triangle_wave_24 : std_logic_vector(23 downto 0);
  signal triangle_counter : std_logic_vector(31 downto 0);

--clock division table
type div_table is array(0 to 127) of unsigned(31 downto 0);
--sine wavetable
type sin_wt is array(0 to 2**wt_size-1) of signed(data_depth-1 downto 0);

--clock generation for wavetable driving
function generate_ck_div return div_table is
	constant f_ck: integer := 100000000;
	constant div_by: real := 13.75;
   --constant p_acc_size_sqrt : integer := 2**16;
	constant gambi : real := 42.9496;
	variable f_out : real;
   variable m : real;
	variable mwords : div_table;
begin
	for p in 0 to 127 loop
      f_out := (div_by*(2**(real(p - 9)/12.0)));
      m := f_out * gambi;
      mwords(p) := to_unsigned(integer(round(m)), 32);
	end loop;
	return mwords;
end function;

--clock divider py pitch table
constant ck_div_by_pitch: div_table := generate_ck_div;

constant wave_max_val : integer := 2**(data_depth - 1) - 1;
constant wave_min_val : integer := -2**(data_depth - 1);
constant wave_offset : integer := 2**(data_depth - 2);

constant counter_max_val : unsigned(31 downto 0) := (others=>'1');

--sine wavetable generator
function generate_sin_wt return sin_wt is
	variable x, y: real;
	variable table: sin_wt;
begin
	for k in 0 to 2**wt_size-1 loop
		x := (real(k))/real(2**wt_size);
		y := sin(math_2_pi*x);
		table(k) := to_signed(integer(round(real(wave_max_val)*y)), data_depth);
	end loop;
	return table;
end function;

--sine wavetable
constant sin_wt_sig : sin_wt := generate_sin_wt;


--divided clock for signal output
signal wt_clk : std_logic;

begin

--wavetable clock divider
--probably best to synchronize this
ck_div_by <= ck_div_by_pitch(to_integer(unsigned(pitch)));

--sigout <= sigout_16 & "00000000";

dds0: entity work.dds_compiler_v4_0
  port map(clk=>sysclk_10,
           pinc_in=>std_logic_vector(ck_div_by),
           sine=>sigout_16,
           phase_out=>phase_counter_32);

square_wave_24 <= std_logic_vector(to_signed(wave_max_val, 24)) when sigout_16(15) = '0' else
                  std_logic_vector(to_signed(wave_min_val, 24));

sawtooth_wave_24 <= std_logic_vector(to_signed(-to_integer(unsigned(phase_counter_32(31 downto 8))) + wave_offset, 24));

triangle_counter <= phase_counter_32(30 downto 0) & '0' when phase_counter_32(31) = '0' else
                    std_logic_vector(counter_max_val(31 downto 0) - unsigned(phase_counter_32(30 downto 0) & '0'));

triangle_wave_24 <= std_logic_vector(to_signed(to_integer(unsigned(triangle_counter(30 downto 7))) - wave_offset, 24));

sigout <= sigout_16 & "00000000" when osc_sel = "001" else
          square_wave_24 when osc_sel = "010" else
          sawtooth_wave_24 when osc_sel = "011" else
          triangle_wave_24 when osc_sel = "100" else
          (others=>'0');

--clock divider
--process(sysclk_10, rst, ck_div_by)
--variable ckdiv_count : unsigned(31 downto 0);
--constant max_counter : unsigned(31 downto 0) := (others=>'1');
--variable mword : unsigned(31 downto 0);
--begin

--	if rst = '1' then
--		ckdiv_count := to_unsigned(0, 32);
--		wt_clk <= '0';
--		mword := to_unsigned(0, 32);
--	elsif rising_edge(sysclk_10) then

--      case osc_sel is

--        when "00" =>
--          if ckdiv_count(31) = '1' then
--            sigout <= std_logic_vector(to_signed(wave_min_val, data_depth));
--          else
--            sigout <= std_logic_vector(to_signed(wave_max_val, data_depth));
--          end if;

--        when "01" =>
--          sigout <= std_logic_vector(sin_wt_sig(to_integer(ckdiv_count(31 downto 21))));
--        when others=>
--          null;

--      end case;
		
--		ckdiv_count := ckdiv_count + mword;
		
--	else
--		--pitch changed
--		mword := ck_div_by;
--		ckdiv_count := to_unsigned(0, 32);
--	end if;	
--end process;

end Behavioral;


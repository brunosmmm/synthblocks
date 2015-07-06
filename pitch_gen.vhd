library ieee;
use ieee.std_logic_1164.all;
use iee.numeric_std.all;

entity pitch_gen is
  generic(voice_num : integer := 1);
  port(clk : in std_logic;
       rst : in std_logic;

   --control bus
       data_addr : in std_logic_vector(15 downto 0);
       data_in : in std_logic_vector(15 downto 0);
       data_out : out std_logic_vector(15 downto 0);
       rd_en : in std_logic;
       wr_en : in std_logic;

       --voice pitch
       v0_pitch : out std_logic_vector(6 downto 0)
       );
end entity;

architecture gen of pitch_gen is

  --ctl addresses
  --addresses related to midi messages for easier use
  constant note_on_addr : std_logic_vector(15 downto 0) := x"8000";
  constant note_off_addr : std_logic_vector(15 downto 0) := x"9000";
  
  --note event registers
  --upper byte is 0kkkkkkk, not number
  --lower byte is 0vvvvvvv, velocity
  signal note_on_event : std_logic_vector(15 downto 0);
  signal note_off_event : std_logic_vector(15 downto 0);


  --internal logic

  --currently active (on) notes
  signal active_notes : std_logic_vector(127 downto 0);
  signal active_voice_count : integer;
  
begin

  --allocate voices whe new note events are received
  
  process(clk, rst)
  begin

    if rst = '1' then

      active_notes <= (others=>'0');
      active_voice_count <= 0;
      
    elsif rising_edge(clk) then

      if wr_en = '1' and rd_en = '1' then

        case ctl_addr is

          when note_on_addr =>

            --allocate a voice if available
            if active_voice_count < voice_num then
              --find next available
              active_voice_count <= active_voice_count + 1;
            end if;
            
          when note_off_addr =>

            --free a voice
            if active_voice_count > 0 then
              active_voice_count = active_voice_count - 1;
            end if;
            
          when others =>
            null

        end case;

      end if;
      
    end if;
   
  end process;
  
end architecture;
       

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
       v0_pitch : out std_logic_vector(6 downto 0);
       v0_active : out std_logic
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

  alias evt_note_number : std_logic_vector(6 downto 0) is data_in(14 downto 8);
  alias evt_note_velocity : std_logic_vector(6 downto 0) is data_in(6 downto 0);

  --internal logic

  type note_to_voice is array(127 downto 0) of std_logic_vector(2**voice_num -1 downto 0);

  type voice_to_note is array(2**voice_num-1 downto 0) of std_logic_vector(6 downto 0);
  
  --currently active (on) notes
  signal active_notes : std_logic_vector(127 downto 0);
  signal active_voices : std_logic_vector(voice_num-1 downto 0);
  signal note_to_voices : note_to_voice;
  signal voices_to_note : voice_to_note;
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

        case data_addr is

          when note_on_addr =>

            --allocate a voice if available
            if active_voice_count < voice_num then
              --find next available

              for i in 0 to voice_num-1 loop
                if active_voices(i) = '0' then
                  --allocate this voice
                  active_voices(i) <= '1';
                  active_notes(to_integer(unsigned(evt_note_number))) <= '1';
                  note_to_voices(to_integer(unsigned(evt_note_number))) <= std_logic_vector(to_unsigned(i, 2**voice_num));
                  voices_to_note(i) <= evt_note_number;
                  exit;
                end if;
              end loop;

              active_voice_count <= active_voice_count + 1;
            end if;
            
          when note_off_addr =>

            --free a voice
            if active_voice_count > 0 then

              --deactivate
              active_notes(to_integer(unsigned(evt_note_number))) <= '0';
              active_voices(to_integer(unsigned(note_to_voices(to_integer(unsigned(evt_note_number)))))) <= '0';
              
              active_voice_count <= active_voice_count - 1;
            end if;
            
          when others =>
            null;

        end case;

      end if;
      
    end if;
   
  end process;

  v0_pitch <= voices_to_note(0);
  v0_active <= active_voices(0);
 
end architecture;
       

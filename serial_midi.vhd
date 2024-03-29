library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_midi is
  generic(midi_buf_size : integer := 16);
  port(clk : in std_logic;
       rst : in std_logic;
       tx : out std_logic;
       rx: in std_logic;

       --control bus
       ctl_addr : out std_logic_vector(15 downto 0);
       ctl_data_out : out std_logic_vector(15 downto 0);
       pitch_data_in : in std_logic_vector(15 downto 0);
		 voice_data_in : in std_logic_vector(15 downto 0);
       ctl_rd : out std_logic;
       ctl_wr : out std_logic

       );

end entity;

architecture comm of serial_midi is

signal uart_rx_d : std_logic_vector(7 downto 0);
signal uart_rx_e : std_logic;
signal uart_tx_d : std_logic_vector(7 downto 0);
signal uart_tx_e : std_logic;
signal uart_tx_rdy : std_logic;

type midi_rx_machine is (rx_status, rx_data, rx_ctlop);
type ctl_machine is (ctl_idle, ctl_write, ctl_read);

type midi_data is array(midi_buf_size-1 downto 0) of std_logic_vector(7 downto 0);
type midi_message is
record
  status_byte : std_logic_vector(7 downto 0);
  data_bytes : midi_data;
  data_size : unsigned(3 downto 0);
  is_sysex : std_logic;
end record;

signal midi_message_valid : std_logic;
signal midi_message_done : std_logic;

signal rx_midi_msg : midi_message;

--MIDI message constants
constant note_off_byte : std_logic_vector(3 downto 0) := "1000";
constant note_on_byte : std_logic_vector(3 downto 0) := "1001";
constant kpressure_byte : std_logic_vector(3 downto 0) := "1010";
constant cc_byte : std_logic_vector(3 downto 0) := "1011";
constant pc_byte : std_logic_vector(3 downto 0) := "1100";
constant cpressure_byte : std_logic_vector(3 downto 0) := "1101";
constant pbend_byte : std_logic_vector(3 downto 0) := "1110";
constant common_byte : std_logic_vector(3 downto 0) := "1111";

constant sysex_byte : std_logic_vector(3 downto 0) := "0000";
constant timecode_byte : std_logic_vector(3 downto 0) := "0001";
constant sposptr_byte : std_logic_vector(3 downto 0) := "0010";
constant ssel_byte : std_logic_vector(3 downto 0) := "0011";
constant sysex_end_byte : std_logic_vector(3 downto 0) := "0111";

begin

  	uart0: entity work.basic_uart(Behavioral)
	generic map(54) --31250 baud
	port map(clk=>clk,
             reset=>rst,
             rx_data=>uart_rx_d,
             rx_enable=>uart_rx_e,
             tx_data=>uart_tx_d,
             tx_enable=>uart_tx_e,
             tx_ready=>uart_tx_rdy,
             rx=>rx,
             tx=>tx);

    rxmidi: process(clk, rst)
      variable midi_rx_status : midi_rx_machine;
      variable midi_rx_bytes_recv : integer range 0 to midi_buf_size;
    begin

      if rst = '1' then
        uart_tx_e <= '0';
        uart_tx_d <= (others=>'0');
        midi_rx_status := rx_status;
        midi_rx_bytes_recv := 0;
        midi_message_valid <= '0';

        rx_midi_msg.status_byte <= (others=>'0');
        rx_midi_msg.is_sysex <= '0';
        rx_midi_msg.data_size <= (others=>'0');
        for i in 0 to 15 loop
          rx_midi_msg.data_bytes(i) <= (others=>'0');
        end loop;

      elsif rising_edge(clk) then

        case midi_rx_status is

          when rx_status =>

            midi_message_valid <= '0';
            midi_rx_bytes_recv := 0;
            rx_midi_msg.is_sysex <= '0';

            if uart_rx_e = '1' then
              --new data
              rx_midi_msg.status_byte <= uart_rx_d;
              midi_rx_status := rx_data;

              --parse status byte; message length predefined
              case uart_rx_d(7 downto 4) is
                
                when note_off_byte | note_on_byte | kpressure_byte |
                  cc_byte | cpressure_byte | pbend_byte=>
                  --2 bytes
                  rx_midi_msg.data_size <= to_unsigned(2, 4);

                when pc_byte=>
                  rx_midi_msg.data_size <= to_unsigned(1, 4);

                when common_byte=>
                  case uart_rx_d(3 downto 0) is
                    when sposptr_byte=>
                      rx_midi_msg.data_size <= to_unsigned(2, 4);
                    when timecode_byte | ssel_byte=>
                      rx_midi_msg.data_size <= to_unsigned(1, 4);
                    when sysex_byte=>
                      rx_midi_msg.is_sysex <= '1';
                    when others=>
                      null;
                  end case;
                when others=>
                  null;

              end case;

            end if;
          when rx_data =>

            if to_integer(rx_midi_msg.data_size) > midi_rx_bytes_recv then

              if uart_rx_e = '1' then
                --store bytes
                rx_midi_msg.data_bytes(midi_rx_bytes_recv) <= uart_rx_d;
                --increment counter
                midi_rx_bytes_recv := midi_rx_bytes_recv + 1;
              end if;
            elsif rx_midi_msg.is_sysex = '1' then
              --receive until end
              if uart_rx_e = '1' then
                if uart_rx_d = common_byte & sysex_end_byte then
                  --end
                  midi_rx_status := rx_ctlop;
                  --store count
                  rx_midi_msg.data_size <= to_unsigned(midi_rx_bytes_recv, 4);
                  --finished
                  midi_message_valid <= '1';
                else
                  --store data
                  rx_midi_msg.data_bytes(midi_rx_bytes_recv) <= uart_rx_d;
                  midi_rx_bytes_recv := midi_rx_bytes_recv + 1;
                end if;
              end if;
            else
              --finished
              midi_rx_status := rx_status;
              midi_message_valid <= '1';
            end if;

          when rx_ctlop=>
            --delay for one cycle
            midi_rx_status := rx_status;

          when others =>
            null;

        end case;
      end if;
    end process;

    ctlbus: process (clk, rst, midi_message_valid)
      variable ctl_state : ctl_machine;
    begin

      if rst = '1' then
        midi_message_done <= '0';
        ctl_wr <= '0';
        ctl_rd <= '0';
        ctl_data_out <= (others=>'0');
        ctl_addr <= (others=>'0');
        ctl_state := ctl_idle;

      elsif rising_edge(clk) then

        if ctl_state = ctl_write then
          ctl_wr <= '0';
          ctl_state := ctl_idle;
        end if;

        if midi_message_valid = '1' then
          --start write to control bus
          if rx_midi_msg.is_sysex = '0' then
            ctl_addr <= rx_midi_msg.status_byte & "00000000";

            if rx_midi_msg.data_size = to_unsigned(2, 4) then
              ctl_data_out <= rx_midi_msg.data_bytes(0) & rx_midi_msg.data_bytes(1);
            elsif rx_midi_msg.data_size = to_unsigned(1, 4) then
              ctl_data_out <= rx_midi_msg.data_bytes(0) & "00000000";

            end if;

            ctl_wr <= '1';
            ctl_state := ctl_write;
            
          end if;
       
        end if;

      end if;
    end process;



end architecture;

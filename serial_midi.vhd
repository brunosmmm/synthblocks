library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_midi is
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
begin



end architecture;

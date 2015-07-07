library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_unit is
  port(rst : in std_logic;
       clk : in std_logic;

       data_addr: in std_logic_vector(15 downto 0);
       data_in : in std_logic_vector(15 downto 0);
       data_out : out std_logic_vector(15 downto 0);
       rd_en : in std_logic;
       wr_en : in std_logic;

       --register control outputs
       v0_r0 : out std_logic_vector(15 downto 0);
       v0_r1 : out std_logic_vector(15 downto 0);
       v0_r2 : out std_logic_vector(15 downto 0);
       v0_r3 : out std_logic_vector(15 downto 0);
       v0_r4 : out std_logic_vector(15 downto 0);
       v0_r5 : out std_logic_vector(15 downto 0)
       
       );
  constant voice_0_base : unsigned(15 downto 0) := x"0000";
  constant voice_1_base : unsigned(15 downto 0) := x"0010";
  constant voice_2_base : unsigned(15 downto 0) := x"0020";
  constant voice_3_base : unsigned(15 downto 0) := x"0030";

end entity;

architecture control of control_unit is

  --control registers
  signal v0_shamt_12 : std_logic_vector(15 downto 0);
  signal v0_shamt_34 : std_logic_vector(15 downto 0);
  signal v0_cmat1 : std_logic_vector(15 downto 0);
  signal v0_cmat2 : std_logic_vector(15 downto 0);
  signal v0_osc_sel : std_logic_vector(15 downto 0);
  signal v0_op_sel : std_logic_vector(15 downto 0);
  
begin

  --connect control signals
  v0_r0 <= v0_shamt_12;
  v0_r1 <= v0_shamt_34;
  v0_r2 <= v0_cmat1;
  v0_r3 <= v0_cmat2;
  v0_r4 <= v0_osc_sel;
  v0_r5 <= v0_op_sel;

  --data out
  data_out <= v0_shamt_12 when data_addr = x"0000" else
              v0_shamt_34 when data_addr = x"0001" else
              v0_cmat1 when data_addr = x"0002" else
              v0_cmat2 when data_addr = x"0003" else
              v0_osc_sel when data_addr = x"0004" else
              v0_op_sel when data_addr = x"0005" else
              (others=>'0');
  
                                                    
  process(clk, rst)
  begin

    if rst = '1' then

      v0_shamt_12 <= (others=>'0');
      v0_shamt_34 <= (others=>'0');
      v0_cmat1 <= (others=>'0');
      v0_cmat2 <= (others=>'0');
      v0_osc_sel <= (others=>'0');
      v0_op_sel <= (others=>'0');
      
    elsif rising_edge(clk) then

      if wr_en = '1' then

        case data_addr is

          when x"0000" =>
            v0_shamt_12 <= data_in;
            
          when x"0001" =>
            v0_shamt_34 <= data_in;

          when x"0002" =>
            v0_cmat1 <= data_in;

          when x"0003" =>
            v0_cmat2 <= data_in;

          when x"0004" =>
            v0_osc_sel <= data_in;

          when x"0005" =>
            v0_op_sel <= data_in;

          when others =>
            null;

        end case;
       
      end if;

    end if;

  end process;

end architecture;

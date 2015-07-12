library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sb_common.all;

entity control_unit is
  generic(base_address : std_logic_vector(15 downto 0));
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
       v0_r5 : out std_logic_vector(15 downto 0);
       v0_r6 : out std_logic_vector(15 downto 0);
       v0_r7 : out std_logic_vector(15 downto 0);
       v0_r8 : out std_logic_vector(15 downto 0);
       v0_r9 : out std_logic_vector(15 downto 0);
       v0_r10 : out std_logic_vector(15 downto 0)
       
       );
end entity;

architecture control of control_unit is

  --control registers
  signal v0_shamt_12 : std_logic_vector(15 downto 0);
  signal v0_shamt_34 : std_logic_vector(15 downto 0);
  signal v0_cmat1 : std_logic_vector(15 downto 0);
  signal v0_cmat2 : std_logic_vector(15 downto 0);
  signal v0_osc_sel : std_logic_vector(15 downto 0);
  signal v0_op_sel : std_logic_vector(15 downto 0);
  signal v0_pconf1 : std_logic_vector(15 downto 0);
  signal v0_adsr_a : std_logic_vector(15 downto 0);
  signal v0_adsr_d : std_logic_vector(15 downto 0);
  signal v0_adsr_r : std_logic_vector(15 downto 0);
  signal v0_adsr_s : std_logic_vector(15 downto 0);

  signal relative_addr : std_logic_vector(15 downto 0);
  
begin

  relative_addr <= std_logic_vector(unsigned(data_addr) - unsigned(base_address));

  --connect control signals
  v0_r0 <= v0_shamt_12;
  v0_r1 <= v0_shamt_34;
  v0_r2 <= v0_cmat1;
  v0_r3 <= v0_cmat2;
  v0_r4 <= v0_osc_sel;
  v0_r5 <= v0_op_sel;
  v0_r6 <= v0_pconf1;
  v0_r7 <= v0_adsr_a;
  v0_r8 <= v0_adsr_d;
  v0_r9 <= v0_adsr_s;
  v0_r10 <= v0_adsr_r;

  --data out
  data_out <= v0_shamt_12 when relative_addr = x"0000" else
              v0_shamt_34 when relative_addr = x"0001" else
              v0_cmat1 when relative_addr = x"0002" else
              v0_cmat2 when relative_addr = x"0003" else
              v0_osc_sel when relative_addr = x"0004" else
              v0_op_sel when relative_addr = x"0005" else
              v0_pconf1 when relative_addr = x"0006" else
              v0_adsr_a when relative_addr = x"0007" else
              v0_adsr_d when relative_addr = x"0008" else
              v0_adsr_s when relative_addr = x"0009" else
              v0_adsr_r when relative_addr = x"000A" else
              (others=>'0');
  
                                                    
  process(clk, rst)
  begin

    if rst = '1' then

      v0_shamt_12 <= v_shamt_12;
      v0_shamt_34 <= v_shamt_34;
      v0_cmat1 <= v_cmat1;
      v0_cmat2 <= v_cmat2;
      v0_osc_sel <= v_oscsel;
      v0_op_sel <= v_opsel;
      v0_pconf1 <= v_pconf1;
      v0_adsr_a <= v_adsr_a;
      v0_adsr_d <= v_adsr_d;
      v0_adsr_s <= v_adsr_s;
      v0_adsr_r <= v_adsr_r;
      
    elsif rising_edge(clk) then

      if wr_en = '1' then

        case relative_addr is

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

          when x"0006" =>
            v0_pconf1 <= data_in;

          when x"0007" =>
            v0_adsr_a <= data_in;

          when x"0008" =>
            v0_adsr_d <= data_in;

          when x"0009" =>
            v0_adsr_s <= data_in;

          when x"000A" =>
            v0_adsr_r <= data_in;

          when others =>
            null;

        end case;
       
      end if;

    end if;

  end process;

end architecture;

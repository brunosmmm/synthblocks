library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--a 4x4 signal operation matrix

entity op_matrix is
  generic(data_depth : integer := 24);
  port(in_1 : in std_logic_vector(data_depth-1 downto 0);
           in_2 : in std_logic_vector(data_depth-1 downto 0);
           in_3 : in std_logic_vector(data_depth-1 downto 0);
           in_4 : in std_logic_vector(data_depth-1 downto 0);

           cmat_1 : in std_logic_vector(15 downto 0);
           cmat_2 : in std_logic_vector(15 downto 0);
           op_sel : in std_logic_vector(15 downto 0);

           out_a : out std_logic_vector(data_depth-1 downto 0);
           out_b : out std_logic_vector(data_depth-1 downto 0);
           out_c : out std_logic_vector(data_depth-1 downto 0);
           out_d : out std_logic_vector(data_depth-1 downto 0));

end entity;

architecture operate of op_matrix is

  signal opa_in_1 : std_logic_vector(data_depth-1 downto 0);
  signal opa_in_2 : std_logic_vector(data_depth-1 downto 0);
  signal opb_in_1 : std_logic_vector(data_depth-1 downto 0);
  signal opb_in_2 : std_logic_vector(data_depth-1 downto 0);
  signal opc_in_1 : std_logic_vector(data_depth-1 downto 0);
  signal opc_in_2 : std_logic_vector(data_depth-1 downto 0);
  signal opd_in_1 : std_logic_vector(data_depth-1 downto 0);
  signal opd_in_2 : std_logic_vector(data_depth-1 downto 0);
  
  signal opa_sel : std_logic_vector(2 downto 0);
  signal opb_sel : std_logic_vector(2 downto 0);
  signal opc_sel : std_logic_vector(2 downto 0);
  signal opd_sel : std_logic_vector(2 downto 0);
  
begin

  --operation select
  opa_sel <= op_sel(2 downto 0);
  opb_sel <= op_sel(5 downto 3);
  opc_sel <= op_sel(8 downto 6);
  opd_sel <= op_sel(11 downto 9);

  --connection matrixes
  opa_in_1 <= in_1 when cmat_1(3 downto 0) = "0001" else
              in_2 when cmat_1(3 downto 0) = "0010" else
              in_3 when cmat_1(3 downto 0) = "0100" else
              in_4 when cmat_1(3 downto 0) = "1000" else
              (others=>'0');

  opa_in_2 <= in_1 when cmat_2(3 downto 0) = "0001" else
              in_2 when cmat_2(3 downto 0) = "0010" else
              in_3 when cmat_2(3 downto 0) = "0100" else
              in_4 when cmat_2(3 downto 0) = "1000" else
              (others=>'0');

  opb_in_1 <= in_1 when cmat_1(7 downto 4) = "0001" else
              in_2 when cmat_1(7 downto 4) = "0010" else
              in_3 when cmat_1(7 downto 4) = "0100" else
              in_4 when cmat_1(7 downto 4) = "1000" else
              (others=>'0');

  opb_in_2 <= in_1 when cmat_2(7 downto 4) = "0001" else
              in_2 when cmat_2(7 downto 4) = "0010" else
              in_3 when cmat_2(7 downto 4) = "0100" else
              in_4 when cmat_2(7 downto 4) = "1000" else
              (others=>'0');

  opc_in_1 <= in_1 when cmat_1(11 downto 8) = "0001" else
              in_2 when cmat_1(11 downto 8) = "0010" else
              in_3 when cmat_1(11 downto 8) = "0100" else
              in_4 when cmat_1(11 downto 8) = "1000" else
              (others=>'0');

  opc_in_2 <= in_1 when cmat_2(11 downto 8) = "0001" else
              in_2 when cmat_2(11 downto 8) = "0010" else
              in_3 when cmat_2(11 downto 8) = "0100" else
              in_4 when cmat_2(11 downto 8) = "1000" else
              (others=>'0');

  opd_in_1 <= in_1 when cmat_1(15 downto 12) = "0001" else
              in_2 when cmat_1(15 downto 12) = "0010" else
              in_3 when cmat_1(15 downto 12) = "0100" else
              in_4 when cmat_1(15 downto 12) = "1000" else
              (others=>'0');

  opd_in_2 <= in_1 when cmat_2(15 downto 12) = "0001" else
              in_2 when cmat_2(15 downto 12) = "0010" else
              in_3 when cmat_2(15 downto 12) = "0100" else
              in_4 when cmat_2(15 downto 12) = "1000" else
              (others=>'0');
  
  
  --operation core A
  opa : entity work.data_binop(operate)
    generic map(data_depth=>data_depth)
    port map(data_1=>opa_in_1,
             data_2=>opa_in_2,
             op_sel=>opa_sel,
             data_out=>out_a);

  --operation core A
  opb : entity work.data_binop(operate)
    generic map(data_depth=>data_depth)
    port map(data_1=>opb_in_1,
             data_2=>opb_in_2,
             op_sel=>opb_sel,
             data_out=>out_b);

  --operation core A
  opc : entity work.data_binop(operate)
    generic map(data_depth=>data_depth)
    port map(data_1=>opc_in_1,
             data_2=>opc_in_2,
             op_sel=>opc_sel,
             data_out=>out_c);

  --operation core A
  opd : entity work.data_binop(operate)
    generic map(data_depth=>data_depth)
    port map(data_1=>opd_in_1,
             data_2=>opd_in_2,
             op_sel=>opd_sel,
             data_out=>out_d);

end architecture;

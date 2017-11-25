library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity single_port_memory is
  generic(
    data_width    : integer := 32;
    address_width : integer := 10
  );
  port(
    clk      : in std_logic;
    reset    : in std_logic;
    dataA : in signed(data_width-1 downto 0);
    addressA : in unsigned(address_width-1 downto 0);
    memEnable: in std_logic;
    writeAEn : in std_logic;
    dataAOut : out signed(data_width-1 downto 0)
  );
end single_port_memory;

architecture single_port_memory_arch of single_port_memory is
  type ram_type is array (0 to (2**address_width)-1) of signed(data_width-1 downto 0);
  signal memory : ram_type;
begin
  READ_DATA_A : process(clk)
  begin
    if rising_edge(clk) then
      if memEnable = '1' then
        if writeAEn = '1' then
          dataAOut <= dataA;
        else
          dataAOut <= memory(to_integer(addressA));
        end if;
      end if;
    end if;
  end process;

  WRITE_DATA_A : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
          memory(0) <= to_signed(65536, data_width);
          memory(1) <= to_signed(2137191285, data_width);
          memory(2) <= to_signed(2106255112, data_width);
          memory(3) <= to_signed(2055068376, data_width);
          memory(4) <= to_signed(1984024325, data_width);
          memory(5) <= to_signed(1893909418, data_width);
          memory(6) <= to_signed(1785575652, data_width);
          memory(7) <= to_signed(1660071629, data_width);
          memory(8) <= to_signed(1518511486, data_width);
          memory(9) <= to_signed(1362337038, data_width);
          memory(10) <= to_signed(1193055635, data_width);
          memory(11) <= to_signed(1012305694, data_width);
          memory(12) <= to_signed(821791167, data_width);
          memory(13) <= to_signed(623412611, data_width);
          memory(14) <= to_signed(418939510, data_width);
          memory(15) <= to_signed(210469022, data_width);
          memory(16) <= to_signed(65535, data_width);
          memory(17) <= to_signed(-210403170, data_width);
          memory(18) <= to_signed(-418872714, data_width);
          memory(19) <= to_signed(-623344253, data_width);
          memory(20) <= to_signed(-821720641, data_width);
          memory(21) <= to_signed(-1012232418, data_width);
          memory(22) <= to_signed(-1192979053, data_width);
          memory(23) <= to_signed(-1362256626, data_width);
          memory(24) <= to_signed(-1518426754, data_width);
          memory(25) <= to_signed(-1659982131, data_width);
          memory(26) <= to_signed(-1785480988, data_width);
          memory(27) <= to_signed(-1893809238, data_width);
          memory(28) <= to_signed(-1983918331, data_width);
          memory(29) <= to_signed(-2054956328, data_width);
          memory(30) <= to_signed(-2106136824, data_width);
          memory(31) <= to_signed(-2137066635, data_width);
      else
        if memEnable = '1' then
          if writeAEn = '1' then
            memory(to_integer(addressA)) <= dataA;
          end if;
        end if;
      end if;
    end if;
  end process;

end single_port_memory_arch;

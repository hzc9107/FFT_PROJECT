library IEEE;
library std;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity dual_port_memory is
  generic(
    data_width    : integer := 32;
    address_width : integer := 10
  );
  port(
    clk      : in std_logic;
    reset    : in std_logic; -- Remove for synthesis
    dataA : in signed(data_width-1 downto 0);
    dataB : in signed(data_width -1 downto 0);
    addressA : in unsigned(address_width-1 downto 0);
    addressB : in unsigned(address_width-1 downto 0);
    memEnable: in std_logic;
    writeAEn : in std_logic;
    writeBEn : in std_logic;
    dataAOut : out signed(data_width-1 downto 0);
    dataBOut : out signed(data_width-1 downto 0)
  );
end dual_port_memory;

architecture dual_port_memory_arch of dual_port_memory is
  type ram_type is array (0 to (2**address_width)-1) of signed(data_width-1 downto 0);
  signal memory : ram_type;

  function to_bstring(sl : std_logic) return string is
    variable sl_str_v : string(1 to 3);  -- std_logic image with quotes around
  begin
    sl_str_v := std_logic'image(sl);
    return "" & sl_str_v(2);  -- "" & character to get string
  end function;

  function to_bstring(slv : std_logic_vector) return string is
    alias    slv_norm : std_logic_vector(1 to slv'length) is slv;
    variable sl_str_v : string(1 to 1);  -- String of std_logic
    variable res_v    : string(1 to slv'length);
  begin
    for idx in slv_norm'range loop
      sl_str_v := to_bstring(slv_norm(idx));
      res_v(idx) := sl_str_v(1);
    end loop;
    return res_v;
  end function;
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

  READ_DATA_B : process(clk)
  begin
    if rising_edge(clk) then
      if memEnable = '1' then
        if writeBEn = '1' then
          dataBOut <= dataB;
        else
          dataBOut <= memory(to_integer(addressB));
        end if;
      end if;
    end if;
  end process;


--  WRITE_DATA_A : process(clk)
--  begin
--    if rising_edge(clk) then
--      if memEnable = '1' then
--        if writeAEn = '1' then
--          memory(to_integer(addressA)) <= dataA;
--        end if;
--      end if;
--    end if;
--  end process;

  WRITE_DATA_B : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        memory(0) <= (others=>'0');
      	memory(1) <= (others=>'0');
      	memory(2) <= (others=>'0');
      	memory(3) <= (others=>'0');
      	memory(4) <= (others=>'0');
      	memory(5) <= (others=>'0');
      	memory(6) <= (others=>'0');
      	memory(7) <= (others=>'0');
      	memory(8) <= (others=>'0');
      	memory(9) <= (others=>'0');
      	memory(10) <= (others=>'0');
      	memory(11) <= (others=>'0');
      	memory(12) <= (others=>'0');
      	memory(13) <= (others=>'0');
      	memory(14) <= (others=>'0');
      	memory(15) <= (others=>'0');
      	memory(16) <= (others=>'0');
      	memory(17) <= (others=>'0');
      	memory(18) <= (others=>'0');
      	memory(19) <= (others=>'0');
      	memory(20) <= (others=>'0');
      	memory(21) <= (others=>'0');
      	memory(22) <= (others=>'0');
      	memory(23) <= (others=>'0');
      	memory(24) <= (others=>'0');
      	memory(25) <= (others=>'0');
      	memory(26) <= (others=>'0');
      	memory(27) <= (others=>'0');
      	memory(28) <= (others=>'0');
      	memory(29) <= (others=>'0');
      	memory(30) <= (others=>'0');
      	memory(31) <= (others=>'0');
      	memory(32) <= to_signed(16777216, data_width);
      	memory(33) <= (others=>'0');
      	memory(34) <= to_signed(33554432, data_width);
      	memory(35) <= (others=>'0');
      	memory(36) <= (others=>'0');
      	memory(37) <= (others=>'0');
      	memory(38) <= (others=>'0');
      	memory(39) <= (others=>'0');
      	memory(40) <= (others=>'0');
      	memory(41) <= (others=>'0');
      	memory(42) <= (others=>'0');
      	memory(43) <= (others=>'0');
      	memory(44) <= (others=>'0');
      	memory(45) <= (others=>'0');
      	memory(46) <= (others=>'0');
      	memory(47) <= (others=>'0');
      	memory(48) <= to_signed(16777216, data_width);
      	memory(49) <= (others=>'0');
      	memory(50) <= (others=>'0');
      	memory(51) <= (others=>'0');
      	memory(52) <= (others=>'0');
      	memory(53) <= (others=>'0');
      	memory(54) <= (others=>'0');
      	memory(55) <= (others=>'0');
      	memory(56) <= (others=>'0');
      	memory(57) <= (others=>'0');
      	memory(58) <= (others=>'0');
      	memory(59) <= (others=>'0');
      	memory(60) <= to_signed(16777216, data_width);
      	memory(61) <= (others=>'0');
      	memory(62) <= (others=>'0');
      	memory(63) <= (others=>'0');
      else
        if memEnable = '1' then
          if writeBEn = '1' then
            memory(to_integer(addressB)) <= dataB;
          end if;
          if writeAEn = '1' then
            memory(to_integer(addressA)) <= dataA;
          end if;
        end if;
      end if;
    end if;
  end process;

  process (clk) is
  variable line_v   : line;
  file     out_file : text open write_mode is "out.txt";
  variable done : std_logic;
begin
  if rising_edge(clk) then
    if writeAEn = '0' and done = '0' then
      write(line_v, string'("hola"));
      writeline(out_file, line_v);
      for i in memory'low to 63 loop
        write(line_v, to_bstring(std_logic_vector(memory(i))));
        writeline(out_file, line_v);
      end loop;
      done := '1';
    end if;
  elsif writeAEn = '1' then
    done := '0';
  end if;
end process;
end dual_port_memory_arch;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity address_generator is
  generic(
    address_width : integer := 10;
    counter_width : integer := 9;
    stage_width   : integer := 9
  );

  port(
    clk          : in std_logic;
    reset        : in std_logic;
    enable       : in std_logic;
    max_count    : in unsigned(counter_width-1 downto 0);
    stage_count  : in unsigned(stage_width -1 downto 0);
    stage_finish : out std_logic;
    address_low  : out unsigned(address_width-1 downto 0);
    address_high : out unsigned(address_width -1 downto 0)
  );
end address_generator;

architecture address_generator_arch of address_generator is
  signal count : unsigned(counter_width-1 downto 0);
begin
  ADDR_GENERATION : process(max_count, stage_count, count)
  begin
    address_low  <= (others => '0');
    address_high <= (others => '0');
    if max_count(8) = '1' then
      case to_integer(stage_count) is
        when 9 =>
          address_high(9) <= '1';
          address_high(8 downto 0) <= count(8 downto 0);
          address_low(8 downto 0) <= count(8 downto 0);
        when 8 =>
          address_high(8) <= '1';
          address_high(9) <= count(8);
          address_low(9)  <= count(8);
          address_low(7 downto 0) <= count(7 downto 0);
          address_high(7 downto 0) <= count(7 downto 0);
        when 7 =>
          address_high(7) <= '1';
          address_high(9 downto 8) <= count(8 downto 7);
          address_low(9 downto 8)  <= count(8 downto 7);
          address_low(6 downto 0) <= count(6 downto 0);
          address_high(6 downto 0) <= count(6 downto 0);
        when 6 =>
          address_high(6) <= '1';
          address_high(9 downto 7) <= count(8 downto 6);
          address_low(9 downto 7)  <= count(8 downto 6);
          address_low(5 downto 0) <= count(5 downto 0);
          address_high(5 downto 0) <= count(5 downto 0);
        when 5 =>
          address_high(5) <= '1';
          address_high(9 downto 6) <= count(8 downto 5);
          address_low(9 downto 6)  <= count(8 downto 5);
          address_low(4 downto 0) <= count(4 downto 0);
          address_high(4 downto 0) <= count(4 downto 0);
        when 4 =>
          address_high(4) <= '1';
          address_high(9 downto 5) <= count(8 downto 4);
          address_low(9 downto 5)  <= count(8 downto 4);
          address_low(3 downto 0) <= count(3 downto 0);
          address_high(3 downto 0) <= count(3 downto 0);
        when 3 =>
          address_high(3) <= '1';
          address_high(9 downto 4) <= count(8 downto 3);
          address_low(9 downto 4)  <= count(8 downto 3);
          address_low(2 downto 0) <= count(2 downto 0);
          address_high(2 downto 0) <= count(2 downto 0);
        when 2 =>
          address_high(2) <= '1';
          address_high(9 downto 3) <= count(8 downto 2);
          address_low(9 downto 3)  <= count(8 downto 2);
          address_low(1 downto 0) <= count(1 downto 0);
          address_high(1 downto 0) <= count(1 downto 0);
        when 1 =>
          address_high(1) <= '1';
          address_high(9 downto 2) <= count(8 downto 1);
          address_low(9 downto 2)  <= count(8 downto 1);
          address_low(0) <= count(0);
          address_high(0) <= count(0);
        when 0 =>
          address_high(0) <= '1';
          address_high(9 downto 1) <= count(8 downto 0);
          address_low(9 downto 1)  <= count(8 downto 0);
        when others =>
          address_low  <= (others => '0');
          address_high <= (others => '0');
      end case;
    elsif max_count(7) = '1' then
      case to_integer(stage_count) is
        when 8 =>
          address_high(8) <= '1';
          address_low(7 downto 0) <= count(7 downto 0);
          address_high(7 downto 0) <= count(7 downto 0);
        when 7 =>
          address_high(7) <= '1';
          address_high(8) <= count(7);
          address_low(8)  <= count(7);
          address_low(6 downto 0) <= count(6 downto 0);
          address_high(6 downto 0) <= count(6 downto 0);
        when 6 =>
          address_high(6) <= '1';
          address_high(8 downto 7) <= count(7 downto 6);
          address_low(8 downto 7)  <= count(7 downto 6);
          address_low(5 downto 0) <= count(5 downto 0);
          address_high(5 downto 0) <= count(5 downto 0);
        when 5 =>
          address_high(5) <= '1';
          address_high(8 downto 6) <= count(7 downto 5);
          address_low(8 downto 6)  <= count(7 downto 5);
          address_low(4 downto 0) <= count(4 downto 0);
          address_high(4 downto 0) <= count(4 downto 0);
        when 4 =>
          address_high(4) <= '1';
          address_high(8 downto 5) <= count(7 downto 4);
          address_low(8 downto 5)  <= count(7 downto 4);
          address_low(3 downto 0) <= count(3 downto 0);
          address_high(3 downto 0) <= count(3 downto 0);
        when 3 =>
          address_high(3) <= '1';
          address_high(8 downto 4) <= count(7 downto 3);
          address_low(8 downto 4)  <= count(7 downto 3);
          address_low(2 downto 0) <= count(2 downto 0);
          address_high(2 downto 0) <= count(2 downto 0);
        when 2 =>
          address_high(2) <= '1';
          address_high(8 downto 3) <= count(7 downto 2);
          address_low(8 downto 3)  <= count(7 downto 2);
          address_low(1 downto 0) <= count(1 downto 0);
          address_high(1 downto 0) <= count(1 downto 0);
        when 1 =>
          address_high(1) <= '1';
          address_high(8 downto 2) <= count(7 downto 1);
          address_low(8 downto 2)  <= count(7 downto 1);
          address_low(0) <= count(0);
          address_high(0) <= count(0);
        when 0 =>
          address_high(0) <= '1';
          address_high(8 downto 1) <= count(7 downto 0);
          address_low(8 downto 1)  <= count(7 downto 0);
        when others =>
          address_low  <= (others => '0');
          address_high <= (others => '0');
      end case;
    elsif max_count(6) = '1' then
      case to_integer(stage_count) is
        when 7 =>
          address_high(7) <= '1';
          address_low(6 downto 0) <= count(6 downto 0);
          address_high(6 downto 0) <= count(6 downto 0);
        when 6 =>
          address_high(6) <= '1';
          address_high(7) <= count(6);
          address_low(7)  <= count(6);
          address_low(5 downto 0) <= count(5 downto 0);
          address_high(5 downto 0) <= count(5 downto 0);
        when 5 =>
          address_high(5) <= '1';
          address_high(7 downto 6) <= count(6 downto 5);
          address_low(7 downto 6)  <= count(6 downto 5);
          address_low(4 downto 0) <= count(4 downto 0);
          address_high(4 downto 0) <= count(4 downto 0);
        when 4 =>
          address_high(4) <= '1';
          address_high(7 downto 5) <= count(6 downto 4);
          address_low(7 downto 5)  <= count(6 downto 4);
          address_low(3 downto 0) <= count(3 downto 0);
          address_high(3 downto 0) <= count(3 downto 0);
        when 3 =>
          address_high(3) <= '1';
          address_high(7 downto 4) <= count(6 downto 3);
          address_low(7 downto 4)  <= count(6 downto 3);
          address_low(2 downto 0) <= count(2 downto 0);
          address_high(2 downto 0) <= count(2 downto 0);
        when 2 =>
          address_high(2) <= '1';
          address_high(7 downto 3) <= count(6 downto 2);
          address_low(7 downto 3)  <= count(6 downto 2);
          address_low(1 downto 0) <= count(1 downto 0);
          address_high(1 downto 0) <= count(1 downto 0);
        when 1 =>
          address_high(1) <= '1';
          address_high(7 downto 2) <= count(6 downto 1);
          address_low(7 downto 2)  <= count(6 downto 1);
          address_low(0) <= count(0);
          address_high(0) <= count(0);
        when 0 =>
          address_high(0) <= '1';
          address_high(7 downto 1) <= count(6 downto 0);
          address_low(7 downto 1)  <= count(6 downto 0);
        when others =>
          address_low  <= (others => '0');
          address_high <= (others => '0');
      end case;
    elsif max_count(5) = '1' then
      case to_integer(stage_count) is
        when 6 =>
          address_high(6) <= '1';
          address_low(5 downto 0) <= count(5 downto 0);
          address_high(5 downto 0) <= count(5 downto 0);
        when 5 =>
          address_high(5) <= '1';
          address_high(6) <= count(5);
          address_low(6)  <= count(5);
          address_low(4 downto 0) <= count(4 downto 0);
          address_high(4 downto 0) <= count(4 downto 0);
        when 4 =>
          address_high(4) <= '1';
          address_high(6 downto 5) <= count(5 downto 4);
          address_low(6 downto 5)  <= count(5 downto 4);
          address_low(3 downto 0) <= count(3 downto 0);
          address_high(3 downto 0) <= count(3 downto 0);
        when 3 =>
          address_high(3) <= '1';
          address_high(6 downto 4) <= count(5 downto 3);
          address_low(6 downto 4)  <= count(5 downto 3);
          address_low(2 downto 0) <= count(2 downto 0);
          address_high(2 downto 0) <= count(2 downto 0);
        when 2 =>
          address_high(2) <= '1';
          address_high(6 downto 3) <= count(5 downto 2);
          address_low(6 downto 3)  <= count(5 downto 2);
          address_low(1 downto 0) <= count(1 downto 0);
          address_high(1 downto 0) <= count(1 downto 0);
        when 1 =>
          address_high(1) <= '1';
          address_high(6 downto 2) <= count(5 downto 1);
          address_low(6 downto 2)  <= count(5 downto 1);
          address_low(0) <= count(0);
          address_high(0) <= count(0);
        when 0 =>
          address_high(0) <= '1';
          address_high(6 downto 1) <= count(5 downto 0);
          address_low(6 downto 1)  <= count(5 downto 0);
        when others =>
          address_low  <= (others => '0');
          address_high <= (others => '0');
      end case;
    elsif max_count(4) = '1' then
        case to_integer(stage_count) is
          when 5 =>
            address_high(5) <= '1';
            address_low(4 downto 0) <= count(4 downto 0);
            address_high(4 downto 0) <= count(4 downto 0);
          when 4 =>
            address_high(4) <= '1';
            address_high(5) <= count(4);
            address_low(5)  <= count(4);
            address_low(3 downto 0) <= count(3 downto 0);
            address_high(3 downto 0) <= count(3 downto 0);
          when 3 =>
            address_high(3) <= '1';
            address_high(5 downto 4) <= count(4 downto 3);
            address_low(5 downto 4)  <= count(4 downto 3);
            address_low(2 downto 0) <= count(2 downto 0);
            address_high(2 downto 0) <= count(2 downto 0);
          when 2 =>
            address_high(2) <= '1';
            address_high(5 downto 3) <= count(4 downto 2);
            address_low(5 downto 3)  <= count(4 downto 2);
            address_low(1 downto 0) <= count(1 downto 0);
            address_high(1 downto 0) <= count(1 downto 0);
          when 1 =>
            address_high(1) <= '1';
            address_high(5 downto 2) <= count(4 downto 1);
            address_low(5 downto 2)  <= count(4 downto 1);
            address_low(0) <= count(0);
            address_high(0) <= count(0);
          when 0 =>
            address_high(0) <= '1';
            address_high(5 downto 1) <= count(4 downto 0);
            address_low(5 downto 1)  <= count(4 downto 0);
          when others =>
            address_low  <= (others => '0');
            address_high <= (others => '0');
        end case;
    end if;
  end process;

  FINISH_SIGNAL_GENERATION : process(count, enable, max_count)
  begin
    if max_count = count and enable = '1' then
      stage_finish <= '1';
    else
      stage_finish <= '0';
    end if;
  end process;

  COUNT_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        count <= (others => '0');
      else
        if enable = '1' then
          if count = max_count then
            count <= (others => '0');
          else
            count <= count + to_unsigned(1, count'length);
          end if;
        end if;
      end if;
    end if;
  end process;

end address_generator_arch;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity twiddle_address_generator is
  generic(
    address_width : integer := 11;
    stage_width   : integer := 4
  );

  port(
    clk             : in std_logic;
    reset           : in std_logic;
    enable          : in std_logic;
    stage_count     : in unsigned(stage_width-1 downto 0);
    sample_number   : in unsigned(address_width downto 0);
    twiddle_address : out unsigned(address_width-1 downto 0)
  );
end twiddle_address_generator;


architecture twid_addr_arch of twiddle_address_generator is
  signal count          : unsigned(address_width-1 downto 0);
  signal max_count      : unsigned(address_width-1 downto 0);
  signal add_value      : unsigned(address_width-1 downto 0);
  signal temp_twid_addr : unsigned(address_width-1 downto 0);
begin
  GEN_TWID_ADDR : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        count          <= (others => '0');
        temp_twid_addr <= (others => '0');
      else
        if enable = '1' then
          if count = max_count then
            count          <= (others => '0');
            temp_twid_addr <= (others => '0');
          else
            temp_twid_addr <= temp_twid_addr + add_value;
            count          <= count + to_unsigned(1, count'length);
          end if;
        end if;
      end if;
    end if;

  end process;

  GEN_MAX_COUNT : process(stage_count)
  begin
    max_count <= (others => '0');
    case to_integer(stage_count) is
      when 1 =>
        max_count <= to_unsigned(1, max_count'length);
      when 2 =>
        max_count <= to_unsigned(3, max_count'length);
      when 3 =>
        max_count <= to_unsigned(7, max_count'length);
      when 4 =>
        max_count <= to_unsigned(15, max_count'length);
      when 5 =>
        max_count <= to_unsigned(31, max_count'length);
      when 6 =>
        max_count <= to_unsigned(63, max_count'length);
      when 7 =>
        max_count <= to_unsigned(127, max_count'length);
      when 8 =>
        max_count <= to_unsigned(255, max_count'length);
      when 9 =>
        max_count <= to_unsigned(511, max_count'length);
      when others =>
    end case;
  end process;

  GEN_ADD_VALUE : process(sample_number, stage_count)
  begin
    add_value <= (others => '0');
    case to_integer(stage_count) is
      when 1 =>
        add_value <= shift_right(sample_number, 2)(add_value'length-1 downto 0);
      when 2 =>
        add_value <= shift_right(sample_number, 3)(add_value'length-1 downto 0);
      when 3 =>
        add_value <= shift_right(sample_number, 4)(add_value'length-1 downto 0);
      when 4 =>
        add_value <= shift_right(sample_number, 5)(add_value'length-1 downto 0);
      when 5 =>
        add_value <= shift_right(sample_number, 6)(add_value'length-1 downto 0);
      when 6 =>
        add_value <= shift_right(sample_number, 7)(add_value'length-1 downto 0);
      when 7 =>
        add_value <= shift_right(sample_number, 8)(add_value'length-1 downto 0);
      when 8 =>
        add_value <= shift_right(sample_number, 9)(add_value'length-1 downto 0);
      when 9 =>
        add_value <= shift_right(sample_number, 10)(add_value'length-1 downto 0);
      when others =>
        add_value <= (others => '0');
    end case;
  end process;

  twiddle_address <= temp_twid_addr;
end twid_addr_arch;

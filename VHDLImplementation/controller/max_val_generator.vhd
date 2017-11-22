LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity max_val_gen is
  generic(
    number_sample_widths : integer := 5;
    counter_width        : integer := 9;
    stage_width          : integer := 4
  );
  port(
    sample_width_selector : in unsigned(number_sample_widths-1 downto 0);
    max_count             : out unsigned(counter_width-1 downto 0);
    max_stage             : out unsigned(stage_width-1 downto 0)
  );
end max_val_gen;

architecture max_val_gen_arch of max_val_gen is
begin
  MAX_VAL_GEN : process(sample_width_selector)
  begin
    case to_integer(sample_width_selector) is
      when 16 =>
        max_count <= to_unsigned(511, max_count'length);
        max_stage <= to_unsigned(9, max_stage'length);
      when 8 =>
        max_count <= to_unsigned(255, max_count'length);
        max_stage <= to_unsigned(8, max_stage'length);
      when 4 =>
        max_count <= to_unsigned(127, max_count'length);
        max_stage <= to_unsigned(7, max_stage'length);
      when 2 =>
        max_count <= to_unsigned(63, max_count'length);
        max_stage <= to_unsigned(6, max_stage'length);
      when 1 =>
        max_count <= to_unsigned(31, max_count'length);
        max_stage <= to_unsigned(5, max_stage'length);
      when others =>
        max_count <= (others => '0');
        max_stage <= (others => '0');
    end case;
  end process;
end max_val_gen_arch;

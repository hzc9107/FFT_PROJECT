LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity stage_counter is
  generic(
    stage_width : integer := 4
  );

  port(
    clk           : in std_logic;
    reset         : in std_logic;
    enable        : in std_logic;
    stage_finish  : in std_logic;
    stage_cnt     : out unsigned(stage_width-1 downto 0)
  );
end stage_counter;

architecture stage_counter_arch of stage_counter is
  signal stage_cnt_tmp : unsigned(stage_width-1 downto 0);
begin
  COUNT : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        stage_cnt_tmp <= (others => '0');
      elsif enable = '1' and stage_finish = '1' then
        stage_cnt_tmp <= stage_cnt_tmp + to_unsigned(1, stage_cnt'length);
      end if;
    end if;
  end process;

  stage_cnt <= stage_cnt_tmp;
end stage_counter_arch;

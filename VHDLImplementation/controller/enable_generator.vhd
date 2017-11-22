LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;

entity enable_generator is
  port(
    clk          : in std_logic;
    reset        : in std_logic;
    start        : in std_logic;
    mem_selector : in std_logic;
    stage_finish : in std_logic;
    pipe_finish  : in std_logic;
    addr_gen_en  : out std_logic;
    pipe_en      : out std_logic;
    memA_wen     : out std_logic;
    memB_wen     : out std_logic
  );
end enable_generator;

architecture enable_generator_arch of enable_generator is
  signal internal_state      : std_logic;
  signal temp_internal_state : std_logic;
begin

  GENERATE_PIPE_EN : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pipe_en <= '0';
      elsif start = '1' and internal_state = '0' then
        pipe_en <= '1';
      end if;
    end if;
  end process;

  GENERATE_ADDR_GEN_EN : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        addr_gen_en <= '0';
      elsif start = '1' and internal_state = '0' then
        addr_gen_en <= '1';
      elsif stage_finish = '1' and internal_state = '1' then
        addr_gen_en <= '0';
      elsif pipe_finish = '1' and internal_state = '1' then
        addr_gen_en <= '1';
      end if;
    end if;
  end process;

  STATE_MACH : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        internal_state      <= '0';
        temp_internal_state <= '0';
      elsif start = '1' then
        internal_state      <= temp_internal_state;
        temp_internal_state <= '1';
      end if;
    end if;
  end process;

  memA_wen <= mem_selector;
  memB_wen <= not(mem_selector);
end enable_generator_arch;

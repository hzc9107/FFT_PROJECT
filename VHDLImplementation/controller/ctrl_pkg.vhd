library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package ctrl_pkg is
  component address_generator
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
  end component address_generator;

  component twiddle_address_generator
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
  end component twiddle_address_generator;

  component enable_generator
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
  end component enable_generator;

  component max_val_gen
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
  end component max_val_gen;

  component stage_counter
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
  end component stage_counter;
end package ctrl_pkg;

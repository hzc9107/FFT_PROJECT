library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ctrl_pkg.all;
entity controller is
  generic(
    sample_width                    : integer := 11;
    address_width                   : integer := 10;
    stage_width                     : integer := 4;
    number_of_supported_sample_size : integer := 5
  );

  port(
    clk               : in std_logic;
    reset             : in std_logic;
    start             : in std_logic;
    pipe_finish       : in std_logic;
    number_of_samples : in unsigned(sample_width-1 downto 0);
    address_low       : out unsigned(address_width-1 downto 0);
    address_high      : out unsigned(address_width-1 downto 0);
    twiddle_address   : out unsigned(address_width-1 downto 0);
    mem_en            : out std_logic;
    pipe_en           : out std_logic;
    memA_wen          : out std_logic;
    memB_wen          : out std_logic;
    stage_finish      : out std_logic;
    fft_done          : out std_logic
  );
end controller;

architecture controller_arch of controller is
  signal internal_reset         : std_logic;
  signal fft_finish_reset       : std_logic;
  signal addr_gen_en            : std_logic;
  signal stage_finish_internal  : std_logic;
  signal pipe_en_internal       : std_logic;
  signal mem_selector           : std_logic;
  signal max_count              : unsigned(address_width-2 downto 0);
  signal stage_count            : unsigned(stage_width-1 downto 0);
  signal max_stage              : unsigned(stage_width-1 downto 0);
  signal sample_width_selector  : unsigned(number_of_supported_sample_size-1 downto 0);
begin

  addr_gen_inst : address_generator
    generic map(
      address_width => address_width,
      counter_width => address_width-1,
      stage_width   => stage_width
    )
    port map(
      clk           => clk,
      reset         => internal_reset,
      enable        => addr_gen_en,
      max_count     => max_count,
      stage_count   => stage_count,
      stage_finish  => stage_finish_internal,
      address_low   => address_low,
      address_high  => address_high
    );

  twid_addr_gen_inst : twiddle_address_generator
    generic map(
      address_width => address_width,
      stage_width => stage_width
    )

    port map(
      clk             => clk,
      reset           => internal_reset,
      enable          => addr_gen_en,
      stage_count     => stage_count,
      sample_number   => number_of_samples,
      twiddle_address => twiddle_address
    );

  max_val_gen_inst : max_val_gen
    generic map(
      number_sample_widths  => number_of_supported_sample_size,
      counter_width         => address_width-1,
      stage_width           => stage_width
    )

    port map(
      sample_width_selector => sample_width_selector,
      max_count             => max_count,
      max_stage             => max_stage
    );

  enable_gen_inst : enable_generator
    port map(
      clk           => clk,
      reset         => internal_reset,
      start         => start,
      mem_selector  => mem_selector,
      stage_finish  => stage_finish_internal,
      pipe_finish   => pipe_finish,
      addr_gen_en   => addr_gen_en,
      pipe_en       => pipe_en_internal,
      memA_wen      => memA_wen,
      memB_wen      => memB_wen
    );

  stage_cnt_inst : stage_counter
    generic map(
      stage_width => stage_width
    )

    port map(
      clk           => clk,
      reset         => reset,
      enable        => pipe_en_internal,
      stage_finish  => pipe_finish,
      stage_cnt     => stage_count
    );

  INTERNAL_RESET_GEN : process(reset, max_stage, pipe_finish, stage_count)
  begin
    if max_stage = stage_count and pipe_finish = '1' then
      fft_done <= '1';
    else
      fft_done <= '0';
    end if;

    if reset = '1' or (max_stage = stage_count and pipe_finish = '1') then
      internal_reset <= '1';
    else
      internal_reset <= '0';
    end if;
  end process;



  mem_en <= pipe_en_internal;
  pipe_en <= pipe_en_internal;
  stage_finish <= stage_finish_internal;
  sample_width_selector <= number_of_samples(sample_width-1 downto sample_width-5);
  mem_selector <= stage_count(0);
end controller_arch;

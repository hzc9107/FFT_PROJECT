library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity test_bench is

end test_bench;

architecture test_fft of test_bench is
  signal reset                : std_logic;
  signal clk                  : std_logic := '0';
  signal start                : std_logic;
  signal sample_size          : unsigned(10 downto 0);
  signal twiddle_write_port   : std_logic;
  signal twiddle_data_port    : signed(31 downto 0);
  signal twiddle_address_port : unsigned(9 downto 0);
  signal fft_finish           : std_logic;
  constant half_period        : time := 1 ns;

  component fft_top is
    generic(
      data_width                      : integer := 32;
      address_width                   : integer := 10;
      sample_width                    : integer := 11;
      stage_width                     : integer := 4;
      number_of_supported_sample_size : integer := 5
    );
    port(
      reset                : in std_logic;
      clk                  : in std_logic;
      start                : in std_logic;
      sample_size          : in unsigned(sample_width-1 downto 0);
      twiddle_write_port   : in std_logic;
      twiddle_data_port    : in signed(data_width-1 downto 0);
      twiddle_address_port : in unsigned(address_width-1 downto 0);
      fft_finish           : out std_logic

    );
  end component;
begin

  fft_inst : fft_top
  port map (
    reset                 => reset,
    clk                   => clk,
    start                 => start,
    sample_size           => sample_size,
    twiddle_write_port    => twiddle_write_port,
    twiddle_data_port     => twiddle_data_port,
    twiddle_address_port  => twiddle_address_port,
    fft_finish            => fft_finish
  );

  SIMULATION : process
  begin
    wait for 2*half_period;
      reset <= '1';
      start <= '1';
      sample_size <= to_unsigned(64, sample_size'length);
      twiddle_write_port <= '0';
      twiddle_data_port  <= (others => '0');
      twiddle_address_port <= (others => '0');
    wait for 4*half_period;
      reset <= '0';
    wait for 2*half_period;
      start <= '0';
    wait for 80*half_period;
    wait;
  end process;

  clk <= not clk after half_period;

end test_fft;

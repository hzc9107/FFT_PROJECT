library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.fft_pkg.all;

entity fft_top is
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
end fft_top;

architecture fft_top_arch of fft_top is
  signal pipe_en                    : std_logic;
  signal writeEnable                : std_logic;
  signal firstOperandReal           : signed((data_width/2)-1 downto 0);
  signal firstOperandImaginary      : signed((data_width/2)-1 downto 0);
  signal secondOperandReal          : signed((data_width/2)-1 downto 0);
  signal secondOperandImaginary     : signed((data_width/2)-1 downto 0);
  signal twiddleFactorReal          : signed((data_width/2)-1 downto 0);
  signal twiddleFactorImaginary     : signed((data_width/2)-1 downto 0);
  signal firstOperandOutReal        : signed((data_width/2)-1 downto 0);
  signal firstOperandOutImaginary   : signed((data_width/2)-1 downto 0);
  signal secondOperandOutReal       : signed((data_width/2)-1 downto 0);
  signal secondOperandOutImaginary  : signed((data_width/2)-1 downto 0);
  signal destAddressOutLow          : unsigned(address_width -1 downto 0);
  signal destAddressOutHigh         : unsigned(address_width -1 downto 0);
  signal writeEnableOut             : std_logic;
  signal memADataAOut               : signed(data_width -1 downto 0);
  signal memADataBOut               : signed(data_width -1 downto 0);
  signal memBDataAOut               : signed(data_width -1 downto 0);
  signal memBDataBOut               : signed(data_width -1 downto 0);
  signal memDataAIn                 : signed(data_width -1 downto 0);
  signal memDataBIn                 : signed(data_width -1 downto 0);
  signal twiddle_dataA              : signed(data_width -1 downto 0);
  signal memAAddressA               : unsigned(address_width -1 downto 0);
  signal memAAddressB               : unsigned(address_width -1 downto 0);
  signal memBAddressA               : unsigned(address_width -1 downto 0);
  signal memBAddressB               : unsigned(address_width -1 downto 0);
  signal memEnable                  : std_logic;
  signal memEnable_twiddle          : std_logic;
  signal writeAEn                   : std_logic;
  signal writeBEn                   : std_logic;
  signal address_low                : unsigned(address_width -1 downto 0);
  signal address_high               : unsigned(address_width -1 downto 0);
  signal twiddle_address            : unsigned(address_width -1 downto 0);
  signal twiddle_address_ctrl       : unsigned(address_width -1 downto 0);
begin
  pipeline_inst : pipeline
  generic map(
    data_width => data_width/2,
    address_width => address_width
  )
  port map(
    clk => clk,
    addStageEnable            => pipe_en,
    multStageEnable           => pipe_en,
    reset                     => reset,
    writeEnable               => writeEnable,
    firstOperandReal          => firstOperandReal,
    firstOperandImaginary     => firstOperandImaginary,
    secondOperandReal         => secondOperandReal,
    secondOperandImaginary    => secondOperandImaginary,
    twiddleFactorReal         => twiddleFactorReal,
    twiddleFactorImaginary    => twiddleFactorImaginary,
    firstOperandOutReal       => firstOperandOutReal,
    firstOperandOutImaginary  => firstOperandOutImaginary,
    secondOperandOutReal      => secondOperandOutReal,
    secondOperandOutImaginary => secondOperandOutImaginary,
    destAddressInLow          => address_low,
    destAddressInHigh         => address_high,
    destAddressOutLow         => destAddressOutLow,
    destAddressOutHigh        => destAddressOutHigh,
    writeEnableOut            => writeEnableOut
  );

  controller_inst : controller
  generic map(
    sample_width  => sample_width,
    address_width => address_width,
    stage_width   => stage_width
  )
  port map(
    clk => clk,
    reset => reset,
    start => start,
    pipe_finish => writeEnableOut,
    number_of_samples => sample_size,
    address_low       => address_low,
    address_high      => address_high,
    twiddle_address   => twiddle_address_ctrl,
    mem_en            => memEnable,
    pipe_en           => pipe_en,
    memA_wen          => writeAEn,
    memB_wen          => writeBEn,
    stage_finish      => writeEnable,
    fft_done          => fft_finish
  );

  memoryA : dual_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memAAddressA,
    addressB  => memAAddressB,
    dataA     => memDataAIn,
    dataB     => memDataBIn,
    memEnable => memEnable,
    writeAEn  => writeAEn,
    writeBEn  => writeAEn,
    dataAOut  => memADataAOut,
    dataBOut  => memADataBOut
  );

  memoryB : dual_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memBAddressA,
    addressB  => memBAddressB,
    dataA     => memDataAIn,
    dataB     => memDataBIn,
    memEnable => memEnable,
    writeAEn  => writeBEn,
    writeBEn  => writeBEn,
    dataAOut  => memBDataAOut,
    dataBOut  => memBDataBOut
  );

  twiddle_memory : single_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => twiddle_address,
    dataA     => twiddle_data_port,
    memEnable => memEnable_twiddle,
    writeAEn  => twiddle_write_port,
    dataAOut  => twiddle_dataA
  );

  memAAddressA <= destAddressOutLow when writeAEn = '1' else address_low;
  memBAddressA <= address_low when writeAEn = '1' else destAddressOutLow;

  memAAddressB <= destAddressOutHigh when writeAEn = '1' else address_high;
  memBAddressB <= address_high when writeAEn = '1' else destAddressOutHigh;

  memDataAIn <= firstOperandOutReal & firstOperandOutImaginary;
  memDataBIn <= secondOperandOutReal & secondOperandOutImaginary;

  memEnable_twiddle <= twiddle_write_port or (not(twiddle_write_port) and memEnable);

  twiddle_address <= twiddle_address_port when twiddle_write_port = '1' else twiddle_address_ctrl;

  firstOperandReal <= memBDataAOut(data_width-1 downto (data_width/2)) when writeAEn = '1' else memADataAOut(data_width-1 downto (data_width/2));
  firstOperandImaginary <= memBDataAOut((data_width/2)-1 downto 0) when writeAEn = '1' else memADataAOut((data_width/2)-1 downto 0);

  secondOperandReal <= memBDataBOut(data_width-1 downto (data_width/2)) when writeAEn = '1' else memADataBOut(data_width-1 downto (data_width/2));
  secondOperandImaginary <= memBDataBOut((data_width/2)-1 downto 0) when writeAEn = '1' else memADataBOut((data_width/2)-1 downto 0);

  twiddleFactorReal      <= twiddle_dataA(data_width-1 downto (data_width/2));
  twiddleFactorImaginary <= twiddle_dataA((data_width/2)-1 downto 0);

end fft_top_arch;

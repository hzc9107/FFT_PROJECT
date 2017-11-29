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
    number_of_supported_sample_size : integer := 5;
    block_width                     : integer := 3
  );
  port(
    reset                 : in std_logic;
    clk                   : in std_logic;
    start                 : in std_logic;
    radix_type            : in std_logic;
    sample_size           : in unsigned(sample_width-1 downto 0);
    twiddle_write_port    : in std_logic;
    twiddle_data_port     : in signed(data_width-1 downto 0);
    twiddle_address_port  : in unsigned(address_width-1 downto 0);
    fft_finish            : out std_logic
  );
end fft_top;

architecture fft_top_arch of fft_top is
  component pipeline is
    generic(
      data_width    : integer := 16;
      address_width : integer := 10
    );
    port(
      clk                         : in std_logic;
      addStageEnable              : in std_logic;
      multStageEnable             : in std_logic;
      reset                       : in std_logic;
      writeEnable                 : in std_logic;
      radix_type                  : in std_logic;
      firstOperandReal            : in signed(data_width-1 downto 0);
      firstOperandImaginary       : in signed(data_width-1 downto 0);
      secondOperandReal           : in signed(data_width-1 downto 0);
      secondOperandImaginary      : in signed(data_width-1 downto 0);
      thirdOperandReal            : in signed(data_width-1 downto 0);
      thirdOperandImaginary       : in signed(data_width-1 downto 0);
      fourthOperandReal           : in signed(data_width-1 downto 0);
      fourthOperandImaginary      : in signed(data_width-1 downto 0);
      twiddleFactorReal           : in signed(data_width-1 downto 0);
      twiddleFactorImaginary      : in signed(data_width-1 downto 0);
      twiddleFactor2Real          : in signed(data_width-1 downto 0);
      twiddleFactor2Imaginary     : in signed(data_width-1 downto 0);
      twiddleFactor3Real          : in signed(data_width-1 downto 0);
      twiddleFactor3Imaginary     : in signed(data_width-1 downto 0);
      destAddressInLow1           : in unsigned(address_width-1 downto 0);
      destAddressInLow2           : in unsigned(address_width-1 downto 0);
      destAddressInHigh1          : in unsigned(address_width-1 downto 0);
      destAddressInHigh2          : in unsigned(address_width-1 downto 0);
      firstOperandOutReal         : out signed(data_width-1 downto 0);
      firstOperandOutImaginary    : out signed(data_width-1 downto 0);
      secondOperandOutReal        : out signed(data_width-1 downto 0);
      secondOperandOutImaginary   : out signed(data_width-1 downto 0);
      thirdOperandOutReal         : out signed(data_width-1 downto 0);
      thirdOperandOutImaginary    : out signed(data_width-1 downto 0);
      fourthOperandOutReal        : out signed(data_width-1 downto 0);
      fourthOperandOutImaginary  : out signed(data_width-1 downto 0);
      destAddressOutLow1          : out unsigned(address_width-1 downto 0);
      destAddressOutLow2          : out unsigned(address_width-1 downto 0);
      destAddressOutHigh1         : out unsigned(address_width-1 downto 0);
      destAddressOutHigh2         : out unsigned(address_width-1 downto 0);
      writeEnableOut              : out std_logic
    );
  end component;

  signal pipe_en                    : std_logic;
  signal writeEnable                : std_logic;
  signal firstOperandReal           : signed((data_width/2)-1 downto 0);
  signal firstOperandImaginary      : signed((data_width/2)-1 downto 0);
  signal secondOperandReal          : signed((data_width/2)-1 downto 0);
  signal secondOperandImaginary     : signed((data_width/2)-1 downto 0);
  signal thirdOperandReal           : signed((data_width/2)-1 downto 0);
  signal thirdOperandImaginary      : signed((data_width/2)-1 downto 0);
  signal fourthOperandReal          : signed((data_width/2)-1 downto 0);
  signal fourthOperandImaginary     : signed((data_width/2)-1 downto 0);
  signal twiddleFactorReal          : signed((data_width/2)-1 downto 0);
  signal twiddleFactorImaginary     : signed((data_width/2)-1 downto 0);
  signal twiddleFactor2Real          : signed((data_width/2)-1 downto 0);
  signal twiddleFactor2Imaginary     : signed((data_width/2)-1 downto 0);
  signal twiddleFactor3Real          : signed((data_width/2)-1 downto 0);
  signal twiddleFactor3Imaginary     : signed((data_width/2)-1 downto 0);
  signal firstOperandOutReal        : signed((data_width/2)-1 downto 0);
  signal firstOperandOutImaginary   : signed((data_width/2)-1 downto 0);
  signal secondOperandOutReal       : signed((data_width/2)-1 downto 0);
  signal secondOperandOutImaginary  : signed((data_width/2)-1 downto 0);
  signal thirdOperandOutReal        : signed((data_width/2)-1 downto 0);
  signal thirdOperandOUtImaginary   : signed((data_width/2)-1 downto 0);
  signal fourthOperandOutReal       : signed((data_width/2)-1 downto 0);
  signal fourthOperandOutImaginary  : signed((data_width/2)-1 downto 0);
  signal destAddressOutLow1         : unsigned(address_width -1 downto 0);
  signal destAddressOutHigh1        : unsigned(address_width -1 downto 0);
  signal destAddressOutLow2         : unsigned(address_width -1 downto 0);
  signal destAddressOutHigh2        : unsigned(address_width -1 downto 0);
  signal writeEnableOut             : std_logic;
  signal memADataAOut_to_router     : signed(data_width -1 downto 0);
  signal memADataBOut_to_router     : signed(data_width -1 downto 0);
  signal memBDataAOut_to_router     : signed(data_width -1 downto 0);
  signal memBDataBOut_to_router     : signed(data_width -1 downto 0);
  signal memCDataAOut_to_router     : signed(data_width -1 downto 0);
  signal memCDataBOut_to_router     : signed(data_width -1 downto 0);
  signal memDDataAOut_to_router     : signed(data_width -1 downto 0);
  signal memDDataBOut_to_router     : signed(data_width -1 downto 0);
  signal memDataAIn1                : signed(data_width -1 downto 0);
  signal memDataBIn1                : signed(data_width -1 downto 0);
  signal memDataAIn2                : signed(data_width -1 downto 0);
  signal memDataBIn2                : signed(data_width -1 downto 0);
  signal twiddle_data1              : signed(data_width -1 downto 0);
  signal twiddle_data2              : signed(data_width -1 downto 0);
  signal twiddle_data3              : signed(data_width -1 downto 0);
  signal memAAddressA_from_router   : unsigned(address_width -1 downto 0);
  signal memAAddressB_from_router   : unsigned(address_width -1 downto 0);
  signal memBAddressA_from_router   : unsigned(address_width -1 downto 0);
  signal memBAddressB_from_router   : unsigned(address_width -1 downto 0);
  signal memCAddressA_from_router   : unsigned(address_width -1 downto 0);
  signal memCAddressB_from_router   : unsigned(address_width -1 downto 0);
  signal memDAddressA_from_router   : unsigned(address_width -1 downto 0);
  signal memDAddressB_from_router   : unsigned(address_width -1 downto 0);
  signal memEnable                  : std_logic;
  signal memEnable_twiddle          : std_logic;
  signal writeAEn                   : std_logic;
  signal writeBEn                   : std_logic;
  signal address_low1               : unsigned(address_width -1 downto 0);
  signal address_high1              : unsigned(address_width -1 downto 0);
  signal address_low2               : unsigned(address_width -1 downto 0);
  signal address_high2              : unsigned(address_width -1 downto 0);
  signal twiddle_address1           : unsigned(address_width -1 downto 0);
  signal twiddle_address_ctrl1      : unsigned(address_width -1 downto 0);
  signal twiddle_address2           : unsigned(address_width -1 downto 0);
  signal twiddle_address_ctrl2      : unsigned(address_width -1 downto 0);
  signal twiddle_address3           : unsigned(address_width -1 downto 0);
  signal twiddle_address_ctrl3      : unsigned(address_width -1 downto 0);
  signal positionToBlock            : unsigned(block_width -1  downto 0);
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
    radix_type                => radix_type,
    firstOperandReal          => firstOperandReal,
    firstOperandImaginary     => firstOperandImaginary,
    secondOperandReal         => secondOperandReal,
    secondOperandImaginary    => secondOperandImaginary,
    thirdOperandReal          => thirdOperandReal,
    thirdOperandImaginary     => thirdOperandImaginary,
    fourthOperandReal         => fourthOperandReal,
    fourthOperandImaginary    => fourthOperandImaginary,
    twiddleFactorReal         => twiddleFactorReal,
    twiddleFactorImaginary    => twiddleFactorImaginary,
    twiddleFactor2Real        => twiddleFactor2Real,
    twiddleFactor2Imaginary   => twiddleFactor2Imaginary,
    twiddleFactor3Real        => twiddleFactor3Real,
    twiddleFactor3Imaginary   => twiddleFactor3Imaginary,
    firstOperandOutReal       => firstOperandOutReal,
    firstOperandOutImaginary  => firstOperandOutImaginary,
    secondOperandOutReal      => secondOperandOutReal,
    secondOperandOutImaginary => secondOperandOutImaginary,
    thirdOperandOutReal       => thirdOperandOutReal,
    thirdOperandOutImaginary  => thirdOperandOutImaginary,
    fourthOperandOutReal      => fourthOperandOutReal,
    fourthOperandOutImaginary => fourthOperandOutImaginary,
    destAddressInLow1         => address_low1,
    destAddressInLow2         => address_low2,
    destAddressInHigh1        => address_high1,
    destAddressInHigh2        => address_high2,
    destAddressOutLow1        => destAddressOutLow1,
    destAddressOutHigh1       => destAddressOutHigh1,
    destAddressOutLow2        => destAddressOutLow2,
    destAddressOutHigh2       => destAddressOutHigh2,
    writeEnableOut            => writeEnableOut
  );

  controller_inst : controller
  generic map(
    sample_width  => sample_width,
    address_width => address_width,
    stage_width   => stage_width,
    number_of_supported_sample_size => number_of_supported_sample_size,
    block_width   => block_width
  )
  port map(
    clk                   => clk,
    reset                 => reset,
    radix_type            => radix_type,
    start                 => start,
    pipe_finish           => writeEnableOut,
    number_of_samples     => sample_size,
    address_low1          => address_low1,
    address_high1         => address_high1,
    address_low2          => address_low2,
    address_high2         => address_high2,
    twiddle_address1      => twiddle_address_ctrl1,
    twiddle_address2      => twiddle_address_ctrl2,
    twiddle_address3      => twiddle_address_ctrl3,
    mem_en                => memEnable,
    pipe_en               => pipe_en,
    memA_wen              => writeAEn,
    memB_wen              => writeBEn,
    stage_finish          => writeEnable,
    positionToBlock       => positionToBlock,
    fft_done              => fft_finish
  );

  memoryA : dual_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memAAddressA_from_router,
    addressB  => memAAddressB_from_router,
    dataA     => memDataAIn1,
    dataB     => memDataBIn1,
    memEnable => memEnable,
    writeAEn  => writeAEn,
    writeBEn  => writeAEn,
    dataAOut  => memADataAOut_to_router,
    dataBOut  => memADataBOut_to_router
  );

  memoryC : dual_port_memory1
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memCAddressA_from_router,
    addressB  => memCAddressB_from_router,
    dataA     => memDataAIn2,
    dataB     => memDataBIn2,
    memEnable => memEnable,
    writeAEn  => writeAEn,
    writeBEn  => writeAEn,
    dataAOut  => memCDataAOut_to_router,
    dataBOut  => memCDataBOut_to_router
  );

  memoryB : dual_port_memory2
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memBAddressA_from_router,
    addressB  => memBAddressB_from_router,
    dataA     => memDataAIn1,
    dataB     => memDataBIn1,
    memEnable => memEnable,
    writeAEn  => writeBEn,
    writeBEn  => writeBEn,
    dataAOut  => memBDataAOut_to_router,
    dataBOut  => memBDataBOut_to_router
  );

  memoryD : dual_port_memory3
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => memDAddressA_from_router,
    addressB  => memDAddressB_from_router,
    dataA     => memDataAIn2,
    dataB     => memDataBIn2,
    memEnable => memEnable,
    writeAEn  => writeBEn,
    writeBEn  => writeBEn,
    dataAOut  => memDDataAOut_to_router,
    dataBOut  => memDDataBOut_to_router
  );

  twiddle_memory1 : single_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => twiddle_address1,
    dataA     => twiddle_data_port,
    memEnable => memEnable_twiddle,
    writeAEn  => twiddle_write_port,
    dataAOut  => twiddle_data1
  );

  twiddle_memory2 : single_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => twiddle_address2,
    dataA     => twiddle_data_port,
    memEnable => memEnable_twiddle,
    writeAEn  => twiddle_write_port,
    dataAOut  => twiddle_data2
  );

  twiddle_memory3 : single_port_memory
  generic map(
    data_width    => data_width,
    address_width => address_width
  )
  port map(
    clk       => clk,
    reset     => reset,
    addressA  => twiddle_address3,
    dataA     => twiddle_data_port,
    memEnable => memEnable_twiddle,
    writeAEn  => twiddle_write_port,
    dataAOut  => twiddle_data3
  );

  mem_router : memRouter
    generic map(
      address_width => address_width,
      data_width    => data_width,
      block_width   => block_width
    )
    port map(
      clk                           => clk,
      reset                         => reset,
      writeAEn                      => writeAEn,
      radix_type                    => radix_type,
      positionToBlock               => positionToBlock,
      address_low1                  => address_low1,
      address_low2                  => address_low2,
      address_high1                 => address_high1,
      address_high2                 => address_high2,
      destAddressLow1               => destAddressOutLow1,
      destAddressLow2               => destAddressOutLow2,
      destAddressHigh1              => destAddressOutHigh1,
      destAddressHigh2              => destAddressOutHigh2,
      memAAddressA                  => memAAddressA_from_router,
      memAAddressB                  => memAAddressB_from_router,
      memBAddressA                  => memBAddressA_from_router,
      memBAddressB                  => memBAddressB_from_router,
      memCAddressA                  => memCAddressA_from_router,
      memCAddressB                  => memCAddressB_from_router,
      memDAddressA                  => memDAddressA_from_router,
      memDAddressB                  => memDAddressB_from_router,
      fromMemADataA                 => memADataAOut_to_router,
      fromMemADataB                 => memADataBOut_to_router,
      fromMemBDataA                 => memBDataAOut_to_router,
      fromMemBDataB                 => memBDataBOut_to_router,
      fromMemCDataA                 => memCDataAOut_to_router,
      fromMemCDataB                 => memCDataBOut_to_router,
      fromMemDDataA                 => memDDataAOut_to_router,
      fromMemDDataB                 => memDDataBOut_to_router,
      toMemDataAOut1                => memDataAIn1,
      toMemDataBOut1                => memDataBIn1,
      toMemDataAOut2                => memDataAIn2,
      toMemDataBOut2                => memDataBIn2,
      firstOperandReal              => firstOperandReal,
      firstOperandImaginary         => firstOperandImaginary,
      secondOperandReal             => secondOperandReal,
      secondOperandImaginary        => secondOperandImaginary,
      thirdOperandReal              => thirdOperandReal,
      thirdOperandImaginary         => thirdOperandImaginary,
      fourthOperandReal             => fourthOperandReal,
      fourthOperandImaginary        => fourthOperandImaginary,
      firstOpRealPipelineOut        => firstOperandOutReal,
      firstOpImaginaryPipelineOut   => firstOperandOutImaginary,
      secondOpRealPipelineOut       => secondOperandOutReal,
      secondOpImaginaryPipelineOut  => secondOperandOutImaginary,
      thirdOpRealPipelineOut        => thirdOperandOutReal,
      thirdOpImaginaryPipelineOut   => thirdOperandOutImaginary,
      fourthOpRealPipelineOut       => fourthOperandOutReal,
      fourthOpImaginaryPipelineOut  => fourthOperandOutImaginary
    );

  memEnable_twiddle <= twiddle_write_port or (not(twiddle_write_port) and memEnable);

  twiddle_address1 <= twiddle_address_port when twiddle_write_port = '1' else twiddle_address_ctrl1;

  twiddle_address2 <= twiddle_address_port when twiddle_write_port = '1' else twiddle_address_ctrl2;

  twiddle_address3 <= twiddle_address_port when twiddle_write_port = '1' else twiddle_address_ctrl3;

  twiddleFactorReal      <= twiddle_data1(data_width-1 downto (data_width/2));
  twiddleFactorImaginary <= twiddle_data1((data_width/2)-1 downto 0);

  twiddleFactor2Real      <= twiddle_data2(data_width-1 downto (data_width/2));
  twiddleFactor2Imaginary <= twiddle_data2((data_width/2)-1 downto 0);

  twiddleFactor3Real      <= twiddle_data3(data_width-1 downto (data_width/2));
  twiddleFactor3Imaginary <= twiddle_data3((data_width/2)-1 downto 0);

end fft_top_arch;

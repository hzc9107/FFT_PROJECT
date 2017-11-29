library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fft_pkg is
  component controller is
    generic(
      sample_width                    : integer := 11;
      address_width                   : integer := 10;
      stage_width                     : integer := 4;
      number_of_supported_sample_size : integer := 5;
      block_width                     : integer := 3
    );

    port(
      clk                   : in std_logic;
      reset                 : in std_logic;
      radix_type            : in std_logic;
      start                 : in std_logic;
      pipe_finish           : in std_logic;
      number_of_samples     : in unsigned(sample_width-1 downto 0);
      address_low1          : out unsigned(address_width-1 downto 0);
      address_low2          : out unsigned(address_width-1 downto 0);
      address_high1         : out unsigned(address_width-1 downto 0);    address_high2         : out unsigned(address_width-1 downto 0);
      twiddle_address1      : out unsigned(address_width-1 downto 0);
      twiddle_address2      : out unsigned(address_width-1 downto 0);
      twiddle_address3      : out unsigned(address_width-1 downto 0);
      mem_en                : out std_logic;
      pipe_en               : out std_logic;
      memA_wen              : out std_logic;
      memB_wen              : out std_logic;
      stage_finish          : out std_logic;
      positionToBlock       : out unsigned(block_width-1 downto 0);
      fft_done              : out std_logic
    );
  end component;

  component dual_port_memory is
    generic(
      data_width    : integer := 32;
      address_width : integer := 10
    );
    port(
      clk      : in std_logic;
      reset    : in std_logic; --remove for synthesis
      dataA : in signed(data_width-1 downto 0);
      dataB : in signed(data_width -1 downto 0);
      addressA : in unsigned(address_width-1 downto 0);
      addressB : in unsigned(address_width-1 downto 0);
      memEnable: in std_logic;
      writeAEn : in std_logic;
      writeBEn : in std_logic;
      dataAOut : out signed(data_width-1 downto 0);
      dataBOut : out signed(data_width-1 downto 0)
    );
  end component;

  component dual_port_memory1 is
    generic(
      data_width    : integer := 32;
      address_width : integer := 10
    );
    port(
      clk      : in std_logic;
      reset    : in std_logic; --remove for synthesis
      dataA : in signed(data_width-1 downto 0);
      dataB : in signed(data_width -1 downto 0);
      addressA : in unsigned(address_width-1 downto 0);
      addressB : in unsigned(address_width-1 downto 0);
      memEnable: in std_logic;
      writeAEn : in std_logic;
      writeBEn : in std_logic;
      dataAOut : out signed(data_width-1 downto 0);
      dataBOut : out signed(data_width-1 downto 0)
    );
  end component;

  component dual_port_memory2 is
    generic(
      data_width    : integer := 32;
      address_width : integer := 10
    );
    port(
      clk      : in std_logic;
      reset    : in std_logic; --remove for synthesis
      dataA : in signed(data_width-1 downto 0);
      dataB : in signed(data_width -1 downto 0);
      addressA : in unsigned(address_width-1 downto 0);
      addressB : in unsigned(address_width-1 downto 0);
      memEnable: in std_logic;
      writeAEn : in std_logic;
      writeBEn : in std_logic;
      dataAOut : out signed(data_width-1 downto 0);
      dataBOut : out signed(data_width-1 downto 0)
    );
  end component;

  component dual_port_memory3 is
    generic(
      data_width    : integer := 32;
      address_width : integer := 10
    );
    port(
      clk      : in std_logic;
      reset    : in std_logic; --remove for synthesis
      dataA : in signed(data_width-1 downto 0);
      dataB : in signed(data_width -1 downto 0);
      addressA : in unsigned(address_width-1 downto 0);
      addressB : in unsigned(address_width-1 downto 0);
      memEnable: in std_logic;
      writeAEn : in std_logic;
      writeBEn : in std_logic;
      dataAOut : out signed(data_width-1 downto 0);
      dataBOut : out signed(data_width-1 downto 0)
    );
  end component;

  component single_port_memory is
    generic(
      data_width    : integer := 32;
      address_width : integer := 10
    );
    port(
      clk       : in std_logic;
      reset     : in std_logic;
      dataA     : in signed(data_width-1 downto 0);
      addressA  : in unsigned(address_width-1 downto 0);
      memEnable : in std_logic;
      writeAEn  : in std_logic;
      dataAOut  : out signed(data_width-1 downto 0)
    );
  end component;

  component memRouter
    generic(
      address_width : integer := 10;
      data_width    : integer := 32;
      block_width   : integer := 3
    );
    port(
      clk                          : in std_logic;
      reset                        : in std_logic;
      writeAEn                     : in std_logic;
      radix_type                   : in std_logic;
      positionToBlock              : in unsigned(block_width - 1 downto 0); address_low1                 : in unsigned(address_width - 1 downto 0);
      address_low2                 : in unsigned(address_width - 1 downto 0);
      address_high1                : in unsigned(address_width - 1 downto 0);
      address_high2                : in unsigned(address_width - 1 downto 0);

      destAddressLow1              : in unsigned(address_width - 1 downto 0);
      destAddressLow2              : in unsigned(address_width - 1 downto 0);
      destAddressHigh1             : in unsigned(address_width - 1 downto 0);
      destAddressHigh2             : in unsigned(address_width - 1 downto 0);

      memAAddressA                 : out unsigned(address_width - 1 downto 0);
      memAAddressB                 : out unsigned(address_width - 1 downto 0);
      memBAddressA                 : out unsigned(address_width - 1 downto 0);
      memBAddressB                 : out unsigned(address_width - 1 downto 0);
      memCAddressA                 : out unsigned(address_width - 1 downto 0);
      memCAddressB                 : out unsigned(address_width - 1 downto 0);
      memDAddressA                 : out unsigned(address_width - 1 downto 0);
      memDAddressB                 : out unsigned(address_width - 1 downto 0);

      fromMemADataA                : in signed(data_width-1 downto 0);
      fromMemADataB                : in signed(data_width-1 downto 0);
      fromMemBDataA                : in signed(data_width-1 downto 0);
      fromMemBDataB                : in signed(data_width-1 downto 0);
      fromMemCDataA                : in signed(data_width-1 downto 0);
      fromMemCDataB                : in signed(data_width-1 downto 0);
      fromMemDDataA                : in signed(data_width-1 downto 0);
      fromMemDDataB                : in signed(data_width-1 downto 0);

      toMemDataAOut1               : out signed(data_width-1 downto 0);
      toMemDataBOut1               : out signed(data_width-1 downto 0);
      toMemDataAOut2               : out signed(data_width-1 downto 0);
      toMemDataBOut2               : out signed(data_width-1 downto 0);

      firstOperandReal             : out signed(data_width/2-1 downto 0);
      firstOperandImaginary        : out signed(data_width/2-1 downto 0);
      secondOperandReal            : out signed(data_width/2-1 downto 0);
      secondOperandImaginary       : out signed(data_width/2-1 downto 0);
      thirdOperandReal             : out signed(data_width/2-1 downto 0);
      thirdOperandImaginary        : out signed(data_width/2-1 downto 0);
      fourthOperandReal            : out signed(data_width/2-1 downto 0);
      fourthOperandImaginary       : out signed(data_width/2-1 downto 0);

      firstOpRealPipelineOut       : in signed(data_width/2-1 downto 0);
      firstOpImaginaryPipelineOut  : in signed(data_width/2-1 downto 0);
      secondOpRealPipelineOut      : in signed(data_width/2-1 downto 0);
      secondOpImaginaryPipelineOut : in signed(data_width/2-1 downto 0);
      thirdOpRealPipelineOut       : in signed(data_width/2-1 downto 0);
      thirdOpImaginaryPipelineOut : in signed(data_width/2-1 downto 0);
      fourthOpRealPipelineOut      : in signed(data_width/2-1 downto 0);
      fourthOpImaginaryPipelineOut : in signed(data_width/2-1 downto 0)
    );
  end component;
end fft_pkg;

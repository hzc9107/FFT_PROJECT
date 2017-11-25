library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fft_pkg is
  component controller is
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

  component pipeline is
    generic(
      data_width    : integer := 16;
      address_width : integer := 10
    );
    port(
      clk : in std_logic;
      addStageEnable            : in std_logic;
      multStageEnable           : in std_logic;
      reset                     : in std_logic;
      writeEnable               : in std_logic;
      firstOperandReal          : in signed(data_width-1 downto 0);
      firstOperandImaginary     : in signed(data_width-1 downto 0);
      secondOperandReal         : in signed(data_width-1 downto 0);
      secondOperandImaginary    : in signed(data_width-1 downto 0);
      twiddleFactorReal         : in signed(data_width-1 downto 0);
      twiddleFactorImaginary    : in signed(data_width-1 downto 0);
      destAddressInLow          : in unsigned(address_width-1 downto 0);
      destAddressInHigh         : in unsigned(address_width-1 downto 0);
      firstOperandOutReal       : out signed(data_width-1 downto 0);
      firstOperandOutImaginary  : out signed(data_width-1 downto 0);
      secondOperandOutReal      : out signed(data_width-1 downto 0);
      secondOperandOutImaginary : out signed(data_width-1 downto 0);
      destAddressOutLow         : out unsigned(address_width-1 downto 0);
      destAddressOutHigh        : out unsigned(address_width-1 downto 0);
      writeEnableOut            : out std_logic
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
end fft_pkg;

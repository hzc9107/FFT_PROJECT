library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeline is
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
end pipeline;

architecture pipeline_arch of pipeline is
  signal multStageFirstOperandReal      : signed(data_width-1 downto 0);
  signal multStageFirstOperandImaginary : signed(data_width-1 downto 0);
  signal multStageResultReal            : signed(data_width-1 downto 0);
  signal multStageResultImaginary       : signed(data_width-1 downto 0);
  signal multStageResultImaginaryReal   : signed(data_width-1 downto 0);
  signal multStageResultRealImaginary   : signed(data_width-1 downto 0);
  signal multStageDestAddressLow        : unsigned(address_width-1 downto 0);
  signal multStageDestAddressHigh       : unsigned(address_width-1 downto 0);
  signal buffStageDestAddressLow        : unsigned(address_width-1 downto 0);
  signal buffStageDestAddressHigh       : unsigned(address_width-1 downto 0);
  signal multStageWriteEnable           : std_logic;
  signal buffStageWriteEnable           : std_logic;

  signal multiplication1                : signed(2*data_width-1 downto 0);
  signal multiplication2                : signed(2*data_width-1 downto 0);
  signal multiplication3                : signed(2*data_width-1 downto 0);
  signal multiplication4                : signed(2*data_width-1 downto 0);

  signal tempSubstract                  : signed(data_width-1 downto 0);
  signal tempAdd                        : signed(data_width-1 downto 0);

begin
  MULT_STAGE : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        multStageFirstOperandReal      <= (others => '0');
        multStageFirstOperandImaginary <= (others => '0');
        multStageResultReal            <= (others => '0');
        multStageResultImaginary       <= (others => '0');
        multStageResultImaginaryReal   <= (others => '0');
        multStageResultRealImaginary   <= (others => '0');
        multStageWriteEnable           <= '0';
        multStageDestAddressHigh       <= (others => '0');
        multStageDestAddressLow        <= (others => '0');
      elsif multStageEnable = '1' then
        multStageFirstOperandReal      <= firstOperandReal;
        multStageFirstOperandImaginary <= firstOperandImaginary;
        multStageDestAddressLow        <= buffStageDestAddressLow;
        multStageDestAddressHigh       <= buffStageDestAddressHigh;

        multStageWriteEnable          <= buffStageWriteEnable;

        if twiddleFactorReal /= to_signed(0, twiddleFactorReal'length) and twiddleFactorImaginary /= to_signed(0, twiddleFactorImaginary'length) then
          multStageResultReal          <= multiplication1(2*data_width-2 downto data_width-1);

          multStageResultImaginary     <= multiplication2(2*data_width-2 downto data_width-1);

          multStageResultImaginaryReal <= multiplication3(2*data_width-2 downto data_width-1);

          multStageResultRealImaginary <= multiplication4(2*data_width-2 downto data_width-1);
        elsif twiddleFactorReal = to_signed(0, twiddleFactorReal'length) then
              multStageResultReal          <= to_signed(0, multStageResultImaginaryReal'length);
              multStageResultImaginary     <= secondOperandImaginary;
              multStageResultRealImaginary <= not(secondOperandReal) + to_signed(1, multStageResultImaginary);
              multStageResultImaginaryReal <=
                              to_signed(0, multStageResultImaginaryReal'length);
        else
            multStageResultReal          <= secondOperandReal;
            multStageResultImaginary     <= to_signed(0, multStageResultRealImaginary'length);
            multStageResultRealImaginary <=
                            to_signed(0, multStageResultRealImaginary'length);
            multStageResultImaginaryReal <= secondOperandImaginary;

        end if;
      end if;
    end if;
  end process;

  ADD_STAGE : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        firstOperandOutReal       <= to_signed(0, firstOperandOutReal'length);
        firstOperandOutImaginary  <= to_signed(0, firstOperandOutImaginary'length);
        secondOperandOutReal      <= to_signed(0, secondOperandOutReal'length);
        secondOperandOutImaginary <= to_signed(0, secondOperandOutImaginary'length);
        destAddressOutLow         <= to_unsigned(0, destAddressOutLow'length);
        destAddressOutHigh        <= to_unsigned(0, destAddressOutHigh'length);
        writeEnableOut            <= '0';
      else
        if addStageEnable = '1' then
          firstOperandOutReal       <= multStageFirstOperandReal + multStageResultReal - multStageResultImaginary;

          firstOperandOutImaginary  <= multStageFirstOperandImaginary + multStageResultImaginaryReal + multStageResultRealImaginary;

          secondOperandOutReal      <= multStageFirstOperandReal - multStageResultReal + multStageResultImaginary;

          secondOperandOutImaginary <= multStageFirstOperandImaginary - multStageResultImaginaryReal - multStageResultRealImaginary;
          destAddressOutLow  <= multStageDestAddressLow;
          destAddressOutHigh <= multStageDestAddressHigh;

          writeEnableOut     <=  multStageWriteEnable;
        end if;
      end if;
    end if;
  end process;

  BUFF_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        buffStageWriteEnable <= '0';

        buffStageDestAddressLow <= to_unsigned(0, buffStageDestAddressLow'length);

        buffStageDestAddressHigh <= to_unsigned(0, buffStageDestAddressHigh'length);
      else
        buffStageWriteEnable      <= writeEnable;
        buffStageDestAddressLow   <= destAddressInLow;
        buffStageDestAddressHigh  <= destAddressInHigh;
      end if;
    end if;
  end process;

    multiplication1 <= secondOperandReal * twiddleFactorReal;
    multiplication2 <= secondOperandImaginary * twiddleFactorImaginary;
    multiplication3 <= secondOperandImaginary * twiddleFactorReal;
    multiplication4 <= secondOperandReal * twiddleFactorImaginary;
end pipeline_arch;

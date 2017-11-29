library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeline is
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
end pipeline;

architecture pipeline_arch of pipeline is
  signal multStageFirstOperandReal      : signed(data_width-1 downto 0);
  signal multStageFirstOperandImaginary : signed(data_width-1 downto 0);
  signal multStageResultReal1            : signed(data_width-1 downto 0);
  signal multStageResultImaginary1       : signed(data_width-1 downto 0);
  signal multStageResultImaginaryReal1   : signed(data_width-1 downto 0);
  signal multStageResultRealImaginary1   : signed(data_width-1 downto 0);
  signal multStageResultReal2            : signed(data_width-1 downto 0);
  signal multStageResultImaginary2       : signed(data_width-1 downto 0);
  signal multStageResultImaginaryReal2   : signed(data_width-1 downto 0);
  signal multStageResultRealImaginary2   : signed(data_width-1 downto 0);
  signal multStageResultReal3            : signed(data_width-1 downto 0);
  signal multStageResultImaginary3       : signed(data_width-1 downto 0);
  signal multStageResultImaginaryReal3   : signed(data_width-1 downto 0);
  signal multStageResultRealImaginary3   : signed(data_width-1 downto 0);

  signal multStageDestAddressLow1       : unsigned(address_width-1 downto 0);
  signal multStageDestAddressHigh1      : unsigned(address_width-1 downto 0);
  signal multStageDestAddressLow2       : unsigned(address_width-1 downto 0);
  signal multStageDestAddressHigh2      : unsigned(address_width-1 downto 0);
  signal multStageWriteEnable           : std_logic;

  signal buffStageDestAddressLow1       : unsigned(address_width-1 downto 0);
  signal buffStageDestAddressHigh1      : unsigned(address_width-1 downto 0);
  signal buffStageDestAddressLow2       : unsigned(address_width-1 downto 0);
  signal buffStageDestAddressHigh2      : unsigned(address_width-1 downto 0);
  signal buffStageWriteEnable           : std_logic;

  signal multiplication1                : signed(2*data_width-1 downto 0);
  signal multiplication2                : signed(2*data_width-1 downto 0);
  signal multiplication3                : signed(2*data_width-1 downto 0);
  signal multiplication4                : signed(2*data_width-1 downto 0);
  signal multiplication5                : signed(2*data_width-1 downto 0);
  signal multiplication6                : signed(2*data_width-1 downto 0);
  signal multiplication7                : signed(2*data_width-1 downto 0);
  signal multiplication8                : signed(2*data_width-1 downto 0);
  signal multiplication9                : signed(2*data_width-1 downto 0);
  signal multiplication10               : signed(2*data_width-1 downto 0);
  signal multiplication11               : signed(2*data_width-1 downto 0);
  signal multiplication12               : signed(2*data_width-1 downto 0);
  signal tempSubstract                  : signed(data_width-1 downto 0);
  signal tempAdd                        : signed(data_width-1 downto 0);

begin
  MULT_STAGE : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        multStageFirstOperandReal       <= (others => '0');
        multStageFirstOperandImaginary  <= (others => '0');
        multStageResultReal1            <= (others => '0');
        multStageResultImaginary1       <= (others => '0');
        multStageResultImaginaryReal1   <= (others => '0');
        multStageResultRealImaginary1   <= (others => '0');
        multStageResultReal2            <= (others => '0');
        multStageResultImaginary2       <= (others => '0');
        multStageResultImaginaryReal2   <= (others => '0');
        multStageResultRealImaginary2   <= (others => '0');
        multStageResultReal3            <= (others => '0');
        multStageResultImaginary3       <= (others => '0');
        multStageResultImaginaryReal3   <= (others => '0');
        multStageResultRealImaginary3   <= (others => '0');

        multStageWriteEnable           <= '0';
        multStageDestAddressHigh1      <= (others => '0');
        multStageDestAddressLow1       <= (others => '0');
        multStageDestAddressHigh2      <= (others => '0');
        multStageDestAddressLow2       <= (others => '0');

      elsif multStageEnable = '1' then
        multStageFirstOperandReal      <= firstOperandReal;
        multStageFirstOperandImaginary <= firstOperandImaginary;
        multStageDestAddressLow1       <= buffStageDestAddressLow1;
        multStageDestAddressHigh1      <= buffStageDestAddressHigh1;
        multStageDestAddressLow2       <= buffStageDestAddressLow2;
        multStageDestAddressHigh2      <= buffStageDestAddressHigh2;

        multStageWriteEnable          <= buffStageWriteEnable;

        if twiddleFactorReal /= to_signed(0, twiddleFactorReal'length) and twiddleFactorImaginary /= to_signed(0, twiddleFactorImaginary'length) then
          multStageResultReal1          <= multiplication1(2*data_width-2 downto data_width-1);

          multStageResultImaginary1     <= multiplication2(2*data_width-2 downto data_width-1);

          multStageResultImaginaryReal1 <= multiplication3(2*data_width-2 downto data_width-1);

          multStageResultRealImaginary1 <= multiplication4(2*data_width-2 downto data_width-1);
        elsif twiddleFactorReal = to_signed(0, twiddleFactorReal'length) then
          if twiddleFactorImaginary = to_signed(-1, twiddleFactorImaginary'length) then
              multStageResultReal1          <= to_signed(0, multStageResultImaginaryReal1'length);
              multStageResultImaginary1     <= not(secondOperandImaginary) +
               to_signed(1, multStageResultImaginary1'length);
              multStageResultRealImaginary1 <= not(secondOperandReal) + to_signed(1, multStageResultImaginary1'length);
              multStageResultImaginaryReal1 <=
                              to_signed(0, multStageResultImaginaryReal1'length);
          else
            multStageResultReal1          <= to_signed(0, multStageResultImaginaryReal1'length);
            multStageResultImaginary1     <= secondOperandImaginary;
            multStageResultRealImaginary1 <= secondOperandReal;
            multStageResultImaginaryReal1 <=
                            to_signed(0, multStageResultImaginaryReal1'length);
          end if;
        else
          if twiddleFactorReal = to_signed(1, twiddleFactorReal'length) then
            multStageResultReal1          <= secondOperandReal;
            multStageResultImaginary1     <= to_signed(0, multStageResultRealImaginary1'length);
            multStageResultRealImaginary1 <=
                            to_signed(0, multStageResultRealImaginary1'length);
            multStageResultImaginaryReal1 <= secondOperandImaginary;
          else
            multStageResultReal1          <= not(secondOperandReal) + to_signed(1, multStageResultReal1'length);
            multStageResultImaginary1     <= to_signed(0, multStageResultRealImaginary1'length);
            multStageResultRealImaginary1 <=
                            to_signed(0, multStageResultRealImaginary1'length);
            multStageResultImaginaryReal1 <= not(secondOperandImaginary) + to_signed(1, multStageResultImaginaryReal1'length);

          end if;
        end if;

        if twiddleFactor2Real /= to_signed(0, twiddleFactor2Real'length) and twiddleFactor2Imaginary /= to_signed(0, twiddleFactor2Imaginary'length) then
          multStageResultReal2          <= multiplication5(2*data_width-2 downto data_width-1);

          multStageResultImaginary2     <= multiplication6(2*data_width-2 downto data_width-1);

          multStageResultImaginaryReal2 <= multiplication7(2*data_width-2 downto data_width-1);

          multStageResultRealImaginary2 <= multiplication8(2*data_width-2 downto data_width-1);
        elsif twiddleFactor2Real = to_signed(0, twiddleFactor2Real'length) then
          if twiddleFactor2Imaginary = to_signed(-1, twiddleFactor2Imaginary'length) then
            multStageResultReal2          <= to_signed(0, multStageResultImaginaryReal2'length);
            multStageResultImaginary2     <= not(thirdOperandImaginary) +
             to_signed(1, multStageResultImaginary2'length);
            multStageResultRealImaginary2 <= not(thirdOperandReal) + to_signed(1, multStageResultImaginary2'length);
            multStageResultImaginaryReal2 <=
                            to_signed(0, multStageResultImaginaryReal2'length);
          else
            multStageResultReal2          <= to_signed(0, multStageResultImaginaryReal2'length);
            multStageResultImaginary2     <= thirdOperandImaginary;
            multStageResultRealImaginary2 <= thirdOperandReal;
            multStageResultImaginaryReal2 <=
                            to_signed(0, multStageResultImaginaryReal2'length);
          end if;
        else
          if twiddleFactor2Real = to_signed(1, twiddleFactor2Real'length) then
            multStageResultReal2          <= thirdOperandReal;
            multStageResultImaginary2     <= to_signed(0, multStageResultRealImaginary2'length);
            multStageResultRealImaginary2 <=
                            to_signed(0, multStageResultRealImaginary2'length);
            multStageResultImaginaryReal2 <= thirdOperandImaginary;
          else
            multStageResultReal2          <= not(thirdOperandReal) + to_signed(1, multStageResultReal2'length);
            multStageResultImaginary2     <= to_signed(0, multStageResultRealImaginary2'length);
            multStageResultRealImaginary2 <=
                            to_signed(0, multStageResultRealImaginary2'length);
            multStageResultImaginaryReal2 <= not(thirdOperandImaginary) + to_signed(1, multStageResultImaginaryReal2'length);
          end if;
        end if;

        if twiddleFactor3Real /= to_signed(0, twiddleFactor3Real'length) and twiddleFactor3Imaginary /= to_signed(0, twiddleFactor3Imaginary'length) then
          multStageResultReal3          <= multiplication9(2*data_width-2 downto data_width-1);

          multStageResultImaginary3     <= multiplication10(2*data_width-2 downto data_width-1);

          multStageResultImaginaryReal3 <= multiplication11(2*data_width-2 downto data_width-1);

          multStageResultRealImaginary3 <= multiplication11(2*data_width-2 downto data_width-1);
        elsif twiddleFactor3Real = to_signed(0, twiddleFactor3Real'length) then
          if twiddleFactor3Imaginary = to_signed(-1, twiddleFactor3Imaginary'length) then
            multStageResultReal3          <= to_signed(0, multStageResultImaginaryReal3'length);
            multStageResultImaginary3     <= not(fourthOperandImaginary) +
             to_signed(1, multStageResultImaginary3'length);
            multStageResultRealImaginary3 <= not(fourthOperandReal) + to_signed(1, multStageResultImaginary3'length);
            multStageResultImaginaryReal3 <=
                            to_signed(0, multStageResultImaginaryReal3'length);
          else
            multStageResultReal3          <= to_signed(0, multStageResultImaginaryReal3'length);
            multStageResultImaginary3     <= fourthOperandImaginary;
            multStageResultRealImaginary3 <= fourthOperandReal;
            multStageResultImaginaryReal3 <=
                            to_signed(0, multStageResultImaginaryReal3'length);
          end if;

        else
          if twiddleFactor3Real = to_signed(1, twiddleFactor3Real'length) then
            multStageResultReal3          <= fourthOperandReal;
            multStageResultImaginary3     <= to_signed(0, multStageResultRealImaginary3'length);
            multStageResultRealImaginary3 <=
                            to_signed(0, multStageResultRealImaginary3'length);
            multStageResultImaginaryReal3 <= fourthOperandImaginary;
          else
            multStageResultReal3          <= not(fourthOperandReal) + to_signed(1, multStageResultReal3'length);
            multStageResultImaginary3     <= to_signed(0, multStageResultRealImaginary3'length);
            multStageResultRealImaginary3 <=
                            to_signed(0, multStageResultRealImaginary3'length);
            multStageResultImaginaryReal3 <= not(fourthOperandImaginary) + to_signed(1, multStageResultImaginaryReal3'length);
          end if;

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
        thirdOperandOutReal       <= to_signed(0, thirdOperandOutReal'length);
        thirdOperandOutImaginary  <= to_signed(0, thirdOperandOutImaginary'length);
        fourthOperandOutReal      <= to_signed(0, fourthOperandOutReal'length);
        fourthOperandOutImaginary <= to_signed(0, fourthOperandOutImaginary'length);
        destAddressOutLow1         <= to_unsigned(0, destAddressOutLow1'length);
        destAddressOutHigh1        <= to_unsigned(0, destAddressOutHigh1'length);
        destAddressOutLow2         <= to_unsigned(0, destAddressOutLow2'length);
        destAddressOutHigh2        <= to_unsigned(0, destAddressOutHigh2'length);
        writeEnableOut            <= '0';
      else
        if addStageEnable = '1' then
          if radix_type = '1' then
            firstOperandOutReal       <= multStageFirstOperandReal + multStageResultReal1 - multStageResultImaginary1;

            firstOperandOutImaginary  <= multStageFirstOperandImaginary + multStageResultImaginaryReal1 + multStageResultRealImaginary1;

            secondOperandOutReal      <= multStageFirstOperandReal - multStageResultReal1 + multStageResultImaginary1;

            secondOperandOutImaginary <= multStageFirstOperandImaginary - multStageResultImaginaryReal1 - multStageResultRealImaginary1;

            thirdOperandOutReal         <= (others => '0');
            thirdOperandOutImaginary       <= (others => '0');
            fourthOperandOutReal        <= (others => '0');
            fourthOperandOutImaginary  <= (others => '0');
          else
            firstOperandOutReal <= multStageFirstOperandReal + multStageResultReal1 - multStageResultImaginary1 + multStageResultReal2 - multStageResultImaginary2 +
            multStageResultReal3 - multStageResultImaginary3;

            firstOperandOutImaginary <= multStageFirstOperandImaginary + multStageResultRealImaginary1 + multStageResultImaginary1 + multStageResultRealImaginary2 + multStageResultImaginary2 + multStageResultRealImaginary3 + multStageResultImaginary3;

            secondOperandOutReal <= multStageFirstOperandReal + (multStageResultRealImaginary1 + multStageResultImaginary1) - (multStageResultReal2 - multStageResultImaginary2) - (multStageResultRealImaginary3 + multStageResultImaginaryReal3);

            secondOperandOutImaginary <= multStageFirstOperandImaginary - (multStageResultReal1 - multStageResultImaginary1) - (multStageResultRealImaginary2 + multStageResultImaginaryReal2) + (multStageResultReal3 - multStageResultImaginary3);

            thirdOperandOutReal <= multStageFirstOperandReal - (multStageResultReal1 - multStageResultImaginary1) + multStageResultReal2 - multStageResultImaginary2 -
            (multStageResultReal3 - multStageResultImaginary3);

            thirdOperandOutImaginary <= multStageFirstOperandImaginary - multStageResultRealImaginary1 - multStageResultImaginary1 + multStageResultRealImaginary2 + multStageResultImaginary2 - multStageResultRealImaginary3 - multStageResultImaginary3;

            fourthOperandOutReal <= multStageFirstOperandReal - (multStageResultRealImaginary1 + multStageResultImaginary1) - (multStageResultReal2 - multStageResultImaginary2) + (multStageResultRealImaginary3 + multStageResultImaginaryReal3);

            fourthOperandOutImaginary <= multStageFirstOperandImaginary + (multStageResultReal1 - multStageResultImaginary1) - (multStageResultRealImaginary2 + multStageResultImaginaryReal2) - (multStageResultReal3 - multStageResultImaginary3);

          end if;
          destAddressOutLow1  <= multStageDestAddressLow1;
          destAddressOutHigh1 <= multStageDestAddressHigh1;
          destAddressOutLow2  <= multStageDestAddressLow2;
          destAddressOutHigh2 <= multStageDestAddressHigh2;
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

        buffStageDestAddressLow1 <= to_unsigned(0, buffStageDestAddressLow1'length);

        buffStageDestAddressHigh1 <= to_unsigned(0, buffStageDestAddressHigh1'length);

        buffStageDestAddressLow2 <= to_unsigned(0, buffStageDestAddressLow2'length);

        buffStageDestAddressHigh2 <= to_unsigned(0, buffStageDestAddressHigh2'length);
      else
        buffStageWriteEnable       <= writeEnable;
        buffStageDestAddressLow1   <= destAddressInLow1;
        buffStageDestAddressHigh1  <= destAddressInHigh1;
        buffStageDestAddressLow2   <= destAddressInLow2;
        buffStageDestAddressHigh2  <= destAddressInHigh2;
      end if;
    end if;
  end process;

    multiplication1 <= secondOperandReal * twiddleFactorReal;
    multiplication2 <= secondOperandImaginary * twiddleFactorImaginary;
    multiplication3 <= secondOperandImaginary * twiddleFactorReal;
    multiplication4 <= secondOperandReal * twiddleFactorImaginary;
    multiplication5 <= thirdOperandReal * twiddleFactor2Real;
    multiplication6 <= thirdOperandImaginary * twiddleFactor2Imaginary;
    multiplication7 <= thirdOperandImaginary * twiddleFactor2Real;
    multiplication8 <= thirdOperandReal * twiddleFactor2Imaginary;
    multiplication9 <= fourthOperandReal * twiddleFactor3Real;
    multiplication10 <= fourthOperandImaginary * twiddleFactor3Imaginary;
    multiplication11 <= fourthOperandImaginary * twiddleFactor3Real;
    multiplication12 <= fourthOperandReal * twiddleFactor3Imaginary;
end pipeline_arch;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memRouter is
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
end memRouter;

architecture Behavioural of memRouter is
  signal address_low1_buff : unsigned(address_width-1 downto 0);
begin

  MEM_ADDRESS_ASSIGN : process(radix_type, destAddressLow1, destAddressLow2, destAddressHigh1, destAddressHigh2, address_low1, address_low2, address_high1, address_high2, writeAEn, positionToBlock)
  begin
    memAAddressA <= (others => '0');
    memAAddressB <= (others => '0');
    memBAddressA <= (others => '0');
    memBAddressB <= (others => '0');
    memCAddressA <= (others => '0');
    memCAddressB <= (others => '0');
    memDAddressA <= (others => '0');
    memDAddressB <= (others => '0');
    if radix_type = '1' then
      if writeAEn = '1' then
        memAAddressA <= destAddressLow1;
        memAAddressB <= destAddressHigh1;
        memBAddressA <= address_low1;
        memBAddressB <= address_high1;
      else
        memAAddressA <= address_low1;
        memAAddressB <= address_high1;
        memBAddressA <= destAddressLow1;
        memBAddressB <= destAddressHigh1;
      end if;
    else
      if writeAEn = '1' then
        case to_integer(positionToBlock) is
          when 1 =>
            if address_low1(2) = address_low1(0) then
              memBAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 1);

              memBAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 1);

              memDAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 1);

              memDAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 1);
            else
              memDAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 1);

              memDAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 1);

              memBAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 1);

              memBAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 1);
            end if;
          when 2 =>
            if address_low1(4) = address_low1(2) then
              memBAddressA(address_width-2 downto 0) <=  address_low1(address_width-1 downto 3) & address_low1(1 downto 0);

              memBAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 3) & address_high1(1 downto 0);

              memDAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 3) & address_low2(1 downto 0);

              memDAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 3) & address_high2(1 downto 0);
            else
              memDAddressA(address_width-2 downto 0) <=  address_low1(address_width-1 downto 3) & address_low1(1 downto 0);

              memDAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 3) & address_high1(1 downto 0);

              memBAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 3) & address_low2(1 downto 0);

              memBAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 3) & address_high2(1 downto 0);
            end if;
          when 3 =>
          if address_low1(6) = address_low1(4) then
            memBAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 5) & address_low1(3 downto 0);

            memBAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 5) & address_high1(3 downto 0);

            memDAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 5) & address_low2(3 downto 0);

            memDAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 5) & address_high2(3 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 5) & address_low1(3 downto 0);

            memDAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 5) & address_high1(3 downto 0);

            memBAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 5) & address_low2(3 downto 0);

            memBAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 5) & address_high2(3 downto 0);
          end if;
          when 4 =>
          if address_low1(8) = address_low1(6) then
            memBAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 7) & address_low1(5 downto 0);

            memBAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 7) & address_high1(5 downto 0);

            memDAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 7) & address_low2(5 downto 0);

            memDAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 7) & address_high2(5 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 7) & address_low1(5 downto 0);

            memDAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 7) & address_high1(5 downto 0);

            memBAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 7) & address_low2(5 downto 0);

            memBAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 7) & address_high2(5 downto 0);
          end if;
          when others =>
            memBAddressA <= (others => '0');

            memBAddressB <= (others => '0');

            memDAddressA <= (others => '0');

            memDAddressB <= (others => '0');
        end case;

        case to_integer(positionToBlock) is
          when 0 =>
            memAAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 1);

            memAAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 1);

            memCAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 1);

            memCAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 1);
          when 1 =>
            if destAddressLow1(2) = destAddressLow1(4) then
              memAAddressA(address_width-2 downto 0) <=  destAddressLow1(address_width-1 downto 3) & destAddressLow1(1 downto 0);

              memAAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 3) & destAddressHigh1(1 downto 0);

              memCAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 3) & destAddressLow2(1 downto 0);

              memCAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 3) & destAddressHigh2(1 downto 0);
            else
              memCAddressA(address_width-2 downto 0) <=  destAddressLow1(address_width-1 downto 3) & destAddressLow1(1 downto 0);

              memCAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 3) & destAddressHigh1(1 downto 0);

              memAAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 3) & destAddressLow2(1 downto 0);

              memAAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 3) & destAddressHigh2(1 downto 0);
            end if;
          when 2 =>
            if destAddressLow1(4) = destAddressLow1(6) then
              memAAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 5) & destAddressLow1(3 downto 0);

              memAAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 5) & destAddressHigh1(3 downto 0);

              memCAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 5) & destAddressLow2(3 downto 0);

              memCAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 5) & destAddressHigh2(3 downto 0);
            else
              memCAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 5) & destAddressLow1(3 downto 0);

              memCAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 5) & destAddressHigh1(3 downto 0);

              memAAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 5) & destAddressLow2(3 downto 0);

              memAAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 5) & destAddressHigh2(3 downto 0);
            end if;
          when 3 =>
          if destAddressLow1(8) = destAddressLow1(6) then
            memAAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 7) & destAddressLow1(5 downto 0);

            memAAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 7) & destAddressHigh1(5 downto 0);

            memCAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 7) & destAddressLow2(5 downto 0);

            memCAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 7) & destAddressHigh2(5 downto 0);
          else
            memCAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 7) & destAddressLow1(5 downto 0);

            memCAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 7) & destAddressHigh1(5 downto 0);

            memAAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 7) & destAddressLow2(5 downto 0);

            memAAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 7) & destAddressHigh2(5 downto 0);
          end if;

          when 4 =>
          if destAddressLow1(0) = destAddressLow1(8) then
            memAAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1) & destAddressLow1(7 downto 0);

            memAAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1) & destAddressHigh1(7 downto 0);

            memCAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1) & destAddressLow2(7 downto 0);

            memCAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1) & destAddressHigh2(7 downto 0);
          else
            memCAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1) & destAddressLow1(7 downto 0);

            memCAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1) & destAddressHigh1(7 downto 0);

            memAAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1) & destAddressLow2(7 downto 0);

            memAAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1) & destAddressHigh2(7 downto 0);
          end if;
          when others =>
            memAAddressA <= (others => '0');

            memAAddressB <= (others => '0');

            memCAddressA <= (others => '0');

            memCAddressB <= (others => '0');
        end case;
      else
        case to_integer(positionToBlock) is
          when 0 =>
            memAAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 1);

            memAAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 1);

            memCAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 1);

            memCAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 1);
          when 1 =>
          if address_low1(2) = address_low1(0) then
            memAAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 1);

            memAAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 1);

            memCAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 1);

            memCAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 1);
          else
            memCAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 1);

            memCAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 1);

            memAAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 1);

            memAAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 1);
          end if;
          when 2 =>
          if address_low1(4) = address_low1(2) then
            memAAddressA(address_width-2 downto 0) <=  address_low1(address_width-1 downto 3) & address_low1(1 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 3) & address_high1(1 downto 0);

            memCAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 3) & address_low2(1 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 3) & address_high2(1 downto 0);
          else
            memCAddressA(address_width-2 downto 0) <=  address_low1(address_width-1 downto 3) & address_low1(1 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 3) & address_high1(1 downto 0);

            memAAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 3) & address_low2(1 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 3) & address_high2(1 downto 0);
          end if;
          when 3 =>
          if address_low1(6) = address_low1(4) then
            memAAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 5) & address_low1(3 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 5) & address_high1(3 downto 0);

            memCAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 5) & address_low2(3 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 5) & address_high2(3 downto 0);
          else
            memCAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 5) & address_low1(3 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 5) & address_high1(3 downto 0);

            memAAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 5) & address_low2(3 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 5) & address_high2(3 downto 0);
          end if;
          when 4 =>
          if address_low1(8) = address_low1(6) then
            memAAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 7) & address_low1(5 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 7) & address_high1(5 downto 0);

            memCAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 7) & address_low2(5 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 7) & address_high2(5 downto 0);
          else
            memCAddressA(address_width-2 downto 0) <= address_low1(address_width-1 downto 7) & address_low1(5 downto 0);

            memCAddressB(address_width-2 downto 0) <= address_high1(address_width-1 downto 7) & address_high1(5 downto 0);

            memAAddressA(address_width-2 downto 0) <= address_low2(address_width-1 downto 7) & address_low2(5 downto 0);

            memAAddressB(address_width-2 downto 0) <= address_high2(address_width-1 downto 7) & address_high2(5 downto 0);
          end if;
          when others =>
            memAAddressA <= (others => '0');

            memAAddressB <= (others => '0');

            memCAddressA <= (others => '0');

            memCAddressB <= (others => '0');
        end case;

        case to_integer(positionToBlock) is
          when 0 =>
          if destAddressLow1(2) = destAddressLow1(0) then
            memBAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 1);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 1);

            memDAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 1);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 1);
          else
            memDAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 1);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 1);

            memBAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 1);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 1);
          end if;

          when 1 =>
          if destAddressLow1(4) = destAddressLow1(2) then
            memBAddressA(address_width-2 downto 0) <=  destAddressLow1(address_width-1 downto 3) & destAddressLow1(1 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 3) & destAddressHigh1(1 downto 0);

            memDAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 3) & destAddressLow2(1 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 3) & destAddressHigh2(1 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <=  destAddressLow1(address_width-1 downto 3) & destAddressLow1(1 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 3) & destAddressHigh1(1 downto 0);

            memBAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 3) & destAddressLow2(1 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 3) & destAddressHigh2(1 downto 0);
          end if;
          when 2 =>
          if destAddressLow1(6) = destAddressLow1(4) then
            memBAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 5) & destAddressLow1(3 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 5) & destAddressHigh1(3 downto 0);

            memDAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 5) & destAddressLow2(3 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 5) & destAddressHigh2(3 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 5) & destAddressLow1(3 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 5) & destAddressHigh1(3 downto 0);

            memBAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 5) & destAddressLow2(3 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 5) & destAddressHigh2(3 downto 0);
          end if;

          when 3 =>
          if destAddressLow1(8) = destAddressLow1(6) then
            memBAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 7) & destAddressLow1(5 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 7) & destAddressHigh1(5 downto 0);

            memDAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 7) & destAddressLow2(5 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 7) & destAddressHigh2(5 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1 downto 7) & destAddressLow1(5 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1 downto 7) & destAddressHigh1(5 downto 0);

            memBAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1 downto 7) & destAddressLow2(5 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1 downto 7) & destAddressHigh2(5 downto 0);
          end if;

          when 4 =>
          if destAddressLow1(0) = destAddressLow1(8) then
            memBAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1) & destAddressLow1(7 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1) & destAddressHigh1(7 downto 0);

            memDAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1) & destAddressLow2(7 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1) & destAddressHigh2(7 downto 0);
          else
            memDAddressA(address_width-2 downto 0) <= destAddressLow1(address_width-1) & destAddressLow1(7 downto 0);

            memDAddressB(address_width-2 downto 0) <= destAddressHigh1(address_width-1) & destAddressHigh1(7 downto 0);

            memBAddressA(address_width-2 downto 0) <= destAddressLow2(address_width-1) & destAddressLow2(7 downto 0);

            memBAddressB(address_width-2 downto 0) <= destAddressHigh2(address_width-1) & destAddressHigh2(7 downto 0);
          end if;
          when others =>
            memBAddressA <= (others => '0');

            memBAddressB <= (others => '0');

            memDAddressA <= (others => '0');

            memDAddressB <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  WRITE_DATA_TO_MEM : process(radix_type, writeAEn, firstOpRealPipelineOut, firstOpImaginaryPipelineOut, secondOpRealPipelineOut, secondOpImaginaryPipelineOut, thirdOpRealPipelineOut, thirdOpImaginaryPipelineOut, fourthOpRealPipelineOut, fourthOpImaginaryPipelineOut, destAddressLow1, positionToBlock)
  begin
    toMemDataAOut1 <= (others => '0');
    toMemDataBOut1 <= (others => '0');
    toMemDataAOut2 <= (others => '0');
    toMemDataBOut2 <= (others => '0');
    if radix_type = '1' then
      toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
      toMemDataBOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
    else
      case to_integer(positionToBlock) is
        when 0 =>
          if destAddressLow1(2) = destAddressLow1(0) then
            toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut1 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut2 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut2 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          else
            toMemDataAOut2 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut2 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut1 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          end if;
        when 1 =>
          if destAddressLow1(4) = destAddressLow1(2) then
            toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut1 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut2 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut2 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          else
            toMemDataAOut2 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut2 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut1 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          end if;
        when 2 =>
          if destAddressLow1(6) = destAddressLow1(4) then
            toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut1 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut2 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut2 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          else
            toMemDataAOut2 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut2 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut1 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          end if;
        when 3 =>
          if destAddressLow1(8) = destAddressLow1(6) then
            toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut1 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut2 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut2 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          else
            toMemDataAOut2 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut2 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut1 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          end if;
        when 4 =>
          if destAddressLow1(0) = destAddressLow1(8) then
            toMemDataAOut1 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut1 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut2 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut2 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          else
            toMemDataAOut2 <= firstOpRealPipelineOut & firstOpImaginaryPipelineOut;
            toMemDataBOut2 <= thirdOpRealPipelineOut & thirdOpImaginaryPipelineOut;
            toMemDataAOut1 <= secondOpRealPipelineOut & secondOpImaginaryPipelineOut;
            toMemDataBOut1 <= fourthOpRealPipelineOut & fourthOpImaginaryPipelineOut;
          end if;
          when others =>
          toMemDataAOut2 <= (others => '0');
          toMemDataBOut2 <= (others => '0');
          toMemDataAOut1 <= (others => '0');
          toMemDataBOut1 <= (others => '0');
      end case;
    end if;
  end process;

  READ_DATA_FROM_MEMORY : process(radix_type, writeAEn, fromMemADataA, fromMemADataB, fromMemBDataA, fromMemBDataB, fromMemCDataA, fromMemCDataB, fromMemDDataA, fromMemDDataB, address_low1, positionToBlock)
  begin
    firstOperandReal        <= (others => '0');
    firstOperandImaginary   <= (others => '0');
    secondOperandReal       <= (others => '0');
    secondOperandImaginary  <= (others => '0');
    thirdOperandReal        <= (others => '0');
    thirdOperandImaginary   <= (others => '0');
    fourthOperandReal       <= (others => '0');
    fourthOperandImaginary  <= (others => '0');
    if radix_type = '1' then
      if writeAEn = '1' then
        firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
        firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
        secondOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
        secondOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
      else
        firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
        firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
        secondOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
        secondOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
      end if;
    else
      if writeAEn = '1' then
        case to_integer(positionToBlock) is
          when 0 =>
            firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
          when 1 =>
          if address_low1_buff(2) = address_low1_buff(0) then
            firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
          end if;
          when 2 =>
          if address_low1_buff(2) = address_low1_buff(0) then
            firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
          end if;
          when 3 =>
          if address_low1_buff(8) = address_low1_buff(6) then
            firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
          end if;
          when 4 =>
          if address_low1_buff(0) = address_low1_buff(8) then
            firstOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemDDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemDDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemDDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemDDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemBDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemBDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemBDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemBDataB(data_width/2-1 downto 0);
          end if;
          when others =>
            firstOperandReal        <= (others => '0');
            firstOperandImaginary   <= (others => '0');
            thirdOperandReal        <= (others => '0');
            thirdOperandImaginary   <= (others => '0');
            secondOperandReal       <= (others => '0');
            secondOperandImaginary  <= (others => '0');
            fourthOperandReal       <= (others => '0');
            fourthOperandImaginary  <= (others => '0');
        end case;
      else
        case to_integer(positionToBlock) is
          when 0 =>
            firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
          when 1 =>
          if address_low1_buff(2) = address_low1_buff(0) then
            firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
          end if;
          when 2 =>
          if address_low1_buff(4) = address_low1_buff(2) then
            firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
          end if;
          when 3 =>
          if address_low1_buff(6) = address_low1_buff(4) then
            firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
          end if;
          when 4 =>
          if address_low1_buff(8) = address_low1_buff(6) then
            firstOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
          else
            firstOperandReal <= fromMemCDataA(data_width-1 downto data_width/2);
            firstOperandImaginary <= fromMemCDataA(data_width/2-1 downto 0);
            thirdOperandReal <= fromMemCDataB(data_width-1 downto data_width/2);
            thirdOperandImaginary <= fromMemCDataB(data_width/2-1 downto 0);
            secondOperandReal <= fromMemADataA(data_width-1 downto data_width/2);
            secondOperandImaginary <= fromMemADataA(data_width/2-1 downto 0);
            fourthOperandReal <= fromMemADataB(data_width-1 downto data_width/2);
            fourthOperandImaginary <= fromMemADataB(data_width/2-1 downto 0);
          end if;
          when others =>
            firstOperandReal        <= (others => '0');
            firstOperandImaginary   <= (others => '0');
            thirdOperandReal        <= (others => '0');
            thirdOperandImaginary   <= (others => '0');
            secondOperandReal       <= (others => '0');
            secondOperandImaginary  <= (others => '0');
            fourthOperandReal       <= (others => '0');
            fourthOperandImaginary  <= (others => '0');
        end case;
      end if;
    end if;
  end process;

  BUFF_LOW_ADDR : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        address_low1_buff <= (others => '0');
      else
        address_low1_buff <= address_low1;
      end if;
    end if;
  end process;
end Behavioural;

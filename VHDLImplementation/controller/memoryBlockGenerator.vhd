library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity mem_block_generator is
  generic(
    stage_width   : integer := 4;
    block_width   : integer := 3
  );
  port(
    stage_count : in unsigned(stage_width-1 downto 0);
    positionToBlock : out unsigned(block_width-1 downto 0)
  );
end mem_block_generator;

architecture Behavioural of mem_block_generator is
begin
  BLOCK_GEN : process(stage_count)
  begin
    positionToBlock <= (others => '0');
    case to_integer(stage_count) is
      when 0 =>
        positionToBlock   <= to_unsigned(0, positionToBlock'length);
      when 1 =>
        positionToBlock   <= to_unsigned(1, positionToBlock'length);
      when 2 =>
        positionToBlock   <= to_unsigned(2, positionToBlock'length);
      when 3 =>
        positionToBlock   <= to_unsigned(3, positionToBlock'length);
      when 4 =>
        positionToBlock   <= to_unsigned(4, positionToBlock'length);
      when others =>
        positionToBlock <= (others => '0');
    end case;
  end process;
end Behavioural;

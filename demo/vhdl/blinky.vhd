 library IEEE;
 use IEEE.STD_LOGIC_1164.ALL;
 use IEEE.numeric_std.all;
 
 entity blinky is
    port ( 
           CLK_IN : in std_logic;
           RSTn_i : in std_logic;
           RLED1 : out std_logic
    );
 end blinky;
 
 architecture RTL of blinky is
    constant MAX_COUNT : natural := natural(12_000_000.0 / 0.5 - 1.0);
    signal led : std_logic;
 begin

    counter : process(CLK_IN)
        variable count : natural range 0 to MAX_COUNT;
    begin
        if RSTn_i = '0' then
            count := MAX_COUNT;
            led <= '0';
        elsif rising_edge(CLK_IN) then
            if count > 0 then
	            count := count - 1;
            else
			count := MAX_COUNT;
			led <= not led;
         end if;
        end if;
    end process counter;
    
    RLED1 <= led;
 end RTL;

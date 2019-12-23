library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blink_tb is
end blink_tb;

architecture behave of blink_tb is

	/* 12 MHz */
	constant CLOCK_PERIOD : time := 83 ns;
	
	signal CLOCK     : std_logic := '0';
	signal LED_ENABLE    : std_logic := '0';
	signal SWITCH1  : std_logic := '0';
	signal SWITCH2  : std_logic := '0';
	signal LED : std_logic; 

	component blink_cp is
		port(
			clock		: in	std_logic;
			ledEnable	: in	std_logic;
			switch1		: in	std_logic;
			switch2		: in	std_logic;
			led			: out	std_logic);
	end component blink_cp;
	
	for all : blink_cp use entity work.blink(rtl);
	
begin
	uut : blink_cp
		port map(
			clock		=> CLOCK,
			ledEnable	=> LED_ENABLE,
			switch1		=> SWITCH1,
			switch2		=> SWITCH2,
			led			=> LED
		);

	CLK_GEN : process is
	begin
		wait for CLOCK_PERIOD / 2;
		CLOCK <= not CLOCK;
	end process CLK_GEN;
	
	process
	begin
		LED_ENABLE <= '1';
		
		SWITCH1 <= '0';
		SWITCH2 <= '0';
		wait for 0.2 sec;

		SWITCH1 <= '0';
		SWITCH2 <= '1';
		wait for 0.2 sec;

		SWITCH1 <= '1';
		SWITCH2 <= '0';
		wait for 0.2 sec;

		SWITCH1 <= '1';
		SWITCH2 <= '1';
		wait for 0.2 sec;
		
		report "Test bench completed!";
		
/*		std.env.finish;*/
	end process;

end architecture behave;

		

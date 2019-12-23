library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blink is
	port(
		clock		: in	std_logic;
		ledEnable	: in	std_logic;
		switch1		: in	std_logic;
		switch2		: in	std_logic;
		led			: out	std_logic
	);
end blink;

architecture rtl of blink is 

	/* 12 MHz */
	constant FPGA_SPEED : real := 12_000_000.0;
	
	constant CNT_100HZ : natural := natural(FPGA_SPEED / 100.0 * 0.5);
	constant CNT_50HZ : natural := natural(FPGA_SPEED / 50.0 * 0.5);
	constant CNT_10HZ : natural := natural(FPGA_SPEED / 10.0 * 0.5);
	constant CNT_1HZ : natural := natural(FPGA_SPEED * 0.5);
	
	signal counter100 : natural range 0 to CNT_100HZ;
	signal counter50 : natural range 0 to CNT_50HZ;
	signal counter10 : natural range 0 to CNT_10HZ;
	signal counter1 : natural range 0 to CNT_1HZ;
	
	signal state100 : std_logic := '0';
	signal state50 : std_logic := '0';
	signal state10 : std_logic := '0';
	signal state1 : std_logic := '0';
	
	signal ledSelect : std_logic;

begin
	p100 : process(clock) is
	begin
		if rising_edge(clock) then
			if (counter100 = 0) then
				state100 <= not state100;
				counter100 <= CNT_100HZ;
			else
				counter100 <= counter100 - 1;
			end if;
		end if;	
	end process p100;

	p50 : process(clock) is
	begin
		if rising_edge(clock) then
			if (counter50 = 0) then
				state50 <= not state50;
				counter50 <= CNT_50HZ;
			else
				counter50 <= counter50 - 1;
			end if;
		end if;	
	end process p50;
	
	p10 : process(clock) is
	begin
		if rising_edge(clock) then
			if (counter10 = 0) then
				state10 <= not state10;
				counter10 <= CNT_10HZ;
			else
				counter10 <= counter10 - 1;
			end if;
		end if;	
	end process p10;
	
	p1 : process(clock) is
	begin
		if rising_edge(clock) then
			if (counter1 = 0) then
				state1 <= not state1;
				counter1 <= CNT_1HZ;
			else
				counter1 <= counter1 - 1;
			end if;
		end if;	
	end process p1;
	
	ledSelect <= 
		state100 when (switch1 = '0' and switch2 = '0') else
		state50 when (switch1 = '0' and switch2 = '1') else
		state10 when (switch1 = '1' and switch2 = '0') else
		state1; 
		
	led <= ledSelect and ledEnable;	 
end rtl;
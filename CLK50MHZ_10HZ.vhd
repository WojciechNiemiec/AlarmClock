library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK50MHZ_10HZ is
port( CLK50MHZ: in std_logic; --50 MHZ CLOCK signal
		CLK10HZ: out std_logic);
end CLK50MHZ_10HZ;

architecture arch of CLK50MHZ_10HZ is

signal s : std_logic;

begin

	process(CLK50MHZ)
		variable i: integer := 0;
		variable tmp: std_logic := '0';
	begin
		if (rising_edge(CLK50MHZ)) then
			i := i + 1;
			if (i = 2500000) then
				if (tmp = '1') then
					tmp := '0';
				else
					tmp := '1';
				end if;
				i := 0;
			end if;	
		end if;
		CLK10HZ <= tmp; --to się dzieje niezależnie od przepływu procesu
	end process;
		
end arch;
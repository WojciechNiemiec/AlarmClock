library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

entity Alarm_Clock is
port( CLOCK_50: in std_logic; --50 MHZ CLOCK signal
		HEX0: out std_logic_vector(0 to 6);
		HEX1: out std_logic_vector(0 to 6);
		HEX2: out std_logic_vector(0 to 6);
		HEX3: out std_logic_vector(0 to 6);
		HEX4: out std_logic_vector(0 to 6);
		HEX5: out std_logic_vector(0 to 6);
		HEX6: out std_logic_vector(0 to 6);
		HEX7: out std_logic_vector(0 to 6);
		SW: in std_logic_vector(17 downto 0);
		KEY: in std_logic_vector(3 downto 0);
		LEDR: out std_logic_vector(17 downto 0));
end Alarm_Clock

architecture arch of Alarm_Clock is

component CLK50MHZ_1HZ is
port( CLK50MHZ: in std_logic; --50 MHZ CLOCK signal
		CLK1HZ: out std_logic);
end component;

component CLK50MHZ_10HZ is
port( CLK50MHZ: in std_logic;
		CLK10HZ: out std_logic);
end component;

component segdekoder is
port( x:in std_logic_vector(3 downto 0);
		y:out std_logic_vector(6 downto 0));
end component;

signal clk: std_logic;
signal clk1: std_logic;
signal clk2: std_logic;

signal S: std_logic_vector(7 downto 0);
signal M: std_logic_vector(7 downto 0);
signal H: std_logic_vector(7 downto 0);
signal AP: std_logic_vector(6 downto 0);

shared variable i: integer := 0;
shared variable sec: integer :=0;
shared variable min: integer :=0;
shared variable hours: integer :=0;
		
shared variable alarm_min: integer :=0;
shared variable alarm_hours: integer :=0;

shared variable start_min: integer :=0;
shared variable start_hours: integer :=0;

shared variable system: integer :=12;

begin

	HEX0 <= "1111111";
	HEX1 <= AP;

	c1: CLK50MHZ_1HZ port map (CLOCK_50,clk1);
	c2: CLK50MHZ_10HZ port map (CLOCK_50,clk2);
	clk <= (clk1 and not SW(17)) or (clk2 and SW(17));
	
	process(KEY(0))
	begin
		if (falling_edge(KEY(0))) then
			if (SW(16)='1') then
				alarm_min := alarm_min + 1;
			
				if (alarm_min > 59) then
					alarm_min := 0;
				end if;
			end if;
			
			if (SW(15)='1') then
				start_min := start_min + 1;
			
				if (start_min > 59) then
					start_min := 0;
				end if;
			end if;
			
		end if;
	end process;
	
	-----------------------------------
	
	process(KEY(1))
	begin
		if (falling_edge(KEY(1))) then
			if (SW(16)='1') then
				alarm_hours := alarm_hours + 1;
			
				if (alarm_hours > 23) then
					alarm_hours := 0;
				end if;
			end if;
			
			if (SW(15)='1') then
				start_hours := start_hours + 1;
			
				if (start_hours > 23) then
					start_hours := 0;
				end if;
			end if;
		end if;
	end process;
	
	-----------------------------------
	
	process(clk)
		variable lights: std_logic_vector(17 downto 0) := "000000000000000000";
	begin
		if (rising_edge(clk)) then
			
			if (SW(14) = '0') then
				system := 12;
			else
				system := 24;
			end if;
				
			i := i + 1;
			sec := i mod 60;
			min := (i / 60) mod 60;
			hours := (i / 3600) mod system;
			
			if (i = 86400) then
				i := 0;
			end if;
			
			if (SW(15) = '1') then
				i := start_min * 60 + start_hours * 3600;
			end if;
			
		end if;
		
		if (SW(16) = '1') then
			H(7 downto 4) <= conv_std_logic_vector(alarm_hours / 10, 4);
			H(3 downto 0) <= conv_std_logic_vector(alarm_hours mod 10, 4);
			M(7 downto 4) <= conv_std_logic_vector(alarm_min / 10, 4);
			M(3 downto 0) <= conv_std_logic_vector(alarm_min mod 10, 4);
			S(7 downto 4) <= conv_std_logic_vector(0,4);
			S(3 downto 0) <= conv_std_logic_vector(0,4);
		elsif (SW(15) = '1') then
			H(7 downto 4) <= conv_std_logic_vector(start_hours / 10, 4);
			H(3 downto 0) <= conv_std_logic_vector(start_hours mod 10, 4);
			M(7 downto 4) <= conv_std_logic_vector(start_min / 10, 4);
			M(3 downto 0) <= conv_std_logic_vector(start_min mod 10, 4);
			S(7 downto 4) <= conv_std_logic_vector(0,4);
			S(3 downto 0) <= conv_std_logic_vector(0,4);
		else
			H(7 downto 4) <= conv_std_logic_vector(hours / 10, 4);
			H(3 downto 0) <= conv_std_logic_vector(hours mod 10, 4);
			M(7 downto 4) <= conv_std_logic_vector(min / 10, 4);
			M(3 downto 0) <= conv_std_logic_vector(min mod 10, 4);
			S(7 downto 4) <= conv_std_logic_vector(sec / 10, 4);
			S(3 downto 0) <= conv_std_logic_vector(sec mod 10, 4);
		end if;
		
		if (SW(15) = '0' and SW(16) = '0' and SW(14) = '0') then
			if (i > 43200) then
				AP <= "0011000";
			else
				AP <= "0001000";
			end if;
		else
			AP <= "1111111";
		end if;
		
		if (hours = alarm_hours and min = alarm_min) then
			if (i mod 2 = 1) then
				lights := "010101010101010101";
			else
				lights := "101010101010101010";
			end if;
		else
			lights := "000000000000000000";
		end if;
		
		LEDR <= lights;
		
	end process;
	
	b1: segdekoder port map (S(3 downto 0),HEX2);
	b2: segdekoder port map (S(7 downto 4),HEX3);
	b3: segdekoder port map (M(3 downto 0),HEX4);
	b4: segdekoder port map (M(7 downto 4),HEX5);
	b5: segdekoder port map (H(3 downto 0),HEX6);
	b6: segdekoder port map (H(7 downto 4),HEX7);
	
end arch;
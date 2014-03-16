LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY slow_clock IS
	PORT(clock_50MHz, reset : IN STD_LOGIC;
			clock : OUT STD_LOGIC);
END slow_clock;


ARCHITECTURE a OF slow_clock IS

--initalize counter
--signal counter: integer;
signal temp_clock: std_logic;

BEGIN
clock<=temp_clock;

PROCESS (clock_50MHz,reset)
	   variable counter : integer;
	   BEGIN
	   if (reset = '0') then
	     temp_clock<='1';
	     counter:=0;
	     
	    elsif (rising_edge(clock_50MHz)) then
	     
	     if(counter>250000) then
	         counter := 0;
				temp_clock<=not temp_clock;
	     end if;
	     
		  counter:=counter+1;
	   end if;
	   
	   
		END PROCESS;
	
	End a; 
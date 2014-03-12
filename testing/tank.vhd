library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--Additional standard or custom libraries go here 
 
entity tank is 
 port( 
 --Inputs 
 keyboard_clk, keyboard_data, clk : in std_logic; 

 
 --Outputs 
 remainder : out std_logic_vector (5 downto 0); 
 overflow : out std_logic
 ); 
end entity tank; 

architecture structural_combinational of tank is 

component ps2 is 
	port( 	keyboard_clk, keyboard_data, clock_50MHz ,
			reset : in std_logic;
			--read : in std_logic;
			scan_code : out std_logic_vector( 7 downto 0 );
			scan_readyo : out std_logic;
			hist3 : out std_logic_vector(7 downto 0);
			hist2 : out std_logic_vector(7 downto 0);
			hist1 : out std_logic_vector(7 downto 0);
			hist0 : out std_logic_vector(7 downto 0);
			led_seq: out std_logic_vector (55 downto 0)
		);  
end component;

signal scan_code : std_logic_vector(7 downto 0);
signal scan_readyo : std_logic;
signal hist3, hist2, hist1, hist0 : std_logic_vector(7 downto 0);
signal led_seq : std_logic_vector (55 downto 0);



signal T1_position_x  : integer;
signal T1_position_y  : integer;
signal T2_position_x  : integer;
signal T2_position_y  : integer;
signal T1_speed       : integer;
signal T2_speed       : integer;
signal T1_direction   : std_logic;
signal T2_direction   : std_logic;

signal temp_1 : std_logic_vector (5 downto 0);
signal activate : std_logic;
signal reset : std_logic;
signal press : std_logic;
signal T1_shoots : std_logic;
signal T2_shoots : std_logic;
signal T1_bullet_exists : std_logic;
signal T2_bullet_exists : std_logic;
signal T1_bullet_x : integer;
signal T1_bullet_y : integer;

begin 

keyboard_0 : ps2 port map (keyboard_clk, keyboard_data, clk, reset, scan_code, scan_readyo, hist3, hist2, hist1, hist0, led_seq);

key_press : process(hist0) is --see if key is pressed, in which case something may need to get updated
begin
  press <= '1';
end process key_press;


game: process(press,reset,clk) is
  begin
    reset <= '1';    
  if (press='1') then
    press <= '0';
    CASE hist0 IS
			WHEN X"16" =>
				    T1_speed <= 1;
			WHEN X"1E" =>
			      T1_speed <= 2;
			WHEN X"26" =>
			      T1_speed <= 3;
			WHEN X"0D" =>
			  if (hist1=X"F0") then
			      T1_direction <= NOT T1_direction;  --latch?
			  end if;
			WHEN X"69" =>
				    T2_speed <= 1;
			WHEN X"72" =>
			      T2_speed <= 2;
			WHEN X"7A" =>
			      T2_speed <= 3;
			WHEN X"4A" =>
			   if (hist1=X"F0") then
			      T2_direction <= NOT T2_direction;  --latch?
			   end if;
			WHEN X"29" =>  --T1 shoots
			   if (T1_shoots='0') then
			      T1_shoots <= '1';
			   else
			      T1_shoots <= '1';
			   end if;
			WHEN X"59" =>  --T2 shoots
			   if (T2_shoots='0') then
			      T2_shoots <= '1';
			   else
			      T2_shoots <= '1';
			   end if;
			WHEN X"66" => --reset button (backspace)
            reset <= '0';
            T1_direction   <= '1';   T2_direction  <= '0';
            T1_speed       <= 1;     T2_speed      <= 1;
            T1_position_x  <= 315;   T2_position_x <= 315;
            T1_position_y  <= 470;   T2_position_y <= 0;
            T1_shoots      <= '0';   T2_shoots     <= '0';
            T1_bullet_exists <= '0'; T2_bullet_exists <= '0';
            T1_bullet_x      <= 320;
            T1_bullet_y      <= 470-5;
			WHEN others =>
			      null;
	   end CASE;
	   
  elsif (rising_edge(clk)) then
      if (T1_direction='1') then  --right
        if (T1_position_x > 640-10-T1_speed) then --if going to go past end of screen, invert direction
          T1_direction <= '0';
          T1_position_x <= 640-10;
        else
          T1_position_x  <= T1_position_x + T1_speed;
          T1_direction <= '1';
        end if;
        
      else --going left
        if (T1_position_x < T1_speed) then --if going to go past end of screen, invert direction
          T1_direction <= '1';
          T1_position_x <= 0;
        else
          T1_position_x  <= T1_position_x - T1_speed;
          T1_direction <= '0';
        end if;
      end if;
    
    ------------
    
      if (T2_direction='1') then  --right
        if (T2_position_x > 640-10-T2_speed) then --if going to go past end of screen, invert direction
          T2_direction <= '0';
          T2_position_x <= 640-10;
        else
          T2_position_x  <= T2_position_x + T2_speed;
          T2_direction <= '1';
        end if;
        
      else --going left
        if (T2_position_x < T2_speed) then --if going to go past end of screen, invert direction
          T2_direction <= '1';
          T2_position_x <= 0;
        else
          T2_position_x  <= T2_position_x - T2_speed;
          T2_direction <= '0';
        end if;
      end if;
    
      
      T1_shoots <= '0';
            
      if(T1_bullet_exists = '1') then  -- if the bullet exists
        if(T1_bullet_x<10) then
          T1_bullet_exists <= '0';
          T1_bullet_x <= T1_position_x;   --re-hide/delete bullet
          T1_bullet_y <= 470-5;
        else
          T1_bullet_y <= T1_bullet_y - 10;
        end if;
        
      elsif(T1_shoots = '0' and T1_bullet_exists = '0') then --if no command to shoot and bullet does not exist, hide bullet in tank
        T1_bullet_x <= T1_position_x; ---might need to get updated to get new position
      end if;
      
      
      
      
      if (T1_shoots = '1' and T1_bullet_exists='0') then  --if the bullet does not exist and there is a command to shoot
            T1_bullet_exists <= '1';
            T1_bullet_x <= T1_position_x;
            T1_bullet_y <= T1_bullet_y - 10;
      end if;
        
    

    
    
  end if;
    
    
end process game;



end architecture structural_combinational;
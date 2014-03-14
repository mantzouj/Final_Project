library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
--Additional standard or custom libraries go here 
 
entity tank is 
 port( 
 --Inputs 
 keyboard_clk, keyboard_data, clk : in std_logic; 

 
 --Outputs 
			VGA_RED, VGA_GREEN, VGA_BLUE 					: out std_logic_vector(9 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK		: out std_logic
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

component VGA_top_level is
	port(
	    T1_position_x, T1_position_y, T1_bullet_x, T1_bullet_y, T2_position_x, T2_position_y, T2_bullet_x, T2_bullet_y : in integer;
			CLOCK_50 										: in std_logic;
			RESET_N											: in std_logic;
			game_over, winner :in std_logic;
	
			--VGA 
			VGA_RED, VGA_GREEN, VGA_BLUE 					: out std_logic_vector(9 downto 0); 
			HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK		: out std_logic

		);
end component;

component slow_clock IS
	PORT(clock_50MHz, reset : IN STD_LOGIC;
			clock : OUT STD_LOGIC);
END component slow_clock;

signal slow_clk: std_logic;
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
signal winner         : std_logic;
signal game_over      : std_logic;
signal tie            : std_logic;
signal done           : std_logic;

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
signal T2_bullet_x : integer;
signal T2_bullet_y : integer;

begin 

keyboard_0 : ps2 port map (keyboard_clk, keyboard_data, clk, reset, scan_code, scan_readyo, hist3, hist2, hist1, hist0, led_seq);
vga_0 : VGA_top_level port map (T1_position_x, T1_position_y, T1_bullet_x, T1_bullet_y, T2_position_x, T2_position_y, T2_bullet_x, T2_bullet_y, clk, reset, game_over, winner, VGA_RED, VGA_GREEN, VGA_BLUE, HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK);
slow_clock_map: slow_clock port map(clock_50MHz=> clk, reset=>reset, clock=>slow_clk);

key_press : process(hist0,press,done,hist1) is --see if key is pressed, in which case something may need to get updated
begin
  --press <= '1';
  
  --preferred
  
 	if (hist1/=X"F0") then
		done <= '0';
	elsif (done='1') then
		press<='0';
	elsif(hist1=X"F0" and done='0') then
		press <= '1';
		done <= '1';
	end if;

  --end preferred
  
  
    --  --press<='1';     --add press to the sensitivity list
    --  	 --if (press='1' and hist1=X"F0") then
      	--press <= '0';
    --   --end if;
  
         --	press<='0';
      	--if (hist1=X"F0" and press='0') then
      	--	press <= '1';
      -- end if;
  
     --if (press='1') then
     --press <= '0';
      --else
      --press<= '1';
      --end if;
  
end process key_press;


game: process(press,reset,slow_clk) is
  begin
   --asynchrounous 
  reset <= '1';    
  
  if (press='1') then
    --press <= '0';
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
			WHEN X"29" =>  --T1 shoots (space)
			      T1_shoots <= '1';
			WHEN X"59" =>  --T2 shoots (r shift)
			      T2_shoots <= '1';
			WHEN X"66" => --reset button (backspace)
            reset <= '0'; winner <= '0'; game_over <= '0'; tie <= '0';
            T1_direction   <= '1';              T2_direction  <= '0';
            T1_speed       <= 1;                T2_speed      <= 1;
            T1_position_x  <= 320-T_SIZE/2;     T2_position_x <= 320-T_SIZE/2;
            T1_position_y  <= 470;              T2_position_y <= 0;
            T1_shoots      <= '0';              T2_shoots     <= '0';
            T1_bullet_exists <= '0';            T2_bullet_exists <= '0';
            T1_bullet_x    <= 320;              T2_bullet_x   <= 320;
            T1_bullet_y    <= 480-T_SIZE-C_LENGTH;   T2_bullet_y   <= T_SIZE+C_LENGTH-1;
			WHEN others =>
			      null;
	   end CASE;
	   
  elsif (rising_edge(slow_clk)) then
  --synchronous- change states
     
    --Control T1-----------------------------------------------------------    
    
      if (T1_direction='1') then  --right
        if (T1_position_x > 640-T_SIZE-T1_speed) then --if going to go past end of screen, invert direction
          T1_direction <= '0';
          T1_position_x <= 640-T_SIZE;
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
    
    --Control T2-----------------------------------------------------------
    
      if (T2_direction='1') then  --right
        if (T2_position_x > 640-T_SIZE-T2_speed) then --if going to go past end of screen, invert direction
          T2_direction <= '0';
          T2_position_x <= 640-T_SIZE;
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
    
    --Control T1 Bullet-----------------------------------------------------------      

            
      if(T1_bullet_exists = '1') then  -- if the bullet exists
        if(T1_bullet_y<BULLET_TRAVEL) then
          T1_bullet_exists <= '0';
          T1_bullet_x <= T1_position_x+T_SIZE/2;   --re-hide/delete bullet
          T1_bullet_y <= 480-T_SIZE-C_LENGTH; --480-10-5
        else
          T1_bullet_y <= T1_bullet_y - BULLET_TRAVEL;
        end if; 
      elsif(T1_shoots = '0' and T1_bullet_exists = '0') then --if no command to shoot and bullet does not exist, hide bullet in tank
        T1_bullet_x <= T1_position_x+T_SIZE/2; ---might need to get updated to get new position
      end if;
      
      if (T1_shoots = '1' and T1_bullet_exists='0') then  --if the bullet does not exist and there is a command to shoot
            T1_bullet_exists <= '1';
            T1_bullet_x <= T1_position_x+T_SIZE/2;
            T1_bullet_y <= T1_bullet_y - BULLET_TRAVEL;
      end if;
      T1_shoots <= '0';
      
    --Control T2 Bullet-----------------------------------------------------------  

      if(T2_bullet_exists = '1') then  -- if the bullet exists
        if(T2_bullet_y>479-BULLET_TRAVEL) then
          T2_bullet_exists <= '0';
          T2_bullet_x <= T2_position_x+T_SIZE/2;   --re-hide/delete bullet
          T2_bullet_y <= T_SIZE+C_LENGTH;
        else
          T2_bullet_y <= T2_bullet_y + BULLET_TRAVEL;
        end if; 
      elsif(T2_shoots = '0' and T2_bullet_exists = '0') then --if no command to shoot and bullet does not exist, hide bullet in tank
        T2_bullet_x <= T2_position_x+T_SIZE/2; ---might need to get updated to get new position
      end if;
      
      if (T2_shoots = '1' and T2_bullet_exists='0') then  --if the bullet does not exist and there is a command to shoot
            T2_bullet_exists <= '1';
            T2_bullet_x <= T2_position_x+T_SIZE/2;
            T2_bullet_y <= T2_bullet_y + BULLET_TRAVEL;
      end if;
      T2_shoots <= '0';

    --Tank Explosion Test-----------------------------------------------------------
    
    if ((T2_bullet_x >= T1_position_x) and (T2_bullet_x < T1_position_x+T_size) and (T2_bullet_y >= T1_position_y) and (T2_bullet_y < T1_position_y+T_size) and (T1_bullet_x >= T2_position_x) and (T1_bullet_x < T2_position_x+T_size) and (T1_bullet_y >= T2_position_y) and (T1_bullet_y < T2_position_y+T_size)) then
      tie <= '1';
    
    else
      if((T2_bullet_x >= T1_position_x) and (T2_bullet_x < T1_position_x+T_size)) then   --if in x-range
        if ((T2_bullet_y >= T1_position_y) and (T2_bullet_y < T1_position_y+T_size)) then
          game_over <= '1';
          winner <= '1';  
        end if;
      end if;

      if((T1_bullet_x >= T2_position_x) and (T1_bullet_x < T2_position_x+T_size)) then   --if in x-range
        if ((T1_bullet_y >= T2_position_y) and (T1_bullet_y < T2_position_y+T_size)) then
          game_over <= '1';
          winner <= '0';  
        end if;
      end if;    
    
    end if;
    
    
    
    
    
    
    
    
    
    
  end if; -- end rising edge
    
-------    
end process game;



end architecture structural_combinational;
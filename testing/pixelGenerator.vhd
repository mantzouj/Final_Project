library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity pixelGenerator is
	port(
	    T1_position_x, T1_position_y, T1_bullet_x, T1_bullet_y, T2_position_x, T2_position_y, T2_bullet_x, T2_bullet_y : in integer;
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(9 downto 0)
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
constant color_green	 : std_logic_vector(2 downto 0) := "001";
constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
constant color_magenta 	 : std_logic_vector(2 downto 0) := "100";
constant color_cyan 	 : std_logic_vector(2 downto 0) := "101";
constant color_black 	 : std_logic_vector(2 downto 0) := "110";
constant color_white	 : std_logic_vector(2 downto 0) := "111";
	
component colorROM is
	port
	(
		address		: in std_logic_vector (2 downto 0);
		clock		: in std_logic  := '1';
		q			: out std_logic_vector (29 downto 0)
	);
end component colorROM;

signal colorAddress : std_logic_vector (2 downto 0);
signal color        : std_logic_vector (29 downto 0);

signal pixel_row_int, pixel_column_int : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(29 downto 20);
	green_out <= color(19 downto 10);
	blue_out <= color(9 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);

--------------------------------------------------------------------------------------------	

	pixelDraw : process(clk, rst_n) is
	
	begin
		colorAddress <= color_white;	
		if (rst_n = '0') then
			if ((pixel_column_int >= T1_position_x) and (pixel_column_int < T1_position_x+T_size) and (pixel_row_int >= T1_position_y) and (pixel_row_int < T1_position_y+T_size)) then
				colorAddress <= color_blue;
			elsif ((pixel_column_int >= T2_position_x) and (pixel_column_int < T2_position_x+T_size) and (pixel_row_int >= T2_position_y) and (pixel_row_int < T2_position_y+T_size)) then
				colorAddress <= color_red;---------------up to here, 2 tanks are initialized on screen
			elsif (pixel_row_int < 200 and pixel_column_int >= 50) then
				colorAddress <= color_red;
			elsif (pixel_row_int >= 200 and pixel_column_int >= 50) then
				colorAddress <= color_blue;
			else
			end if;  
		
		elsif (rising_edge(clk)) then
		--(0,0) is top left
			--colorAddress <= color_white;
			
			if (pixel_row_int < 200 and pixel_column_int < 50) then
				colorAddress <= color_green;
			elsif (pixel_row_int >= 200 and pixel_column_int < 50) then
				colorAddress <= color_yellow;
			elsif (pixel_row_int < 200 and pixel_column_int >= 50) then
				colorAddress <= color_red;
			elsif (pixel_row_int >= 200 and pixel_column_int >= 50) then
				colorAddress <= color_blue;
			else
				colorAddress <= color_white;
			end if;
			
		end if;
		
	end process pixelDraw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral;		
library ieee;
use ieee.all;
use ieee.std_logic.unsigned.all;

entity main_entity is
	Port (
			...
		);
end main_entity;

architecture main_arch of main_entity
component moj_dalmierz
  port (...);
end component;

component moj_piezo
	port(...);
end component;

component moj_lcd
	port(...);
end component;

signal ivert_hc: std_logic_vector(14 downto to 0);
signal hc_cm: std_logic_vector(4 downto to 0);
signal hc_dm: std_logic_vector(4 downto to 0);
signal hc_m: std_logic_vector(4 downto to 0);

begin;
	dalmierz: moj_dalmierz port map (..., hc_cm, hc_dm, hc_m,...);
	invert_hc <= "11111"&"11111"&"11111" - (hc_m&hc_dm&hc_cm); -- the bigger number the bigger distance, so we need to substract it
	piezo: moj_piezo port map(invert_hc, clk,reset, ...)


end main_arch;
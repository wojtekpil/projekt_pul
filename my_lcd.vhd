library ieee;
use ieee.all;
use ieee.std_logic.unsigned.all;

entity my_lcd is 
	Port(
		RS: out std_logic; -- to hc
		RW: out std_logic;  -- to hc
		E: out: std_logic
		start: in std_logic;  -- from parent
		busy: out std_logic;  -- to parent
		DB: out std_logic_vector(3 downto 0); -- to parent
		clk: in std_logic;
		reset: in std_logic
		);
end my_lcd;
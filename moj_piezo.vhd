library ieee;
use ieee.all;
use ieee.std_logic.unsigned.all;

entity moj_piezo is
	Port (
			freq: in std_logic_vector(14 downto 0);
			clk: in std_logic;
			reset: in std_logic;
			piezo: out std_logic
		);
end moj_piezo;

architecture my_arch_piezo of moj_piezo is
signal counter: std_logic_vector(14 downto 0);
begin

gen_freq: process(clk, reset) 
begin
	if(reset = '0') then 
		counter <= (others => '0');
		piezo <= '0';
	elsif(clk'event AND clk = '1') then
		counter <= counter + "01";
		if(counter < (freq(14 downto 1))) then
			piezo <= '1';
		else 
			piezo <= '0'
		end if;
		if(counter >= freq) then
			counter <= 0;
		end if;
	end if;

end gen_freq;

end my_arch_piezo;
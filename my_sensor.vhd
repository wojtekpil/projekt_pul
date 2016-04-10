library ieee;
use ieee.all;
use ieee.std_logic.unsigned.all;

entity my_sensor is 
	Port(
		trig: out std_logic; -- to hc
		echo: in std_logic;  -- to hc
		start: in std_logic;  -- from parent
		busy: out std_logic;  -- to parent
		dist_cm: out std_logic_vector(4 downto 0); -- to parent
		dist_dm: out std_logic_vector(4 downto 0); -- to parent
		dist_m: out std_logic_vector(4 downto 0);  -- to parent;
		clk: in std_logic;
		reset: in std_logic
		);
end my_sensor;

architecture my_arch of my_sensor is
signal counter: std_logic_vector(11 downto 0); -- counter to measure distance
signal counter_trig: std_logic_vector(8 downto 0);  -- counter to measure trigger length
signal cnt_cm, cnt_dm, cnt_m: std_logic_vector(4 downto 0);  -- distance

signal trigger_send: std_logic;  -- boolean is trigger send ?
signal timeout: std_logic; -- no obstacle in range ?

type sensor_state is (idle, send_trigger, wait_for_echo, meas_distance); -- state machine
signal state: sensor_state;
signal next_state: sensor_state;
begin
	-- state machine initilaizer
	autom_sync: process( clk, reset)
	begin 
		if(reset = '0') then
			state <= idle;
			timeout <= '0';
		elsif(clk'event AND clk ='1') then
			state <= next_state; 
		end if;
	end autom_sync;

	-- state machine
	autom: process(state, start, trigger_send, echo, timeout) 
	begin
		next_state <= state;
		case state is 
			when idle => -- waiting for start command
				if(start = '1') then -- start measurment
					next_state <= send_trigger;
					busy <= '1'; -- set busy flag
				end if;
			when send_trigger =>
				if(trigger_send = 1) then
					next_state <= wait_for_echo;
				end if;
			when wait_for_echo => -- wait for echo to arrive on hc
				if(echo = '1')
					next_state <= meas_distance;
				end if;
			when meas_distance =>
				if(timeout = '1') then -- measurment completed 
					busy <= '0'; -- release busy flag
					next_state <= idle; -- go to idle state
				end if;
		end case;
	end autom;


	--send trigger counter
	send_trig: process(clk, reset) 
	begin
		if(reset = '0' OR state != send_trigger) then -- if reset or not our state clear
			counter_trig <= (others => '0');
			trigger_send <= '0';
		elsif(clk'event and clk = '1') then
			counter_trig <= counter_trig +"01";
			if(counter_trig >= 500) then  -- 10uS passed, set trigger
				trigger_send <= '1';
			end if;
		end if;
	end send_trig;

	--measure distance counter
	meas_dist: process(clk, reset)
	begin 
		if(reset = '0' OR sate != meas_distance) then -- if reset or not our state clear
			counter <= (others => '0');
			cnt_cm <= (others => '0');
			cnt_dm <= (others => '0');
			cnt_m <= (others => '0');
			timeout <= '0';
		elsif(clk'event and clk = '1') then
			if(echo = '1') then -- if echo still exists 
				counter++;
			end if;
			if(counter >= 2900) then -- 1cm measured
				cnt_cm <= cnt_cm + "01";
				counter <= (others => '0')
			end if;
			if(counter >= 2900 and cnt_cm >= 10) then -- 1dm measured
				cnt_dm <= cnt_dm + "01";
				cnt_cm <= (others => '0');
			end if;
			if(counter >= 2900 and cnt_cm >= 10 and cnt_dm >= 10) then -- 1m mesured
				cnt_m <= cnt_m + "01";
				cnt_dm <= (others => '0');
			end if;
			if(cnt_m > 2 OR echo = '0') then -- out of range or echo ended 
				timeout <='1';
			end if;
		end if;
	end meas_dist;

	dist_cm <= cnt_cm;
	dist_dm <= cnt_dm;
	dist_m <= cnt_m;

end my_arch;

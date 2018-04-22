--
--
-- State machine to control trains
--
--

LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY Tcontrol IS
	PORT(
		reset, clock, sensor1, sensor2      : IN std_logic;
		sensor3, sensor4, sensor5, sensor6  : IN std_logic;
		switch1, switch2, switch3, switch4  : OUT std_logic;
		dirA, dirB                          : OUT std_logic_vector(1 DOWNTO 0)
	);
END Tcontrol;


ARCHITECTURE a OF Tcontrol IS
	-- We create a new TYPE called STATE_TYPE that is only allowed
	-- to have the values specified here. This
	-- 1) allows us to use helpful names for values instead of
	--    arbitrary values
	-- 2) ensures that we can never accidentally set a signal of
	--    this type to an invalid value, and 
	-- 3) helps the synthesis software create efficient hardware for our design.
	TYPE STATE_TYPE IS (
		A1LeftB3,
		A1LeftB2Right,
		A1RightB3,
		A4DownB2,
		A1RightB2,
		A2LeftB3,
		A2S4StoppedB2,
		BStopped,
		AStopped,
		A2LeftBStopped,
		B1LeftAStopped,
		B1LeftDownAStopped,
		B2RightAStopped
	);
	-- Now we can create a signal of our new type.  Note that there is
	-- nothing special about the names "state" or "state_type", but it makes
	-- sense to use these names because that is how we are using them.
	SIGNAL state                                : STATE_TYPE;
	-- Here we create some new internal signals which will be concatenations
	-- of some of the sensor signals.  This will make CASE statements easier.
	SIGNAL sensor12, sensor13, sensor24, sensor26, sensor36, sensor35        : std_logic_vector(1 DOWNTO 0);

BEGIN
	-- A process statement is required for clocked logic, such as a state machine.
	PROCESS (clock, reset)
	BEGIN
		IF reset = '1' THEN
			-- Reset to this state
			state <= A1LeftB3;
		ELSIF clock'EVENT AND clock = '1' THEN
			-- Case statement to determine next state.
			-- Case statements are a nice, clean way to make decisions
			-- based on different values of a signal.
			CASE state IS
				WHEN A1LeftB3 =>
					CASE Sensor26 IS
						WHEN "00" => state <= A1LeftB3;
						WHEN "01" => state <= A1RightB3;
						WHEN "10" => state <= A1LeftB2Right;
						WHEN "11" => state <= A4DownB2;
						WHEN OTHERS => state <= A1LeftB3;
					END CASE;

				WHEN A1LeftB2Right =>
						CASE Sensor36 IS
						WHEN "00" => state <= A1LeftB2Right;
						WHEN "01" => state <=A4DownB2;
						WHEN "10" => state <= A1LeftB3;
						WHEN "11" => state <= A1RightB3;
						WHEN OTHERS => state <= A1LeftB2Right;
					END CASE;

				WHEN A1RightB3 =>
					CASE Sensor24 IS
						WHEN "00" => state <= A1RightB3;
						WHEN "01" => state <= A2LeftB3;
						WHEN "10" => state <= A1RightB2;
						WHEN "11" => state <= A2S4StoppedB2;
						WHEN OTHERS => state <= A1RightB3;
					END CASE;
					
					
				WHEN A4DownB2 =>
					CASE Sensor35 IS
						WHEN "00" => state <= A4DownB2;
						WHEN "01" => state <= BStopped;
						WHEN "10" => state <= AStopped;
						WHEN "11" => state <= A2LeftB3;
						WHEN OTHERS => state <= A4DownB2;
					END CASE;
					
				WHEN A1RightB2 =>
					CASE Sensor34 IS
						WHEN "00" => state <= A1RightB2;
						WHEN "01" => state <= AStopped;
						WHEN "10" => state <= BStopped;
						WHEN "11" => state <= A2LeftBStopped;
						WHEN OTHERS => state <= A1RightB2;
					END CASE;
					
				WHEN A2LeftB3 =>
					CASE Sensor12 IS
						WHEN "00" => state <= A2LeftB3;
						WHEN "01" => state <= BStopped;
						WHEN "10" => state <= A1LeftB3;
						WHEN "11" => state <= A1LeftB2Right;
						WHEN OTHERS => state <= A1RightB2;
					END CASE;
					
				WHEN A2S4StoppedB2 =>
					CASE Sensor13 IS
						WHEN "00" => state <= A2S4StoppedB2;
						WHEN "01" => state <= A2BStopped;
						WHEN "10" => state <= A2S4StoppedB2;
						WHEN "11" => state <= A2BStopped;
						WHEN OTHERS => state <= A2S4StoppedB2;
					END CASE;
					
				WHEN A2LeftBStopped =>
					CASE Sensor12 IS
						WHEN "00" => state <= A2LeftBStopped;
						WHEN "01" => state <= A2LeftBStopped;
						WHEN "10" => state <= A1LeftB3;
						WHEN "11" => state <= A1LeftB3;
						WHEN OTHERS => state <= A2LeftBStopped;
					END CASE;
					
				WHEN B1LeftAStopped =>
					CASE Sensor46 IS
						WHEN "00" => state <= B1LeftAStopped;
						WHEN "01" => state <= B1LeftDownAStopped;
						WHEN "10" => state <= B1LeftAStopped;
						WHEN "11" => state <= B1LeftDownAStopped;
						WHEN OTHERS => state <= B1LeftAStopped;
					END CASE;
				
				WHEN B1LeftDownAStopped =>
					CASE Sensor14 IS
						WHEN "00" => state <= B1LeftDownAStopped;
						WHEN "01" => state <= B1LeftDownAStopped;
						WHEN "10" => state <= B2LeftAStopped;
						WHEN "11" => state <= B2LeftAStopped;
						WHEN OTHERS => state <= B1LeftDownAStopped;
					END CASE;
					
				
				WHEN B2RightAStopped =>
					CASE Sensor34 IS
						WHEN "00" => state <= B2RightAStopped;
						WHEN "01" => state <= B2RightAStopped;
						WHEN "10" => state <= BStopped;
						WHEN "11" => state <= BStopped;
						WHEN OTHERS => state <= B2RightAStopped;
					END CASE;
					
				
					

				WHEN AStopped =>
					IF Sensor3 = '1' THEN
						state <= A4RightBStopped;
					ELSE 
						state <= AStopped;
					END IF;

				WHEN BStopped =>
					IF Sensor1 = '1' THEN
						state <= A1LeftB3;
					ELSE
						state <= BStopped;
					END IF;

			END CASE;
		END IF;
	END PROCESS;

	-- Notice that all of the following logic is NOT in a process block,
	-- and thus does not depend on any clock.  Everything here is pure combinational
	-- logic, and exists in parallel with everything else.
	
	-- Combine bits for the internal signals declared above.
	-- ("&" operator concatenates bits)
	sensor12 <= sensor1 & sensor2;
	sensor13 <= sensor1 & sensor3;
	sensor24 <= sensor2 & sensor4;
	sensor26 <= sensor2 & sensor6;
	sensor36 <= sensor3 & sensor6;
	sensor35 <= sensor3 & sensor5;
	

	-- The following outputs depend on the state.
	WITH state SELECT Switch1 <=
		'1' WHEN A1LeftB3,
		'0' WHEN A1LeftB2Right,
		'0' WHEN A1RightB3,
		'0' WHEN A4DownB2,
		'0' WHEN A1RightB2,
		'0' WHEN A2LeftB3,
		'1' WHEN A2S4StoppedB2,
		'0' WHEN BStopped,
		'1' WHEN AStopped,
		'0' WHEN A2LeftBStopped,
		'0' WHEN B1LeftAStopped,
		'0' WHEN B1LeftDownAStopped,
		'0' WHEN B2RightAStopped;
	WITH state SELECT Switch2 <=
		'0' WHEN A1LeftB3,
		'1' WHEN A1LeftB2Right,
		'0' WHEN A1RightB3,
		'1' WHEN A4DownB2,
		'1' WHEN A1RightB2,
		'0' WHEN A2LeftB3,
		'1' WHEN A2S4StoppedB2,
		'0' WHEN BStopped,
		'0' WHEN AStopped,
		'0' WHEN A2LeftBStopped,
		'0' WHEN B1LeftAStopped,
		'0' WHEN B1LeftDownAStopped,
		'1' WHEN B2RightAStopped;
	WITH state SELECT Switch3 <=
		'0' WHEN A1LeftB3,
		'0' WHEN A1LeftB2Right,
		'0' WHEN A1RightB3,
		'1' WHEN A4DownB2,
		'0' WHEN A1RightB2,
		'0' WHEN A2LeftB3,
		'0' WHEN A2S4StoppedB2,
		'0' WHEN BStopped,
		'0' WHEN AStopped,
		'0' WHEN A2LeftBStopped,
		'0' WHEN B1LeftAStopped,
		'0' WHEN B1LeftDownAStopped,
		'0' WHEN B2RightAStopped;
	WITH state SELECT Switch4 <=
		'0' WHEN A1LeftB3,
		'0' WHEN A1LeftB2Right,
		'0' WHEN A1RightB3,
		'0' WHEN A4DownB2,
		'0' WHEN A1RightB2,
		'0' WHEN A2LeftB3,
		'0' WHEN A2S4StoppedB2,
		'0' WHEN BStopped,
		'0' WHEN AStopped,
		'0' WHEN A2LeftBStopped,
		'0' WHEN B1LeftAStopped,
		'0' WHEN B1LeftDownAStopped,
		'0' WHEN B2RightAStopped;
	WITH state SELECT DirA <=
		"01" WHEN A1LeftB3,
		"01" WHEN A1LeftB2Right,
		"01" WHEN A1RightB3,
		"01" WHEN A4DownB2,
		"01" WHEN A1RightB2,
		"01" WHEN A2LeftB3,
		"01" WHEN A2S4StoppedB2,
		"01" WHEN BStopped,
		"00" WHEN AStopped,
		"01" WHEN A2LeftBStopped,
		"01" WHEN B1LeftAStopped,
		"01" WHEN B1LeftDownAStopped,
		"01" WHEN B2RightAStopped;
	WITH state SELECT DirB <=
		"01" WHEN A1LeftB3,
		"01" WHEN A1LeftB2Right,
		"01" WHEN A1RightB3,
		"01" WHEN A4DownB2,
		"01" WHEN A1RightB2,
		"01" WHEN A2LeftB3,
		"01" WHEN A2S4StoppedB2,
		"00" WHEN BStopped,
		"01" WHEN AStopped,
		"01" WHEN A2LeftBStopped,
		"01" WHEN B1LeftAStopped,
		"01" WHEN B1LeftDownAStopped,
		"01" WHEN B2RightAStopped;
	
	-- These outputs happen to be constant values for this solution;
	-- they do not depend on the state.
	-- Switch3 <= '0';
	-- Switch4 <= '0';

END a;



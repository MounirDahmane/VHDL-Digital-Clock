------------------------- Digital-Clock-Using-DE1's-SSD's ------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all; -- INCLUDES THE SSD DRIVER FUNCTION : integer_to_SSD
-----------------------------------------------------------------
Entity d_counter is

	GENERIC( N 	  : INTEGER := 5;
			 fclk : INTEGER := 50_000_000);
	Port(
		Clk, Rst  	: IN  STD_LOGIC;
		
		SPEED_FAC 	: IN  STD_LOGIC_VECTOR(1 DOWNTO 0); -- TO ADJUST THE SPEED OF THE CLOCK, IT HELPS ON VISUALING THE HOURS, AND MINUTES
		NEW_VALUE	: IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- THE GIVEN VALUE FOR THE DIGITAL CLOCK ON SSD's WHEN SETTING THEM
		ADJUST	 	: IN  STD_logic;					-- TO ENTER ADJUSTING MODE 
		ENTER_VALUE : IN  STD_LOGIC;					-- A KEY USED TO ENTER THE NEW_VALUE AND TRANSLATING TO THE NEXT STATE WHEN PRESSED
		
		ssd_SecU  	: OUT STD_logic_VECTOR(6 DOWNTO 0);	-- SSD[0] OF THE FPGA ==> DE1 IN MY CASE
		ssd_SecT  	: OUT STD_logic_VECTOR(6 DOWNTO 0);	-- SSD[1] OF THE FPGA ==> DE1 IN MY CASE
		ssd_MinU  	: OUT STD_logic_VECTOR(6 DOWNTO 0);	-- SSD[2] OF THE FPGA ==> DE1 IN MY CASE
		ssd_MinT  	: OUT STD_logic_VECTOR(6 DOWNTO 0);	-- SSD[3] OF THE FPGA ==> DE1 IN MY CASE
		ssd_HourU 	: OUT STD_logic_VECTOR(6 DOWNTO 0);	-- SSD[4] OF THE FPGA ==> DE1 IN MY CASE
		ssd_HourT 	: OUT STD_logic_VECTOR(6 DOWNTO 0) 	-- SSD[5] OF THE FPGA ==> DE1 IN MY CASE
	);
END Entity;

-----------------------------------------------------------------
Architecture arch of d_counter is
	
	Signal Qin       : UNSIGNED(25 DOWNTO 0);
	Signal SecUnits  : INTEGER RANGE 0 to 10 ;
	Signal SecTens   : INTEGER RANGE 0 to 6  ;
	Signal MinUnits  : INTEGER RANGE 0 to 10 ;
	Signal MinTens   : INTEGER RANGE 0 to 6;
	Signal HourUnits : INTEGER RANGE 0 to 10;
	Signal HourTens  : INTEGER RANGE 0 to 3;
	Signal limit     : INTEGER RANGE 0 TO fclk;
	
	
	TYPE STATES IS (IDLE, SU, ST, MU, MT, HU, HT); -- FSM TO CONTROLL THE ADJUSTING MODE
	SIGNAL PS: STATES;
	
	ATTRIBUTE ENUM_ENCODING : STRING;
	ATTRIBUTE ENUM_ENCODING OF STATES : TYPE IS "SEQUENTIAL";

BEGIN
	-- SETTING THE SPEED OF THE CLOCK
	limit <= fclk 	   when SPEED_FAC = "00" ELSE
			 fclk/2048 when SPEED_FAC = "01" ELSE
			 fclk/4096 when SPEED_FAC = "10" ELSE
			 fclk/8192;
	
	-- CLK DIVIDER ==> FOR GENERATING ONE SECOND DELAY
	PROCESS(CLK, RST)
    BEGIN
		IF(RST = '0') THEN 
			Qin <= (OTHERS => '0');
		ELSIF(RISING_EDGE(CLK)) THEN
			IF(Qin < 50_000_000) THEN
				Qin <= Qin + 1;
			ELSE
				Qin <= (OTHERS => '0');
			END IF;
		END IF;
    END PROCESS;
	
	PROCESS(CLK, RST)
		VARIABLE one_s : NATURAL RANGE 0 to fclk; -- THE ONE SECOND OF THE CLOCK, DEPENDING ON THE LIMIT FACTOR
		VARIABLE SecU  : NATURAL RANGE 0 to 10;
		VARIABLE SecT  : NATURAL RANGE 0 to 6 ;
		VARIABLE MinU  : NATURAL RANGE 0 to 10;
		VARIABLE MinT  : NATURAL RANGE 0 to 6 ;
		VARIABLE HourU : NATURAL RANGE 0 to 10;
		VARIABLE HourT : NATURAL RANGE 0 to 3 ;
		VARIABLE delay : BOOLEAN;				  -- TO HANDLE THE DEBOUNCING OF THE KEY ie. THE ENTER_VALUE KEY
		
	BEGIN
		IF(RST = '0') THEN
			PS <= IDLE;
			one_s := 0;	delay := FALSE;
			SecU  := 0;	SecT  := 0;
			MinU  := 0;	MinT  := 0;
			HourU := 0;	HourT := 0;
			
		ELSIF(RISING_EDGE(Clk)) THEN -- (CLK'Event and CLK = '1')
		
			IF(Qin = 50_000_000) THEN delay := TRUE; END IF;
			
			IF(ADJUST = '1') THEN 
				
				CASE PS IS
					WHEN IDLE => IF(ENTER_VALUE = '1') THEN PS <= IDLE; ELSE PS <= SU; END IF;
					WHEN SU => SecU  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(SecU  > 9) THEN SecU  := 9; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= ST; delay := FALSE; END IF;
					WHEN ST => SecT  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(SecT  > 5) THEN SecT  := 5; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= MU; delay := FALSE; END IF;
					WHEN MU => MinU  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(MinU  > 9) THEN MinU  := 9; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= MT; delay := FALSE; END IF;
					WHEN MT => MinT  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(MinT  > 5) THEN MinT  := 5; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= HU; delay := FALSE; END IF;
					WHEN HU => HourU := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(HourU > 9) THEN HourU := 9; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= HT; delay := FALSE; END IF;
					WHEN HT => HourT := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(HourU > 3 AND HourT > 1) THEN HourT := 1; ELSIF(HourT > 2) THEN HourT := 2; END IF; IF(ENTER_VALUE = '0' AND DELAY = TRUE) THEN PS <= SU; delay := FALSE; END IF;
				END CASE;
				
			ELSE
				one_s := one_s + 1;
				IF(one_s = limit) THEN
					one_s := 0;
					SecU := SecU + 1;
					IF(SecU > 9) THEN
						SecU := 0;
						SecT := SecT + 1;
						IF(SecT > 5) THEN
							SecT := 0;
							MinU := MinU + 1;
							IF(MinU > 9) THEN
								MinU := 0;
								MinT := MinT + 1;
								IF(MinT > 5) THEN
									MinT := 0;
									HourU := HourU + 1;
									IF((HourT /= 2 AND HourU > 9) OR 
										(HourT = 2 AND HourU > 3)) THEN
										HourU := 0;
										HourT := HourT + 1;
										IF(HourT > 2) THEN
											HourT := 0;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
		
		SecUnits  <= SecU	;
		SecTens   <= SecT ;	
		MinUnits  <= MinU ;	
		MinTens   <= MinT ;
		HourUnits <= HourU;	
		HourTens <= HourT;	
	
	END PROCESS;
	
	ssd_SecU  <= integer_to_SSD(SecUnits );
	ssd_SecT  <= integer_to_SSD(SecTens  );
	ssd_MinU  <= integer_to_SSD(MinUnits );
	ssd_MinT  <= integer_to_SSD(MinTens  );
	ssd_HourU <= integer_to_SSD(HourUnits);
	ssd_HourT <= integer_to_SSD(HourTens );
	
END arch;
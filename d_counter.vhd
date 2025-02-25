--adding pakage and optimizing, pins, syntax, naming-----------------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------
Entity d_counter is

GENERIC ( N 	: INTEGER := 5;
			 fclk : INTEGER := 50_000_000);
Port(
	Clk, Rst  	: IN  STD_LOGIC;
		
	SPEED_FAC 	: IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
	
	NEW_VALUE	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
	ADJUST	 	: IN  STD_logic;
	SEL_EVENT 	: IN  STD_LOGIC;
	SEL 		 	: IN  STD_LOGIC;
	ENTER_VALUE : IN  STD_LOGIC;
	
	ssd_SecU  	: OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_SecT  	: OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_MinU  	: OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_MinT  	: OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_HourU 	: OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_HourT 	: OUT STD_logic_VECTOR(6 DOWNTO 0)
);
END Entity;
		
-----------------------------------------------------------------
Architecture arch of d_counter is
	
	Signal Qin       : UNSIGNED(27 DOWNTO 0);
	Signal SecUnits  : INTEGER RANGE 0 to 10 ;
	Signal SecTePS   : INTEGER RANGE 0 to 6  ;
	Signal MinUnits  : INTEGER RANGE 0 to 10 ;
	Signal MinTePS   : INTEGER RANGE 0 to 6;
	Signal HourUnits : INTEGER RANGE 0 to 10;
	Signal HourTePSt : INTEGER RANGE 0 to 3;
	Signal Clk_Slow  : STD_logic;
	Signal limit     : INTEGER RANGE 0 TO fclk;
	
	
	TYPE STATES IS (IDLE, SU, ST, MU, MT, HU, HT);
	SIGNAL PS: STATES;
	
	ATTRIBUTE ENUM_ENCODING : STRING;
	ATTRIBUTE ENUM_ENCODING OF STATES : TYPE IS "SEQUENTIAL";
	
	FUNCTION integer_to_SSD(SIGNAL input : INTEGER) RETURN STD_logic_VECTOR 
	IS VARIABLE output : STD_logic_VECTOR(6 DOWNTO 0);
	BEGIN
		CASE input IS
			WHEN 0 	=> output := "1000000"; --"0" on SSD
			WHEN 1 	=> output := "1111001"; --"1" on SSD
			WHEN 2 	=> output := "0100100"; --"2" on SSD
			WHEN 3 	=> output := "0110000"; --"3" on SSD
			WHEN 4 	=> output := "0011001"; --"4" on SSD
			WHEN 5 	=> output := "0010010"; --"5" on SSD
			WHEN 6 	=> output := "0000010"; --"6" on SSD
			WHEN 7 	=> output := "1111000"; --"7" on SSD
			WHEN 8 	=> output := "0000000"; --"8" on SSD
			WHEN 9 	=> output := "0010000"; --"9" on SSD
			WHEN OTHERS => output := "0000110"; -- E ON SSD
		END CASE;
		RETURN output;
	END integer_to_SSD;
	
	PROCEDURE max_limit(VARIABLE VAR : INOUT NATURAL;	CONSTANT MAX : IN NATURAL) IS
	BEGIN
			IF(VAR > MAX) THEN
				VAR := MAX;
			END IF;
   END PROCEDURE;

BEGIN
	
	limit <= fclk 		 when SPEED_FAC = "00" ELSE
				fclk/2048 when SPEED_FAC = "01" ELSE
				fclk/4096 when SPEED_FAC = "10" ELSE
				fclk/8192;
				
----------------------

----------------------

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
		VARIABLE one_s : NATURAL RANGE 0 to fclk;
		VARIABLE SecU	: NATURAL RANGE 0 to 10;
		VARIABLE SecT 	: NATURAL RANGE 0 to 6 ;
		VARIABLE MinU 	: NATURAL RANGE 0 to 10;
		VARIABLE MinT  : NATURAL RANGE 0 to 6 ;
		VARIABLE HourU	: NATURAL RANGE 0 to 10;
		VARIABLE HourT	: NATURAL RANGE 0 to 3 ;
		VARIABLE delay : BOOLEAN;
		
	BEGIN
		
		IF(RST = '0') THEN
			delay := FALSE;
			
			one_s := 0;	PS <= IDLE;
			SecU	:= 0;	SecT 	:= 0;
			MinU 	:= 0;	MinT  := 0;
			HourU	:= 0;	HourT	:= 0;
		ELSIF(RISING_EDGE(Clk)) THEN -- (CLK'Event and CLK = '1')
			
			max_limit(SecU, 9);	max_limit(MinU, 9);	max_limit(HourU, 9);
			max_limit(SecT, 5);	max_limit(MinT, 5);	max_limit(HourT, 2);
			IF(HourT > 1 and HourU > 3) THEN HourU := 3; END IF;
			
			IF(Qin = 50_000_000) THEN delay := TRUE; END IF;
---------------------------------------------------------------
		IF(ADJUST = '1') THEN
			
			CASE PS IS
			
				WHEN IDLE => IF(SEL_EVENT = '1') THEN PS <= IDLE; ELSE PS <= SU; END IF;
				WHEN SU   => SecU  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(HourU > 3 AND HourT > 1) THEN HourT := 1; ELSIF(HourT > 2) THEN HourT := 2; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= ST; delay := FALSE; END IF;-- END IF;
				WHEN ST   => SecT  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(SecU  > 9) THEN SecU  := 9; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= MU; delay := FALSE; END IF;-- END IF;
				WHEN MU   => MinU  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(SecT  > 5) THEN SecT  := 5; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= MT; delay := FALSE; END IF;-- END IF;
				WHEN MT   => MinT  := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(MinU  > 9) THEN MinU  := 9; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= HU; delay := FALSE; END IF;-- END IF;
				WHEN HU   => HourU := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(MinT  > 5) THEN MinT  := 5; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= HT; delay := FALSE; END IF;-- END IF;
				WHEN HT   => HourT := TO_INTEGER(UNSIGNED(NEW_VALUE)); IF(HourU > 9) THEN HourU := 9; END IF; IF(SEL_EVENT = '0' AND DELAY = TRUE) THEN PS <= SU; delay := FALSE; END IF;-- END IF;
				
			END CASE;
			
---------------------------------------------------------------
		
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
		SecTePS   <= SecT ;	
		MinUnits  <= MinU ;	
		MinTePS   <= MinT ;
		HourUnits <= HourU;	
		HourTePSt <= HourT;	
	
	END PROCESS;
	
	ssd_SecU  <= integer_to_SSD(SecUnits );
	ssd_SecT  <= integer_to_SSD(SecTePS  );
	ssd_MinU  <= integer_to_SSD(MinUnits );
	ssd_MinT  <= integer_to_SSD(MinTePS  );
	ssd_HourU <= integer_to_SSD(HourUnits);
	ssd_HourT <= integer_to_SSD(HourTePSt);
	
END arch;

-----------------------------------------------------------------
Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-----------------------------------------------------------------
Entity d_counter is

GENERIC ( N 	: INTEGER := 5;
			 fclk : INTEGER := 50_000_000);
Port(
	Clk, Rst   : IN  STD_LOGIC;
	SPEED_FAC  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
	--ENTER      : IN  STD_logic;
	--mode       : IN  STD_logic;
	--Sel		  : IN  STD_logic_VECTOR(1 DOWNTO 0);
	--New_Value  : IN  STD_logic_VECTOR(N DOWNTO 0);
	--nope		  : OUT STD_logic;
	ssd_SecU  : OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_SecT  : OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_MinU  : OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_MinT  : OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_HourU : OUT STD_logic_VECTOR(6 DOWNTO 0);
	ssd_HourT : OUT STD_logic_VECTOR(6 DOWNTO 0)
);
END Entity;
		
-----------------------------------------------------------------
Architecture arch of d_counter is
	
	Signal Qin       : UNSIGNED(25 DOWNTO 0);
	Signal SecUnits  : INTEGER RANGE 0 to 10;
	Signal SecTens   : INTEGER RANGE 0 to 6 ;
	Signal MinUnits  : INTEGER RANGE 0 to 10;
	Signal MinTens   : INTEGER RANGE 0 to 6;
	Signal HourUnits : INTEGER RANGE 0 to 10;
	Signal HourTenst : INTEGER RANGE 0 to 3;
	Signal Clk_Slow  : STD_logic;
	Signal limit     : INTEGER RANGE 0 TO fclk;
	
	FUNCTION integer_to_SSD(SIGNAL input : INTEGER) RETURN STD_logic_VECTOR 
	IS VARIABLE output : STD_logic_VECTOR(6 DOWNTO 0);
	BEGIN
		CASE input IS
			WHEN 0 => output := "0000001"; --"0" on SSD
			WHEN 1 => output := "1001111"; --"1" on SSD
			WHEN 2 => output := "0010010"; --"2" on SSD
			WHEN 3 => output := "0000110"; --"3" on SSD
			WHEN 4 => output := "1001100"; --"4" on SSD
			WHEN 5 => output := "0100100"; --"5" on SSD
			WHEN 6 => output := "0100000"; --"6" on SSD
			WHEN 7 => output := "0001111"; --"7" on SSD
			WHEN 8 => output := "0000000"; --"8" on SSD
			WHEN 9 => output := "0000100"; --"9" on SSD
			WHEN OTHERS => output := "0110000"; -- E ON SSD
		END CASE;
		RETURN output;
	END integer_to_SSD;

BEGIN

	limit <= fclk/8192;
----------------- CLK DIV --------------------------
	CLK_DIV : PROCESS(CLK, SPEED_FAC)
	BEGIN
		IF(CLK'EVENT AND CLK = '1') THEN
			IF(Qin < fclk/50_000) THEN
				Qin <= Qin + 1;
			ELSE 
				Qin <= (others =>'0');
			END IF;
		END IF;
		
	END PROCESS CLK_DIV;
	Clk_Slow <= Qin(10);
----------------------------------------------------
	PROCESS(CLK, RST)
		VARIABLE one_s : NATURAL RANGE 0 to fclk;
		VARIABLE SecU	: NATURAL RANGE 0 to 10;
		VARIABLE SecT 	: NATURAL RANGE 0 to 6 ;
		VARIABLE MinU 	: NATURAL RANGE 0 to 10;
		VARIABLE MinT  : NATURAL RANGE 0 to 6 ;
		VARIABLE HourU	: NATURAL RANGE 0 to 10;
		VARIABLE HourT	: NATURAL RANGE 0 to 3 ;
		
	BEGIN
		END PROCESS;
--ELSIF (mode = '1') THEN
--
--case Sel is
--	when "00" => 
--		IF(ENTER = '0') THEN S_state <= unsigned(New_Value); END IF;
--	when "01" =>
--		IF(ENTER = '0') THEN M_state <= unsigned(New_Value); END IF;
--	when "10" =>
--		IF(ENTER = '0') THEN H_state <= unsigned(New_Value(4 DOWNTO 0)); END IF;
--	when others => nope <='1';
--END case;
			
END arch;

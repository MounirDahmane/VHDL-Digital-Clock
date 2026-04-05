LIBRARY ieee;
USE ieee.std_logic_1164.all;

------------------------------------------------------------
PACKAGE utils IS
	FUNCTION integer_to_SSD(SIGNAL input : INTEGER) RETURN STD_logic_VECTOR;
END utils;

------------------------------------------------------------
PACKAGE BODY utils IS

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
	
END utils;



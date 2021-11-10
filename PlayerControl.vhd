LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY PlayerControl IS
	PORT 	(		up     	:	IN		STD_LOGIC;
	            down	   :	IN		STD_LOGIC;
					clk	   :	IN		STD_LOGIC;
					PosRk	   :	OUT	INTEGER
			);
END ENTITY PlayerControl;
-----------------------------------------------------------
ARCHITECTURE rtl OF PlayerControl IS

SIGNAL	Posracket   :	INTEGER:=255;

BEGIN

PosRk<=Posracket;

PROCESS(clk,down,up) BEGIN

	IF(rising_edge(clk))THEN
		
		IF(down='1')THEN
			IF(Posracket=465)THEN -- extremo inferior
				Posracket<=Posracket;
			ELSE
				Posracket<=Posracket+10;
			END IF;
		END IF;
		
		IF(up='1')THEN
			IF(Posracket=45)THEN -- extremo superior
				Posracket<=Posracket;
			ELSE
				Posracket<=Posracket-10;
			END IF;
		END IF;
	END IF;

END PROCESS;
	 
END ARCHITECTURE rtl;
-----------------------------------------------------------
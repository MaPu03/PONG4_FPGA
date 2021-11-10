LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY BallControl IS

	PORT 	(		clk					:	IN		STD_LOGIC;
					rst					:	IN		STD_LOGIC;
					screen				:	IN		STD_LOGIC;
					Player1         	:	IN		INTEGER;
					Player2         	:	IN		INTEGER;
					posix,posiy     	:	OUT	INTEGER;
					PointP2,PointP1   :	OUT	INTEGER
			 );
			 
END ENTITY BallControl;
-----------------------------------------------------------
ARCHITECTURE rtl OF BallControl IS

SIGNAL	ptx                 :	INTEGER:=1;
SIGNAL	pty                 :	INTEGER:=0;
SIGNAL	PointsP2,PointsP1   :	INTEGER:=0;
SIGNAL	bangP1,bangP2       :	INTEGER:=0;--bounce
SIGNAL	inc,screens         :	STD_LOGIC;
SIGNAL	timee               :INTEGER:=125000;-- 3 segundos 
SIGNAL	anclax              :	INTEGER:=475;
SIGNAL	anclay              :	INTEGER:=280;


BEGIN

	posix<=anclax;-- posicion ball x
	posiy<=anclay;-- posicion ball y
	bangP1<=anclay-Player1; -- 
	bangP2<=anclay-Player2;
	PointP2<=PointsP2;
	PointP1<=PointsP1;
	screens<=screen;
	
	PROCESS(clk,inc,anclax,anclay,ptx,pty,bangP1,bangP2) 
	BEGIN
	
	--longrackeet = 60*15
	--rbola = 10
	
	IF(rising_edge(clk))THEN
      -------- Posicion pelota ---------------	
		IF(inc='1')THEN
			anclax <= anclax+ptx;
			anclay <= anclay+pty;
		END IF;
		-------- REBOTES PLAYER 1 ---------------
		IF((anclax=775) AND (40>bangP1 AND bangP1>20))THEN-- rebote recto
			ptx<=-1;
			pty<=0;
		END IF;
		IF((anclax=775) AND (60>bangP1 AND bangP1>40))THEN -- rebote -45 (hacia arriba)
			ptx<=-1;
			pty<=1;
		END IF;
		IF((anclax=775) AND (20>bangP1 AND bangP1>-10))THEN -- rebote +45 (hacia abajo)
			ptx<=-1;
			pty<=-1;
		END IF;
		--------- REBOTES PLAYER 2 --------------
		IF((anclax=175) AND (40>bangP2 AND bangP2>20))THEN -- rebote recto
			ptx<=1;
			pty<=0;
		END IF;
		IF((anclax=175) AND (60>bangP2 AND bangP2>40))THEN -- rebote -45 (hacia arriba)
			ptx<=1;
			pty<=1;
		END IF;
		IF((anclax=175) AND (20>bangP2 AND bangP2>-10))THEN -- rebote +45 (hacia abajo)
			ptx<=1;
			pty<=-1;
		END IF;
		---------- FIELD LIMITS  -----------------
		IF(anclay=45)THEN -- Borde superior rebote
			pty<=1;
			ptx<=ptx;
		END IF;
		IF(anclay=515)THEN -- Borde inferior rebote
			pty<=-1;
			ptx<=ptx;
		END IF;
		--------- POINTS CONDITIONS ---------------
		IF(anclax=160)THEN -- Extremo izquierdo
			PointsP1<=PointsP1+1;
			timee<=timee-4200;
			anclax<=475;
			anclay<=280;
			ptx<=1;
			pty<=0;
		END IF;
		
		IF(anclax=790)THEN -- Extremo derecho
			PointsP2<=PointsP2+1;
			timee<=timee-4200;
			anclax<=475;
			anclay<=280;
			ptx<=-1;
			pty<=0;
		END IF;
		--------- POINTS LIMITS ------------
		IF((PointsP2=10)OR(PointsP1=10))THEN
			PointsP2<=0;
			PointsP1<=0;
			timee<=125000;
		END IF;
	END IF;
		
	END PROCESS;
	
	speedball: ENTITY work.univ_bin_counter
			GENERIC MAP(N        => 19)
			PORT MAP	(clk			=>	clk,
						 rst			=>	rst OR NOT(screens),
						 ena			=>	'1',
						 syn_clr		=>	'0',
						 load			=> '0',
						 up			=> '1',
						 num_in		=>	"0000000000000000000",
						 max        => STD_LOGIC_VECTOR(TO_UNSIGNED(timee,19)),
						 max_tick	=>	inc);
	 
END ARCHITECTURE rtl;
-----------------------------------------------------------
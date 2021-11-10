-----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY PonGame IS
	  PORT 	(	clk	 :	IN		STD_LOGIC;
					rst	 :	IN		STD_LOGIC;
					filap1 : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
					filap2 : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
					colump1: OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
					colump2: OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
					Hsync	 :	OUT	STD_LOGIC;
					Vsync	 :	OUT	STD_LOGIC;
					digp1  :	OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
					decp1  :	OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
					digp2  :	OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
					decp2  :	OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
					R		 :	OUT	STD_LOGIC_VECTOR(3 DOWNTO 0);
					G		 :	OUT	STD_LOGIC_VECTOR(3 DOWNTO 0);
					B		 :	OUT	STD_LOGIC_VECTOR(3 DOWNTO 0)
					);
END ENTITY PonGame;
-----------------------------------------------------------
ARCHITECTURE rtl OF PonGame IS

SIGNAL 	clk1       		       : STD_LOGIC;
SIGNAL	waitt,screen          : STD_LOGIC:='0';
SIGNAL   deccp1                : STD_LOGIC:='1';
SIGNAL   deccp2,diggp1,diggp2  : STD_LOGIC:='0';
SIGNAL   seg0,seg1,seg2,seg3   : STD_LOGIC_VECTOR(12 DOWNTO 0);
---
SIGNAL   up1s,up2s,down1s,down2s : STD_LOGIC;
SIGNAL   stops,starts            : STD_LOGIC;
SIGNAL   anclaP1,anclaP2         : INTEGER;
SIGNAL	BallX, BallY            : INTEGER;
SIGNAL	PointsP1,PointsP2	      : INTEGER:=0;


BEGIN

----------------- CLOCK DIVISOR --------------------------
  pllit:ENTITY work.PLL
	               PORT MAP(inclk0  =>clk,
		                     c0	     =>clk1);
----------------- VGA CONTROLLER -------------------------

ControlVGA:ENTITY work.VGAController	   
           PORT MAP( clk     =>clk1,
							rst	  =>rst,
							starts  =>starts,
							stops   =>stops,
							anclaP1 =>anclaP1,
							anclaP2 =>anclaP2,
							BallX   =>BallX,
							BallY   =>BallY,
							DecP1   =>seg1(3 DOWNTO 0),
							DecP2   =>seg3(3 DOWNTO 0),
							DigP1   =>seg0(3 DOWNTO 0),
							DigP2   =>seg2(3 DOWNTO 0),
							Hsync	  =>Hsync,
							Vsync	  =>Vsync,
							screens =>screen,
							waitt   =>waitt,
							R		  =>R,
							G		  =>G,
							B		  =>B);

-----------------------------------------------------------	
--------------- IN KEYPAD PLAYERS ---------------------------
 Player1:ENTITY work.teclado_fsm
         PORT MAP (  clk		 =>clk1,
							rst		 =>rst,
							fila		 =>filap1,
							columna	 =>colump1,
							up    	 =>up1s,
							down      =>down1s,
							stop      =>stops,
							start     =>starts);
 Player2:ENTITY work.teclado_fsm
         PORT MAP (  clk		 =>clk1,
							rst		 =>rst,
							fila		 =>filap2,
							columna	 =>colump2,
							up    	 =>up2s,
							down      =>down2s);
							
--------------- PLAYERS CONTROL ---------------------------								 
 Player1Control:ENTITY work.Playercontrol
						PORT MAP( clk    =>clk1,
									 up     =>up1s,
									 down   =>down1s,
									 PosRk  =>anclaP1);
 Player2Control:ENTITY work.Playercontrol
						PORT MAP( clk    =>clk1,
									 up     =>up2s,
									 down   =>down2s,
									 PosRk  =>anclaP2);
------------------------------------------------------------
-------------------- Ball Control --------------------------
  Pelota :ENTITY work.BallControl
				PORT MAP( clk     =>clk1,
							 screen  =>screen,
							 rst     =>rst OR waitt,
							 Player1 =>anclaP1,
							 Player2 =>anclaP2,
							 posix   =>BallX,
							 posiy   =>BallY,
							 PointP1 =>PointsP1,
							 PointP2 =>PointsP2);
------------------------------------------------------------
-------------------- Puntaje display --------------------------
      displ0:ENTITY work.bin_to_sseg
						PORT MAP( bin     => seg1(3 DOWNTO 0),
									 sseg	   => digp1);
	   displ1:ENTITY work.bin_to_sseg
						PORT MAP( bin     => seg0(3 DOWNTO 0),
									 sseg	   => decp1);
		displ2:ENTITY work.bin_to_sseg
						PORT MAP( bin     => seg3(3 DOWNTO 0),
									 sseg	   => digp2);
		displa3:ENTITY work.bin_to_sseg
						PORT MAP( bin     => seg2(3 DOWNTO 0),
									 sseg	   => decp2);
									 
		seg0<=STD_LOGIC_VECTOR(to_unsigned(PointsP2,13)/10);
		seg1<=STD_LOGIC_VECTOR((to_unsigned(PointsP2,13)mod 10));
		seg2<=STD_LOGIC_VECTOR(((to_unsigned(PointsP1,13)/10)));
		seg3<=STD_LOGIC_VECTOR(((to_unsigned(PointsP1,13)mod 10)));
-----------------------------------------------------------------
			
END ARCHITECTURE rtl;
-----------------------------------------------------------
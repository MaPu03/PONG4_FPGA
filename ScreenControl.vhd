-----------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
-----------------------------------------------------------
ENTITY ScreenControl IS
	  PORT 	(	clk	   :	IN	 STD_LOGIC;
					rst	   :	IN	 STD_LOGIC;
					starts	:	IN	 STD_LOGIC;
					stops    :	IN	 STD_LOGIC;
					anclaP1  :  IN  INTEGER;
					anclaP2  :  IN  INTEGER;
					BallX    :  IN  INTEGER;
					BallY    :  IN  INTEGER;
					DecP1    :	IN	 STD_LOGIC_VECTOR(3 DOWNTO 0);
					DecP2    :	IN	 STD_LOGIC_VECTOR(3 DOWNTO 0);
					DigP1    :	IN	 STD_LOGIC_VECTOR(3 DOWNTO 0);
					DigP2    :	IN	 STD_LOGIC_VECTOR(3 DOWNTO 0);
					Hsync	   :	OUT STD_LOGIC;
					Vsync	   :	OUT STD_LOGIC;
					screens  :	OUT STD_LOGIC;
					waitt    :	OUT STD_LOGIC;
					R		   :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
					G		   :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
					B		   :	OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
					);
END ENTITY ScreenControl;
-----------------------------------------------------------
ARCHITECTURE rtl OF ScreenControl IS
SIGNAL	Hpos_S,Vpos_S,adr,adrsc	:	INTEGER:=0;
SIGNAL	screen,screenpau        :	STD_LOGIC:='0';
SIGNAL   Rs,Gs,Bs,Ri,Gi,Bi	      :	STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL   Rc,Gc,Bc,Rn,Gn,Bn,Numero:	STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	contadormem 	         :	INTEGER:=499;
SIGNAL   contpunt,contp          :  INTEGER:=289;
SIGNAL   contadormemsc           :  INTEGER:=130;
SIGNAL 	data0,data1,data2	      : 	STD_LOGIC_VECTOR(499 DOWNTO 0);
SIGNAL 	datas0,datas1,datas2	   : 	STD_LOGIC_VECTOR(499 DOWNTO 0);
SIGNAL 	datac0            	   : 	STD_LOGIC_VECTOR(129 DOWNTO 0);
SIGNAL   datan0                  :  STD_LOGIC_VECTOR(289 DOWNTO 0);
---
SIGNAL   backg                   :STD_LOGIC_VECTOR(3 DOWNTO 0):="0000";
SIGNAL   relleno                 :STD_LOGIC_VECTOR(3 DOWNTO 0):="1111";


BEGIN

 PROCESS(clk,rst,Hpos_S,Vpos_S,starts,stops,screen,anclaP1,anclaP2,BallX,BallY) 
	BEGIN
	
	IF (rst='1') THEN 
	      R<="0000";
			G<="0000";
			B<="0000";
	ELSIF(rising_edge(clk))THEN
	
		----------- CONTEO DE PIXELS -------------------
		IF(HPos_S<800) THEN
		HPos_S<=Hpos_S+1;
		ELSE
		Hpos_S<=0;
				IF(VPos_S<525) THEN
					VPOs_S<=Vpos_S+1;
					
					IF(adrsc=32)THEN--- mem score
					adrsc<=0;
					ELSIF(((79)>=Vpos_S AND Vpos_S>=47))THEN
					adrsc<=adrsc+1;
					END IF;
					
					IF(adr=375)THEN-- mem screen
					adr<=0;
					ELSIF(((472)>=Vpos_S AND Vpos_S>=97))THEN
					adr<=adr+1;
					END IF;
				ELSE
					Vpos_S<=0;
				END IF;
		END IF;
		-- Señales VSYNC Y HSYNC----------------
		IF(Hpos_S<112 AND Hpos_S>16) THEN
			Hsync<= '0';
			ELSE
			Hsync<= '1';
		END IF;
				
		IF(Vpos_S>10 AND Vpos_S<12) THEN
			Vsync<= '0';
			ELSE
			Vsync<= '1';
		END IF;
		----- POSICIONES MEMORIAS -----------------
		IF((730>=Hpos_S AND Hpos_S>=230))THEN
		contadormem<=contadormem-1;
		ELSE
		contadormem<=500;
		END IF;
		
		IF((430>=Hpos_S AND Hpos_S>=300))THEN
		contadormemsc<=contadormemsc-1;
		ELSE
		contadormemsc<=129;
		END IF;
		
		IF(421=Hpos_S) THEN---DECIMAS p1--------------------
		Numero<= DecP1;--seg1(3 DOWNTO 0);
		contp<=contpunt;
		ELSIF(445>=Hpos_S AND Hpos_S>=422) THEN
		contp<=contp-1;
		END IF;
		
		IF(446=Hpos_S) THEN---Dig p1----------------------
		Numero<= DigP1;--seg2(3 DOWNTO 0);
		contp<=contpunt;
		ELSIF(476>=Hpos_S AND Hpos_S>=447) THEN
		contp<=contp-1;
		END IF;
		
		IF(482=Hpos_S) THEN---DECIMAS p2
		Numero<= DecP2;--seg3(3 DOWNTO 0);
		contp<=contpunt;
		ELSIF(507>=Hpos_S AND Hpos_S>=483) THEN
		contp<=contp-1;
		END IF;
		
      IF(508=Hpos_S) THEN---Dig p2
		Numero<= DigP1;--seg0(3 DOWNTO 0);
		contp<=contpunt;
		ELSIF(538>=Hpos_S AND Hpos_S>=509) THEN
		contp<=contp-1;
		END IF;
		
	   ------------ JUEGUITO ---------------------------
		IF(starts='1')THEN
		screen<='1';
		END IF;
		IF(stops='1')THEN
		screenpau<='1';
		END IF;
		-------------  PANTALLA INICIO ----------------
		IF(screen='0' AND screenpau<='0')THEN
		IF((472>=Vpos_S AND Vpos_S>=97)AND(730>=Hpos_S AND Hpos_S>=230))THEN
			R<=Ri;
			G<=Gi;
			B<=Bi;
			ELSE
			R<="0000";
			G<="0000";
			B<="0000";
		END IF;
		END IF;
		-------------  PANTALLA PAUSA ----------------
		IF(screenpau='1' AND screen='1')THEN
		waitt<='1';
		IF((screenpau='1')AND(472>=Vpos_S AND Vpos_S>=97)AND(730>=Hpos_S AND Hpos_S>=230))THEN
			R<=Rs;
			G<=Gs;
			B<=Bs;
			ELSE
			R<="0000";
			G<="0000";
			B<="0000";
			IF(starts='1')THEN
			waitt<='0';
		   screenpau<='0';
		   END IF;
		  END IF;
		END IF;
		--------------- RELLENO OBJETOS ---------------
		IF(screen='1' AND screenpau='0')THEN
		---------------    BOLA -----------------------
		IF(((BallY+10)>=Vpos_S AND Vpos_S>=BallY)AND(BallX+10>=Hpos_S AND Hpos_S>=BallX))THEN
		R	<=	relleno;
		G	<=	relleno;
		B	<=	relleno;
		----------------- SCORE BOARD -----------------
		ELSIF(((80)>=Vpos_S AND Vpos_S>=45)AND(540>=Hpos_S AND Hpos_S>=310))THEN
	   R	<=	relleno;
	   G	<=	relleno;
	   B	<=	relleno;
		         ------ ----- "SCORE"  ------ -------  
		IF(((79)>=Vpos_S AND Vpos_S>=47)AND(420>=Hpos_S AND Hpos_S>=312))THEN
			R	<=	Rc;
			G	<=	Gc;
			B	<=	Bc;
			      ------ ----- "PUNTOS" ------ ------- 
		ELSIF(((79)>=Vpos_S AND Vpos_S>=47)AND(479>=Hpos_S AND Hpos_S>=422))THEN
			R	<=	Rn;
			G	<=	Gn;
			B	<=	Bn;
		ELSIF(((79)>=Vpos_S AND Vpos_S>=47)AND(538>=Hpos_S AND Hpos_S>=481))THEN
			R	<=	Rn;
			G	<=	Gn;
			B	<=	Bn;
		END IF;
		------ ----- LINEA MITAD ------ ------- 
		ELSIF(Hpos_S=480)THEN
			R	<=	relleno;
			G	<=	relleno;
			B	<=	relleno;
		------ -----  RAQUETAS  ------ ------- 
		ELSIF((anclaP2+60>=Vpos_S AND Vpos_S>=(anclaP2))AND(175>=Hpos_S AND Hpos_S>=160 ))THEN
			R	<=	relleno;
			G	<=	relleno;
			B	<=	relleno;
		ELSIF((anclaP1+60>=Vpos_S AND Vpos_S>=(anclaP1))AND(800>=Hpos_S AND Hpos_S>=785))THEN
			R	<=	relleno;
			G	<=	relleno;
			B	<=	relleno(3 DOWNTO 0);
		ELSE
		R	<=	backg;
		G	<=	backg;
		B	<=	backg;
		END IF;
	 END IF;	
	
	END IF;
	----------------------------------------------
	END PROCESS;
	 
   backg  <="0000";
	relleno<="1111";
	
	WITH Numero SELECT
	contpunt<= 28  WHEN "1001",
	           57  WHEN "1000",
				  86  WHEN "0111",
				  115 WHEN "0110",
				  144 WHEN "0101",
				  173 WHEN "0100",
				  202 WHEN "0011",
				  231 WHEN "0010",
				  260 WHEN "0001",
				  289 WHEN "0000",
				  289 WHEN OTHERS;
	
	screens <= screen;
	
	Ri<=data0(contadormem)&data0(contadormem)&data0(contadormem)&data0(contadormem);
   Gi<=data1(contadormem)&data1(contadormem)&data1(contadormem)&data1(contadormem);
   Bi<=data2(contadormem)&data2(contadormem)&data2(contadormem)&data2(contadormem);
	
	Rs<=datas0(contadormem)&datas0(contadormem)&datas0(contadormem)&datas0(contadormem);
   Gs<=datas1(contadormem)&datas1(contadormem)&datas1(contadormem)&datas1(contadormem);
   Bs<=datas2(contadormem)&datas2(contadormem)&datas2(contadormem)&datas2(contadormem);
	
	Rc<=datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc);
	Gc<=datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc);
	Bc<=datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc)&datac0(contadormemsc);
	
	Rn<=datan0(contp)&datan0(contp)&datan0(contp)&datan0(contp);
	Gn<=datan0(contp)&datan0(contp)&datan0(contp)&datan0(contp);
	Bn<=datan0(contp)&datan0(contp)&datan0(contp)&datan0(contp);

------------------ IMAGEN MEMORIA -----------------------------
   ------------------ IMAGEN INICIO  ------------------------
  rojo:ENTITY work.memR
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>data0);		
  verde:ENTITY work.memG
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>data1);		
  azu:ENTITY work.memB
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>data2);
	------------------  IMAGEN STOP ----------------------								 
  rojos:ENTITY work.memSR
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>datas0);		
  verdes:ENTITY work.memSG
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>datas1);		
  azus:ENTITY work.memSB
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adr,9)),
									 r_data =>datas2);
    ----------------- IMAGEN SCORE --------------------
  SCORE:ENTITY work.memScor
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adrsc,5)),
									 r_data =>datac0);
	----------------- IMAGEN PUNTUACION --------------------
  puntos :ENTITY work.memNum
						PORT MAP( clk    =>clk ,
									 addr   =>STD_LOGIC_VECTOR(to_unsigned(adrsc,5)),
									 r_data =>datan0);
 ----------------------------------------------------------	
END ARCHITECTURE rtl;
-----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
ENTITY teclado_fsm IS
	PORT ( 	
			clk		   : IN 	STD_LOGIC;
			rst		   : IN 	STD_LOGIC;
			fila		   : IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
			columna	   : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			up    	   : OUT STD_LOGIC;
			down     	: OUT STD_LOGIC;
		   stop        : OUT STD_LOGIC;
	    	start       : OUT STD_LOGIC
         );
END ENTITY;

ARCHITECTURE fsm OF teclado_fsm IS

--SIGNAL stop,start,up,down   : STD_LOGIC;
SIGNAL ready0,ready1,ready2,ready3, ready   : STD_LOGIC;
SIGNAL filas,sig   :  STD_LOGIC_VECTOR(3 DOWNTO 0);   

TYPE state IS (s0,s1,s2,s3,s4);
SIGNAL pr_state, next_state: state;
BEGIN
------------------------------------------
	PROCESS(clk,rst) IS
	BEGIN 
			IF (rst = '1') THEN 
			   pr_state <= s0;
			ELSIF(rising_edge(clk)) THEN
					pr_state <= next_state;
			END IF;
	END PROCESS;
-----------------------------------------
PROCESS (pr_state, filas, ready)
BEGIN 
	CASE pr_state IS
				
		WHEN s0 => 
					columna 	<= "011";-- START
					IF(filas="1110") THEN
						up 	<= '0';
						down 	<= '0';
						start <= '1';
						stop  <= '0';
						next_state<= s0;
					ELSE 
						up 	<= '0';
						down 	<= '0';
						start <= '0';
						stop  <= '0';
						next_state<= s1;
					END IF; 
				
			
		WHEN s1 => 
					columna 	<= "101";-- UP
					IF (filas="0111") THEN
						up 	<= '1';
						down 	<= '0';
						start <= '0';
						stop  <= '0';
						next_state<= s1;
					ELSE 
						up 	<= '0';
						down 	<= '0';
						start <= '0';
						stop  <= '0';
						next_state<= s2;	
					END IF;

			
				
		WHEN s2 => 
					columna 	<= "101";-- DOWN
					IF(filas="1101") THEN
						up 	<= '0';
						down 	<= '1';
						start <= '0';
						stop  <= '0';
						next_state<= s2;
					ELSE  
						up 	<= '0';
						down 	<= '0';
						start <= '0';
						stop  <= '0';
						next_state<= s3;	
					END IF; 

		WHEN s3 => 
					columna 	<= "110";-- STOP
					IF(filas="1110") THEN
						up 	<= '0';
						down 	<= '0';
						start <= '0';
						stop  <= '1';
						next_state<= s3;
					ELSE 
						up 	<= '0';
						down 	<= '0';
						start <= '0';
						stop  <= '0';
						next_state<= s4;
					END IF;
				
			WHEN s4 => 
			   columna 	<= "000";
				up 	<= '0';
				down 	<= '0';
				start <= '0';
				stop  <= '0';
				IF (ready='1') THEN
					next_state<= s0;
				ELSE
					next_state<= s4;	
				END IF;
		END CASE;
END PROCESS;
-------------------------------------------

 filas <= NOT sig(3) & NOT sig(2) & NOT sig(1) & NOT sig(0);
 Ready <= ready0 OR ready1 OR ready2 OR ready3;

  Debounfila0 : ENTITY work.debouncing
               PORT MAP(    clk     => clk,
					             ena     => '1',
									 rst     => rst,
									 disp    => ready0,
									 sw      => NOT fila(0),
									 debsw  => sig(0));
										

  Debounfila1 : ENTITY work.debouncing
               PORT MAP(    clk     => clk,
					             ena     => '1',
									 rst     => rst,
									 disp    => ready1,
									 sw      => NOT fila(1),
									 debsw   => sig(1));

  Debounfila2 : ENTITY work.debouncing
               PORT MAP(    clk     => clk,
					             ena     => '1',
									 rst     => rst,
									 disp    => ready2,
									 sw      => NOT fila(2),
									 debsw  => sig(2));
  Debounfila3 : ENTITY work.debouncing
               PORT MAP(    clk     => clk,
					             ena     => '1',
									 rst     => rst,
									 disp    => ready3,
									 sw      => NOT fila(3),
									 debsw  => sig(3));

END ARCHITECTURE fsm;
				
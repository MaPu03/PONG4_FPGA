LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
------------------------------------------------------------------------------------
ENTITY debouncing IS
	PORT (	clk		:	IN		STD_LOGIC;
				ena		:	IN		STD_LOGIC;
				sw			:	IN		STD_LOGIC;
				rst		:	IN		STD_LOGIC;
				disp     :	OUT	STD_LOGIC;
				debsw		:	OUT	STD_LOGIC);
END ENTITY debouncing;
-------------------------------------------------------------------------------------
ARCHITECTURE rtl OF debouncing IS
	TYPE state IS (state0, state1,state2,state3,state4,state5);
	SIGNAL pr_state, nx_state: state;
	SIGNAL sync_timer1,sync_timer2,sync_timer3,enacont	:	STD_LOGIC;
	SIGNAL max_tick1,max_tick2,max_tick3			:	STD_LOGIC;
	SIGNAL debsw_b,debsw_a,mxt								:	STD_LOGIC;
	SIGNAL cont1_ena,cont2_ena,cont3_ena			:	STD_LOGIC;
-------------------------------------------------------------------------------------
BEGIN
------------OUTPUTS
debsw	<=	debsw_a;
-----------------------------------------------------------------	
		PROCESS(rst,ena,clk)
			BEGIN
				IF(rst='1') THEN
					pr_state <= state0;
				ELSIF(rising_edge(clk)) THEN
						pr_state <= nx_state;
						debsw_a	<=	debsw_b;
				END IF;
			END PROCESS;
-----------------------------------------------------------------------------------
	PROCESS (pr_state,sw,max_tick1,max_tick2,max_tick3,mxt)
		BEGIN
			CASE pr_state IS
			
				WHEN state0 =>
				debsw_b		<=	'0';
				cont1_ena	<=	'0';
				enacont		<=	'0';
				disp        <=	'0';
				cont2_ena	<=	'0';
				cont3_ena	<=	'0';
				sync_timer1	<=	'1';
				sync_timer2	<= '1';
				sync_timer3	<=	'1';
					IF(sw = '1')	THEN
						nx_state <= state1;
					ELSE
						nx_state	<= state0;
					END IF;
----------------------------------------------------------------					
				WHEN state1 =>
				debsw_b		<=	'0';
				cont1_ena	<=	'1';
				enacont		<=	'0';
				disp        <=	'0';
				cont2_ena	<=	'0';
				cont3_ena	<=	'0';
				sync_timer1	<=	'0';
				sync_timer2	<= '1';
				sync_timer3	<=	'1';
					IF(max_tick1	=	'1') THEN
						IF(sw	=	'1') THEN
							nx_state <=	state2;
						ELSE 
							nx_state	<=	state0;
						END IF;
					ELSE
						nx_state	<=	state1;
					END IF;
-------------------------------------------------
				WHEN state2 =>
				debsw_b		<=	'0';
				cont1_ena	<=	'0';
				cont2_ena	<=	'1';
				enacont		<=	'0';
				disp        <=	'0';
				cont3_ena	<=	'0';
				sync_timer1	<=	'1';
				sync_timer2	<= '0';
				sync_timer3	<=	'1';
					IF(max_tick2	=	'1') THEN
						IF(sw	=	'1') THEN
							nx_state <=	state3;
						ELSE 
							nx_state	<=	state0;
						END IF;
					ELSE
						nx_state	<=	state2;
					END IF;
-------------------------------------------------
				WHEN state3	=>
				debsw_b		<=	'0';
				cont1_ena	<=	'0';
				cont2_ena	<=	'0';
				disp        <=	'0';
				enacont		<=	'0';
				disp        <=	'0';
				cont3_ena	<=	'1';
				sync_timer1	<=	'1';
				sync_timer2	<= '1';
				sync_timer3	<=	'0';
					IF(max_tick3	=	'1') THEN
						IF(sw	=	'1') THEN
							nx_state <=	state4;
						ELSE 
							nx_state	<=	state0;
						END IF;
					ELSE
						nx_state	<=	state3;
					END IF;
-----------------------------------------------
				WHEN state4	=>
				debsw_b		<=	'1';
				cont1_ena	<=	'0';
				cont2_ena	<=	'0';
				enacont		<=	'0';
				disp        <=	'1';
				cont3_ena	<=	'0';
				sync_timer1	<=	'1';
				sync_timer2	<= '1';
				sync_timer3	<=	'1';
				nx_state <=	state5;
-----------------------------------------------					
				WHEN state5	=>
					debsw_b		<=	'0';
					cont1_ena	<=	'0';
					cont2_ena	<=	'0';
					enacont		<=	'1';
					disp        <=	'0';
					cont3_ena	<=	'0';
					sync_timer1	<=	'1';
					sync_timer2	<= '1';
					sync_timer3	<=	'1';
					IF(mxt='1')THEN
					IF(sw = '1') THEN
						
							nx_state <=	state4;
						
					ELSE 
							nx_state	<= state0;
					END IF;
					ELSE
							nx_state <=	state5;
					END IF;
			END CASE;
		END PROCESS;		
-----------------------------------------------------------------------------------
timer0: 	ENTITY work.univ_bin_counter
			GENERIC MAP(N=> 24)
			PORT MAP	(rst			=>	rst,
						 ena			=>	enacont,
						 clk			=>	clk,
						 load			=> '0',
						 num_in		=> "100000001001011010000000",
						 max			=>	"001000000001111111111111",
						 syn_clr		=>	'0',
						 up			=> '1',
						 max_tick	=>	mxt);
timer1: 	ENTITY work.univ_bin_counter
			GENERIC MAP(N=> 17)
			PORT MAP	(rst			=>	rst,
						 ena			=>	cont1_ena,
						 clk			=>	clk,
						 load			=> '0',
						 num_in		=> "10100010110000110",
						 max			=>	"10100010110000110",
						 syn_clr		=>	sync_timer1,
						 up			=> '1',
						 max_tick	=>	max_tick1);


timer2: 	ENTITY work.univ_bin_counter
			GENERIC MAP(N=> 17)
			PORT MAP	(rst			=>	rst,
						 ena			=>	cont2_ena,
						 clk			=>	clk,
						 load			=> '0',
						 num_in		=> "10100010110000110",
						 max			=>	"10100010110000110",
						 syn_clr		=>	sync_timer2,
						 up			=> '1',
						 max_tick	=>	max_tick2);
timer3: 	ENTITY work.univ_bin_counter
			GENERIC MAP(N=> 17)
			PORT MAP	(rst			=>	rst,
						 ena			=>	cont3_ena,
						 clk			=>	clk,
						 load			=> '0',
						 num_in		=> "10100010110000110",
						 max			=>	"10100010110000110",
						 syn_clr		=>	sync_timer3,
						 up			=> '1',
						 max_tick	=>	max_tick3);
						
END ARCHITECTURE rtl;
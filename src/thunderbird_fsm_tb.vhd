--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------

-- TEST PLAN --------------------

-- 1. Put on the reset state to see if both left and right start off in the OFF state
-- 2. Test left lights when left = 1: OFF -> L1 -> L2 -> L3 -> OFF
-- 3. Test right lights when right = 1: OFF -> R1 -> R2 -> R3 -> OFF
-- 3. Test hazard lights when left = 1 and right = 1: OFF -> ON

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
         i_reset     : in  std_logic;
         i_clk 	     : in  std_logic;
         i_left      : in  std_logic;
         i_right     : in  std_logic;
         o_lights_L  : out  std_logic_vector(2 downto 0);
         o_lights_R  : out  std_logic_vector(2 downto 0)
        );
	end component thunderbird_fsm;

	-- test I/O signals
	signal i_reset     : std_logic := '0';
    signal i_clk 	   : std_logic := '0';
    signal i_left      : std_logic := '0';
    signal i_right     : std_logic := '0';
    
    signal o_lights_L : std_logic_vector(2 downto 0);
    signal o_lights_R : std_logic_vector(2 downto 0);
    
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
  	-- PORT MAPS ---------------------------------------------------
	-- Instantiate the Unit Under Test (UUT)
   UUT : thunderbird_fsm
   port map (
         i_reset     => i_reset,
         i_clk 	     => i_clk, 
         i_left      => i_left,
         i_right     => i_right,
         o_lights_L  => o_lights_L,
         o_lights_R  => o_lights_R
   );
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
	   loop --need a loop to keep the clock going (EX: hazard lights don't stop blinking)
            i_clk <= '0';
            wait for k_clk_period/2; --makes low for half cycle
            i_clk <= '1';
            wait for k_clk_period/2; --makes high for half cycle
       end loop;
	end process;
	-----------------------------------------------------
	
	-- Test Plan Process --------------------------------
sim_proc: process
	begin
	
	-- TEST 1: RESET
	   -- forces light OFF
	   
	   i_reset <= '1';
	   wait for k_clk_period;
	   
	   i_reset <= '0';
	   wait for k_clk_period;
	   
	   assert o_lights_L = "000" AND o_lights_R = "000" report "lights should be OFF" severity failure;
	   	
	-- TEST 2: LEFT
	   -- makes lights cycle through left
	   
	   i_left <= '1';
	   
	   wait for k_clk_period;
	   assert o_lights_L = "001" AND o_lights_R = "000" report "left light for L1 should be ON" severity failure;

	   wait for k_clk_period;
	   assert o_lights_L = "011" AND o_lights_R = "000" report "left, middle light for L1 should be ON" severity failure;

	   wait for k_clk_period;
	   assert o_lights_L = "111" AND o_lights_R = "000" report "left, middle, right light for L1 should be ON" severity failure;
	   wait for k_clk_period;
	   assert o_lights_L = "000" AND o_lights_R = "000" report "all left should be OFF" severity failure;
    
       i_left <= '0';



-- TEST 3: RIGHT
	   -- makes lights cycle through right
	   
	   i_right <= '1';
	   
	   wait for k_clk_period;
	   assert o_lights_R = "001" AND o_lights_L = "000" report "first light for R1 should be ON" severity failure;

	   wait for k_clk_period;
	   assert o_lights_R = "011" AND o_lights_L = "000" report "first and second lights for R1 should be ON" severity failure;

	   wait for k_clk_period;
	   assert o_lights_R = "111" AND o_lights_L = "000" report "all lights for R1 should be ON" severity failure;
	   
	   wait for k_clk_period;
	   assert o_lights_R = "000" AND o_lights_L = "000" report "all right should be OFF" severity failure;
    
       i_right <= '0';
       
       
 -- TEST 4: HAZARD LIGHT
    --when right and left are 1
        -- lights should be ON for a clock period, then OFF
        
       i_right <= '1';
       i_left <= '1';
	   
	   wait for k_clk_period;
	   assert o_lights_R = "111" AND o_lights_L = "111" report "left and right sides should be ON" severity failure;

	   wait for k_clk_period;
	   assert o_lights_R = "000" AND o_lights_L = "000" report "left and right sides should be OFF" severity failure;

       i_right <= '0';
       
     wait;
   end process;
        
	
end test_bench;

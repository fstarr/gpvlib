--------------------------------------------------------------------------------
-- Engineer:		sfo
--
-- Create Date:		12:12:01 05/13/2013
-- Module Name:		freqDiv - testbench
-- Description:		VHDL testbench for frequency divider module.
-- 
-- Dependencies:	none
-- 
-- Revision:		0.01 - File Created
--
-- Additional Comments:
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY freqDiv_tb IS
END freqDiv_tb;

ARCHITECTURE behavior OF freqDiv_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT freqDiv
	GENERIC(
		constant scaling_factor : integer
	);
	PORT(
		rst : IN  std_logic;
		clk : IN  std_logic;
		clkdv : OUT  std_logic
	);
	END COMPONENT;

	--Inputs
	signal rst : std_logic := '0';
	signal clk : std_logic := '0';

	--Outputs
	signal clkdv : std_logic;

	-- Clock period definitions
	constant clk_period : time := 15.151515151515 ns;
	
BEGIN
	
	-- Instantiate the Unit Under Test (UUT)
	uut: freqDiv
	GENERIC MAP (
		scaling_factor => 16
	)
	PORT MAP (
		rst => rst,
		clk => clk,
		clkdv => clkdv
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	-- Stimulus process
	stim_proc: process
	begin
		-- hold reset state for 100 ns.
		rst <= '1';
		wait for 100 ns;	
		rst <= '0';
		wait for clk_period*10;

		-- insert stimulus here 

		wait;
	end process;

END;

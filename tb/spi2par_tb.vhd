--------------------------------------------------------------------------------
-- Engineer:		sfo
--
-- Create Date:		09:05:05 05/07/2013
-- Module Name:		spi2par - testbench
-- Description:		VHDL testbench for the SPI data collector.
-- 
-- Dependencies:	none
-- 
-- Revision:		Revision 0.01 - File Created
--
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.math_real.ALL;
USE ieee.numeric_std.ALL;

ENTITY spi2par_tb IS
END spi2par_tb;

ARCHITECTURE behavior OF spi2par_tb IS

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT spi2par
	PORT(
		clk : IN  std_logic;
		rst : IN  std_logic;
		ce  : IN  std_logic;
		din_rdy : IN  std_logic;
		din : IN  std_logic;
		dout : OUT  std_logic_vector(31 downto 0);
		dout_valid : OUT  std_logic
	);
	END COMPONENT;

	-- Inputs
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal ce  : std_logic := '0';
	signal din_rdy : std_logic := '0';
	signal din : std_logic := '0';

	-- Outputs
	signal dout : std_logic_vector(31 downto 0);
	signal dout_valid : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

	signal input_data: std_logic_vector( 0 downto 0 ) := "0";

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: spi2par
	PORT MAP (
		clk => clk,
		rst => rst,
		ce => ce,
		din_rdy => din_rdy,
		din => din,
		dout => dout,
		dout_valid => dout_valid
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;
 

	-- Stimulus process
	stim_proc: process
		variable seed1, seed2: positive;
		variable rand: real;
	begin
		ce <= '0';
		-- hold reset state for 10 clk cycles.
		rst <= '1';
		wait for clk_period*10;	
		rst <= '0';
		wait for clk_period*10;
		-- insert stimulus here 

		ce <= '1';

		for j in 1 to 5 loop
			-- set ready signal
			din_rdy <= '1';
			wait for clk_period;
			din_rdy <= '0';
			
			-- generate random input data on din
			for i in 1 to 32 loop
				UNIFORM( seed1, seed2, rand );
				input_data <= std_logic_vector( to_unsigned( integer( rand ), 1 ) );
				din <= input_data(0);
				wait for clk_period;
			end loop;
		end loop;

		wait;
	end process;

END;

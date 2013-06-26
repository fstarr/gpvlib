--------------------------------------------------------------------------------
-- Engineer:		sfo
--
-- Create Date:		12:31:54 06/26/2013
-- Module Name:		par2spi - testbench
-- Description:		VHDL testbench for the SPI data generator.
-- 
-- Dependencies:	none
-- 
-- Revision:		0.01 - File Created
-- 
-- Additional Comments:
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
ENTITY par2spi_tb IS
END par2spi_tb;

ARCHITECTURE behavior OF par2spi_tb IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT par2spi
	PORT(
		sysrst_i : IN  std_logic;
		sclk_i : IN  std_logic;
		data_i : IN  std_logic_vector(19 downto 0);
		din_rdy_i : IN  std_logic;
		addr_i : IN  std_logic_vector(2 downto 0);
		data_o : OUT  std_logic;
		sclk_o : OUT  std_logic;
		sync_n_o : OUT  std_logic;
		ldac_n_o : OUT  std_logic
	);
	END COMPONENT;
	

	--Inputs
	signal sysrst_i : std_logic := '0';
	signal sclk_i : std_logic := '0';
	signal data_i : std_logic_vector(19 downto 0) := (others => '0');
	signal din_rdy_i : std_logic := '0';
	signal addr_i : std_logic_vector(2 downto 0) := (others => '0');

	--Outputs
	signal data_o : std_logic;
	signal sclk_o : std_logic;
	signal sync_n_o : std_logic;
	signal ldac_n_o : std_logic;
	
	constant clk_period : time := 20 ns;
	
BEGIN
	
	-- Instantiate the Unit Under Test (UUT)
	uut: par2spi
	PORT MAP (
		sysrst_i => sysrst_i,
		sclk_i => sclk_i,
		data_i => data_i,
		din_rdy_i => din_rdy_i,
		addr_i => addr_i,
		data_o => data_o,
		sclk_o => sclk_o,
		sync_n_o => sync_n_o,
		ldac_n_o => ldac_n_o
	);

	-- Clock process definitions
	clk_process :process
	begin
	sclk_i <= '0';
	wait for clk_period/2;
	sclk_i <= '1';
	wait for clk_period/2;
	end process;

	-- Stimulus process
	stim_proc: process
	begin		
	-- hold reset state for 100 ns.
	sysrst_i <= '1';
	wait for 100 ns;

	sysrst_i <= '0';
	wait for clk_period*10;

	-- insert stimulus here
	data_i <= x"DEADB";
	addr_i <= "001";	-- DAC Register
	din_rdy_i <= '1';
	wait for clk_period;
	
	for j in 1 to 24 loop
		din_rdy_i <= '0';
		wait for clk_period;
	end loop;

	wait;
	end process;

END;

---------------------------------------------------------------------------------
-- Engineer:		sfo
--
-- Create Date:		11:07:10 05/13/2013
-- Module Name:		freqDiv - Behavioral
-- Description:		The frequency divider module divides the input clock
--			frequency by the provided sampling factor and thus
--			generates the lower output frequency.
--			
--			SF = Fin / Fout
--
-- Dependencies:	none
--
-- Revision:		0.10 - Module function verified by VHDL simulation.
--			0.01 - File Created
--
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity freqDiv is
	Generic (
		-- set scaling factor (sf = fin / fout)
		constant scaling_factor : integer := 2
	);
	Port (
		rst	: in  STD_LOGIC;
		clk	: in  STD_LOGIC;
		clkdv	: out  STD_LOGIC);

	constant int_sf	: integer := scaling_factor / 2;
end freqDiv;

architecture Behavioral of freqDiv is
	signal int_cnt	: integer := 0;
	signal int_clkdv: std_logic := '1';
begin
	-- Frequency divider process
	freqdiv: process(rst, clk)
	begin
		if( rst = '1') then
			int_cnt <= 0;
			int_clkdv <= '1';
		elsif( rising_edge( clk ) ) then
			if( int_cnt = (int_sf-1) ) then
				int_clkdv <= not int_clkdv;
				int_cnt <= 0;
			else
				int_cnt <= int_cnt+1;
			end if;
		end if;
	end process;

	-- Signal routing
	clkdv <= int_clkdv;

end Behavioral;


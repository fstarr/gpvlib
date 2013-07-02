----------------------------------------------------------------------------------
-- Engineer:		sfo
-- 
-- Create Date:		10:34:23 06/26/2013
-- Module Name:		par2spi - Behavioral
-- Description:		Data generator that transforms parallel input data
-- 			into a serial output bit stream using a SPI-like output
-- 			interface.
-- 
-- 			See doc/par2spi_ctrlfsm.png for a graphical representation
-- 			of the controller FSM.
-- 
-- 			For simulation in Xilinx iSim use tb/par2spi_tb.vhd
-- 			together with waveform config file tb/par2spi_tb.wcfg.
--
-- Dependencies:	math_pack:log2 (src/math_pack.vhd)
--
-- Revision:		0.10 - Module functionally validated on RTL (iSim).
-- 			0.01 - File Created.
--
-- Additional Comments:	
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.math_pack.all;

entity par2spi is
	Generic (
		constant data_width : integer := 20;
		constant addr_width : integer := 3
	);
	Port (
		sysrst_i	: in  STD_LOGIC;	-- system reset
		sclk_i		: in  STD_LOGIC;	-- serial interface clk (in)
		data_i		: in  STD_LOGIC_VECTOR ( data_width-1 downto 0 );
		din_rdy_i	: in  STD_LOGIC;	-- input data valid
		addr_i		: in  STD_LOGIC_VECTOR ( addr_width-1 downto 0 );
		data_o		: out STD_LOGIC;	-- serial output bit stream
		sclk_o		: out STD_LOGIC;	-- serial interface clk (out)
		sync_n_o	: out STD_LOGIC;	-- output bit stream syncronisation
		ldac_n_o	: out STD_LOGIC;	-- output bit stream valid
		reset_n_o	: out STD_LOGIC;	-- reset
		clr_n_o		: out STD_LOGIC		-- clear
	);
end par2spi;

architecture Behavioral of par2spi is

	-- controller fsm
	type p2s_fsmtype is ( ctrl_init, idle, input, write_output, finish_output );
	signal cstate	: p2s_fsmtype := ctrl_init;
	signal nstate	: p2s_fsmtype := ctrl_init;

	-- internal signals
	signal rst		: std_logic := '0';
	signal sclk		: std_logic := '0';
	signal output_reg	: std_logic_vector( addr_width + data_width downto 0 ) := ( others => '0' );

	signal data_cnt		: integer range 0 to ( addr_width + data_width ) := 0;

begin

	fsm_state_update: process( rst, sclk )
	begin
		if( rst = '1' ) then
			cstate <= ctrl_init;
		elsif( rising_edge( sclk ) ) then
			cstate <= nstate;
		end if;
	end process;

	fsm_output: process
	begin
		wait until rising_edge( sclk );

		case cstate is
			when ctrl_init =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;
				-- set DAC in reset state
				reset_n_o <= '0';
				clr_n_o <= '0';

			when idle =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;
				-- set DAC in operating mode
				-- (set output according to DAC input register)
				reset_n_o <= '1';
				clr_n_o <= '1';

			when input =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;
				-- set DAC in operating mode
				-- (set output according to DAC input register)
				reset_n_o <= '1';
				clr_n_o <= '1';

				output_reg <= '0' & addr_i & data_i;

			when write_output =>
				sync_n_o <= '0';
				ldac_n_o <= '1';
				data_cnt <= data_cnt + 1;
				-- set DAC in operating mode
				-- (set output according to DAC input register)
				reset_n_o <= '1';
				clr_n_o <= '1';

				data_o <= output_reg( addr_width + data_width - data_cnt );

			when finish_output =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '0';
				data_cnt <= 0;
				-- set DAC in operating mode
				-- (set output according to DAC input register)
				reset_n_o <= '1';
				clr_n_o <= '1';

			when others =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;
				-- set DAC in reset state
				reset_n_o <= '0';
				clr_n_o <= '0';
		end case;
	end process;

	fsm_transition: process( cstate, din_rdy_i, data_cnt )
	begin
		nstate <= cstate;

		case cstate is
			when ctrl_init =>
				nstate <= idle;

			when idle =>
				if( din_rdy_i = '1' ) then
					nstate <= input;
				else
					nstate <= idle;
				end if;

			when input =>
				nstate <= write_output;

			when write_output =>
				if( data_cnt < 23 ) then
					nstate <= write_output;
				else
					nstate <= finish_output;
				end if;

			when finish_output =>
				nstate <= idle;

			when others =>
				nstate <= ctrl_init;
		end case;
	end process;

	-- -------------- --
	-- signal mapping --
	--------------------

	-- internal signals
	rst <= sysrst_i;
	sclk <= sclk_i;

	-- output ports
	sclk_o <= sclk;

end Behavioral;


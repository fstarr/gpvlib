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
-- 			together with waveform config file tb/par2spi_tb.wcfg
--
-- Dependencies:	math_pack:log2 (src/math_pack.vhd)
--
-- Revision:		0.01 - File Created
--
-- Additional Comments:	
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.math_pack.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

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
		ldac_n_o	: out STD_LOGIC		-- output bit stream valid
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
	signal sclk_h		: std_logic := '0';
	signal output_reg	: std_logic_vector( addr_width + data_width downto 0 ) := ( others => '1' );

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

	fsm_output: process( cstate, sclk_h )
	begin
		case cstate is
			when ctrl_init =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;

			when idle =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;

			when input =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;

-- 				input_reg <= data_i;
-- 				addr_reg <= addr_i;
				output_reg <= '1' & addr_i & data_i;

			when write_output =>
				sync_n_o <= '0';
				ldac_n_o <= '1';
				data_cnt <= data_cnt + 1;

				-- data ...
				data_o <= output_reg( addr_width + data_width - data_cnt );

			when finish_output =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '0';
				data_cnt <= 0;

			when others =>
				data_o <= '0';
				sync_n_o <= '1';
				ldac_n_o <= '1';
				data_cnt <= 0;
		end case;
	end process;

	fsm_transition: process( sclk )
	begin
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
				if( data_cnt < 24 ) then
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

	int_clk: process( sclk )
	begin
		if( rising_edge( sclk ) ) then
			sclk_h <= not sclk_h;
		end if;
	end process;

	-- -------------- --
	-- signal mapping --
	--------------------

	-- internal signals
	rst <= sysrst_i;
	sclk <= sclk_i;
	sclk_o <= sclk;

end Behavioral;


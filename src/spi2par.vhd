----------------------------------------------------------------------------------
-- Engineer: 		sfo
-- 
-- Create Date:		11:10:07 05/06/2013 
-- Module Name:		spi2par - Behavioral 
-- Description:		SPI data collector that transform serial input into
--			parallel output.
--
--			See doc/spi2par_ctrlfsm.png for a graphical representation
--			of the controller FSM.
--
--			For simulation in Xilinx iSim use tb/spi2par_tb.vhd
--			together with waveform config file tb/spi2par_tb.wcfg
--
-- Dependencies:	math_pack:log2 (src/math_pack.vhd)
--
--
-- Revision: 		0.10 - On RTL functionally validated module (iSim)
-- 			0.01 - File Created
--
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.std_logic_arith.all;

use work.math_pack.all;

entity spi2par is
	Generic (
		-- set width ouf output data register
		constant dout_width : integer := 32
	);
	Port (
		-- Ctrl ports
		clk		: in  STD_LOGIC;	-- fclk (4.096 MHz)
		sclk		: in  STD_LOGIC;	-- sclk (256kHz <= sclk <= 2.048 MHz)
		rst		: in  STD_LOGIC;
		ce		: in  STD_LOGIC;
		-- SPI-like interface
		din_rdy		: in  STD_LOGIC;
		din		: in  STD_LOGIC;
		sclk_o		: out STD_LOGIC;
		-- Output interface
		dout		: out  STD_LOGIC_VECTOR (dout_width-1 downto 0);
		dout_valid	: out  STD_LOGIC
	);
	-- set width of internal counter. no need to touch this!
	constant cnt_width : integer := integer(log2( natural( dout_width ) ) );
end spi2par;

architecture Behavioral of spi2par is

	-- controller fsm
	type fsmtype is ( ctrl_init, idle, delay, readbit0, readbit1, finalread, output );
	signal cstate	: fsmtype := ctrl_init;	-- current state
	signal nstate	: fsmtype := ctrl_init;	-- next state

	-- internal signals
	signal s_cnt  : integer := 0;
	signal sa_cnt  : integer := 0;
	signal s_dout : std_logic_vector( dout_width-1 downto 0 ) := ( others => '0' );
	signal sclk_active : std_logic := '0';

begin
	
	fsm_state_update: process( rst, sclk )
	begin
		if( rst = '1' ) then
			cstate <= ctrl_init;
		elsif( ce = '1' ) then
			if( rising_edge( sclk ) ) then
				cstate <= nstate;
			end if;
		end if;
	end process;
	
	fsm_output: process( cstate )
	begin
		case cstate is
			when ctrl_init =>
				-- resest all outputs and internals
				dout <= ( others => '0' );
				dout_valid <= '0';
				s_cnt <= 0;
				s_dout <= ( others => '0' );
				sclk_active <= '0';

			when idle =>
				-- NOP
				dout_valid <= '0';
				sclk_active <= '0';

			when delay =>
				dout_valid <= '0';
				sclk_active <= '1';

			when readbit0 =>
				-- read current bit from din
				dout_valid <= '0';
				s_dout( 31-s_cnt ) <= din;
				s_cnt <= s_cnt + 1;
				sclk_active <= '1';

			when readbit1 =>
				-- read current bit from din
				dout_valid <= '0';
				s_dout( 31-s_cnt ) <= din;
				s_cnt <= s_cnt + 1;
				sclk_active <= '1';

			when finalread =>
				-- read current bit from din
				dout_valid <= '0';
				s_dout( 31-s_cnt ) <= din;
				s_cnt <= s_cnt + 1;
				sclk_active <= '0';

			when output =>
				-- present 32-bit output register
				-- to output port (+ enable valid signal)
				dout <= s_dout;
				dout_valid <= '1';
				-- reset internal counter
				s_cnt <= 0;
				sclk_active <= '0';

			when others =>
				null;
		end case;
	end process;
	
	fsm_state_transition: process( cstate, din_rdy )
	begin
		nstate <= cstate;
		
		case cstate is
			when ctrl_init =>
				if( din_rdy = '1' ) then
					nstate <= delay;
				else
					nstate <= idle;
				end if;

			when idle =>
				if( din_rdy = '1' ) then
					nstate <= delay;
				else
					nstate <= idle;
				end if;

			when delay =>
				nstate <= readbit0;

			when readbit0 =>
				if( s_cnt < 30 ) then
					nstate <= readbit1;
				else
					nstate <= finalread;
				end if;
				
			when readbit1 =>
				if( s_cnt < 30 ) then
					nstate <= readbit0;
				else
					nstate <= finalread;
				end if;
			
			when finalread =>
				nstate <= output;

			when output =>
				if( din_rdy = '1' ) then
					nstate <= delay;
				else
					nstate <= idle;
				end if;
				
			when others =>
				nstate <= ctrl_init;
		end case;
	end process;

	sclk_o <= sclk and sclk_active;
end Behavioral;

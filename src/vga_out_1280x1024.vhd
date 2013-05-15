----------------------------------------------------------------------------------
-- Engineer: 		sfo
-- 
-- Create Date:		19:10:05 12/30/2008 
-- Module Name:		vga_out - Behavioral 
-- Target Devices:	Spartan 3AN (XC3S700AN)
--
-- Description:		Sample VGA driver.
--			Screen resolution: 1280x1024 @ 74 Hz
--			system freq.: 133 MHz
--			pixel freq.: 133 MHz
--
-- Dependencies:	none
--
-- Revision:		0.01 - File Created
--
-- Additional Comments:
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vga_out is
Port (
	red_in : in  STD_LOGIC_VECTOR (3 downto 0);
	green_in : in  STD_LOGIC_VECTOR (3 downto 0);
	blue_in : in  STD_LOGIC_VECTOR (3 downto 0);
	red_out : out  STD_LOGIC_VECTOR (3 downto 0);
	green_out : out  STD_LOGIC_VECTOR (3 downto 0);
	blue_out : out  STD_LOGIC_VECTOR (3 downto 0);
	clk : in  STD_LOGIC;
	hsync_out : out  STD_LOGIC;
	vsync_out : out  STD_LOGIC );
end vga_out;

architecture Behavioral of vga_out is
	signal hsync, vsync: std_logic;
	signal video_on, video_on_h, video_on_v: std_logic;
	signal h_count, v_count: std_logic_vector( 10 downto 0 );

begin
	video_on <= video_on_h and video_on_v;
	
	process( clk )	-- we're working w/ 133 MHz
	begin
		if( rising_edge( clk ) ) then
			if( h_count = 1680 ) then		-- right boundary
				h_count <= "00000000000";	-- reset
			else
				h_count <= h_count + 1;		-- incr. horizontal pixel counter
			end if;
			
-- 			@ 108 MHz
-- 			HSync:	0         1279 1323 1431  1680	 clk cycles @ pixel clk
-- 				|            |    |    |    |	 |Tdisp| = 1280
-- 								 |Tfp|   =   43
-- 				¯¯¯¯¯ ... ¯¯¯¯¯¯¯¯|____|¯¯¯¯	 |Tpw|   =  108
-- 								 |Tbp|   =  248
-- 				|    Tdisp   | Tfp|Tpw| Tbp|	 + ------------
-- 				|           Ts             |	 |Ts|    = 1680

			
			if( ( h_count < 1431 ) and ( h_count >= 1323 ) ) then
				-- set HSync
				hsync <= '0';
			else
				hsync <= '1';
			end if;
			
-- 			@ 108 MHz
-- 			VSync:	0         1023 1024 1027 1065	clk cycles/1685 @ p.c.
-- 				|            |    |   |    |	|Tdisp| = 1024
-- 								|Tfp|   =    1
-- 				¯¯¯¯¯ ... ¯¯¯¯¯¯¯¯|___|¯¯¯¯	|Tpw|   =    3
-- 								|Tbp|   =   38
-- 				|    Tdisp   | Tfp|Tpw| Tbp|	+ ------------
-- 				|           Ts             |	|Ts|    = 1066
			--
			
			if( ( v_count >= 1065 ) and ( h_count >= 1350 ) ) then
				v_count <= "00000000000";	-- reset v_count if lower boundary reached
			elsif( h_count = 1350 ) then
				v_count <= v_count + 1;		-- incr. v_count as soon as HSync in Tpw
			end if;
			
			-- set VSync (see diagram above)
			if( ( v_count < 1027 ) and ( v_count >= 1024 ) ) then
				vsync <= '0';
			else
				vsync <= '1';
			end if;
			
			-- mark writeable area
			if( h_count <= 1279 ) then
				video_on_h <= '1';
			else
				video_on_h <= '0';
			end if;
			
			if( v_count <= 1023 ) then
				video_on_v <= '1';
			else
				video_on_v <= '0';
			end if;
		end if;
	end process;
	
	-- set colors using DIP-switches (8 colors)
	red_out   <= ( others => ( red_in(0) and video_on ) );
	green_out <= ( others => ( green_in(0) and video_on ) );
	blue_out  <= ( others => ( blue_in(0) and video_on ) );
	
	hsync_out <= hsync;
	vsync_out <= vsync;

end Behavioral;


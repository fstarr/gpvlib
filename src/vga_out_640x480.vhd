----------------------------------------------------------------------------------
-- Engineer: 		sfo
-- 
-- Create Date:		12:24:00 12/29/2008 
-- Module Name:   	vga_out - Behavioral 
-- Description: 	Sample VGA driver
--			resolution: 640x480 @ 60 Hz
--			system freq.: 50 MHz
--			pixel freq.: 25 MHz
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_out is
    Port ( red_in : in  STD_LOGIC_VECTOR (3 downto 0);
           green_in : in  STD_LOGIC_VECTOR (3 downto 0);
           blue_in : in  STD_LOGIC_VECTOR (3 downto 0);
           red_out : out  STD_LOGIC_VECTOR (3 downto 0);
           green_out : out  STD_LOGIC_VECTOR (3 downto 0);
           blue_out : out  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC;
           hsync_out : out  STD_LOGIC;
           vsync_out : out  STD_LOGIC);
           --pixel_row : out  STD_LOGIC_VECTOR (9 downto 0);
           --pixel_column : out  STD_LOGIC_VECTOR (9 downto 0));
end vga_out;

architecture Behavioral of vga_out is
	signal clk_25Mhz: std_logic := '0';
	
	signal hsync, vsync: std_logic;
	signal video_on, video_on_h, video_on_v: std_logic;
	signal h_count, v_count: std_logic_vector( 9 downto 0 );
begin

	video_on <= video_on_h and video_on_v;
	
	-- 25 MHz Pixeltakt erzeugen
	process( clk, clk_25Mhz )
	begin
		if( clk='1' and clk'event ) then
			if( clk_25Mhz = '0' ) then
				clk_25Mhz <= '1';
			else
				clk_25Mhz <= '0';
			end if;
		end if;
	end process;
	
	process( clk_25Mhz )
	begin
		if( clk_25Mhz='1' and clk_25Mhz'event ) then
			if( h_count = 799 ) then		-- rechter Rand erreicht
				h_count <= "0000000000";	-- reset
			else
				h_count <= h_count + 1;		-- Pixel-Counter horizontal inkr.
			end if;
			
		-- @ 25 MHz
		-- HSync: 0           639 655 751  799	Clk-Zyklen im Pixeltakt
		--	  |             |   |   |    |	|Tdisp| = 640
		--					|Tfp|   =  16
		--	  ¯¯¯¯¯ ... ¯¯¯¯¯¯¯¯|___|¯¯¯¯	|Tpw|   =  96
		--					|Tbp|   =  48
		--	  |    Tdisp    |Tfp|Tpw| Tbp|	+ -----------
		--	  |           Ts             |	|Ts|    = 800
			
			if( ( h_count < 751 ) and ( h_count >= 655 ) ) then	-- HSync setzen
				hsync <= '0';
			else
				hsync <= '1';
			end if;
			
		-- @ 25 MHz
		-- VSync: 0           479 489 491  520	Clk-Zyklen/800 im Pixeltakt
		--	  |             |   |   |    |	|Tdisp| = 480
		--					|Tfp|   =  10
		--	  ¯¯¯¯¯ ... ¯¯¯¯¯¯¯¯|___|¯¯¯¯	|Tpw|   =   2
		--					|Tbp|   =  29
		--	  |    Tdisp    |Tfp|Tpw| Tbp|	+ -----------
		--	  |           Ts             |	|Ts|    = 521
			
			if( ( v_count >= 520 ) and ( h_count >= 695 ) ) then
				v_count <= "0000000000";	-- reset v_count wenn unterer Bildschirmrand erreicht
			elsif( h_count = 695 ) then
				v_count <= v_count + 1;		-- inkr. v_count sobald HSync im Bereich Tpw
			end if;
			
			-- VSync setzen (Verlauf siehe oben)
			if( ( v_count < 491 ) and ( v_count >= 489 ) ) then
				vsync <= '0';
			else
				vsync <= '1';
			end if;
			
			-- beschreibbaren Bereich markieren
			if( h_count <= 639 ) then
				video_on_h <= '1';
				--pixel_column <= h_count;
			else
				video_on_h <= '0';
			end if;
			
			if( v_count <= 479 ) then
				video_on_v <= '1';
				--pixel_row <= v_count;
			else
				video_on_v <= '0';
			end if;
		end if;
	end process;
	
	-- Farbenbelegung hier mittels Schalter wechselbar (8 Farben)
	red_out   <= ( others => ( red_in(0) and video_on ) );
	green_out <= ( others => ( green_in(0) and video_on ) );
	blue_out  <= ( others => ( blue_in(0) and video_on ) );
	
	hsync_out <= hsync;
	vsync_out <= vsync;

end Behavioral;


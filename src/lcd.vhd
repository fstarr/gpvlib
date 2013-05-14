--
--	lcd.vhd
--
--	Copyright (C) 2010, Folker Schwesinger
--
--	VHDL module to print data on a LCD.
--
--	This module is suitable for LCD displays with a controller compatible
--	to one of the following:
--
--		a)	Samsung S6A0069X
--		b)	Samsung KS0066U
--		c)	Hitachi HD44780
--		d)	SMOS SED1278
--		e)	Sitronix ST7066U
--
--	In the current version displays with a size of 4(2)x40 (rows x characters)
--	are supported.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity lcd is
	port(
		clk		: in std_logic;
		reset		: in std_logic;

		lcd_update	: in std_logic;

		lcd_line0	: in std_logic_vector( 319 downto 0 );	-- up to 40 chars/line
		lcd_line1	: in std_logic_vector( 319 downto 0 );
		lcd_line2	: in std_logic_vector( 319 downto 0 );
		lcd_line3	: in std_logic_vector( 319 downto 0 );

		lcd_data	: out std_logic_vector( 3 downto 0 );
		lcd_e		: out std_logic;
		lcd_rs		: out std_logic;
		lcd_rw		: out std_logic
	);
end lcd;

architecture rtl of lcd is
	signal delay:		std_logic_vector( 19 downto 0 ) := ( others => '0' );
	signal delay2:		std_logic_vector( 7 downto 0 ) := ( others => '0' );
	signal lcd_data_int:	std_logic_vector( 7 downto 0 ) := x"C0";

	type state_lcd_type is ( lcdreset, init1, init2, cmd1, cmd2, cmd3, cmd4, cmd5,
				data_line0, data_line1, data_line2, data_line3, lcdok );
	type state_lcd2_type is ( setdata1, setenable1, disable1, setdata2, setenable2, disable );

	signal state_lcd:	state_lcd_type := lcdreset;
	signal state_lcd2:	state_lcd2_type := setdata1;

	signal lcd_e_int:	std_logic;
	signal lcd_rs_int:	std_logic;

	signal write_lcd:	std_logic;

	signal wait_data_cnt:	integer range 1 to 40 := 1;

	signal lcd_data_line0:	std_logic_vector( 319 downto 0 );
	signal lcd_data_line1:	std_logic_vector( 319 downto 0 );
	signal lcd_data_line2:	std_logic_vector( 319 downto 0 );
	signal lcd_data_line3:	std_logic_vector( 319 downto 0 );

	signal lcd_reset:	std_logic;
begin

	--- PROCESSES ---
	lcd_init: process( clk )
	begin
		if( rising_edge( clk ) ) then
			if( lcd_reset = '1' ) then
				if( lcd_update = '1' ) then
					lcd_data_line0 <= lcd_line0;
					lcd_data_line1 <= lcd_line1;
					lcd_data_line2 <= lcd_line2;
					lcd_data_line3 <= lcd_line3;
				else
					lcd_data_line0 <= ( others => '0' );
					lcd_data_line1 <= ( others => '0' );
					lcd_data_line2 <= ( others => '0' );
					lcd_data_line3 <= ( others => '0' );
				end if;
			
				state_lcd <= lcdreset;
				delay <= x"fffff";
				lcd_e_int <= '0';
				lcd_rs_int <= '0';
				write_lcd <= '0';
				wait_data_cnt <= 1;
			else
				if( delay > x"00000" ) then
					delay <= delay - 1;
				else
					case state_lcd is
						when lcdreset =>
							lcd_data_int <= x"33";
							write_lcd <= '1';
							state_lcd <= init1;

						when init1 =>
							lcd_data_int <= x"32";
							write_lcd <= '1';
							state_lcd <= init2;

						when init2 =>
							lcd_data_int <= x"22";
							write_lcd <= '1';
							state_lcd <= cmd1;

						when cmd1 =>
							lcd_data_int <= x"28";
							write_lcd <= '1';
							state_lcd <= cmd2;

						when cmd2 =>
							lcd_data_int <= x"06";
							write_lcd <= '1';
							state_lcd <= cmd3;

						when cmd3 =>
							lcd_data_int <= x"0c";
							write_lcd <= '1';
							state_lcd <= cmd4;

						when cmd4 =>
							lcd_data_int <= x"c0";
							write_lcd <= '1';
							state_lcd <= cmd5;

						when cmd5 =>
							lcd_data_int <= x"01";
							write_lcd <= '1';
							state_lcd <= data_line0;

						when data_line0 =>
							lcd_rs_int <= '1';
							lcd_data_int <= lcd_data_line0( (wait_data_cnt*8-1) downto ((wait_data_cnt-1)*8) );
							write_lcd <= '1';

							if( wait_data_cnt >= 20 ) then
								state_lcd <= data_line1;
								wait_data_cnt <= 1;
							else
								state_lcd <= data_line0;
								wait_data_cnt <= wait_data_cnt + 1;
							end if;
							
						when data_line1 =>
							--lcd_rs_int <= '1';
							lcd_data_int <= lcd_data_line2( (wait_data_cnt*8-1) downto ((wait_data_cnt-1)*8) );
							write_lcd <= '1';

							if( wait_data_cnt >= 20 ) then
								state_lcd <= data_line2;
								wait_data_cnt <= 1;
							else
								state_lcd <= data_line1;
								wait_data_cnt <= wait_data_cnt + 1;
							end if;
							
						when data_line2 =>
							--lcd_rs_int <= '1';
							lcd_data_int <= lcd_data_line1( (wait_data_cnt*8-1) downto ((wait_data_cnt-1)*8) );
							write_lcd <= '1';

							if( wait_data_cnt >= 20 ) then
								state_lcd <= data_line3;
								wait_data_cnt <= 1;
							else
								state_lcd <= data_line2;
								wait_data_cnt <= wait_data_cnt + 1;
							end if;
							
						when data_line3 =>
							--lcd_rs_int <= '1';
							lcd_data_int <= lcd_data_line3( (wait_data_cnt*8-1) downto ((wait_data_cnt-1)*8) );
							write_lcd <= '1';

							if( wait_data_cnt >= 20 ) then
								state_lcd <= lcdok;
								wait_data_cnt <= 1;
							else
								state_lcd <= data_line3;
								wait_data_cnt <= wait_data_cnt + 1;
							end if;

						when lcdok => null;

						when others => state_lcd <= lcdreset;
					end case;

					delay <= x"3ffff";	-- 100MHz clk
					--delay <= x"28488";	-- 65.2 MHz clk
				end if;

				if( delay2 > x"00" ) then
					delay2 <= delay2 - 1;
				elsif( write_lcd = '1' ) then
					case state_lcd2 is
						when setdata1 =>
							lcd_data <= lcd_data_int( 7 downto 4 );
							lcd_e_int <= '0';
							state_lcd2 <= setenable1;

						when setenable1 =>
							lcd_e_int <= '1';
							state_lcd2 <= disable1;

						when disable1 =>
							lcd_e_int <= '0';
							state_lcd2 <= setdata2;

						when setdata2 =>
							lcd_data <= lcd_data_int( 3 downto 0 );
							lcd_e_int <= '0';
							state_lcd2 <= setenable2;

						when setenable2 =>
							lcd_e_int <= '1';
							state_lcd2 <= disable;

						when disable =>
							write_lcd <= '0';
							lcd_e_int <= '0';
							state_lcd2 <= setdata1;

						when others =>
							state_lcd2 <= setdata1;
					end case;
				
					delay2 <= x"ff";	-- 100MHz
					--delay2 <= x"a0";	-- 65.2 MHz
				end if;
			end if;
		end if;
	end process lcd_init;

	--- WIRING ---
	lcd_e <= lcd_e_int;
	lcd_rs <= lcd_rs_int;
	lcd_rw <= '0';
	lcd_reset <= lcd_update or reset;
end rtl;

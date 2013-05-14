--
--	lcd_decoder_base.vhd
--
--	Copyright (C) 2010, Folker Schwesinger
--
--	Map HEX codes from input vector to memory addresses
--	of LCD module.
--
--	Suitable for LCD displays with a controller compatible to one of the
--	following:
--		a)	Samsung S6A0069X
--		b)	Samsung KS0066U
--		c)	Hitachi HD44780
--		d)	SMOS SED1278
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity lcd_decoder is
	port(
		iv_Nibble	: in std_logic_vector( 3 downto 0 );	-- ASCII code
		ov_Byte		: out std_logic_vector( 7 downto 0 )	-- memory address
	);
end lcd_decoder;

architecture rtl of lcd_decoder is
begin
	decode: process( iv_Nibble )
	begin
		case iv_Nibble is
			-- map inputs to address of corresponding
			-- character in cg ram
			when x"1" => ov_Byte <= x"31";	-- '1'
			when x"2" => ov_Byte <= x"32";	-- '2'
			when x"3" => ov_Byte <= x"33";	-- '3'
			when x"4" => ov_Byte <= x"34";	-- '4'
			when x"5" => ov_Byte <= x"35";	-- '5'
			when x"6" => ov_Byte <= x"36";	-- '6'
			when x"7" => ov_Byte <= x"37";	-- '7'
			when x"8" => ov_Byte <= x"38";	-- '8'
			when x"9" => ov_Byte <= x"39";	-- '9'
			when x"a" => ov_Byte <= x"41";	-- 'A'
			when x"b" => ov_Byte <= x"42";	-- 'B'
			when x"c" => ov_Byte <= x"43";	-- 'C'
			when x"d" => ov_Byte <= x"44";	-- 'D'
			when x"e" => ov_Byte <= x"45";	-- 'E'
			when x"f" => ov_Byte <= x"46";	-- 'F'
			when others => ov_Byte <= x"ff";
		end case;
	end process decode;
end rtl;

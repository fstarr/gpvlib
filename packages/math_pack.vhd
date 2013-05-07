package math_pack is
  function log2 (i : natural) return integer;
end math_pack;

package body math_pack is

	function log2( i : natural) return integer is
		variable temp    : integer := i;
		variable ret_val : integer := 0; 
	begin					
		while temp > 1 loop
			ret_val := ret_val + 1;
			temp    := temp / 2;     
		end loop;
		
		return ret_val;
	end log2;
	
end math_pack;
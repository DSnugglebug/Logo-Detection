library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity logo_reader is 
port(
	DATA_IN 	: in std_logic_vector(15 downto 0);
	RD_ADDR 	: out std_logic_vector(17 downto 0);
	raddr 	: in natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;
	data 		: out std_logic_vector(7 downto 0);
	clk 		: in std_logic
);
end logo_reader;

architecture logo_reader_arch of logo_reader is 

begin
	process(clk)
	variable iseven : integer range 0 to 1 := 0;
	variable ADDRESS: integer range 0 to IMG_HEIGHT*IMG_WIDTH := 0;
	
	begin
		if (rising_edge(clk)) then
			ADDRESS := raddr / 2 + LOGOIMGADDR;
			RD_ADDR <= std_logic_vector(to_unsigned(ADDRESS, 18));
			iseven := raddr mod 2;
			
			if (iseven = 0) then
				data <= DATA_IN(7 downto 0);
			else
				data <= DATA_IN(15 downto 8);
			end if;
		end if;
	end process;
end logo_reader_arch;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.global.all;

entity TemplateMean is
	port 
	(
		clk	   : in std_logic;
		working  : in std_logic;
		raddrTG  : out natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT - 1;
		dataTG_in   : in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		data_valid		: out std_logic := '0';
		dataTM_out	   : out std_logic_vector((PIXEL_WIDTH-1) downto 0)
	);
end TemplateMean;

architecture tm of TemplateMean is	
	
	type state_type is (IDLE, READ_DATA, COMTM, READ_WAIT);
	signal curr_state : state_type := IDLE;
	
begin

	process(clk)
	
	variable tempSum : integer := 0;
	variable TGADDR : natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT - 1;
	variable k1 : integer := 0;
	variable k2 : integer := 0;
	begin
		if(rising_edge(clk)) then
			if(working = '1') then
				case curr_state is
					when IDLE =>
							tempSum := 0;
							curr_state <= READ_WAIT;
							data_valid <= '0';
							raddrTG <= 0;
							TGADDR := 0;
					when READ_DATA =>
							data_valid <= '0';
							TGADDR := TGADDR + 1;
							if(TGADDR > (TEMPL_WIDTH * TEMPL_HEIGHT - 1)) then 
								curr_state <= COMTM;
								tempSum := tempSum/(TEMPL_WIDTH*TEMPL_HEIGHT);
							end if;
							raddrTG <= TGADDR;
							curr_state <= READ_WAIT;
					when COMTM =>
							dataTM_out <= std_logic_vector(to_unsigned(tempSum, PIXEL_WIDTH));
							data_valid <= '1';
							tempSum := 0;
					when READ_WAIT =>
							tempSum := tempSum + to_integer(unsigned(dataTG_in)); --####---Be careful to conv2
							curr_state <= READ_DATA;
				end case;
			else ---working---
				data_valid <= '0';
				curr_state <= IDLE;
			end if; -------working---
		end if; --rising clk;
	end process;

end tm;

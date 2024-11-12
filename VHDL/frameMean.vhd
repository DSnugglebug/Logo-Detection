library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.global.all;

entity frameMean is
	port 
	(
		clk	   : in std_logic;
		working  : in std_logic;
		raddrFG  : out natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;
		dataFG_in   : in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		col : in natural range 0 to IMG_WIDTH - 1;
		row : in natural range 0 to IMG_HEIGHT - 1;
		data_valid		: out std_logic := '0';
		dataFM_out	   : out std_logic_vector((PIXEL_WIDTH-1) downto 0)
	);

end frameMean;

architecture fm of frameMean is	
	
	type state_type is (IDLE, READ_DATA, COMFM, READ_WAIT);
	signal curr_state : state_type := IDLE;
	
begin

	process(clk)
	
	variable tempSum : integer := 0;
	variable FGADDR : natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;
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
							raddrFG <= 0;
							FGADDR := 0;
					when READ_DATA =>
							data_valid <= '0';
							FGADDR := FGADDR + 1;
							if(FGADDR > (IMG_WIDTH*IMG_HEIGHT - 1)) then 
								curr_state <= COMFM;
								tempSum := tempSum/(TEMPL_WIDTH*TEMPL_HEIGHT);
							end if;
							raddrFG <= FGADDR;
							curr_state <= READ_WAIT;
					when COMFM =>
							dataFM_out <= std_logic_vector(to_unsigned(tempSum, PIXEL_WIDTH));
							data_valid <= '1';
							tempSum := 0;
					when READ_WAIT =>
							k1 := FGADDR/IMG_WIDTH;
							k2 := FGADDR mod IMG_WIDTH;
							if(k1 > row + 54 or k2 > col + 90) then
							
							else
								tempSum := tempSum + to_integer(unsigned(dataFG_in)); --####---Be careful to conv2
							end if;
							curr_state <= READ_DATA;
				end case;
			else ---working---
				data_valid <= '0';
				curr_state <= IDLE;
			end if; -------working---
		end if; --rising clk;
	end process;

end fm;

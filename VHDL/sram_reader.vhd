library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity sram_reader is
port(
		-- SRAM ACCESS --
		DATA_IN : in STD_LOGIC_VECTOR(15 downto 0);
		RD_ADDR : out STD_LOGIC_VECTOR(17 downto 0);
		-- SRAM CONTROLLER CHANNEL --
		WE_N : OUT STD_LOGIC;
		CE_N : OUT STD_LOGIC;
		OE_N : OUT STD_LOGIC;
		LB_N : OUT STD_LOGIC;
		UB_N : OUT STD_LOGIC;
		
		-- FIFO CHANNEL --
		
		FINISH  : out STD_LOGIC;
		DATA_OUT : out STD_LOGIC_VECTOR(7 downto 0);	
		
		-- CLK and RESET --
		CLK, RESET: in STD_LOGIC	
);
end sram_reader;

architecture sram_reader_arch of sram_reader is

type state_type is (SRAM_WAIT, RD_SRAM, IDLE);
signal curr_state, next_state: state_type;
-- altri segnali interni
signal TEMP_DATA : std_logic_vector(15 downto 0);
signal ADDRESS, next_address : integer range 0 to 2*(IMG_WIDTH * IMG_HEIGHT / 2 )- 1 := 0;

begin
	WE_N <= '1';
	CE_N <= '0';
	OE_N <= '0';
	LB_N <= '0';
	UB_N <= '0';
	
	sync_proc: process(CLK, RESET)
	begin
		if (RESET = '1') then			
			ADDRESS <= TMPIMGADDR;
			curr_state <= RD_SRAM;
		elsif(rising_edge(CLK)) then				
			curr_state <= next_state;
			ADDRESS <= next_address;
		end if;
	end process sync_proc;
	
	state_proc: process(curr_state)
	begin
		case curr_state is
			when RD_SRAM =>
				TEMP_DATA <= DATA_IN;
				DATA_OUT <= TEMP_DATA(7 downto 0);
				
				next_state <= SRAM_WAIT;
			when SRAM_WAIT =>
				DATA_OUT <= TEMP_DATA(15 downto 8);
				next_address <= ADDRESS + 1;

				if (next_address < IMG_WIDTH * IMG_HEIGHT / 2 + 1) then
					
					next_state <= RD_SRAM;
				else 				
					FINISH <= '1';
					next_state <= IDLE;
				end if;
				
			when IDLE =>
		end case;	
	end process state_proc;
	
RD_ADDR <= std_logic_vector(to_unsigned(ADDRESS, 18));

end sram_reader_arch;
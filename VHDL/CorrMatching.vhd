library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

-- Top level of project
ENTITY CorrMatching IS
PORT(		
		-- SRAM CONTROLLER CHANNEL --
		WE_N : OUT STD_LOGIC;
		CE_N : OUT STD_LOGIC;
		OE_N : OUT STD_LOGIC;
		LB_N : OUT STD_LOGIC;
		UB_N : OUT STD_LOGIC;
		
		-- SRAM ACCESS --
		SRAM_ADDRESS : OUT STD_LOGIC_VECTOR(17 downto 0);
		
		-- SRAMDATA --
		SRAMDATA_IN : IN STD_LOGIC_VECTOR(15 downto 0);
		
		-- RESULT --
		RESULT0 : OUT STD_LOGIC;
		RESULT1 : OUT STD_LOGIC;
		RESULT2 : OUT STD_LOGIC;
		RESULT3 : OUT STD_LOGIC;
		
		-- CLK and RESET --
		CLK, RESET: IN STD_LOGIC
		
);
end CorrMatching;

ARCHITECTURE CorrMatching_arch OF TestCorrMatching IS

SIGNAL readfinish : STD_LOGIC;
SIGNAL pixeldata : STD_LOGIC_VECTOR(7 downto 0);

signal sram_address_sram, sram_address_logo : std_logic_vector(17 downto 0);

signal raddrI : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;
signal line_buffer_data_rdI : std_logic_vector((PIXEL_WIDTH- 1) downto 0);

signal raddrT, waddrT : natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT - 1;
signal line_buffer_data_rdT, line_buffer_data_wrT : std_logic_vector((PIXEL_WIDTH- 1) downto 0);
signal wenT : std_logic;

signal line_buffer_data_wrFM : std_logic_vector((PIXEL_WIDTH- 1) downto 0);


signal dataTM :  std_logic_vector((PIXEL_WIDTH- 1) downto 0);

signal line_buffer_data_wrCP1 : std_logic_vector((MEMCELL_WIDTH- 1) downto 0);
signal wenCP1 : std_logic;

signal line_buffer_data_wrSF : std_logic_vector((MEMCELL_WIDTH- 1) downto 0);

signal workingFM : std_logic := '0';
signal valid_FM : std_logic := '0';
signal raddrI_outFM : natural range 0 to IMG_WIDTH * IMG_HEIGHT -1 ;

signal workingTM : std_logic := '0';
signal valid_TM : std_logic := '0';
signal raddrT_outTM : natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT -1 ;

signal workingCPI : std_logic := '0';
signal valid_CPI : std_logic := '0';
signal raddrI_outCP1 : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;
signal raddrT_outCP1 : natural range 0 to TEMPL_WIDTH*TEMPL_HEIGHT - 1;

signal workingCPII : std_logic := '0';
signal valid_CPII : std_logic := '0';
signal raddrFM_outCP2 : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;
signal raddrT_outCP2 : natural range 0 to TEMPL_WIDTH*TEMPL_HEIGHT - 1;

signal workingSF : std_logic := '0';
signal valid_SF : std_logic := '0';
signal raddrFM_outSF : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;
signal raddrI_outSF : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;

signal workingCS : std_logic := '0';
signal valid_CS : std_logic := '0';
signal raddrSF_outCS : natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;

signal row : natural range 0 to IMG_HEIGHT - 1 ;
signal col : natural range 0 to IMG_WIDTH - 1 ;


COMPONENT sram_reader IS
	PORT(
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
		
		FINISH  	: out STD_LOGIC;
		DATA_OUT : out STD_LOGIC_VECTOR(7 downto 0);	
		
		-- CLK and RESET --
		CLK, RESET: in STD_LOGIC		
	);
END COMPONENT sram_reader;

component logo_reader is 
port(
	DATA_IN : in std_logic_vector(15 downto 0);
	RD_ADDR : out std_logic_vector(17 downto 0);
	raddr   : in natural range 0 to IMG_WIDTH * IMG_HEIGHT - 1;
 	data    : out std_logic_vector(7 downto 0);
	clk	  : in std_logic
);
end component logo_reader;

component simple_dual_port_ram_single_clock is

	generic 
	(
		DATA_WIDTH : natural;
		DATA_NUM 	: natural
	);

	port 
	(
		clk	: in std_logic;
		raddr	: in natural range 0 to DATA_NUM - 1;
		waddr	: in natural range 0 to DATA_NUM - 1;
		data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
		we		: in std_logic;
		q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
	);

end component simple_dual_port_ram_single_clock;


component frameMean is
	port 
	(
		clk	   		: in std_logic;
		working  		: in std_logic;
		raddrFG  		: out natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;
		dataFG_in   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		col 				: in natural range 0 to IMG_WIDTH - 1;
		row 				: in natural range 0 to IMG_HEIGHT - 1;
		data_valid		: out std_logic := '0';
		dataFM_out	   : out std_logic_vector((PIXEL_WIDTH-1) downto 0)
	);

end component frameMean;

component TemplateMean is
	port 
	(
		clk	   		: in std_logic;
		working  		: in std_logic;
		raddrTG  		: out natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT - 1;
		dataTG_in   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		data_valid		: out std_logic := '0';
		dataTM_out	   : out std_logic_vector((PIXEL_WIDTH-1) downto 0)
	);
end component TemplateMean;

component corrPartI is
	port 
	(
		clk	   		: in std_logic;
		working  		: in std_logic;
		raddrFG 			: out natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;
		raddrTG  		: out natural range 0 to TEMPL_WIDTH * TEMPL_HEIGHT -1;
		dataFG_in   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		dataTG_in   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		dataTM_in   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		col 				: in natural range 0 to IMG_WIDTH - 1;
		row 				: in natural range 0 to IMG_HEIGHT - 1;
		data_valid		: out std_logic := '0';
		dataCPI_out	   : out std_logic_vector((MEMCELL_WIDTH-1) downto 0)  --signed
	);
end component corrPartI;


component stdFrame is 
	port 
	(
		clk	   	: in std_logic;
		working  	: in std_logic;
		raddrFM		: out natural range 0 to IMG_WIDTH*IMG_HEIGHT - 1;	
		dataFM		: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		dataFG   	: in std_logic_vector((PIXEL_WIDTH - 1) downto 0);
		col 			: in natural range 0 to IMG_WIDTH - 1;
		row 			: in natural range 0 to IMG_HEIGHT - 1;
		data_valid	: out std_logic := '0';
		dataSF	   : out std_logic_vector((MEMCELL_WIDTH-1) downto 0)
	);

end component stdFrame;


type state_type is (FM,FM_WAIT, TM, TM_WAIT, CPI, CPI_WAIT, SF, SF_WAIT, RESULT, IDLE);
signal curr_state : state_type;

BEGIN
	
	IMG_READER: SRAM_READER PORT MAP(SRAMDATA_IN, SRAM_ADDRESS_SRAM, WE_N, CE_N, OE_N, LB_N, UB_N, readfinish, pixeldata, CLK, RESET);
	LOGO_ITEM_READER: logo_reader port map(SRAMDATA_IN, SRAM_ADDRESS_LOGO, raddrI, line_buffer_data_rdI, clk);

	TMP_MEM: simple_dual_port_ram_single_clock
	generic map 
	(				
		DATA_WIDTH => PIXEL_WIDTH ,
		DATA_NUM => TEMPL_WIDTH * TEMPL_HEIGHT
	)
	port map
	(
		clk	=> CLK,
		raddr	=> raddrT,
		waddr	=> waddrT,
		data	=> line_buffer_data_wrT,
		we		=> wenT,
		q		=> line_buffer_data_rdT
	);
	

	frameMean_module : frameMean
	port map
	(
		clk	  		=> clk, 							
		working 		=> workingFM, 					
		raddrFG 		=> raddrI_outFM, 				
		dataFG_in 	=> line_buffer_data_rdI, 
		col 			=> col, 
		row 			=> row, 
		data_valid	=> valid_FM, 
		dataFM_out	=> line_buffer_data_wrFM 
	);

	templMean_module : TemplateMean
	port map
	(
		clk	 => clk, 
		working  => workingTM, 
		raddrTG  => raddrT_outTM,
		dataTG_in  => line_buffer_data_rdT, 
		data_valid	=> valid_TM,
		dataTM_out	=> dataTM    
	);
	
	cp1_module : corrPartI
	port map
	(
		clk	   	=> clk, 
		working  	=> workingCPI, 
		raddrFG  	=> raddrI_outCP1, 
		raddrTG  	=> raddrT_outCP1, 
		dataFG_in  	=> line_buffer_data_rdI, 
		dataTG_in  	=> line_buffer_data_rdT, 
		dataTM_in  	=> dataTM, 
		col 			=> col, 
		row 			=> row, 
		data_valid	=> valid_CPI, 
		dataCPI_out	=> line_buffer_data_wrCP1 
	);
	
	stdF_module : stdFrame
	port map
	(
		clk	  		=> clk, 
		working  	=> workingSF, 
		raddrFM		=> raddrFM_outSF, 
		dataFM		=> line_buffer_data_wrFM, 
		dataFG   	=> line_buffer_data_rdI, 
		col 			=> col, 
		row 			=> row, 
		data_valid	=> valid_SF, 
		dataSF		=> line_buffer_data_wrSF 
	);
	
	process(CLK, RESET)
	
	variable rowval : natural range 0 to IMG_HEIGHT - 1 := 0;
	variable colval : natural range 0 to IMG_WIDTH - 1 := 0;
	variable maxScore_index : natural range 0 to IMG_HEIGHT*IMG_WIDTH - 1 := 0;
	variable maxScore : integer := -30000;
	variable score : integer ;
	variable index : natural range 0 to IMG_HEIGHT*IMG_WIDTH -1 := 0;
	VARIABLE FM_VAL, CPI_VAL, SF_VAL : integer := 0;
	
	begin
		if (RESET = '1') then
			rowval := 0;
			colval := 0;
			SRAM_ADDRESS <= SRAM_ADDRESS_SRAM;
		elsif(rising_edge(CLK)) then
			if (readfinish = '1') then
				case curr_state is
					when FM =>
						SRAM_ADDRESS <= SRAM_ADDRESS_LOGO;
						curr_state <= FM_WAIT;
						workingFM <= '1';

					when FM_WAIT =>
						if(valid_FM = '1') then 
							workingFM <= '0';
							FM_VAL := to_integer(unsigned(line_buffer_data_wrFM));
							curr_state <= TM;
						end if;

					when TM => 
						curr_state <= TM_WAIT;
						workingTM <= '1';
					when TM_WAIT =>
						if (valid_TM = '1') then
							workingTM <= '0';
							curr_state <= CPI;
						end if;
					when CPI =>
						curr_state <= CPI_WAIT;
						workingCPI <= '1';
					when CPI_WAIT =>
							if (valid_CPI = '1') then
								workingCPI <= '0';
								CPI_VAL :=100 * to_integer(signed(line_buffer_data_wrCP1));
								curr_state <= SF;
							end if;
					when SF =>
						curr_state <= SF_WAIT;
						workingSF <= '1';
					when SF_WAIT =>
						if (valid_SF = '1') then
							workingSF <= '0';
							SF_VAL := to_integer(unsigned(line_buffer_data_wrSF));
							curr_state <= RESULT;	
						end if;
					when RESULT =>
						score := CPI_VAL / SF_VAL;
						if (maxScore < score) then
							maxScore := score;
							maxScore_index := colval;
						end if;
						
						colval := (colval + 1) mod IMG_WIDTH;
						if (colval = 0) then
							rowval := (rowval + 1) mod IMG_HEIGHT;
						end if;
						
						if(colval = 0 and rowval = 0) then
							curr_state <= IDLE;
							if(maxScore_index > 50 and maxScore_index < 150) then
								RESULT0 <= '1'; ---toyota matched
								RESULT1 <= '0';
								RESULT2 <= '0';
								RESULT3 <= '0';
							elsif (maxScore_index > 200 and maxScore_index < 350) then
								RESULT0 <= '0'; 
								RESULT1 <= '1'; --- honda matched
								RESULT2 <= '0';
								RESULT3 <= '0';
							elsif (maxScore_index > 380 and maxScore_index < 480) then
								RESULT0 <= '0'; 
								RESULT1 <= '0';
								RESULT2 <= '1'; --- lexuss matched
								RESULT3 <= '0';
							else 
								RESULT0 <= '0'; 
								RESULT1 <= '0';
								RESULT2 <= '0'; 
								RESULT3 <= '1'; --- no matched
							end if;
						else
							curr_state <= FM;
							col <= colval;
							row <= rowval;
							FM_VAL := 0;
							CPI_VAL:= 0;
							SF_VAL := 0;
						end if;

					when IDLE =>
					-- nothing
				end case;
			---------------------------------------------
		
			else  -- readfinish
				wenT <= '1';
				line_buffer_data_wrT <= pixeldata;
				waddrT <= waddrT + 1;		
			end if;
		end if;
	end process ;
	
END CorrMatching_arch;

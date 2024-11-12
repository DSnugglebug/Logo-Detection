library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package global is
-- global constant and type for image process
	constant IMG_HEIGHT : natural := 350;
	constant IMG_WIDTH : natural := 589;
	constant TEMPL_HEIGHT : natural := 108;
	constant TEMPL_WIDTH : natural := 180;
	
	constant LOGOIMGADDR : natural := 0;
	constant TMPIMGADDR : natural := IMG_HEIGHT * IMG_WIDTH / 2;
	constant MEMCELL_WIDTH : natural := 32;
	
	constant PIXEL_WIDTH : natural := 8;    		-- bits per one pixel
	
end package global;
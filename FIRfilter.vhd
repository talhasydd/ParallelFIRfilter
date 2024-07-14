library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity FIRfilter is

	generic(
	
		data_width	: integer := 16;
		coeff_width	: integer := 16;
		TAPS		: integer := 8

	);
	
	port (
		
		clk 			: in std_logic;
        reset 			: in std_logic;
        data_in 		: in std_logic_vector(data_width-1 downto 0);
        data_out 		: out std_logic_vector(data_width-1 downto 0);
        data_valid 		: in std_logic;
        output_valid 	: out std_logic
	
	);

end entity;


architecture RTL of FIRfilter is

type coeff_array is array (0 to TAPS-1) of signed(coeff_width - 1 downto 0);
type SR_array 	 is array (0 to TAPS-1) of signed(data_width - 1 downto 0);
type mult_array  is array (0 to TAPS-1) of signed(data_width + coeff_width - 1 downto 0);				-- multipled result is sum of coefficient and the data bits

constant coefficients : coeff_array := (

		to_signed(10, coeff_width),
		to_signed(20, coeff_width),
        to_signed(30, coeff_width),
        to_signed(40, coeff_width),
        to_signed(50, coeff_width),
        to_signed(60, coeff_width),
        to_signed(70, coeff_width),
        to_signed(80, coeff_width)

);

constant acc_width 		: integer := data_width + coeff_width + TAPS;								-- add number of taps to 32 bit result.
constant output_shift   : integer := coeff_width + TAPS - 1;											-- defining output shift width to easily resize final output

signal SR 			: SR_array 	 := (others => (others => '0'));
signal acc_result 	: signed(acc_width downto 0) := (others => '0');									


begin

process (clk, reset)

variable temp_acc : signed(acc_width-1 downto 0) := (others => '0'); -- Temporary variable for accumulation.
variable temp_mult : signed(data_width + coeff_width - 1 downto 0);  -- Temporaray variable for multiplication results.

begin
	
	data_out <= std_logic_vector(resize(shift_right(acc_result,(coeff_width - TAPS +1)), data_width));	-- shifts acc_result right to 'delete' LSBs, resized to data_width and converted to std_logic_vector

	if reset = '1' then
	
		SR 				<= (others => (others => '0'));
        acc_result 		<= (others => '0');
        output_valid 	<= '0';
        data_out 		<= (others => '0');
	
	elsif rising_Edge(clk) then
	
		if data_valid = '1' then
		
			SR <=  signed(data_in) & SR(0 to TAPS-2);
			
			 temp_acc := (others => '0'); -- Reset temporary accumulator
			
                for i in 0 to TAPS-1 loop
                 -- sum of the weighted values of the past inputs
                    temp_mult:= SR(i) * coefficients(i);
                    temp_acc := temp_acc + resize(temp_mult, acc_width);
                end loop;
                
                -- sum resized to fit width
                acc_result <= resize(temp_acc, (acc_width + 1));
		
			
            output_valid <= '1';
          else 
          
            output_valid <= '0';

		end if;
	end if;

end process;
end RTL;


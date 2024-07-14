library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIRfilterTB is
end FIRfilterTB;

architecture TB of FIRfilterTB is

    constant data_width : integer := 16;
    constant coeff_width : integer := 16;
    constant TAPS : integer := 8;
    
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal data_in : std_logic_vector(data_width-1 downto 0) := (others => '0');
    signal data_out : std_logic_vector(data_width-1 downto 0);
    signal data_valid : std_logic := '0';
    signal output_valid : std_logic;
    
    component FIRfilter is
        generic (
            data_width : integer := 16;
            coeff_width : integer := 16;
            TAPS : integer := 8
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            data_in : in std_logic_vector(data_width-1 downto 0);
            data_out : out std_logic_vector(data_width-1 downto 0);
            data_valid : in std_logic;
            output_valid : out std_logic
        );
    end component;
    
begin
    uut: FIRfilter
        generic map (
            data_width => data_width,
            coeff_width => coeff_width,
            TAPS => TAPS
        )
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            data_out => data_out,
            data_valid => data_valid,
            output_valid => output_valid
        );
    
  clk <= not clk after 5ns;
    
    process
    begin
    reset <= '1';
    wait for 40 ns;
    reset <= '0';
    wait for 100 ns; -- Initial delay
    
    -- Impulse
    data_in <= std_logic_vector(to_signed(32767, data_width));
    data_valid <= '1';
    wait for 10 ns;
    data_valid <= '0';
    wait for 90 ns;
    
    -- Zero input for the rest of the simulation
    for i in 1 to 50 loop
        data_in <= (others => '0');
        data_valid <= '1';
        wait for 10 ns;
        data_valid <= '0';
        wait for 90 ns;
    end loop;
    
    wait;
end process;
    
end TB;
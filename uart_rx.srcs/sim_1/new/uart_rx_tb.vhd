library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
	Generic(
		clk_freq 		: integer 		:= 100_000_000;
		baudrate 		: integer 		:= 100_000
	);
end uart_rx_tb;

architecture rx_tb of uart_rx_tb is

component uart_rx_ex is
	Generic(
		clk_freq 			: integer 		:= 100_000_000;
		baudrate 			: integer 		:= 100_000
	);	
	Port(	
		clk 				: in std_logic;
		rx_buff				: in std_logic;
		rx_out				: out std_logic_vector(7 downto 0);
		rx_done				: out std_logic
	);	
end component;	
	
signal	clk 				: std_logic						:= '0';
signal	rx_buff				: std_logic						:= '1';
signal	rx_out				: std_logic_vector(7 downto 0); 
signal	rx_done				: std_logic;
	
constant clk_period			: time 	:= 10ns;
constant baudrate_period	: time  := 10us;
constant c_hex14			: std_logic_vector (9 downto 0) := '1' & x"14" & '0';
constant c_hexE7			: std_logic_vector (9 downto 0) := '1' & x"E7" & '0';

begin
DUT : uart_rx_ex
	Generic map(
		clk_freq 			=> clk_freq,
		baudrate 		    => baudrate
	)	                    
	Port map(	            
		clk 			    => clk, 	
		rx_buff			    => rx_buff,
		rx_out			    => rx_out,	
		rx_done			    => rx_done
	);

clk_process : process begin
	clk						<= '0';
	wait for clk_period/2;
	clk						<= '1';
	wait for clk_period/2;
	
end process clk_process;

SIM_process : process begin

	wait for clk_period*10;

	for i in 0 to 9 loop
		rx_buff <= c_hex14(i);
		wait for baudrate_period;
	end loop;

	wait for baudrate_period*10;

	for i in 0 to 9 loop
		rx_buff <= c_hexE7(i);
		wait for baudrate_period;
	end loop; 
	
	wait for 40us;
	
	assert false
	report "SIM DONE"
	severity failure;

end process SIM_process;
end rx_tb;

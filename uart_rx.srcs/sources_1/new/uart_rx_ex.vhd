library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_ex is
	Generic(
		clk_freq 		: integer 		:= 100_000_000;
		baudrate 		: integer 		:= 100_000
	);
	Port(
		clk 			: in std_logic;
		rx_buff			: in std_logic;
		rx_out			: out std_logic_vector(7 downto 0);
		rx_done			: out std_logic
	);
end uart_rx_ex;

architecture uart_receive of uart_rx_ex is

constant bir_bit_icin_timer_limit	: integer	:= clk_freq/baudrate;

type rx_state is (S_IDLE, S_START, S_DATA, S_STOP);
signal states 						: rx_state	:= S_IDLE;

signal timer_counter	: integer range 0 to bir_bit_icin_timer_limit	:= 0;
signal bit_counter		: integer range 0 to 7 							:= 0;
signal shft_register	: std_logic_vector( 7 downto 0) 				:= (others => '0');

begin

process(clk) begin
	if(rising_edge(clk)) then
		case states is 
		
			when S_IDLE =>
			
				timer_counter 			<= 0;
				rx_done 				<= '0';
				if(rx_buff = '0') then
					states 				<= S_START;
				end if;
				
			when S_START =>
			
				if(timer_counter = bir_bit_icin_timer_limit/2 - 1) then
					states				<= S_DATA;
					timer_counter		<= 0;
				else
					timer_counter 		<= timer_counter + 1;
				end if;
				
			when S_DATA =>
			
				if(timer_counter = bir_bit_icin_timer_limit - 1) then
					if(bit_counter = 7) then
						states			<= S_STOP;
						bit_counter		<= 0;
					else
						bit_counter 	<= bit_counter + 1;
					end if;
					shft_register		<= rx_buff & shft_register(7 downto 1);			-- rotate right (shift)
					timer_counter		<= 0;
				else
					timer_counter 		<= timer_counter + 1;
				end if;
				
			when S_STOP =>
			
				if(timer_counter = bir_bit_icin_timer_limit - 1) then
					states				<= S_IDLE;
					timer_counter		<= 0;
					rx_done				<= '1';
				else
					timer_counter 		<= timer_counter + 1;	
				end if;
		end case;
	end if;
end process;

rx_out	<= shft_register;

end uart_receive;

library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX21_GENERIC is
  Generic (NBIT: integer:= numBit);
		-- DELAY_MUX: Time:= tp_mux);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0) ;
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
	end MUX21_GENERIC;


architecture BEHAVIORAL of MUX21_GENERIC is
 signal S_GENERIC: std_logic_vector(NBIT-1 downto 0);
 signal S_NOT_GENERIC: std_logic_vector(NBIT-1 downto 0);
begin
S_GENERIC<= (others => '1') when (SEL = '1') else (others => '0');
  S_NOT_GENERIC<= not S_GENERIC;
  Y <= (A and S_GENERIC) or (B and S_NOT_GENERIC); -- processo implicito

end BEHAVIORAL;

architecture STRUCTURAL of MUX21_GENERIC is

	signal Y1: std_logic_vector(NBIT-1 downto 0);
	signal Y2: std_logic_vector(NBIT-1 downto 0);
	signal SB: std_logic;
        signal S_GENERIC: std_logic_vector(NBIT-1 downto 0);
        signal S_NOT_GENERIC: std_logic_vector(NBIT-1 downto 0);

	component ND2_GENERIC
	Generic(NBIT: integer:= numBit);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
	end component;
	
	component IV
	
	Port (	A:	In	std_logic;
		Y:	Out	std_logic);
	end component;

begin
  S_GENERIC<= (others => '1') when (SEL = '1') else (others => '0');
  S_NOT_GENERIC<= (others => '1') when (SB = '1') else (others => '0');
	UIV : IV
	Port Map ( SEL, SB);

	UND1 : ND2_GENERIC
	generic map(NBIT)
	Port Map ( A, S_GENERIC, Y1);

	UND2 : ND2_GENERIC
	generic map(NBIT)
	Port Map ( B, S_NOT_GENERIC, Y2);

	UND3 : ND2_GENERIC
	generic map(NBIT)
	Port Map ( Y1, Y2, Y);


end STRUCTURAL;

configuration CFG_MUX21_GENERIC_BEHAVIORAL of MUX21_GENERIC is
	for BEHAVIORAL
	end for;
end CFG_MUX21_GENERIC_BEHAVIORAL;

configuration CFG_MUX21_GENERIC_STRUCTURAL of MUX21_GENERIC is
	for STRUCTURAL
		for all : IV
			use configuration WORK.CFG_IV_BEHAVIORAL;
		end for;
		for all : ND2_GENERIC
			use configuration WORK.CFG_ND2_GENERIC_BEHAVIORAL;
		end for;
	end for;
end CFG_MUX21_GENERIC_STRUCTURAL;

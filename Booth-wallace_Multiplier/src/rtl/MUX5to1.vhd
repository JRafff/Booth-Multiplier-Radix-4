library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use WORK.constants.all; -- libreria WORK user-defined

entity MUX5to1 is
  Generic (N: integer:= numBit);
  Port (	A0:	In	std_logic_vector(N-1 downto 0) ;
		A1:	In	std_logic_vector(N-1 downto 0);
                A2:	In	std_logic_vector(N-1 downto 0) ;
                A3:	In	std_logic_vector(N-1 downto 0);
                A4:	In	std_logic_vector(N-1 downto 0);
		SEL:	In	std_logic_vector(2 downto 0);
		Y:	Out	std_logic_vector(N-1 downto 0));
end MUX5to1;


architecture BEHAVIORAL of MUX5to1 is

begin
  mux: process(A0,A1,A2,A3,A4,SEL)
  begin
    case SEL is
      when "000"  => Y <= A0;
      when "001"  => Y <= A1;
      when "010"  => Y <= A2; 
      when "011"  => Y <= A3; 
      when "100"  => Y <= A4; 
      when others => Y <= (others => '0'); -- Default di sicurezza
    end case;

  end process mux;
  

end BEHAVIORAL;

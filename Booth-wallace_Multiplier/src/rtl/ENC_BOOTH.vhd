library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity ENC_BOOTH is
  Port (A:In	std_logic_vector(2 downto 0);
	Y:Out	std_logic_vector(2 downto 0);
  Add_one: out std_logic);
end ENC_BOOTH;


architecture BEHAVIORAL of ENC_BOOTH is

begin
  enc: process(A)
  begin
    case A is
      when "000"  => Y <= "000"; Add_one <= '0'; -- 0
      when "001"  => Y <= "001"; Add_one <= '0'; -- (+A)
      when "010"  => Y <= "001"; Add_one <= '0'; -- (+A)
      when "011"  => Y <= "010"; Add_one <= '0'; -- (+2A)
      when "100"  => Y <= "100"; Add_one <= '1'; -- (-2A)
      when "101"  => Y <= "011"; Add_one <= '1'; -- (-A)
      when "110"  => Y <= "011"; Add_one <= '1'; -- (-A)
      when "111"  => Y <="000"; Add_one <= '0'; -- 0
      when others => Y <= (others => '0');Add_one <= '0' ; -- Default di sicurezza
    end case;

  end process enc ;
  

end BEHAVIORAL;

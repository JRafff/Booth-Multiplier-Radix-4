library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ND2_GENERIC is
    generic ( NBIT : integer := 1  );
    port (
        a : in  STD_LOGIC_VECTOR(NBIT-1 downto 0);
        b : in  STD_LOGIC_VECTOR(NBIT-1 downto 0);
        y : out STD_LOGIC_VECTOR(NBIT-1 downto 0)
    );
end ND2_GENERIC;

architecture BEHAVIORAL of ND2_GENERIC is
begin

    y <= a nand b;

end BEHAVIORAL;

configuration CFG_ND2_GENERIC_BEHAVIORAL of ND2_GENERIC is
  for BEHAVIORAL
end for;
end configuration CFG_ND2_GENERIC_BEHAVIORAL;

library ieee;
use ieee.std_logic_1164.all;

entity IV is
    port (
        A : in  std_logic;
        Y : out std_logic
    );
end entity IV;

architecture BEHAVIORAL of IV is
begin 
   Y <= not A;
end architecture BEHAVIORAL;

configuration CFG_IV_BEHAVIORAL of IV is
	for BEHAVIORAL
	end for;
end CFG_IV_BEHAVIORAL;

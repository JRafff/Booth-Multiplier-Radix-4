library ieee; 
use ieee.std_logic_1164.all; 
use WORK.constants.all;

entity pg_network is                                 
  generic ( N: integer:= numBit);
  port ( A: in std_logic_vector(N-1 downto 0);
         B: in std_logic_vector(N-1 downto 0);
         Cin: in std_logic;                
         p: out std_logic_vector(N-1 downto 0);
         g: out std_logic_vector(N-1 downto 0));
end pg_network;

architecture BEHAVIORAL of pg_network is
begin
  
gen_pg: for i in 0 to N-1 generate
      
      -- Il bit 0 assorbe il Cin
      if_zero: if i = 0 generate
          p(i) <= A(i) xor B(i);
          g(i) <= (A(i) and B(i)) or (A(i) and Cin) or (B(i) and Cin);
      end generate if_zero;

      -- Tutti gli altri bit fanno il calcolo standard
      if_others: if i > 0 generate
          p(i) <= A(i) xor B(i);
          g(i) <= A(i) and B(i);
      end generate if_others;
      
  end generate gen_pg;
  


end BEHAVIORAL;

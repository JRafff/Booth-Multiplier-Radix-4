library ieee; 
use ieee.std_logic_1164.all; 
use WORK.constants.all;

entity PG_block is                                 
  port (G_ik: in std_logic;
        P_ik: in std_logic;
        G_kj: in std_logic;
        P_kj: in std_logic;
        G_ij: out std_logic;
        P_ij: out std_logic);
end PG_block;

architecture BEHAVIORAL of PG_block is
  begin
    G_ij <= G_ik or (P_ik and G_kj);
    P_ij <= P_ik and P_kj;
end BEHAVIORAL;

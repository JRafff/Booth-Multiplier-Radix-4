library ieee; 
use ieee.std_logic_1164.all; 
use WORK.constants.all;

entity G_block is                                 
  port (G_ik: in std_logic;
        P_ik: in std_logic;
        G_kj: in std_logic;
        G_ij: out std_logic);
end G_block;

architecture BEHAVIORAL of G_block is
  begin
    G_ij <= G_ik or (P_ik and G_kj);
end BEHAVIORAL;

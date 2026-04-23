library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity SUM_GENERATOR is                                  -- Carry select Block
  generic ( NBIT_PER_BLOCK: integer:= 4;
            NBLOCKS: integer:=8);
  port ( A:in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
         B: in std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
         Cin: in std_logic_vector(NBLOCKS-1 downto 0);
         S: out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0));
end SUM_GENERATOR;

architecture STRUCTURAL of SUM_GENERATOR is
  
  component CSB                    -- Carry select Block
    generic ( N: integer:= numBit);
    port (A: in std_logic_vector(N-1 downto 0);
          B: in std_logic_vector(N-1 downto 0);
          Cin_eff: in std_logic;                -- Effective carry in
          S: out std_logic_vector(N-1 downto 0));
  end component;

begin
  
  blocks:  for i in 1 to NBLOCKS generate
    CSB_block : CSB generic map (N=>NBIT_PER_BLOCK)
      port map (A => A(NBIT_PER_BLOCK*i-1 downto NBIT_PER_BLOCK*i-NBIT_PER_BLOCK),
                B => B(NBIT_PER_BLOCK*i-1 downto NBIT_PER_BLOCK*i-NBIT_PER_BLOCK),
                Cin_eff => Cin(i-1), S =>S(NBIT_PER_BLOCK*i-1 downto NBIT_PER_BLOCK*i-NBIT_PER_BLOCK));
  end generate blocks;
  
end STRUCTURAL;

configuration CFG_SUM_STRUCTURAL of SUM_GENERATOR is
  for STRUCTURAL
    
	for blocks
          for all : CSB
      use configuration WORK.CFG_CSB_STRUCTURAL;
          end for;
        end for;
  end for;
end CFG_SUM_STRUCTURAL;

library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use WORK.constants.all;

entity CSB is                                  -- Carry select Block
  generic (     N: integer:= numBit);
  port (        A: in std_logic_vector(N-1 downto 0);
                B: in std_logic_vector(N-1 downto 0);
          Cin_eff: in std_logic;                -- Effective carry in
                S: out std_logic_vector(N-1 downto 0));
end CSB;

architecture STRUCTURAL of CSB is
  signal S_0,S_1: std_logic_vector(N-1 downto 0);
  signal C_out_0,C_out_1: std_logic;
  
  -- Components
  component RCA_GENERIC  
	generic ( NBIT: integer:= numBit);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT-1 downto 0);
		Co:	Out	std_logic);
  end component; 

  component MUX21_GENERIC is
        Generic (NBIT: integer:= numBit);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0) ;
		B:	In	std_logic_vector(NBIT-1 downto 0);
		SEL:	In	std_logic;
		Y:	Out	std_logic_vector(NBIT-1 downto 0));
  end component;

begin
  RCA_0 : RCA_GENERIC generic map (N)
    port map (A => A, B => B, Ci => '0', S => S_0, Co => C_out_0 );
  RCA_1 : RCA_GENERIC generic map (N)
    port map (A => A, B => B, Ci => '1', S => S_1, Co => C_out_1 );
  MUX_1 : MUX21_GENERIC generic map(N)
    port map (A => S_1, B => S_0, SEL => Cin_eff, Y=>S );
  
end STRUCTURAL;

configuration CFG_CSB_STRUCTURAL of CSB is
  for STRUCTURAL 
    for all : RCA_GENERIC
      use configuration WORK.CFG_RCA_GENERIC_BEHAVIORAL;
    end for;
    for all : MUX21_GENERIC
      use configuration WORK.CFG_MUX21_GENERIC_BEHAVIORAL;
    end for;
  end for;
end CFG_CSB_STRUCTURAL;

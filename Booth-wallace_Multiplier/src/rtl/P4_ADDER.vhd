library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity P4_ADDER is
    generic (
        NBIT : integer := 64
    );
    port (
        A    : in  std_logic_vector(NBIT-1 downto 0);
        B    : in  std_logic_vector(NBIT-1 downto 0);
        Cin  : in  std_logic;
        S    : out std_logic_vector(NBIT-1 downto 0);
        Cout : out std_logic
    );
end P4_ADDER;

architecture STRUCTURAL of P4_ADDER is

    component CarryGen is
        generic (
            N      : integer := 32;
            Ncarry : integer := 4;
            LEVELS : integer := 5
        );
        port (
            A     : in  std_logic_vector(N-1 downto 0);
            B     : in  std_logic_vector(N-1 downto 0);
            c_in  : in  std_logic;
            c_out : out std_logic_vector((N/Ncarry)-1 downto 0)
        );
    end component;

    component SUM_GENERATOR is
        generic ( 
            NBIT_PER_BLOCK : integer := 4;
            NBLOCKS        : integer := 8
        );
        port ( 
            A   : in  std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
            B   : in  std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0);
            Cin : in  std_logic_vector(NBLOCKS-1 downto 0);
            S   : out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS-1 downto 0)
        );
    end component;

    -- Costanti derivate
    constant NBIT_PER_BLOCK : integer := 4;
    constant NBLOCKS        : integer := NBIT / NBIT_PER_BLOCK;

    -- I segnali interni
    signal Carry_sig   : std_logic_vector(NBLOCKS-1 downto 0);
    signal CS_carry_in : std_logic_vector(NBLOCKS-1 downto 0); -- Vettore per alimentare il Sum_Gen

begin

   
    P4_CARRY_GENERATOR: CarryGen
        generic map (
            N      => NBIT,
            Ncarry => NBIT_PER_BLOCK,
            LEVELS => 5 
        )
        port map (
            A     => A, 
            B     => B, 
            c_in  => Cin,
            c_out => Carry_sig 
        );

    
    -- Il primo blocco del sommatore prende il Cin originale
    CS_carry_in(0) <= Cin;
    
    -- I blocchi successivi prendono i carry generati dall'albero
    -- (CS_carry_in(1) prende Carry_sig(0), e così via...
    CS_carry_in(NBLOCKS-1 downto 1) <= Carry_sig(NBLOCKS-2 downto 0);

    P4_SUM_GENERATOR: SUM_GENERATOR
        generic map (
            NBIT_PER_BLOCK => NBIT_PER_BLOCK,
            NBLOCKS        => NBLOCKS
        ) 
        port map (
            A   => A, 
            B   => B, 
            Cin => CS_carry_in, -- Passiamo il vettore shiftato
            S   => S
        );

    -- Carry in uscita a tutta l'ALU è l'ultimo bit generato (C32)
    Cout <= Carry_sig(NBLOCKS-1);

end STRUCTURAL;

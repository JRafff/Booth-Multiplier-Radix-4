library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity MULTIPLIER_tb is
end MULTIPLIER_tb;

architecture TEST of MULTIPLIER_tb is
  constant N : integer := 32;
  
  signal A_mp_i : std_logic_vector(N-1 downto 0) := (others => '0');
  signal B_mp_i : std_logic_vector(N-1 downto 0) := (others => '0');
  signal Y_mp_i : std_logic_vector(2*N-1 downto 0);
  signal expected_out : std_logic_vector(2*N-1 downto 0);

  -- Component del tuo BOOTHMUL
  component BOOTHMUL is
    generic ( N: integer := 32 );
    port (
      A: in  std_logic_vector(N-1 downto 0);
      B: in  std_logic_vector(N-1 downto 0);
      Y: out std_logic_vector(N*2-1 downto 0)
    );
  end component;

begin

  -- Istanza del moltiplicatore
  UUT: BOOTHMUL 
    generic map (N => N)
    port map (A => A_mp_i, B => B_mp_i, Y => Y_mp_i);

  test: process
    variable expected : signed(2*N-1 downto 0);
    
 procedure check_mul(a_val, b_val : integer) is
    variable a_signed : signed(N-1 downto 0);
    variable b_signed : signed(N-1 downto 0);
  begin
      -- Trasformiamo gli integer in signed a 32 bit
      a_signed := to_signed(a_val, N);
      b_signed := to_signed(b_val, N);

      --  Applichiamo gli ingressi ai segnali
      A_mp_i <= std_logic_vector(a_signed);
      B_mp_i <= std_logic_vector(b_signed);
      
      -- Calcoliamo il riferimento Gold a 64 bit (fondamentale!)
      -- Moltiplicando due signed(32), il VHDL genera un signed(64) corretto
      expected     := a_signed * b_signed;
      expected_out <= std_logic_vector(expected);
      
      -- Aspettiamo la propagazione nell'hardware
      wait for 20 ns;
      
      --  Controllo del risultato
      assert (signed(Y_mp_i) = expected)
          report "ERRORE: " & integer'image(a_val) & " * " & integer'image(b_val) & 
                 " -> Ricevuto (troncato): " & integer'image(to_integer(signed(Y_mp_i(31 downto 0)))) & 
                 " | Atteso (troncato): " & integer'image(to_integer(expected(31 downto 0)))
          severity error;
  end procedure;

  begin
    -- TEST CORNER CASES
    check_mul(0, 0);       -- Zero
    check_mul(1, 1);       -- Identità
    check_mul(-1, 5);      -- Negativo per positivo
    check_mul(-5, -5);     -- Negativo per negativo
    check_mul(2147483647, 2); -- Massimo positivo (2^31 - 1)
    
    -- TEST RANDOM (Esempio di alcuni valori)
    check_mul(1234, 5678);
    check_mul(-1234, 5678);
    
    report "SIMULAZIONE COMPLETATA CON SUCCESSO!";
    wait;
  end process;

end TEST;

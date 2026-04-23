library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.constants.all;

entity carryGEN is
    generic ( 
        N       : integer := 32;
        Ncarry  : integer := 4;
        LEVELS  : integer := 5  -- log2(32)
    );
    port (
        A       : in  std_logic_vector(N-1 downto 0);
        B       : in  std_logic_vector(N-1 downto 0);
        c_in    : in  std_logic;
        -- Uscita: 32/4 = 8 carry sparsi
        c_out   : out std_logic_vector((N/Ncarry)-1 downto 0) 
    );
end carryGEN;

architecture structural of carryGEN is 

    component G_block is
        port (G_ik: in std_logic;
        P_ik: in std_logic;
        G_kj: in std_logic;
        G_ij: out std_logic);
    end component;

    component PG_block is
        port (G_ik: in std_logic;
        P_ik: in std_logic;
        G_kj: in std_logic;
        P_kj: in std_logic;
        G_ij: out std_logic;
        P_ij: out std_logic);
    end component;

    component pg_network is                                 

          generic ( N: integer:= N);

          port ( A: in std_logic_vector(N-1 downto 0);

                 B: in std_logic_vector(N-1 downto 0);

                 Cin: in std_logic;                

                 p: out std_logic_vector(N-1 downto 0);

                 g: out std_logic_vector(N-1 downto 0));

        end component;

    -- LA MATRICE DEI FILI: (LEVELS + 1) righe, ognuna larga N bit
    type matrix_type is array (0 to LEVELS) of std_logic_vector(N-1 downto 0);
    signal G_tree, P_tree : matrix_type;
    
 begin   
    -- declares the pg network and uses the firs row of p and g signals as exit of the pg network
    m_pgNetwork : pg_network generic map ( N => N)
	port map ( A => A, B => B, Cin => c_in, p => P_tree(0), g => G_tree(0));
    


-- due cicli annidati per l'albero:
    gen_levels: for lvl in 0 to LEVELS-1 generate
        constant step : integer := 2**lvl;
        
    begin
        -- secondo ciclo
        gen_bits: for j in 0 to N-1 generate
            constant k : integer := ((j / step) * step) - 1;
            
        begin
            
            
            -- Nel Livello 0, piazzo blocchi solo sulle colonne dispari (1, 3, 5, 7...)
            -- Nei livelli successivi, piazzo blocchi SOLO sulle colonne 3, 7, 11, 15...
            sparse: if (lvl = 0 and (j mod 2 = 1)) or (lvl > 0 and ((j+1) mod 4 = 0)) generate

                
                -- Nei primi 2 livelli lavorano tutti. Dal livello 2 in poi non tutti lavorano
                is_working: if (lvl < 2) or (j mod (2**(lvl+1)) >= 2**lvl) generate
                    
                    -- Il filo passa dritto se k < 0 (es. il nodo C16 al livello finale)
                    if_pass: if k < 0 generate
                        G_tree(lvl+1)(j) <= G_tree(lvl)(j);
                        P_tree(lvl+1)(j) <= P_tree(lvl)(j);
                    end generate if_pass;
                    
                    -- blocco o PG o G
                    if_block: if k >= 0 generate    
                        -- if di quale blocco usare, usiamo G_block
                        if_G: if k < step generate
                            inst_G: G_block 
                                port map (
                                    P_ik     => P_tree(lvl)(j), 
                                    G_ik   => G_tree(lvl)(j), 
                                    G_kj    => G_tree(lvl)(k),
                                    G_ij => G_tree(lvl+1)(j)
                                );
                            -- Il P_out non viene calcolato dal G_block, lo forziamo a '0'
                            P_tree(lvl+1)(j) <= '0'; 
                        end generate if_G;
                        
                        -- usiamo PG_block completo
                        if_PG: if k >= step generate
                            inst_PG: PG_block 
                                port map (
                                    P_ik    => P_tree(lvl)(j), 
                                    G_ik    => G_tree(lvl)(j), 
                                    P_kj    => P_tree(lvl)(k), 
                                    G_kj    => G_tree(lvl)(k),
                                    G_ij => G_tree(lvl+1)(j), 
                                    P_ij => P_tree(lvl+1)(j)
                                );
                        end generate if_PG;
                    end generate if_block;
                end generate is_working;

                -- per i blocchi che non lavorano collego i fili (Es. il nodo 19 al livello 3)
                is_resting: if (lvl >= 2) and (j mod (2**(lvl+1)) < 2**lvl) generate
                    -- Tiro il filo dritto 
                    G_tree(lvl+1)(j) <= G_tree(lvl)(j);
                    P_tree(lvl+1)(j) <= P_tree(lvl)(j);
                end generate is_resting;

            end generate sparse;

            -- Colonne spente fin dall'inizio (es. le colonne pari al livello 0, o quelle non multiple di 4 ai livelli alti)
            sparse_false: if not ((lvl = 0 and (j mod 2 = 1)) or (lvl > 0 and ((j+1) mod 4 = 0))) generate
                -- Tiriamo il filo dritto per evitare i segnali 'U' rossi su ModelSim
                G_tree(lvl+1)(j) <= G_tree(lvl)(j);
                P_tree(lvl+1)(j) <= P_tree(lvl)(j);
            end generate sparse_false;
            
        end generate gen_bits;
        
    end generate gen_levels;

    -- ESTRAZIONE DEI CARRY 
    -- Peschiamo dall'ultimo livello della matrice i carry multipli di Ncarry
    gen_cout: for i in 1 to (N/Ncarry) generate
        c_out(i-1) <= G_tree(LEVELS)(i * Ncarry - 1); 
    end generate gen_cout;

end structural;

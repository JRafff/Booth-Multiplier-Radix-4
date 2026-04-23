# Generatore RTL per Albero di Wallace a 32 bit (16 Prodotti Parziali)

N = 32
N_BITS = 64
N_ROWS = 17

columns = [[] for j in range(N_BITS)] #lista di liste 

# Riempiamo le colonne seguendo la logica del vhdl P(i)(b)
for i in range(16):  # Righe da 0 a 15
    
    # 1. IL PRODOTTO PARZIALE (pp_ready)
    if i < 15:
        # Per le righe 0-14, il pp_ready è lungo 35 bit (da 2*i a 2*i + 34)
        start_bit = 2 * i
        end_bit = 2 * i + 34
    else:
        # Per la riga 15, abbiamo tagliato la testa! Si ferma al bit 63.
        start_bit = 30
        end_bit = 63
        
    for b in range(start_bit, end_bit + 1):
        columns[b].append(f"P({i})({b})")
        
    # IL BIT DEL COMPLEMENTO A 2 (+1)
    if i > 0:
        # Inserito al buco 2*i - 2
        columns[2*i - 2].append(f"P({i})({2*i - 2})")

# (Riga 16)
# Contiene solo l'ultimissimo bit del complemento a 2, a peso 30 (N-2)
columns[30].append(f"P(16)(30)")



# 2. LISTE PER SALVARE IL VHDL
declarations = []   # Per i signal
instantiations = [] # Per i FA e HA

stage = 0
wire_count = 0


# 3. IL MOTORE DEL WALLACE TREE
while max(len(col) for col in columns) > 2:
    stage += 1
    instantiations.append(f"\n  -- STAGE {stage}")
    
    next_columns = [[] for _ in range(N_BITS)]
    
    for w in range(N_BITS):
        col = columns[w]
        
        # FULL ADDER
        while len(col) >= 3:
            a, b, c = col.pop(0), col.pop(0), col.pop(0)
            s_wire = f"s_{stage}_{wire_count}"
            c_wire = f"c_{stage}_{wire_count}"
            wire_count += 1
            
            declarations.append(f"  signal {s_wire}, {c_wire} : std_logic;")
            instantiations.append(f"  FA_{wire_count}: FA port map(A=>{a}, B=>{b}, Ci=>{c}, S=>{s_wire}, Co=>{c_wire});")
            
            next_columns[w].append(s_wire)
            if w + 1 < N_BITS: next_columns[w+1].append(c_wire)
                
        # HALF ADDER
        if len(col) == 2:
            a, b = col.pop(0), col.pop(0)
            s_wire = f"s_{stage}_{wire_count}"
            c_wire = f"c_{stage}_{wire_count}"
            wire_count += 1
            
            declarations.append(f"  signal {s_wire}, {c_wire} : std_logic;")
            instantiations.append(f"  HA_{wire_count}: HA port map(A=>{a}, B=>{b}, S=>{s_wire}, Co=>{c_wire});")
            
            next_columns[w].append(s_wire)
            if w + 1 < N_BITS: next_columns[w+1].append(c_wire)
                
        # PASS THROUGH
        if len(col) == 1:
            next_columns[w].append(col.pop(0))
            
    columns = next_columns


# ASSEGNAZIONI FINALI
instantiations.append("\n  -- ASSEGNAZIONI AI VETTORI FINALI")
for w in range(N_BITS):
    s_val = columns[w][0] if len(columns[w]) > 0 else "'0'"
    c_val = columns[w][1] if len(columns[w]) > 1 else "'0'"
    instantiations.append(f"  Final_Sum({w}) <= {s_val};")
    instantiations.append(f"  Final_Carry({w}) <= {c_val};")


# STAMPA A SCHERMO
print("-- METTI PRIMA DEL BEGIN:")
print("  signal Final_Sum, Final_Carry : std_logic_vector(N-1 downto 0);")
for d in declarations:
    print(d)

print("\n-- METTI DOPO IL BEGIN:")
for i in instantiations:
    print(i)
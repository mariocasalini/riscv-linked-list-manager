.data

# Allocazione di 150 byte per la memoria dinamica della lista
# Ogni nodo occupa 5 byte: 1 per il carattere DATA, 4 per il puntatore PAHEAD
memoria_libera:
    .byte 0, 0, 0, 0, 0     # Nodo 1
    .byte 0, 0, 0, 0, 0     # Nodo 2
    .byte 0, 0, 0, 0, 0     # Nodo 3
    .byte 0, 0, 0, 0, 0     # Nodo 4
    .byte 0, 0, 0, 0, 0     # Nodo 5
    .byte 0, 0, 0, 0, 0     # Nodo 6
    .byte 0, 0, 0, 0, 0     # Nodo 7
    .byte 0, 0, 0, 0, 0     # Nodo 8
    .byte 0, 0, 0, 0, 0     # Nodo 9
    .byte 0, 0, 0, 0, 0     # Nodo 10
    .byte 0, 0, 0, 0, 0     # Nodo 11
    .byte 0, 0, 0, 0, 0     # Nodo 12
    .byte 0, 0, 0, 0, 0     # Nodo 13
    .byte 0, 0, 0, 0, 0     # Nodo 14
    .byte 0, 0, 0, 0, 0     # Nodo 15
    .byte 0, 0, 0, 0, 0     # Nodo 16
    .byte 0, 0, 0, 0, 0     # Nodo 17
    .byte 0, 0, 0, 0, 0     # Nodo 18
    .byte 0, 0, 0, 0, 0     # Nodo 19
    .byte 0, 0, 0, 0, 0     # Nodo 20
    .byte 0, 0, 0, 0, 0     # Nodo 21
    .byte 0, 0, 0, 0, 0     # Nodo 22
    .byte 0, 0, 0, 0, 0     # Nodo 23
    .byte 0, 0, 0, 0, 0     # Nodo 24
    .byte 0, 0, 0, 0, 0     # Nodo 25
    .byte 0, 0, 0, 0, 0     # Nodo 26
    .byte 0, 0, 0, 0, 0     # Nodo 27
    .byte 0, 0, 0, 0, 0     # Nodo 28
    .byte 0, 0, 0, 0, 0     # Nodo 29
    .byte 0, 0, 0, 0, 0     # Nodo 30

# Input principale da analizzare: lista di comandi separati da ~
lista: .string "ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~  ADD(9) ~SORT~PRINT~DEL(b) ~DEL(B) ~PRI~REV~PRINT"

# Buffer per la manipolazione temporanea di stringhe o dati
buffer:
    .byte 0  # 1
    .byte 0  # 2
    .byte 0  # 3
    .byte 0  # 4
    .byte 0  # 5
    .byte 0  # 6
    .byte 0  # 7
    .byte 0  # 8
    .byte 0  # 9
    .byte 0  # 10
    .byte 0  # 11
    .byte 0  # 12
    .byte 0  # 13
    .byte 0  # 14
    .byte 0  # 15
    .byte 0  # 16
    .byte 0  # 17
    .byte 0  # 18
    .byte 0  # 19
    .byte 0  # 20
    .byte 0  # 21
    .byte 0  # 22
    .byte 0  # 23
    .byte 0  # 24
    .byte 0  # 25
    .byte 0  # 26
    .byte 0  # 27
    .byte 0  # 28
    .byte 0  # 29
    .byte 0  # 30
    .byte 0  # 31
    .byte 0  # 32
# Buffer di 32 byte, utile ad esempio per leggere o costruire comandi temporaneamente

# Vari messaggi di output utilizzati durante l'esecuzione

verifica:		        .string 	"\nControllo formattazione "
comandoValido:	        .string 	"\nComando Valido \n"
comandoNonValido:	    .string 	"\nComando Non Valido \n"
eliminato:		        .string 	"\nElemento trovato ed eliminato \n"
nonTrovato:		        .string 	"\nElemento non trovato \n"
ordinata:		        .string 	"\nLista ordinata\n"
stampa:		            .string 	"\nStampa: "
invertita:		        .string 	"\nLista invertita correttamente"
inputCorretto:	        .string 	"\nNumero di comandi validi \n"
erroreInput:	        .string 	"\nNumero di comandi maggiore o uguale a 30 \n"
erroreMemoriaPiena:     .string    "\nMemoria piena, elemento non aggiunto \n"
endS:		            .string 	"\nProgramma terminato"
newLine:		        .string		"\n"                   # Nuova linea per formattazione output

.text
    
# Stampa una nuova linea per separazione visiva (pulizia iniziale output)
la a0, newLine     # Carica indirizzo della stringa di newline
li a7, 4           # Codice syscall per stampa stringa
ecall              # Stampa newline


# Inizializzazione dei registri
la s0, lista            # s0 punta alla stringa lista (input dei comandi)
li sp, 0x10000          # inizializza lo stack pointer (es. base sicura)
li s1, 0                # s1: contenuto DATA del nodo corrente
li s2, 0x00000000       # s2: PAHEAD (puntatore al prossimo nodo)
li s3, 0                # s3: tail della lista (coda)
li s4, 0                # s4: contatore dei comandi letti
li s5, 0                # s5: flag errore (0 = ok, 1 = errore)
la s6, memoria_libera   # s6: inizio area di memoria per nodi (freelist)

#####################
# CONTA COMANDI     #
#####################
contaComandi:
    li s4, 0             # Reset contatore comandi
    li t0, 126           # Codice ASCII del carattere '~'

ciclo:
    lb t1, 0(s0)         # Legge carattere corrente da lista
    beqz t1, fineConta   # Se è terminatore (0), fine conteggio
    beq t1, t0, tilde    # Se è tilde, vai ad aggiornare contatore
    addi s0, s0, 1       # Altrimenti, passa al carattere successivo
    j ciclo

tilde:
    addi s4, s4, 1       # Incrementa il numero di comandi
    addi s0, s0, 1       # Passa oltre la tilde
    li t2, 30            # Limite massimo di comandi
    bge s4, t2, troppi   # Se >=30, mostra errore e termina
    j ciclo

troppi:
    li s5, 1                   # Imposta flag errore
    la a0, erroreInput         # Messaggio di errore per troppi comandi
    li a7, 4
    ecall
    j end                      # Salta alla fine del programma

fineConta:
    la a0, inputCorretto       # Messaggio: numero comandi valido
    li a7, 4
    ecall
    mv a0, s4                  # Mostra quanti comandi sono stati contati
    li a7, 1                   # Stampa numero intero
    ecall

    la s0, lista               # Ripristina s0 all'inizio della lista
    j whileHasChar            # Avvia parsing ed esecuzione comandi

##################################
#      PREPARAZIONE COMANDI      #
##################################
whileHasChar:
    lb t0, 0(s0)              # Legge primo carattere della lista
    beqz t0, end              # Se fine stringa, termina programma

    la t1, buffer             # t1 punta all'inizio del buffer per il comando

# Estrai comando singolo dalla stringa fino alla tilde o terminatore
getCmd:
    lb t2, 0(s0)              # Leggi carattere corrente
    beqz t2, fineGet          # Se è null terminator, fine comando
    li t3, 126                # Codice ASCII di '~'
    beq t2, t3, fineGet       # Se è '~', fine comando

    li t4, 32                 # Codice ASCII per spazio
    beq t2, t4, salta_spazi    # Se è spazio, ignoralo
    sb t2, 0(t1)              # Altrimenti, salva nel buffer
    addi t1, t1, 1            # Avanza nel buffer

salta_spazi:
    addi s0, s0, 1            # Avanza nella stringa lista
    j getCmd

fineGet:
    sb zero, 0(t1)            # Terminatore di stringa nel buffer

# Pulizia degli spazi e tildes dopo il comando estratto
salta_spazi_dopo_tilde:
    lb t3, 0(s0)              # Leggi carattere successivo
    li t4, 32                 # Spazio
    beq t3, t4, salta_spazi_dopo
    li t4, 126                # Tilde
    beq t3, t4, salta_tilde
    beqz t3, ultimaIstruzione  # Se è null termina, è l'ultimo comando
    j verificaFormattazione    # Altrimenti va a verificare il comando

salta_spazi_dopo:
    addi s0, s0, 1
    j salta_spazi_dopo_tilde

salta_tilde:
    addi s0, s0, 1
    j salta_spazi_dopo_tilde

ultimaIstruzione:
    j verificaFormattazione  # Verifica comunque l’ultimo comando prima di terminare


verificaFormattazione:
    # Stampa messaggio per iniziare la validazione del comando
    la a0, verifica        # Messaggio: "Controllo formattazione"
    li a7, 4
    ecall

    la t0, buffer          # t0 punta all'inizio del buffer dove è stato salvato il comando corrente

    # Caricamento dei primi 7 caratteri (fino a 6 lettere + terminatore) del comando nel registro
    lb t1, 0(t0)           # t1 = primo carattere
    lb t2, 1(t0)           # t2 = secondo carattere
    lb t3, 2(t0)           # t3 = terzo carattere
    lb t4, 3(t0)           # t4 = carattere di apertura 
    lb t5, 4(t0)           # t5 = carattere parametro (es. 'a')
    lb t6, 5(t0)           # t6 = carattere di chiusura 
    lb s11, 6(t0)          # s11 = dovrebbe essere null terminator

    # Verifica se è un comando "ADD(?)"
    li s10, 65             # 'A'
    bne t1, s10, controlloDEL
    li s10, 68             # 'D'
    bne t2, s10, controlloDEL
    bne t3, s10, controlloDEL
    li s10, 40         
    bne t4, s10, controlloDEL
    li s10, 41         
    bne t6, s10, controlloDEL
    beqz s11, controlloIntervallo  # se fine stringa, controlla validità del carattere parametro
    j cmdNonValido

controlloIntervallo:
    # Verifica se il parametro t5 è un carattere valido tra 32 e 125 ASCII
    li s9, 32
    blt t5, s9, cmdNonValido
    li s9, 125
    bgt t5, s9, cmdNonValido
    j cmdValido

controlloDEL:
    # Verifica se è un comando "DEL(?)"
    li s10, 68             # 'D'
    bne t1, s10, controlloPRINT
    li s10, 69             # 'E'
    bne t2, s10, controlloPRINT
    li s10, 76             # 'L'
    bne t3, s10, controlloPRINT
    li s10, 40         
    bne t4, s10, controlloPRINT
    li s10, 41          
    bne t6, s10, controlloPRINT
    beqz s11, controlloIntervallo  # se termina correttamente, controlla carattere
    j cmdNonValido

controlloPRINT:
    # Verifica se è "PRINT"
    li s10, 80             # 'P'
    bne t1, s10, controlloREV
    li s10, 82             # 'R'
    bne t2, s10, cmdNonValido
    li s10, 73             # 'I'
    bne t3, s10, cmdNonValido
    li s10, 78             # 'N'
    bne t4, s10, cmdNonValido
    li s10, 84             # 'T'
    bne t5, s10, cmdNonValido
    beqz t6, cmdValido     # t6 deve essere '\0'
    j cmdNonValido

controlloREV:
    # Verifica "REV"
    li s10, 82             # 'R'
    bne t1, s10, controlloSORT
    li s10, 69             # 'E'
    bne t2, s10, cmdNonValido
    li s10, 86             # 'V'
    bne t3, s10, cmdNonValido
    beqz t4, cmdValido     # Deve terminare subito dopo 'V'
    j cmdNonValido

controlloSORT:
    # Verifica "SORT"
    li s10, 83             # 'S'
    bne t1, s10, cmdNonValido
    li s10, 79             # 'O'
    bne t2, s10, cmdNonValido
    li s10, 82             # 'R'
    bne t3, s10, cmdNonValido
    li s10, 84             # 'T'
    bne t4, s10, cmdNonValido
    beqz t5, cmdValido     # Deve terminare subito dopo 'T'
    j cmdNonValido

cmdValido:
    # Stampa messaggio di validità del comando
    la a0, comandoValido
    li a7, 4
    ecall

    # Identifica il comando e chiama la funzione corretta
    lb t0, buffer          # Primo carattere per determinare il comando

    li t1, 65              # 'A' → ADD
    beq t0, t1, is_add

    li t1, 68              # 'D' → DEL
    beq t0, t1, is_del

    li t1, 80              # 'P' → PRINT
    beq t0, t1, is_print

    li t1, 83              # 'S' → SORT
    beq t0, t1, is_sort

    li t1, 82              # 'R' → REV
    beq t0, t1, is_rev

    j whileHasChar         # Se non è nessuno di questi, continua

cmdNonValido:
    # Stampa messaggio di errore e ignora comando
    la a0, comandoNonValido
    li a7, 4
    ecall
    j whileHasChar         # Passa al prossimo comando

# Chiamate alle procedure
is_add:
    jal addElemento        # Chiama procedura per inserimento
    j whileHasChar

is_del:
    jal delElemento        # Chiama procedura per eliminazione
    j whileHasChar

is_print:
    jal printLista         # Chiama procedura per stampa lista
    j whileHasChar

is_sort:
    jal sortListaRicorsiva # Chiama procedura ricorsiva per ordinamento
    j whileHasChar

is_rev:
    jal revLista           # Chiama procedura di inversione
    j whileHasChar

# === Funzione ADD ===
addElemento:
    # Salva contesto (ra) sullo stack per non perdere return address
    addi sp, sp, -4
    sw ra, 0(sp)      # Salva il return address

    # 1. Leggi il carattere da inserire dal buffer (alla posizione 4 corrispondente a ADD(x))
    la t0, buffer
    lb t1, 4(t0)           # t1 = DATA, il carattere da salvare nel nodo

    # 2. Controlla se c'è memoria libera
    li t2, 0
    beq s6, t2, memoria_piena    # Se s6 (freelist) == 0, memoria esaurita

    # 3. Alloca un nuovo nodo: usa il blocco puntato da s6
    mv t2, s6              # t2 = indirizzo nuovo nodo
    addi s6, s6, 5         # Avanza la freelist al prossimo nodo disponibile

    # 4. Inizializza il nuovo nodo
    sb t1, 0(t2)           # [0] = DATA: salva il carattere all'inizio del nodo
    sw zero, 1(t2)         # [1-4] = PAHEAD: inizializza puntatore a 0 (ultimo elemento per ora)

    # 5. Se la lista è vuota (head == 0), inizializza anche la testa
    li t3, 0
    beq s2, t3, lista_vuota   # s2 = head; se 0, la lista è vuota

    # 6. Altrimenti, collega il nuovo nodo in fondo alla lista
    sw t2, 1(s3)           # s3 = tail; tail->PAHEAD = nuovo nodo
    j trovata_testa    

lista_vuota:
    mv s2, t2              # s2 = head = nuovo nodo (inizializza testa della lista)

trovata_testa:
    mv s3, t2              # s3 = tail = nuovo nodo (aggiorna coda della lista)

fine_add:
    # Ripristina il contesto salvato e torna alla funzione chiamante
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

memoria_piena:
    # In caso di memoria piena, stampa messaggio e termina funzione
    la a0, erroreMemoriaPiena   # Messaggio: "Memoria piena, elemento non aggiunto"
    li a7, 4
    ecall
    j fine_add

    
# === Funzione DEL (rimozione di tutti i nodi con lo stesso DATA) ===
delElemento:
    # Salva indirizzo (RA)
    addi sp, sp, -4
    sw ra, 0(sp)

    # Estrai il carattere da eliminare dal buffer (es. DEL(a))
    la t0, buffer
    lb t1, 4(t0)           # t1 = carattere target

    mv t2, s2              # t2 = nodo corrente = testa
    li t4, 0               # t4 = nodo precedente (null)

    li s7, 0               # flag = 0 → nessun nodo eliminato finora

ciclo_del:
    beqz t2, stampaStringa_del      # Se nodo corrente è nullo, fine lista

    lb t3, 0(t2)           # t3 = DATA del nodo
    addi t6, t2, 1         # t6 = indirizzo di PAHEAD
    lw t5, 0(t6)           # t5 = PAHEAD = prossimo nodo

    bne t3, t1, prossimo_nodo  # Se il dato non corrisponde, vai avanti

    # Nodo da eliminare
    beqz t4, del_testa      # Se precedente = 0 → nodo in testa

    # Se nodo corrente è il tail, aggiorna tail
    beq t2, s3, aggiorna_tail
    j continua_del

aggiorna_tail:
    mv s3, t4              # Nuova coda = nodo precedente

continua_del:
    addi t6, t4, 1
    sw t5, 0(t6)           # precedente->PAHEAD = prossimo

    # Rimuovi nodo t2 reinserendolo nella freelist
    sb zero, 0(t2)         # resetto DATA
    sw s6, 1(t2)           # t2->PAHEAD = vecchia testa della freelist
    mv s6, t2              # testa della memoria non occupata = t2

    li s7, 1               # Almeno un nodo eliminato
    mv t2, t5              # Passa al prossimo
    j ciclo_del

del_testa:
    mv s2, t5              # Nuova testa = prossimo
    sb zero, 0(t2)         # Reset DATA
    addi t6, t2, 1
    sw zero, 0(t6)         # Reset PAHEAD
    li s7, 1               # Nodo eliminato
    mv t2, t5
    j ciclo_del

prossimo_nodo:
    mv t4, t2              # precente     = corrente
    mv t2, t5              # corrente = prossimo
    j ciclo_del

stampaStringa_del:
    beqz s7, stampaNonTrovato    # Se nessun nodo eliminato, messaggio dedicato
    la a0, eliminato
    li a7, 4
    ecall
    j fine_endDel

stampaNonTrovato:
    la a0, nonTrovato
    li a7, 4
    ecall

fine_endDel:
    # Ripristina contesto
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
# === Stampa la lista collegata partendo da head ===
printLista:
    # Salva contesto minimo
    addi sp, sp, -12    
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)

    mv t0, s2              # t0 = head
    jal printNodoRic       # chiamata ricorsiva

    # Dopo stampa: stampa newline
    li a7, 11              # syscall: stampa char
    li a0, 10              # newline (ASCII 10)
    ecall

    # Ripristina contesto
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    addi sp, sp, 12
    ret
# === Ricorsiva: stampa nodo corrente e chiama se stesso sul prossimo ===
printNodoRic:
    # Prologo: salva RA
    addi sp, sp, -8
    sw ra, 0(sp)

    beqz t0, fine          # Caso base: se t0 == 0, fine lista

    lb a0, 0(t0)           # a0 = DATA
    li a7, 11              # syscall stampa char
    ecall

    lw t1, 1(t0)           # t1 = PAHEAD
    mv t0, t1              # t0 = prossimo nodo
    jal printNodoRic       # chiamata ricorsiva

fine:
    # Epilogo: ripristina RA
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

# === Funzione REV ===
# Inverte i nodi modificando i puntatori PAHEAD
revLista:
    # Salvataggio indiirizzo 
    addi sp, sp, -4
    sw ra, 0(sp)

    # Inizializzazione
    mv t0, s2        # t0 = corrente → nodo corrente (parte dalla testa)
    li t1, 0         # t1 = precedente → nodo precedente (inizialmente NULL)

rev_ciclo:
    beqz t0, rev_fine     # Se corrente == NULL (fine lista), uscita

    # Ottieni indirizzo e valore del campo PAHEAD (prossimo nodo)
    addi t2, t0, 1        # t2 = indirizzo di corrente->PAHEAD
    lw t3, 0(t2)          # t3 = prossimo → PAHEAD corrente

    # Inversione puntatore
    sw t1, 0(t2)          # corrente->PAHEAD = precedente (inversione link)

    # Avanza nella lista
    mv t1, t0             # precedente = corrente
    mv t0, t3             # corrente = prossimo
    j rev_ciclo

rev_fine:
    # Fine ciclo: nuova testa è l'ultimo nodo visitato
    mv s2, t1             # s2 = head = prev (nuovo primo nodo)

    # Stampa messaggio di successo
    la a0, invertita      # "Lista invertita correttamente"
    li a7, 4
    ecall

    # Stampa newline
    li a7, 11
    li a0, 10
    ecall

    # Ripristina contesto
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

#=============================================
# sortListaRicorsiva - bubble sort ricorsivo robusto
# Esegue bubblePass finché almeno uno swap è effettuato.
# =============================================
sortListaRicorsiva:
    addi sp, sp, -8
    sw ra, 0(sp)          # Salva return address

    jal bubblePass        # Chiama una passata
    beqz a0, fine_sort       # Se non ci sono stati swap, fine
    jal sortListaRicorsiva  # Altrimenti, ripeti ricorsivamente

fine_sort:
    lw ra, 0(sp)
    addi sp, sp, 8
    jr ra                 # Ritorna al chiamante
#===============================================
# bubblePass – una passata a categorie
# Confronta ogni nodo con il successivo:
# - Categoria > scambia
# - Se uguale, confronto ASCII
# a0 = 1 se è stato fatto almeno uno swap
#===============================================
bubblePass:
    addi sp,sp,-16
    sw ra,0(sp)
    sw s0,4(sp)    # flag scambio
    sw s1,8(sp)
    sw s2,12(sp)

    li s0,0        # s0 = flag scambio
    mv t0,s2       # t0 = nodo corrente (inizia da head)
    lw t1,1(t0)    # t1 = prossimo nodo (PAHEAD)
    beqz t1,bp_fine # Se lista vuota o singolo nodo

bp_ciclo:
    lb t2,0(t0)    # t2 = DATA nodo corrente
    lb t3,0(t1)    # t3 = DATA nodo successivo

    # Calcola categoria di t2
    mv a0,t2
    jal categoria
    mv s1,a1       # categoria nodo corrente

    # Calcola categoria di t3
    mv a0,t3
    jal categoria
    mv s2,a1       # categoria nodo successivo

    # Ordina in base a categoria
    blt s1,s2,bp_prossimo   # ok, non serve scambio
    bgt s1,s2,do_scambio   # scambia

    # Se categoria uguale, confronta ASCII
    bgt t2,t3,do_scambio
    j bp_prossimo

do_scambio:
    sb t3,0(t0)     # nodo corrente = t3
    sb t2,0(t1)     # nodo successivo = t2
    li s0,1         # è avvenuto uno swap

bp_prossimo:
    lw t4,1(t1)     # t4 = next->PAHEAD
    beqz t4,bp_fine
    mv t0,t1        # t0 = t1 (scorre avanti)
    mv t1,t4
    j bp_ciclo

bp_fine:
    mv a0,s0        # restituisci flag swap
    lw s2,12(sp)
    lw s1,8(sp)
    lw s0,4(sp)
    lw ra,0(sp)
    addi sp,sp,16
    ret

bp_finito:
    li a0,0         # Lista già ordinata
    lw s2,12(sp)
    lw s1,8(sp)
    lw s0,4(sp)
    lw ra,0(sp)
    addi sp,sp,16
    ret


#===============================================
# categoria: mappa ASCII → categoria per ordinamento
# Input: a0 = codice ASCII del carattere
# Output: a1 = categoria numerica:
#   0 → simboli extra (non lettere né numeri)
#   1 → cifre (0–9)
#   2 → lettere minuscole (a–z)
#   3 → lettere maiuscole (A–Z)
#===============================================
categoria:
    # Controllo se è cifra: '0' (48) ≤ a0 < '9'+1 (58)
    li t5, 48
    blt a0, t5, cat_extra      # a0 < 48 → simbolo extra
    li t5, 58
    blt a0, t5, cat_digit      # a0 < 58 → è cifra

    # Controllo se è lettera maiuscola: 'A' (65) ≤ a0 < 'Z'+1 (91)
    li t5, 65
    blt a0, t5, cat_extra      # a0 < 65 → simbolo extra
    li t5, 91
    blt a0, t5, cat_upper      # a0 < 91 → è maiuscola

    # Controllo se è lettera minuscola: 'a' (97) ≤ a0 < 'z'+1 (123)
    li t5, 97
    blt a0, t5, cat_extra      # a0 < 97 → simbolo extra
    li t5, 123
    blt a0, t5, cat_lower      # a0 < 123 → è minuscola

# Se non è nessuna delle precedenti, è simbolo extra
cat_extra:
    li a1, 0                   # Categoria 0 = simbolo
    ret

cat_digit:
    li a1, 1                   # Categoria 1 = numero
    ret

cat_lower:
    li a1, 2                   # Categoria 2 = minuscola
    ret

cat_upper:
    li a1, 3                   # Categoria 3 = maiuscola
    ret

end:
    la a0, endS
    li a7, 4
    ecall

    li a7, 10      # exit
    ecall
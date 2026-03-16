# ⚙️ RISC-V Assembly: Custom Memory Allocator & Linked List Manager

Progetto per il corso di **Architetture degli Elaboratori** (A.A. 2024/2025). 

Questo progetto consiste nell'implementazione da zero di una lista concatenata in puro **Assembly RISC-V**. Non potendo usufruire delle funzioni di alto livello dei sistemi operativi, il programma include un parser di stringhe personalizzato e un gestore di memoria dinamica manuale (simulando i comportamenti di `malloc` e `free` del linguaggio C) per allocare, deallocare e riutilizzare i nodi nello spazio di memoria.

**Autore:** Mario Casalini

---

## 🚀 Competenze Tecniche Evidenziate

L'obiettivo di questo progetto non è solo gestire una lista, ma dimostrare una profonda padronanza dell'architettura RISC-V, delle convenzioni di chiamata e della manipolazione della memoria a basso livello.

### 1. Gestione Manuale della Memoria (Custom Allocator & Freelist)
* **Struttura del Nodo (5 byte):** La memoria è gestita a livello di singolo byte. Ogni nodo occupa esattamente 5 byte: `1 byte` per il payload (`DATA` - carattere ASCII) e `4 byte` per il puntatore al nodo successivo (`PAHEAD`).
* **Prevenzione dei Memory Leak:** Invece di disperdere semplicemente la memoria quando un nodo viene eliminato (tramite la funzione `DEL`), il programma resetta il nodo e ne riassegna l'indirizzo in testa a una **"freelist"** (memoria libera) gestita dal registro `s6`, rendendo il blocco immediatamente riutilizzabile per le future allocazioni.

### 2. Ricorsione e Stack Frame Management
Le funzioni complesse non utilizzano semplici cicli iterativi, ma sfruttano la **ricorsione profonda**, gestendo manualmente il prologo e l'epilogo delle chiamate a funzione:
* **Salvataggio del Contesto:** Utilizzo rigoroso dello stack pointer (`sp`) per salvare e ripristinare il *Return Address* (`ra`) e i registri salvati (`s0-s11`) ad ogni livello di ricorsione, evitando la corruzione dei dati durante le risalite.
* **Algoritmi implementati:** La funzione `PRINT` e l'algoritmo di `SORT` (Bubble Sort) sono stati implementati in modo puramente ricorsivo.

### 3. In-Place Pointer Manipulation
La funzione `REV` (Reverse) non crea una nuova copia della lista, ma ne inverte l'ordine **"in-place"**. Attraversa la lista e riassegna i puntatori fisici `PAHEAD` di ogni nodo al suo predecessore, un'operazione che richiede un controllo estremamente preciso dei registri (`t0` corrente, `t1` precedente, `t2` indirizzo del prossimo).

### 4. Parsing e Validazione dell'Input
Il programma riceve una stringa raw (es. `ADD(a)~DEL(b)~PRINT`) e implementa un tokenizzatore custom:
* Ignora gli spazi bianchi tra i comandi.
* Isola il comando e i suoi argomenti in un buffer temporaneo dedicato.
* Esegue una validazione stringente basata sui codici ASCII (es. accetta argomenti solo tra ASCII 32 e 125).

---

## 🛠️ Funzionalità Implementate

Il parser riconosce ed esegue i seguenti comandi (fino a un massimo di 30 operazioni per run, causa limite di pool memory pre-impostato a 150 byte):

* `ADD(x)`: Alloca un nuovo nodo con il carattere 'x' pescando dalla *freelist* e lo appende in coda.
* `DEL(x)`: Scorre la lista, identifica **tutti** i nodi contenenti 'x', li estrae scollegando i puntatori e li reinserisce nella memoria libera.
* `PRINT`: Stampa in output i contenuti della lista tramite chiamate ricorsive e `syscall`.
* `REV`: Inverte l'ordine di tutti i nodi riassegnando i puntatori.
* `SORT`: Ordina la lista tramite un Bubble Sort ricorsivo. L'ordinamento avviene prima per **categoria** (Simboli -> Numeri -> Lettere Minuscole -> Lettere Maiuscole) e poi per valore ASCII.

---

## 💻 Come eseguire il codice

Il codice è scritto per essere eseguito su simulatori RISC-V standard come **RARS** o **RIPES**.

1. Clona la repository.
2. Apri il file `src/main.s` (o `.asm`) all'interno del tuo simulatore RISC-V.
3. (Opzionale) Modifica la stringa `listInput` nella sezione `.data` per testare nuove combinazioni di comandi.
4. Compila/Assembla il codice ed esegui. L'output testuale apparirà nella console (I/O) del simulatore.

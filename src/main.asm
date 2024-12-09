org 0x7C00
bits 16

%define ENDL 0x0D, 0x0A

start:
    jmp main

;
; Prints a string to the screen
; Params:
;   - ds:si points to string
;
schreiber:
    ; save registers we will modify
    push si
    push ax
    push bx

    ; ax in ascii konvertieren
    mov bx, 10  ; bx = 10 für dez. ausg.
    xor dx, dx  ; dx wird 0 gesetzt
    div bx      ; AX / 10, der Quotient bleibt in AX, der Rest in DX (die Ziffer)

    ; Ziffer in DX ist die niedrigwertige Ziffer
    add dl, '0' ; Umwandeln in ASCII-Ziffer
    mov ah, 0x02; DOS-Ausgabe-Interrupt
    int 0x21    ; Zeichen ausgeben

    ; Wenn der Quotient nicht null ist, gebe auch diesen aus
    test ax, ax
    jz ende_ausgabe
    add al, '0' ; Umwandeln der nächsten Ziffer in ASCII
    mov ah, 0x02
    int 0x21    ; Zweite Ziffer ausgeben

    ; Weiteren Text ausgeben
.loop:
    lodsb               ; Lädt das nächste Zeichen in AL
    or al, al           ; Überprüft, ob das nächste Zeichen null ist
    jz .done            ; Wenn null, Ende der Ausgabe

    mov ah, 0x0E        ; BIOS interrupt zum Ausgeben von Zeichen
    mov bh, 0           ; Seitenzahl auf 0 setzen
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si    
    ret

ende_ausgabe:
    ; Rückkehr zum Aufrufer
    pop bx
    pop ax
    pop si
    ret

;
; Waits for a key press and stores the ASCII code in AL
;
get_key:
    mov ah, 0           ; BIOS: Get keystroke (wartet auf Tastendruck)
    int 0x16            ; Ergebnis in AX, AL = ASCII, AH = Scan-Code
    ret

main:
    ; Setup des Daten-Segments
    mov ax, 0           ; Wir können ds/es nicht direkt setzen
    mov ds, ax
    mov es, ax

    ; Setup des Stack-Segments
    mov ss, ax
    mov sp, 0x7C00      ; Stack wächst nach unten ab der Ladeadresse

    ; Text ausgeben lassen
    mov si, nachricht
    call schreiber      ; Dieser Aufruf gibt den Text aus
    mov si, Dings
    call schreiber
    call SpamDings

    ; Inkrementierung und Ausgabe der Zahl im Loop
    call Etwas_rechnen

SpamDings:
    mov si, Bums
    call schreiber

Etwas_rechnen:
    ; Initialisierung der Zahl
    mov ax, 0

.loop:
    ; Inkrementiere die Zahl
    inc ax              ; Zahl in AX um 1 erhöhen

    ; Die aktuelle Zahl ausgeben
    push ax             ; Speichern des Werts von AX auf Stack
    call schreiber      ; Zahl ausgeben
    pop ax              ; Wiederherstellen des Werts von AX vom Stack

    ; Text ausgeben nach der Zahl
    call schreiber

    ; Warte auf Tastendruck
    call get_key

    ; Endlosschleife fortsetzen
    jmp .loop

.halt:
    jmp .halt

nachricht: db 'Du kannst schreiben!', ENDL, 0
Dings: db 'Hier steht vielleicht auch was', ENDL, 0
Bums: db 'DINGSSSS!!', ENDL, 0
times 510-($-$$) db 0
dw 0AA55h
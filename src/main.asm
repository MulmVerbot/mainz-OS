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
    xor dx, dx ; dx wird 0 gesetzt
    div bx          ; AX / 10, der Quotient bleibt in AX, der Rest in DX (die Ziffer)

    ; Ziffer in DX ist die niedrigwertige Ziffer
    add dl, '0'     ; Umwandeln in ASCII-Ziffer
    mov ah, 0x02    ; DOS-Ausgabe-Interrupt
    int 0x21        ; Zeichen ausgeben

    ; Wenn der Quotient nicht null ist, gebe auch diesen aus
    test ax, ax
    jz ende_ausgabe
    add al, '0'     ; Umwandeln der nächsten Ziffer in ASCII
    mov ah, 0x02
    int 0x21        ; Zweite Ziffer ausgeben

.loop:
    lodsb               ; loads next character in al
    or al, al           ; verify if next character is null?
    jz .done

    mov ah, 0x0E        ; call bios interrupt
    mov bh, 0           ; set page number to 0
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
    mov ah, 0           ; BIOS: Get keystroke (waits for key press)
    int 0x16            ; result in AX, AL = ASCII, AH = scan code
    ret

main:
    ; setup data segments
    mov ax, 0           ; can't set ds/es directly
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7C00      ; stack grows downwards from where we are loaded in memory

    ; text schreiben lassen
    mov si, nachricht
    call schreiber  ; dieses schreiber muss jedes mal aufgerufen werden wenn ich den wert si nutzen will
    mov si, Dings
    call schreiber
    call SpamDings

    call Etwas_rechnen

SpamDings:
    mov si, Bums
    call schreiber

Etwas_rechnen:
    mov ax, 0
    inc ax  ; Das hier sollte um eins hochrechnen
    push ax
    call schreiber

.input_loop:
    ; Wait for a key press
    call get_key

    ; Display the key
    mov ah, 0x0E        ; BIOS interrupt to print character
    int 0x10

    ; Loop forever
    jmp .input_loop

.halt:
    jmp .halt

nachricht: db 'Du kannst schreiben!', ENDL, 0
Dings: db 'Hier steht vielleicht auch was', ENDL, 0
Bums: db 'DINGSSSS!!', ENDL, 0


times 510-($-$$) db 0
dw 0AA55h
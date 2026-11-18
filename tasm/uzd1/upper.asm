; Didziuju raidziu skaiciavimas
; Atliko: Simonas Andreika

.model small
.stack 100h
.code

start:
	mov bl, 0		; bl - skaitliukas

skaityti:
	mov ah, 1		; nuskaito simboli i al
	int 21h

	cmp al, 13		; enter
	je baigti

	cmp al, 'A'
	jb skaityti
	cmp al, 'Z'
	ja skaityti

	inc bl
	jmp skaityti

baigti:
	mov ah, 2		; spausdina simboli is dl
	mov dl, 10		; nauja eilute
	int 21h

	mov al, bl
	mov ah, 0
	mov bl, 10
	div bl			; al - desimtys, ah - vienetai
	mov bh, ah		; bh - vienetai

	mov ah, 2
	cmp al, 0
	je vienetai
	mov dl, al
	add dl, '0'
	int 21h

vienetai:
	mov dl, bh
	add dl, '0'
	int 21h

	mov ah, 4Ch
	int 21h

end start

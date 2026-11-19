; 22 uzduotis: raidziu pasiskirstymo grafikas
; Parametrai - failu vardai. Suskaiciuoja kiek kartu pasikartoja
; kiekviena raide ir i faila REZ.TXT nupiesia grafika.
; Atliko: Simonas Andreika

.model small
.stack 100h

.data
	pagalba   db "Naudojimas: raides [failas1] [failas2] ...", 13,10
	          db "Suskaiciuoja raides failuose ir i REZ.TXT nupiesia grafika.", 13,10
	          db "Be parametru skaitoma is standartinio ivedimo.", 13,10, "$"
	klaida    db "Nepavyko atidaryti failo", 13,10, "$"
	rezvardas db "REZ.TXT", 0

	cmd       db 130 dup(0)		; komandine eilute
	buf       db 512 dup(?)		; skaitymo buferis
	eil       db 80 dup(?)		; viena rezultato eilute
	kiek      dw 26 dup(0)		; kiek kartu pasikartojo kiekviena raide
	failu     db 0			; 1 - jei buvo failu
	rez       dw ?			; REZ.TXT handle
	eilnr     dw ?			; kuria eilute piesiam

.code

start:
	mov ah, 62h		; bx = PSP
	int 21h
	mov ax, @data
	mov es, ax
	mov ds, bx
	mov cl, ds:[80h]	; parametru ilgis
	mov ch, 0
	mov si, 81h		; parametrai nuo 81h
	mov di, offset cmd
	rep movsb		; nukopijuojam i cmd
	mov ds, ax

	mov si, offset cmd
parametras:
	cmp byte ptr [si], ' '	; tarpus praleidziam
	jne ne_tarpas
	inc si
	jmp parametras
ne_tarpas:
	cmp byte ptr [si], 0	; parametru pabaiga
	je skaityta
	cmp word ptr [si], '?/'	; "/?" (atmintyje baitai sukeisti)
	je rodyti_pagalba

	mov dx, si		; failo vardo pradzia
vardo_galas:
	inc si
	cmp byte ptr [si], ' '
	je vardas_baigtas
	cmp byte ptr [si], 0
	jne vardo_galas
vardas_baigtas:
	mov byte ptr [si], 0	; vardo gale 0
	inc si
	mov failu, 1

	mov ax, 3D00h		; atidaryti faila
	int 21h
	jc neatidare
	mov bx, ax
	call skaityti
	mov ah, 3Eh		; uzdaryti
	int 21h
	jmp parametras
neatidare:
	push si
	mov si, dx

zodzio_simbolis:
	mov al, [si]
	cmp al, 0
	je zodis_baigtas
	inc si
	and al, 11011111b
	cmp al, 'A'
	jb ne_raide
	cmp al, 'Z'
	ja ne_raide
	sub al, 'A'
	mov bl, al
	mov bh, 0
	shl bx, 1
	inc kiek[bx]

ne_raide:
	jmp zodzio_simbolis

zodis_baigtas:
	pop si
	jmp parametras

rodyti_pagalba:
	mov ah, 9
	mov dx, offset pagalba
	int 21h
	jmp pabaiga

skaityta:
	cmp failu, 1
	je grafikas
	mov bx, 0		; failu nebuvo - skaitom stdin
	call skaityti

grafikas:
	mov ah, 3Ch		; sukurti REZ.TXT
	mov cx, 0
	mov dx, offset rezvardas
	int 21h
	mov rez, ax

	mov ax, 0		; randam didziausia kieki
	mov si, 0
maks_ciklas:
	cmp kiek[si], ax
	jbe ne_didesnis
	mov ax, kiek[si]
ne_didesnis:
	add si, 2
	cmp si, 52
	jb maks_ciklas
	mov eilnr, ax		; grafiko aukstis = didziausias kiekis

eilute:				; piesiam is virsaus i apacia
	cmp eilnr, 0
	je asis
	mov di, offset eil
	mov ax, eilnr		; kaireje - kiekis
	call skaicius
	mov byte ptr [di], '|'
	inc di
	mov si, 0
stulpelis:
	mov byte ptr [di], ' '
	mov byte ptr [di+1], ' '
	mov ax, kiek[si]
	cmp ax, eilnr		; stulpelis siekia sia eilute?
	jb tuscia
	mov byte ptr [di+1], '#'
tuscia:
	add di, 2
	add si, 2
	cmp si, 52
	jb stulpelis
	call rasyti
	dec eilnr
	jmp eilute

asis:				; "    +-----..."
	mov di, offset eil
	mov ax, 0
	call skaicius
	mov byte ptr [di], '+'
	inc di
	mov cx, 52
bruksnys:
	mov byte ptr [di], '-'
	inc di
	loop bruksnys
	call rasyti

	mov di, offset eil	; po asimi raides: "      A B C ..."
	mov cx, 6
tarpai:
	mov byte ptr [di], ' '
	inc di
	loop tarpai
	mov al, 'A'
raides:
	mov byte ptr [di], ' '
	mov [di+1], al
	add di, 2
	inc al
	cmp al, 'Z'
	jbe raides
	call rasyti

	mov ah, 3Eh		; uzdaryti REZ.TXT
	mov bx, rez
	int 21h

pabaiga:
	mov ax, 4C00h
	int 21h

; skaito is bx failo buferiais ir skaiciuoja raides
skaityti proc
	push si
	push bx
skaityti_buf:
	pop bx
	push bx
	mov ah, 3Fh		; nuskaityti iki 512 baitu
	mov cx, 512
	mov dx, offset buf
	int 21h
	jc skaityti_pab		; klaida
	cmp ax, 0		; 0 - failo pabaiga
	je skaityti_pab
	mov cx, ax		; cx - kiek nuskaitem
	mov si, offset buf
simbolis:
	mov al, [si]
	inc si
	and al, 11011111b	; mazoji -> didzioji (isvalom 5 bita)
	cmp al, 'A'
	jb kitas
	cmp al, 'Z'
	ja kitas
	sub al, 'A'		; raides numeris 0..25
	mov bl, al
	mov bh, 0
	shl bx, 1		; kiek[] po 2 baitus
	inc kiek[bx]
kitas:
	loop simbolis
	jmp skaityti_buf
skaityti_pab:
	pop bx
	pop si
	ret
skaityti endp

; ax -> skaicius 5 simboliu plocio i [di]
skaicius proc
	mov cx, 5
tarpai5:
	mov byte ptr [di], ' '
	inc di
	loop tarpai5
	push di
	mov bx, 10
skaitmuo:
	mov dx, 0
	div bx			; ax = ax / 10, dx = liekana
	add dl, '0'
	dec di
	mov [di], dl
	cmp ax, 0
	jne skaitmuo
	pop di
	ret
skaicius endp

; prideda 13,10 ir iraso eil[] i REZ.TXT
rasyti proc
	mov byte ptr [di], 13
	mov byte ptr [di+1], 10
	add di, 2
	mov cx, di
	sub cx, offset eil	; eilutes ilgis
	mov ah, 40h
	mov bx, rez
	mov dx, offset eil
	int 21h
	ret
rasyti endp

end start

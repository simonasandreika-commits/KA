; Programa: suskaiciuoja didziasias raides		; ";" - komentaras, kompiuteris jo neskaito
; Atliko: Vardas Pavarde				; ";" - komentaras

.model small		; programos dydis "mazas" - visada taip rasoma
.stack 100h		; vieta stekui (256 baitai); jo reikia int 21h, kad zinotu kur grizti
.code			; nuo cia prasideda komandos

start:			; zyme (vardas vietai kode) - cia programa prasideda
	mov bl, 0		; mov bl, 0 reiskia bl = 0; bl - registras (dezute skaiciui), cia bus skaitliukas

skaityti:		; zyme - i cia grisim, kai noresim skaityti kita simboli
	mov ah, 1		; ah pasako DOS'ui ka daryti: 1 = nuskaityti viena simboli is klaviaturos
	int 21h			; iskviesti DOS: laukia kol paspausi klavisa, ta simboli ideda i al

	cmp al, 13		; cmp - palyginti; ar al lygus 13? (13 - Enter klaviso kodas)
	je baigti		; je - "sokti jei lygu"; jei Enter - sokam i zyme baigti

	cmp al, 'A'		; palyginti simboli su 'A' (kompiuteryje 'A' = 65)
	jb skaityti		; jb - "sokti jei maziau"; maziau uz 'A' - ne didzioji (pvz. skaitmuo, tarpas)
	cmp al, 'Z'		; palyginti simboli su 'Z' (kompiuteryje 'Z' = 90)
	ja skaityti		; ja - "sokti jei daugiau"; daugiau uz 'Z' - ne didzioji (pvz. mazosios a-z = 97-122)

	inc bl			; inc - prideti 1; atejom iki cia, vadinasi simbolis tarp A ir Z - didzioji raide
	jmp skaityti		; jmp - sokti visada; grizti skaityti kito simbolio

baigti:			; zyme - cia atsiduriam paspaudus Enter
	mov ah, 2		; ah = 2: DOS funkcija "isvesti viena simboli, kuris yra dl"
	mov dl, 10		; 10 - naujos eilutes simbolis
	int 21h			; isvesti nauja eilute, kad atsakymas butu po ivestu tekstu

	mov al, bl		; skaitliuko reiksme perkeliam i al (div dirba su ax)
	mov ah, 0		; ah isvalom, kad ax = tik musu skaicius (ax = ah + al)
	mov bl, 10		; dalinsim is 10 (bl jau galim perrasyti, skaicius yra al)
	div bl			; ax / 10: al = dalmuo (desimtys), ah = liekana (vienetai); pvz. 12 -> al=1, ah=2
	mov bh, ah		; vienetus pasidedam i bh, nes ah tuoj perrasysim

	mov ah, 2		; ah = 2: DOS funkcija "isvesti viena simboli is dl"
	cmp al, 0		; ar desimciu yra 0? (skaicius mazesnis uz 10)
	je vienetai		; jei taip - desimciu nerodom (kitaip vietoj 5 butu 05)
	mov dl, al		; desimtis dedam i dl
	add dl, '0'		; add - prideti; +48: skaicius 1 tampa simboliu '1' (kompiuteryje '1' = 49)
	int 21h			; isvesti desimciu skaitmeni

vienetai:		; zyme - vienetu isvedimas
	mov dl, bh		; vienetus (pasidetus bh) dedam i dl
	add dl, '0'		; skaiciu paverciam simboliu (+48)
	int 21h			; isvesti vienetu skaitmeni (ah vis dar 2)

	mov ah, 4Ch		; ah = 4Ch: DOS funkcija "baigti programa"
	int 21h			; programa baigiasi, griztam i DOS

end start		; failo pabaiga; start - nuo kurios zymes pradeti vykdyti

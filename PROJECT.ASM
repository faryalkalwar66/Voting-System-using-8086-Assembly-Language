.model small
.stack 100h

.data

; ===================== WELCOME / BRANDING =====================
welcome      db "================================================",13,10
             db "       WELCOME TO COAL VOTING SYSTEM           ",13,10
             db "          Powered by 8086 Assembly             ",13,10
             db "================================================",13,10,"$"

; ===================== MAIN MENU =====================
menu         db 13,10,"============= MAIN MENU ================",13,10
             db "1. Register as Voter",13,10
             db "2. Login & Cast Vote",13,10
             db "3. View Live Vote Count",13,10
             db "4. Announce Winner",13,10
             db "5. Admin Panel",13,10
             db "6. Exit",13,10
             db "Enter choice: $"

; ===================== CANDIDATES =====================
cand_header  db 13,10,"======== CANDIDATES ON BALLOT ==========",13,10,"$"
cand1_msg    db "  [1] Ali Raza        - Party: PML",13,10,"$"
cand2_msg    db "  [2] Sara Khan       - Party: PTI",13,10,"$"
cand3_msg    db "  [3] Usman Tariq     - Party: PPP",13,10,"$"
cand4_msg    db "  [4] Nadia Iqbal     - Party: MQM",13,10,"$"
cand_footer  db "========================================",13,10,"$"

votes        dw 0,0,0,0

; ===================== VOTER DATA =====================
voters       dw 10 dup(0)
voter_pins   dw 10 dup(0)
has_voted    db 10 dup(0)

voter_count  db 0
currentVoter dw ?

; ===================== MESSAGES =====================
invalid_msg  db 13,10,"Invalid choice! Try again.$"
full_msg     db 13,10,"Voter registration full!$"
reg_ok       db 13,10,"Voter registered successfully!$"

enter_pin    db 13,10,"Enter your 4-digit PIN: $"
enter_vid    db 13,10,"Enter your Voter ID: $"

wrong_pin    db 13,10,"Wrong PIN!$"
not_found    db 13,10,"Voter not found!$"

login_ok     db 13,10,"Login successful!$"

already_msg  db 13,10,"You already voted!$"

vote_prompt  db 13,10,"Enter candidate number (1-4): $"

vote_ok      db 13,10,"Vote cast successfully!$"

bad_cand     db 13,10,"Invalid candidate!$"

count_hdr    db 13,10,"========= LIVE VOTE COUNT =========",13,10,"$"

cname1       db "Ali Raza    : $"
cname2       db "Sara Khan   : $"
cname3       db "Usman Tariq : $"
cname4       db "Nadia Iqbal : $"

votes_txt    db " votes",13,10,"$"

winner_hdr   db 13,10,"========= WINNER =========",13,10,"$"

winner_msg   db "Winner is: $"

tie_msg      db 13,10,"Election Result: TIE!$"

no_votes_msg db 13,10,"No votes cast yet!$"

goodbye      db 13,10,"Thank you for using Voting System!",13,10,"$"

newline      db 13,10,"$"

; ===================== ADMIN =====================
admin_prompt db 13,10,"Enter Admin Password: $"

admin_pass   dw 9999

admin_deny   db 13,10,"Wrong admin password!$"

your_id_msg  db 13,10,"Your Voter ID is: $"

; ===================== VOTE MENU =====================
vote_menu    db 13,10
             db "1. Cast Vote",13,10
             db "2. Logout",13,10
             db "Enter choice: $"

.code

; ==========================================================
main proc

    mov ax,@data
    mov ds,ax

    mov ah,9
    lea dx,welcome
    int 21h

    call show_candidates

; ==========================================================
main_menu:

    mov ah,9
    lea dx,menu
    int 21h

    mov ah,1
    int 21h

    cmp al,'1'
    jne chk2
    jmp register_voter

chk2:
    cmp al,'2'
    jne chk3
    jmp login_voter

chk3:
    cmp al,'3'
    jne chk4
    jmp view_count

chk4:
    cmp al,'4'
    jne chk5
    jmp announce_winner

chk5:
    cmp al,'5'
    jne chk6
    jmp admin_panel

chk6:
    cmp al,'6'
    jne invalid_option
    jmp end_program

invalid_option:
    mov ah,9
    lea dx,invalid_msg
    int 21h
    jmp main_menu

; ==========================================================
; REGISTER VOTER
; ==========================================================

register_voter:

    mov al,voter_count
    cmp al,10
    jge reg_full

    xor ax,ax
    mov al,voter_count

    mov si,ax
    shl si,1

    add ax,2001

    mov voters[si],ax

    mov ah,9
    lea dx,your_id_msg
    int 21h

    mov ax,voters[si]
    call print_number

    mov ah,9
    lea dx,enter_pin
    int 21h

    call read_4digit

    mov voter_pins[si],cx

    xor ax,ax
    mov al,voter_count

    mov di,ax
    mov has_voted[di],0

    inc voter_count

    mov ah,9
    lea dx,reg_ok
    int 21h

    jmp main_menu

reg_full:
    mov ah,9
    lea dx,full_msg
    int 21h

    jmp main_menu

; ==========================================================
; LOGIN
; ==========================================================

login_voter:

    cmp voter_count,0
    je voter_not_found

    mov ah,9
    lea dx,enter_vid
    int 21h

    call read_4digit

    mov bx,cx

    mov si,0

    xor cx,cx
    mov cl,voter_count

search_loop:

    mov ax,voters[si]

    cmp ax,bx
    je voter_found

    add si,2

    dec cl
    jnz search_loop

voter_not_found:

    mov ah,9
    lea dx,not_found
    int 21h

    jmp main_menu

voter_found:

    mov ah,9
    lea dx,enter_pin
    int 21h

    call read_4digit

    mov bx,cx

    mov ax,voter_pins[si]

    cmp ax,bx
    jne wrong_password

    mov currentVoter,si

    mov ah,9
    lea dx,login_ok
    int 21h

; ==========================================================
voter_menu:

    mov ah,9
    lea dx,vote_menu
    int 21h

    mov ah,1
    int 21h

    cmp al,'1'
    jne vm2
    jmp cast_vote

vm2:
    cmp al,'2'
    jne voter_menu
    jmp logout_user

wrong_password:

    mov ah,9
    lea dx,wrong_pin
    int 21h

    jmp main_menu

; ==========================================================
; CAST VOTE
; ==========================================================

cast_vote:

    mov si,currentVoter

    mov ax,si
    shr ax,1

    mov di,ax

    cmp has_voted[di],1
    je already_voted

    call show_candidates

    mov ah,9
    lea dx,vote_prompt
    int 21h

    mov ah,1
    int 21h

    cmp al,'1'
    jne vc2
    jmp vote1

vc2:
    cmp al,'2'
    jne vc3
    jmp vote2

vc3:
    cmp al,'3'
    jne vc4
    jmp vote3

vc4:
    cmp al,'4'
    jne bad_candidate
    jmp vote4

vote1:
    inc votes[0]
    jmp finish_vote

vote2:
    inc votes[2]
    jmp finish_vote

vote3:
    inc votes[4]
    jmp finish_vote

vote4:
    inc votes[6]
    jmp finish_vote

bad_candidate:

    mov ah,9
    lea dx,bad_cand
    int 21h

    jmp voter_menu

finish_vote:

    mov si,currentVoter

    mov ax,si
    shr ax,1

    mov di,ax

    mov has_voted[di],1

    mov ah,9
    lea dx,vote_ok
    int 21h

    jmp voter_menu

already_voted:

    mov ah,9
    lea dx,already_msg
    int 21h

    jmp voter_menu

logout_user:
    jmp main_menu

; ==========================================================
; VIEW COUNT
; ==========================================================

view_count:

    mov ah,9
    lea dx,count_hdr
    int 21h

    ; Candidate 1
    mov ah,9
    lea dx,cname1
    int 21h

    mov ax,votes[0]
    call print_number

    mov ah,9
    lea dx,votes_txt
    int 21h

    ; Candidate 2
    mov ah,9
    lea dx,cname2
    int 21h

    mov ax,votes[2]
    call print_number

    mov ah,9
    lea dx,votes_txt
    int 21h

    ; Candidate 3
    mov ah,9
    lea dx,cname3
    int 21h

    mov ax,votes[4]
    call print_number

    mov ah,9
    lea dx,votes_txt
    int 21h

    ; Candidate 4
    mov ah,9
    lea dx,cname4
    int 21h

    mov ax,votes[6]
    call print_number

    mov ah,9
    lea dx,votes_txt
    int 21h

    jmp main_menu

; ==========================================================
; WINNER
; ==========================================================

announce_winner:

    mov ax,votes[0]
    add ax,votes[2]
    add ax,votes[4]
    add ax,votes[6]

    cmp ax,0
    je no_votes

    mov ah,9
    lea dx,winner_hdr
    int 21h

    mov ax,votes[0]
    mov bx,0

    cmp votes[2],ax
    jbe next3
    mov ax,votes[2]
    mov bx,2

next3:
    cmp votes[4],ax
    jbe next4
    mov ax,votes[4]
    mov bx,4

next4:
    cmp votes[6],ax
    jbe show_winner
    mov ax,votes[6]
    mov bx,6

show_winner:

    mov ah,9
    lea dx,winner_msg
    int 21h

    cmp bx,0
    jne wc2

    lea dx,cname1
    jmp print_winner

wc2:
    cmp bx,2
    jne wc3

    lea dx,cname2
    jmp print_winner

wc3:
    cmp bx,4
    jne wc4

    lea dx,cname3
    jmp print_winner

wc4:
    lea dx,cname4

print_winner:

    mov ah,9
    int 21h

    jmp main_menu

no_votes:

    mov ah,9
    lea dx,no_votes_msg
    int 21h

    jmp main_menu

; ==========================================================
; ADMIN PANEL
; ==========================================================

admin_panel:

    mov ah,9
    lea dx,admin_prompt
    int 21h

    call read_4digit

    cmp cx,admin_pass
    jne admin_wrong

    jmp view_count

admin_wrong:

    mov ah,9
    lea dx,admin_deny
    int 21h

    jmp main_menu

; ==========================================================
; EXIT
; ==========================================================

end_program:

    mov ah,9
    lea dx,goodbye
    int 21h

    mov ah,4Ch
    int 21h

main endp

; ==========================================================
; SHOW CANDIDATES
; ==========================================================

show_candidates proc

    mov ah,9

    lea dx,cand_header
    int 21h

    lea dx,cand1_msg
    int 21h

    lea dx,cand2_msg
    int 21h

    lea dx,cand3_msg
    int 21h

    lea dx,cand4_msg
    int 21h

    lea dx,cand_footer
    int 21h

    ret

show_candidates endp

; ==========================================================
; PRINT NUMBER
; ==========================================================

print_number proc

    mov bx,10
    mov cx,0

pn1:
    mov dx,0
    div bx

    push dx

    inc cx

    cmp ax,0
    jne pn1

pn2:
    pop dx

    add dl,48

    mov ah,2
    int 21h

    loop pn2

    ret

print_number endp

; ==========================================================
; READ 4 DIGITS
; ==========================================================

read_4digit proc

    ; digit 1
    mov ah,1
    int 21h

    sub al,48

    mov ah,0

    mov bx,1000
    mul bx

    mov cx,ax

    ; digit 2
    mov ah,1
    int 21h

    sub al,48

    mov ah,0

    mov bx,100
    mul bx

    add cx,ax

    ; digit 3
    mov ah,1
    int 21h

    sub al,48

    mov ah,0

    mov bx,10
    mul bx

    add cx,ax

    ; digit 4
    mov ah,1
    int 21h

    sub al,48

    mov ah,0

    add cx,ax

    ret

read_4digit endp

end main
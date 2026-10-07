classify_win:
    push rbx
    mov ebx, edi
    mov esi, 68
    xor edx, edx
    mov ecx, 1
    call get_prop
    test eax, eax
    jz .gone
    cmp dword [rbuf+8], 0
    jne .float
    mov edi, ebx
    mov esi, [atoms+AT_WTYPE*4]
    mov edx, 4
    mov ecx, 8
    call get_prop
    test eax, eax
    jz .gone
    mov ecx, [rbuf+16]
    cmp ecx, 8
    jbe .c
    mov ecx, 8
.c: lea rsi, [xbuf]
.t: test ecx, ecx
    jz .tiled
    mov eax, [rsi]
    cmp eax, [atoms+AT_DIALOG*4]
    je .float
    cmp eax, [atoms+AT_SPLASH*4]
    je .float
    cmp eax, [atoms+AT_UTIL*4]
    je .float
    cmp eax, [atoms+AT_DOCK*4]
    je .dock
    add rsi, 4
    dec ecx
    jmp .t
.tiled:
    xor eax, eax
    jmp .o
.float:
    mov eax, 1
    jmp .o
.dock:

    mov edi, ebx
    mov esi, [atoms+AT_STRUT*4]
    mov edx, 6
    mov ecx, 12
    call get_prop
    test eax, eax
    jz .legacystrut

    cmp dword [rbuf+16], 3
    jae .partialok
.legacystrut:

    mov edi, ebx
    mov esi, [atoms+AT_STRUT_OLD*4]
    mov edx, 6
    mov ecx, 4
    call get_prop
    test eax, eax
    jz .nostrut
    cmp dword [rbuf+16], 3
    jb .nostrut
.partialok:
    mov eax, [xbuf+8]
    jmp .strutdone
.nostrut:
    xor eax, eax
.strutdone:
    mov [bar_top], eax
    mov [bar_win], ebx
    mov eax, 2
    jmp .o
.gone:
    mov eax, -1
.o: pop rbx
    ret

fl_find:
    test edi, edi
    jz .no
    lea rdx, [flt]
    xor eax, eax
.l: cmp eax, FLN
    jge .no
    mov ecx, eax
    shl ecx, 4
    cmp [rdx+rcx], edi
    je .ret
    inc eax
    jmp .l
.no:
    mov eax, -1
.ret:
    ret

fl_add:
    lea rdx, [flt]
    xor eax, eax
.l: cmp eax, FLN
    jge .no
    mov ecx, eax
    shl ecx, 4
    cmp dword [rdx+rcx], 0
    je .f
    inc eax
    jmp .l
.f: mov [rdx+rcx], edi
    mov [rdx+rcx+4], esi
    mov dword [rdx+rcx+8], 0
    ret
.no:
    mov eax, -1
    ret

set_attrs:
    lea rsi, [req]
    mov byte [rsi], 2
    mov byte [rsi+1], 0
    mov word [rsi+2], 5
    mov [rsi+4], edi
    mov dword [rsi+8], 0x808
    mov dword [rsi+12], COL_UNFOC
    mov dword [rsi+16], ENTER_MASK
    mov edx, 20
    jmp send

focus_float:
    push rbx
    mov ebx, edi
    mov eax, [focus]
    cmp eax, -1
    je .nt
    lea rdx, [nodes]
    shl eax, 5
    mov edi, [rdx+rax+N_WIN]
    test edi, edi
    jz .nt
    mov esi, COL_UNFOC
    call send_border
.nt:
    mov edi, [fwin]
    test edi, edi
    jz .nf
    cmp edi, ebx
    je .nf
    mov esi, COL_UNFOC
    call send_border
.nf:
    mov [fwin], ebx
    mov edi, ebx
    mov esi, COL_FOC
    call send_border
    mov edi, ebx
    call send_focus
    call ewmh_active
    pop rbx
    ret

float_window:
    push rbx
    mov ebx, edi
    mov esi, [cur]
    call fl_add
    cmp eax, -1
    je .map
    mov edi, ebx
    call set_attrs
    lea rdi, [req]
    mov byte [rdi], 14
    mov byte [rdi+1], 0
    mov word [rdi+2], 2
    mov [rdi+4], ebx
    mov rsi, rdi
    mov edx, 8
    call send
    call wait_reply
    test eax, eax
    jz .map
    movzx eax, word [rbuf+16]
    movzx ecx, word [rbuf+18]
    lea rdi, [req]
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov word [rdi+2], 7
    mov [rdi+4], ebx
    mov word [rdi+8], 0x53
    mov word [rdi+10], 0
    mov edx, [scrw]
    sub edx, eax
    jns .x1
    xor edx, edx
.x1:shr edx, 1
    mov [rdi+12], edx
    mov edx, [scrh]
    sub edx, ecx
    jns .y1
    xor edx, edx
.y1:shr edx, 1
    mov [rdi+16], edx
    mov dword [rdi+20], BW
    mov dword [rdi+24], 0
    mov rsi, rdi
    mov edx, 28
    call send
.map:
    mov edi, ebx
    call map_window
    mov edi, ebx
    call focus_float
    call ewmh_clients
    pop rbx
    ret

fwd_configure:
    lea rdi, [req]
    movzx ecx, word [ev+26]
    and ecx, 0xf
    mov byte [rdi], 12
    mov byte [rdi+1], 0
    mov eax, [ev+8]
    mov [rdi+4], eax
    mov [rdi+8], cx
    mov word [rdi+10], 0
    lea rsi, [rdi+12]
    test ecx, 1
    jz .y
    movsx eax, word [ev+16]
    mov [rsi], eax
    add rsi, 4
.y: test ecx, 2
    jz .w
    movsx eax, word [ev+18]
    mov [rsi], eax
    add rsi, 4
.w: test ecx, 4
    jz .h
    movzx eax, word [ev+20]
    mov [rsi], eax
    add rsi, 4
.h: test ecx, 8
    jz .s
    movzx eax, word [ev+22]
    mov [rsi], eax
    add rsi, 4
.s: mov rdx, rsi
    sub rdx, rdi
    mov eax, edx
    shr eax, 2
    mov [rdi+2], ax
    mov rsi, rdi
    jmp send

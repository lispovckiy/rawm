find_env:
    mov rcx, [init_sp]
    mov rax, [rcx]
    lea rcx, [rcx+rax*8+16]
.e: mov rdx, [rcx]
    test rdx, rdx
    jz .no
    xor eax, eax
.c: cmp eax, esi
    je .yes
    mov r9b, [rdx+rax]
    cmp r9b, [rdi+rax]
    jne .nx
    inc eax
    jmp .c
.yes:
    lea rax, [rdx+rsi]
    ret
.nx:
    add rcx, 8
    jmp .e
.no:
    xor eax, eax
    ret

load_auth:
    push rbx
    push r12
    push r13
    lea rdi, [env_xauth]
    mov esi, 11
    call find_env
    test rax, rax
    jnz .have
    lea rdi, [env_home]
    mov esi, 5
    call find_env
    test rax, rax
    jz .none
    mov rsi, rax
    lea rdi, [path_buf]
    mov ecx, 200
.h: mov dl, [rsi]
    test dl, dl
    jz .hd
    mov [rdi], dl
    inc rsi
    inc rdi
    dec ecx
    jnz .h
.hd:
    lea rsi, [xauth_sfx]
.s: mov dl, [rsi]
    mov [rdi], dl
    inc rsi
    inc rdi
    test dl, dl
    jnz .s
    lea rax, [path_buf]
.have:
    mov rdi, rax
    xor esi, esi
    mov eax, SYS_OPEN
    syscall
    test rax, rax
    js .none
    mov r12, rax
    mov rdi, r12
    lea rsi, [buf]
    mov edx, BUFSZ
    xor eax, eax
    syscall
    mov r13, rax
    mov rdi, r12
    mov eax, 3
    syscall
    test r13, r13
    jle .none
    lea rsi, [buf]
    lea r8, [rsi+r13]
.entry:
    lea rdx, [rsi+4]
    cmp rdx, r8
    ja .none
    movzx eax, word [rsi+2]
    rol ax, 8
    lea rsi, [rsi+rax+4]
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    xor ebx, ebx
    cmp ecx, 1
    jne .fname
    cmp byte [rsi+2], DISPCH
    sete bl
.fname:
    mov rsi, r10
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    test ebx, ebx
    jz .fdata
    cmp ecx, 18
    jne .nomatch
    lea rdi, [rsi+2]
    lea r9, [mit_name]
.m: mov al, [rdi]
    cmp al, [r9]
    jne .nomatch
    inc rdi
    inc r9
    dec ecx
    jnz .m
    jmp .fdata
.nomatch:
    xor ebx, ebx
.fdata:
    mov rsi, r10
    lea rdx, [rsi+2]
    cmp rdx, r8
    ja .none
    movzx ecx, word [rsi]
    rol cx, 8
    lea r10, [rsi+rcx+2]
    cmp r10, r8
    ja .none
    test ebx, ebx
    jz .next
    cmp ecx, 16
    jne .next
    lea rdi, [hs_buf]
    mov rax, [rsi+2]
    mov [rdi+32], rax
    mov rax, [rsi+10]
    mov [rdi+40], rax
    mov eax, 1
    jmp .out
.next:
    mov rsi, r10
    cmp rsi, r8
    jb .entry
.none:
    xor eax, eax
.out:
    pop r13
    pop r12
    pop rbx
    ret
